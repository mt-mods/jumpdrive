
-- add a position offset
local add_pos = function(pos1, pos2)
	return {x=pos1.x+pos2.x, y=pos1.y+pos2.y, z=pos1.z+pos2.z}
end

-- move single block and meta
local move_block = function(from, to)
	local node = minetest.get_node(from) -- Obtain current node

	-- print("x=" .. ix .. " y=" .. iy .. " z=" .. iz .. " name=" .. node.name)

	if node.name == "air" or node.name == "ignore" then
		return
	end

	local meta = minetest.get_meta(from):to_table() -- Get metadata of current node
	minetest.remove_node(from) -- Remove current node

	local newNode = minetest.get_node(to)
	if newNode.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(to, to)
		newNode = minetest.get_node(to)
	end

	minetest.set_node(to, node) -- Move node to new position
	minetest.get_meta(to):from_table(meta) -- Set metadata of new node
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

-- execute whole jump
local execute_jump = function(pos, offsetPos, radius)

	local pos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
	local pos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};

	minetest.get_voxel_manip():read_from_map(pos1, pos2)

	cube_iterate(pos, radius, function(oldPos)
		local newPos = add_pos(oldPos, offsetPos)
		move_block(oldPos, newPos)
	end)

	local all_objects = minetest.get_objects_inside_radius(pos, radius);
	for _,obj in ipairs(all_objects) do
		obj:moveto( add_pos(obj:get_pos(), offsetPos) )
	end	

end

local can_jump = function(pos, offsetPos, radius, meta)

	-- check inventory
	local inv = meta:get_inventory()
	return inv:contains_item("main", {name="default:mese_crystal", count=1})
end

local is_target_obstructed = function(pos, offsetPos, radius, meta, playername)
	local obstructed = false

	cube_iterate(pos, radius, function(ipos)
		local newPos = add_pos(ipos, offsetPos)
		local node = minetest.get_node(newPos)
		local is_passable = node.name == "air" or node.name == "ignore"

		if not is_passable or minetest.is_protected(pos, playername) then
			obstructed = true
			return false
		end
	end)
	
	return obstructed
end

local deduct_jump_cost = function(pos, meta)
	local inv = meta:get_inventory()
	inv:remove_item("main", {name="default:mese_crystal", count=1})
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
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "jumpdrive:engine",

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

		local inv = meta:get_inventory()
		inv:set_size("main", 8*1)

		update_formspec(meta)
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

		if math.abs(x) > 100 or math.abs(y) > 100 or math.abs(z) > 100 or radius > 20 then
			minetest.chat_send_player(sender:get_player_name(), "Invalid jump: max-range=100 max-radius=20")
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

		if fields.jump or fields.calculate then
			local minjumpdistance = radius * 2

			if math.abs(x) <= minjumpdistance and math.abs(y) <= minjumpdistance and math.abs(z) <= minjumpdistance then
				minetest.chat_send_player(sender:get_player_name(), "Jump too short")
				return
			end

			if is_target_obstructed(pos, offsetPos, radius, meta, sender:get_player_name()) then
				minetest.chat_send_player(sender:get_player_name(), "Jump-target is obstructed!")
				return
			end

			if not can_jump(pos, offsetPos, radius, meta) then
				minetest.chat_send_player(sender:get_player_name(), "Not enough fuel for jump, expected 1 mese cristal")
				return
			end
		end

		if fields.jump then
			deduct_jump_cost(pos, meta)
			execute_jump(pos, offsetPos, radius)
		end

		if fields.calculate then
			calculate_cost(pos, offsetPos, radius, sender)
		end
		
	end
})

minetest.register_craft({
	output = 'jumpdrive:engine',
	recipe = {
		{'', 'default:mese_crystal_fragment', ''},
		{'default:diamond', 'default:mese_block', 'default:diamond'},
		{'', 'default:mese_crystal', ''}
	}
})

print("[OK] Jumpdrive")
