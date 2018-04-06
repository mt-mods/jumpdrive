
local has_travelnet_mod = minetest.get_modpath("travelnet")
local has_technic_mod = minetest.get_modpath("technic")

-- add a position offset
local add_pos = function(pos1, pos2)
	return {x=pos1.x+pos2.x, y=pos1.y+pos2.y, z=pos1.z+pos2.z}
end

-- move single block and meta
local move_block = function(from, to)
	local node = minetest.get_node(from)
	local newNode = minetest.get_node(to)

	-- print("x=" .. ix .. " y=" .. iy .. " z=" .. iz .. " name=" .. node.name)

	local is_from_passable = node.name == "air" or node.name == "ignore"
	local is_to_passable = newNode.name == "air"

	if is_from_passable and is_to_passable then
		return
	end

	local meta = minetest.get_meta(from):to_table() -- Get metadata of current node
	minetest.remove_node(from) -- Remove current node

	if newNode.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(to, to)
		newNode = minetest.get_node(to)
	end

	minetest.set_node(to, node) -- Move node to new position
	minetest.get_meta(to):from_table(meta) -- Set metadata of new node

	newNode = minetest.get_node(to)

	if has_travelnet_mod and newNode.name == "travelnet:travelnet" then
		-- rewire travelnet target
		jumpdrive.travelnet_compat(to)
	end
end

local calculate_cost = function(pos, offsetPos, radius, sender)
	local meta = minetest.get_meta(pos)

	local diameter = radius * 2
	local blocks = math.pow(diameter, 3)

	-- TODO: pow/sqrt
	local distance = math.abs(offsetPos.x) + math.abs(offsetPos.y) + math.abs(offsetPos.z)

	local cost = blocks * distance * 1.0

	minetest.chat_send_player(sender:get_player_name(), "Jump: " .. blocks .. " blocks")
end

-- iterate over a cube area with pos and radius
local cube_iterate = function(pos, radius, callback)
	local ix = pos.x+radius
	while ix >= pos.x-radius do
		local iy = pos.y+radius
		while iy >= pos.y-radius do
			local iz = pos.z+radius
			while iz >= pos.z-radius do
				local ipos = {x=ix, y=iy, z=iz}
				local result = callback(ipos)

				if result == false then
					return
				end

				iz = iz - 1
			end
			iy = iy - 1
		end
		ix = ix - 1
	end

end

-- get offset pos object from pos
local get_offset_pos = function(pos)
	local meta = minetest.get_meta(pos);
	return {x=meta:get_int("x"), y=meta:get_int("y"), z=meta:get_int("z")}
end

-- get offset from meta
local get_radius = function(pos)
	local meta = minetest.get_meta(pos);
	return meta:get_int("radius")
end


local is_target_obstructed = function(pos, offsetPos, radius, meta, playername)
	local obstructed = false

	cube_iterate(pos, radius, function(ipos)
		local newPos = add_pos(ipos, offsetPos)
		local node = minetest.get_node(newPos)
		local is_passable = jumpdrive.config.allow_jumping_into_material or node.name == "air" or node.name == "ignore"

		if not is_passable or minetest.is_protected(ipos, playername) or minetest.is_protected(newPos, playername) then
			obstructed = true
			return false
		end
	end)
	
	return obstructed
end


-- execute whole jump
local execute_jump = function(pos, player)

	local offsetPos = get_offset_pos(pos)
	local radius = get_radius(pos)
	local targetPos = add_pos(pos, offsetPos)
	local meta = minetest.get_meta(pos)
	local playername = meta:get_string("owner")	

	if player ~= nil then
		playername = player:get_player_name()
	end

	if is_target_obstructed(pos, offsetPos, radius, meta, playername) then
		minetest.chat_send_player(playername, "Jump-target is obstructed!")
		return
	end

	if meta:get_int("powerstorage") < jumpdrive.config.powerstorage then

		-- check inventory
		local inv = meta:get_inventory()
		local power_item = jumpdrive.config.power_item
		local power_item_count = jumpdrive.config.power_item_count

		if not inv:contains_item("main", {name=power_item, count=power_item_count}) then
			minetest.chat_send_player(playername, "Not enough fuel for jump, expected " .. power_item_count .. " " .. power_item)
			return
		end

		-- use crystals
		inv:remove_item("main", {name=power_item, count=power_item_count})
	else
		-- use power
		meta:set_int("powerstorage", 0)
	end

	local pos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
	local pos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};

	minetest.get_voxel_manip():read_from_map(pos1, pos2)

	cube_iterate(pos, radius, function(oldPos)
		local newPos = add_pos(oldPos, offsetPos)
		move_block(oldPos, newPos)
	end)

	local all_objects = minetest.get_objects_inside_radius(pos, radius * 1.5);
	for _,obj in ipairs(all_objects) do
		obj:moveto( add_pos(obj:get_pos(), offsetPos) )
	end	
	
	minetest.chat_send_player(playername, "Jump executed!")
