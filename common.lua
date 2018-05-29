
local has_vacuum_mod = minetest.get_modpath("vacuum")
local has_travelnet_mod = minetest.get_modpath("travelnet")
local has_technic_mod = minetest.get_modpath("technic")
local has_elevator_mod = minetest.get_modpath("elevator")

-- add a position offset
local add_pos = function(pos1, pos2)
	return {x=pos1.x+pos2.x, y=pos1.y+pos2.y, z=pos1.z+pos2.z}
end

-- subtract a position offset
local sub_pos = function(pos1, pos2)
	return {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
end

-- calculates the power requirements for a jump
local calculate_power = function(radius, distance)
	-- max-radius == 20
	-- distance example: 500

	return 10 * distance * radius
end

-- iterate over a cube area with pos and radius
local cube_iterate = function(pos, radius, step, callback)
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

				iz = iz - step
			end
			iy = iy - step
		end
		ix = ix - step
	end

end

-- get pos object from pos
jumpdrive.get_meta_pos = function(pos)
	local meta = minetest.get_meta(pos);
	return {x=meta:get_int("x"), y=meta:get_int("y"), z=meta:get_int("z")}
end

-- set pos object from pos
jumpdrive.set_meta_pos = function(pos, target)
	local meta = minetest.get_meta(pos);
	meta:set_int("x", target.x)
	meta:set_int("y", target.y)
	meta:set_int("z", target.z)
end

-- get offset from meta
jumpdrive.get_radius = function(pos)
	local meta = minetest.get_meta(pos);
	return meta:get_int("radius")
end


local is_target_obstructed = function(pos, offsetPos, radius, meta, playername)

	local pos1 = {
		x=pos.x - radius,
		y=pos.y - radius,
		z=pos.z - radius
	}

	local pos2 = {
		x=pos.x + radius,
		y=pos.y + radius,
		z=pos.z + radius
	}

	if minetest.is_area_protected ~= nil then
		return minetest.is_area_protected(pos1, pos2, playername)
	else
		local protected = false
		cube_iterate(pos, radius, 4, function(ipos)
			if minetest.is_protected(ipos, playername) then
				protected = true
				return false -- break loop
			end
		end)
		return protected
	end
end


jumpdrive.simulate_jump = function(pos)
	local meta = minetest.get_meta(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)

	local radius = jumpdrive.get_radius(pos)

	jumpdrive.show_marker(targetPos, radius, "red")
	jumpdrive.show_marker(pos, radius, "green")
end

-- preflight check, for overriding
jumpdrive.preflight_check = function(source, destination, radius, player)
	return { success=true }
end

-- flight check
jumpdrive.flight_check = function(pos, player)

	local result = { success=true }
	local meta = minetest.get_meta(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)
	local radius = jumpdrive.get_radius(pos)


	local preflight_result = jumpdrive.preflight_check(pos, targetPos, radius, player)

	if not preflight_result.success then
		-- check failed in customization
		return preflight_result.success
	end

	local offsetPos = {x=targetPos.x-pos.x, y=targetPos.y-pos.y, z=targetPos.z-pos.z}
	local playername = meta:get_string("owner")

	if player ~= nil then
		playername = player:get_player_name()
	end


	local pos1 = {x=targetPos.x-radius, y=targetPos.y-radius, z=targetPos.z-radius}
	local pos2 = {x=targetPos.x+radius, y=targetPos.y+radius, z=targetPos.z+radius}

	local distance = vector.distance(pos, targetPos)

	local power_requirements = calculate_power(radius, distance)

	minetest.log("action", "[jumpdrive] power requirements: " .. power_requirements)

	-- preload chunk
	minetest.get_voxel_manip():read_from_map(pos1, pos2)

	if is_target_obstructed(pos, offsetPos, radius, meta, playername) then
		return {success=false, pos=pos, message="Jump-target is obstructed!"}
	end

	local powerstorage = meta:get_int("powerstorage")

	if powerstorage < power_requirements then
		-- not enough power, use items

		-- check inventory
		local inv = meta:get_inventory()
		local power_item = jumpdrive.config.power_item
		local power_item_count = math.ceil(power_requirements / jumpdrive.config.power_item_value)

		if not inv:contains_item("main", {name=power_item, count=power_item_count}) then
			local msg = "Not enough fuel for jump, expected " .. power_item_count .. " " .. power_item

			if has_technic_mod then
				msg = msg .. " or " .. power_requirements .. " EU"
			end

			return {success=false, pos=pos, message=msg}
		end

		-- use crystals
		inv:remove_item("main", {name=power_item, count=power_item_count})
	else
		-- remove power
		meta:set_int("powerstorage", powerstorage - power_requirements)
	end


	return result
end


-- execute whole jump
jumpdrive.execute_jump = function(pos, player)

	local meta = minetest.get_meta(pos)
	local playername = meta:get_string("owner")

	if player ~= nil then
		playername = player:get_player_name()
	end

	local preflight = jumpdrive.flight_check(pos, player)
	if not preflight.success then
		minetest.chat_send_player(playername, preflight.message)
		return false
	end

	
	local radius = jumpdrive.get_radius(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)
	local offsetPos = {x=targetPos.x-pos.x, y=targetPos.y-pos.y, z=targetPos.z-pos.z}


	local pos1 = {x=targetPos.x-radius, y=targetPos.y-radius, z=targetPos.z-radius};
	local pos2 = {x=targetPos.x+radius, y=targetPos.y+radius, z=targetPos.z+radius};


	minetest.log("action", "[jumpdrive] jumping to " .. targetPos.x .. "/" .. targetPos.y .. "/" .. targetPos.z .. " with radius " .. radius)

	local all_objects = minetest.get_objects_inside_radius(pos, radius * 1.5);

	-- set gravity to 0 for jump
	for _,obj in ipairs(all_objects) do
		if obj.is_player ~= nil and obj:is_player() then
			local pos = obj:get_pos()
			minetest.log("action", "[jumpdrive] setting zero-gravity for jump @ " .. pos.x .. "/" .. pos.y .. "/" .. pos.z)
			local phys = obj:get_physics_override()
			phys.gravity = 0
			obj:set_physics_override(phys)
		end
	end

	-- move blocks

	local move_block = function(from, to)
		local node = minetest.get_node(from)
		local newNode = minetest.get_node(to)

		if node.name == "air" and newNode.name == "air" then
			-- source is air and target is air, skip block
			return
		end

		if node.name == "air" and newNode.name == "ignore" and has_vacuum_mod then
			-- fill air with buffer air
			minetest.set_node(to, {name="jumpdrive:air"})
			local timer = minetest.get_node_timer(to)
			-- buffer air expires after 10 seconds
			timer:start(10)
			return
		end

		local meta = minetest.get_meta(from):to_table() -- Get metadata of current node
		minetest.set_node(from, {name="air"}) -- perf reason (faster)

		minetest.set_node(to, node) -- Move node to new position
		minetest.get_meta(to):from_table(meta) -- Set metadata of new node


		if has_travelnet_mod and node.name == "travelnet:travelnet" then
			-- rewire travelnet target
			jumpdrive.travelnet_compat(to)
		end
	end

	local ix = pos.x+radius
	while ix >= pos.x-radius do
		local iy = pos.y+radius
		while iy >= pos.y-radius do
			local iz = pos.z+radius
			while iz >= pos.z-radius do
				local from = {x=ix, y=iy, z=iz}
				local to = add_pos(from, offsetPos)
				move_block(from, to)

				iz = iz - step
			end
			iy = iy - step
		end
		ix = ix - step
	end

	if has_elevator_mod then
		jumpdrive.elevator_compat(pos1, pos2)
	end

	-- move objects and restore gravity
	for _,obj in ipairs(all_objects) do
		obj:moveto( add_pos(obj:get_pos(), offsetPos) )
		if obj.is_player ~= nil and obj:is_player() then
			local pos = obj:get_pos()
			minetest.log("action", "[jumpdrive] resetting gravity after jump @ " .. pos.x .. "/" .. pos.y .. "/" .. pos.z)

			local phys = obj:get_physics_override()
			phys.gravity = 1
			obj:set_physics_override(phys)
		end

	end

	-- show animation in target
	minetest.add_particlespawner({
		amount = 200,
		time = 2,
		minpos = targetPos,
		maxpos = {x=targetPos.x, y=targetPos.y+5, z=targetPos.z},
		minvel = {x = -2, y = -2, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = {x = -3, y = -3, z = -3},
		maxacc = {x = 3, y = 3, z = 3},
		minexptime = 0.1,
		maxexptime = 5,
		minsize = 1,
		maxsize = 1,
		texture = "spark.png",
		glow = 5,
	})

	return true
end


jumpdrive.update_formspec = function(meta)
	meta:set_string("formspec", "size[8,10;]" ..
		"field[0,1;2,1;x;X;" .. meta:get_int("x") .. "]" ..
		"field[2,1;2,1;y;Y;" .. meta:get_int("y") .. "]" ..
		"field[4,1;2,1;z;Z;" .. meta:get_int("z") .. "]" ..
		"field[6,1;2,1;radius;Radius;" .. meta:get_int("radius") .. "]" ..

		"button_exit[0,2;2,1;jump;Jump]" ..
		"button_exit[2,2;2,1;show;Show]" ..
		"button_exit[4,2;2,1;save;Save]" ..
		"button[6,2;2,1;reset;Reset]" ..

		"list[context;main;0,3;8,1;]" ..

		"button[0,4;4,1;write_book;Write to book]" ..
		"button[4,4;4,1;read_book;Read from book]" ..

		"list[current_player;main;0,5;8,4;]")
end

jumpdrive.write_to_book = function(pos, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if inv:contains_item("main", {name="default:book", count=1}) then
		local stack = inv:remove_item("main", {name="default:book", count=1})

		local new_stack = ItemStack("default:book_written")
		local stackMeta = new_stack:get_meta()

		local data = {}

		data.owner = sender:get_player_name()
		data.title = "Jumpdrive coordinates"
		data.description = "Jumpdrive coordiates"
		data.text = minetest.serialize(jumpdrive.get_meta_pos(pos))
		data.page = 1
		data.page_max = 1

		new_stack:get_meta():from_table({ fields = data })

		if inv:room_for_item("main", new_stack) then
			-- put written book back
			inv:add_item("main", new_stack)
		else
			-- put back old stack
			inv:add_item("main", stack)
		end

	end

end

jumpdrive.read_from_book = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if inv:contains_item("main", {name="default:book_written", count=1}) then
		local stack = inv:remove_item("main", {name="default:book_written", count=1})
		local stackMeta = stack:get_meta()

		local text = stackMeta:get_string("text")
		local data = minetest.deserialize(text)
		
		if data == nil then
			return
		end

		local x = tonumber(data.x)
		local y = tonumber(data.y)
		local z = tonumber(data.z)

		if x == nil or y == nil or z == nil then
			return
		end

		meta:set_int("x", x)
		meta:set_int("y", y)
		meta:set_int("z", z)

		-- update form
		jumpdrive.update_formspec(meta)

		-- put book back
		inv:add_item("main", stack)
	end
end

jumpdrive.reset_coordinates = function(pos)
	local meta = minetest.get_meta(pos)

	meta:set_int("x", pos.x)
	meta:set_int("y", pos.y)
	meta:set_int("z", pos.z)

	-- update form
	jumpdrive.update_formspec(meta)

end