end


local update_formspec = function(meta)
	meta:set_string("formspec", "size[8,9;]" ..
		"field[0,1;2,1;x;X;" .. meta:get_int("x") .. "]" ..
		"field[2,1;2,1;y;Y;" .. meta:get_int("y") .. "]" ..
		"field[4,1;2,1;z;Z;" .. meta:get_int("z") .. "]" ..
		"field[6,1;2,1;radius;Radius;" .. meta:get_int("radius") .. "]" ..
		"button_exit[1,2;2,1;jump;Jump]" ..
		"button_exit[3,2;2,1;calculate;Calculate]" ..
		"button_exit[5,2;2,1;save;Save]" ..
		"list[context;main;0,3;8,1;]" ..
		"list[current_player;main;0,5;8,4;]")
end

minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",
	tiles = {"jumpdrive.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3,technic_machine = 1, technic_hv = 1},
	drop = "jumpdrive:engine",
	sounds = default.node_sound_glass_defaults(),

	mesecons = {effector = {
		action_on = function (pos, node)
			execute_jump(pos)
		end
	}},

	connects_to = {"group:technic_hv_cable"},
	connect_sides = {"bottom", "top", "left", "right", "front", "back"},

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("x", 0)
		meta:set_int("y", 50)
		meta:set_int("z", 0)
		meta:set_int("radius", 5)
		meta:set_int("powerstorage", 0)

		local inv = meta:get_inventory()
		inv:set_size("main", 8*1)

		if has_technic_mod then
			meta:set_int("HV_EU_input", 0)
			meta:set_int("HV_EU_demand", 0)
		end

		update_formspec(meta)
	end,

	technic_run = function(pos, node)
		local meta = minetest.get_meta(pos)
		local eu_input = meta:get_int("HV_EU_input")
		local demand = meta:get_int("HV_EU_demand")
		local store = meta:get_int("powerstorage")

		meta:set_string("infotext", "Power: " .. eu_input .. "/" .. demand .. " Store: " .. store)

		if store < jumpdrive.config.powerstorage then
			-- charge
			meta:set_int("HV_EU_demand", jumpdrive.config.powerrequirement)
			store = store + eu_input
			meta:set_int("powerstorage", store)
		else
			-- charged
			meta:set_int("HV_EU_demand", 0)
		end
	end,

	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,

	on_receive_fields = function(pos, formname, fields, sender)

		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);
		local radius = tonumber(fields.radius);

		if x == nil or y == nil or z == nil or radius == nil or radius < 1 then
			return
		end

		local max_distance = jumpdrive.config.max_distance
		local max_radius = jumpdrive.config.max_radius

		if math.abs(x) > max_distance or math.abs(y) > max_distance or math.abs(z) > max_distance or radius > max_radius then
			minetest.chat_send_player(sender:get_player_name(), "Invalid jump: max-range=" .. max_distance .. " max-radius=" .. max_radius)
			return
		end

		local minjumpdistance = radius * 2

		if math.abs(x) <= minjumpdistance and math.abs(y) <= minjumpdistance and math.abs(z) <= minjumpdistance then
			minetest.chat_send_player(sender:get_player_name(), "Jump too short")
			return
		end

		local offsetPos = {x=x, y=y, z=z}
		local targetPos = add_pos(pos, offsetPos)
		local meta = minetest.get_meta(pos)

		-- update coords
		meta:set_int("x", x)
		meta:set_int("y", y)
		meta:set_int("z", z)
		meta:set_int("radius", radius)
		update_formspec(meta)

		if fields.jump then
			execute_jump(pos, sender)
		end

		if fields.calculate then
			calculate_cost(pos, offsetPos, radius, sender)
		end
		
	end
})

if has_technic_mod then
	technic.register_machine("HV", "jumpdrive:engine", technic.receiver)
end

minetest.register_craft({
	output = 'jumpdrive:engine',
	recipe = {
		{'', 'default:mese_crystal_fragment', ''},
		{'default:diamond', 'default:mese_block', 'default:diamond'},
		{'', 'default:mese_crystal', ''}
	}
})


