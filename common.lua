
jumpdrive.sanitize_coord = function(coord)
	return math.max( math.min( coord, 31000 ), -31000 )
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

-- calculates the power requirements for a jump
jumpdrive.calculate_power = function(radius, distance, sourcePos, targetPos)
	return 10 * distance * radius
end

jumpdrive.simulate_jump = function(pos, player, show_marker)

	local targetPos = jumpdrive.get_meta_pos(pos)

	if jumpdrive.check_mapgen(pos) then
		return false, "Error: mapgen was active in this area, please try again later for your own safety!"
	end

	local meta = minetest.get_meta(pos)
	local radius = jumpdrive.get_radius(pos)
	local distance = vector.distance(pos, targetPos)

	local playername = meta:get_string("owner")

	if player ~= nil then
		playername = player:get_player_name()
	end

	local radius_vector = {x=radius, y=radius, z=radius}
	local source_pos1 = vector.subtract(pos, radius_vector)
	local source_pos2 = vector.add(pos, radius_vector)
	local target_pos1 = vector.subtract(targetPos, radius_vector)
	local target_pos2 = vector.add(targetPos, radius_vector)

	local x_overlap = (target_pos1.x <= source_pos2.x and target_pos1.x >= source_pos1.x) or
		(target_pos2.x <= source_pos2.x and target_pos2.x >= source_pos1.x)
	local y_overlap = (target_pos1.y <= source_pos2.y and target_pos1.y >= source_pos1.y) or
		(target_pos2.y <= source_pos2.y and target_pos2.y >= source_pos1.y)
	local z_overlap = (target_pos1.z <= source_pos2.z and target_pos1.z >= source_pos1.z) or
		(target_pos2.z <= source_pos2.z and target_pos2.z >= source_pos1.z)

	if x_overlap and y_overlap and z_overlap then
		return false, "Error: jump into itself! extend your jump target"
	end

	-- load chunk
	minetest.get_voxel_manip():read_from_map(target_pos1, target_pos2)

	if show_marker then
		jumpdrive.show_marker(targetPos, radius, "red")
		jumpdrive.show_marker(pos, radius, "green")
	end

	local msg = nil
	local success = true

	local blacklisted_pos_list = minetest.find_nodes_in_area(source_pos1, source_pos2, jumpdrive.blacklist)
	for _, nodepos in ipairs(blacklisted_pos_list) do
		return false, "Can't jump node @ " .. minetest.pos_to_string(nodepos)
	end

	if minetest.find_node_near(targetPos, radius, "vacuum:vacuum", true) then
		msg = "Warning: Jump-target is in vacuum!"
	end

	if minetest.find_node_near(targetPos, radius, "ignore", true) then
		return false, "Warning: Jump-target is in uncharted area"
	end

	if jumpdrive.is_area_protected(source_pos1, source_pos2, playername) then
		return false, "Jump-source is protected!"
	end

	if jumpdrive.is_area_protected(target_pos1, target_pos2, playername) then
		return false, "Jump-target is protected!"
	end

	local is_empty, empty_msg = jumpdrive.is_area_empty(target_pos1, target_pos2)

	if not is_empty then
		msg = "Jump-target is obstructed (" .. empty_msg .. ")"
		success = false
	end

	-- check preflight conditions
	local preflight_result = jumpdrive.preflight_check(pos, targetPos, radius, playername)

	if not preflight_result.success then
		-- check failed in customization
		msg = "Preflight check failed!"
		if preflight_result.message then
			msg = preflight_result.message
		end
		success = false
	end

	local power_req = jumpdrive.calculate_power(radius, distance, pos, targetPos)
	local powerstorage = meta:get_int("powerstorage")

	if powerstorage < power_req then
		-- not enough power
		msg = "Not enough power: required=" .. math.floor(power_req) .. ", actual: " .. powerstorage .. " EU"
		success = false
	end

	return success, msg
end

-- preflight check, for overriding
jumpdrive.preflight_check = function(source, destination, radius, playername)
	return { success=true }
end



-- execute jump
jumpdrive.execute_jump = function(pos, player)

	local meta = minetest.get_meta(pos)
	local playername = meta:get_string("owner")

	if player ~= nil then
		playername = player:get_player_name()
	end


	local radius = jumpdrive.get_radius(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)

	local distance = vector.distance(pos, targetPos)
	local power_req = jumpdrive.calculate_power(radius, distance, pos, targetPos)

	local radius_vector = {x=radius, y=radius, z=radius}
	local source_pos1 = vector.subtract(pos, radius_vector)
	local source_pos2 = vector.add(pos, radius_vector)
	local target_pos1 = vector.subtract(targetPos, radius_vector)
	local target_pos2 = vector.add(targetPos, radius_vector)

	local success, msg = jumpdrive.simulate_jump(pos, player, false)
	if not success then
		minetest.chat_send_player(playername, msg)
		return false, msg
	end

	-- consume power from storage
	local powerstorage = meta:get_int("powerstorage")
	meta:set_int("powerstorage", powerstorage - power_req)

	local t0 = minetest.get_us_time()

	minetest.sound_play("jumpdrive_engine", {
		pos = pos,
		max_hear_distance = 50,
		gain = 0.7,
	})

	-- actual move
	jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)

	local t1 = minetest.get_us_time()
	local time_micros = t1 - t0
	local time_millis = math.floor(time_micros / 1000)

	minetest.log("action", "[jumpdrive] jump took " .. time_micros .. " us")
	minetest.chat_send_player(playername, "Jump executed in " .. time_millis .. " ms")


	-- show animation in source
	minetest.add_particlespawner({
		amount = 200,
		time = 2,
		minpos = source_pos1,
		maxpos = source_pos2,
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


	-- show animation in target
	minetest.add_particlespawner({
		amount = 200,
		time = 2,
		minpos = target_pos1,
		maxpos = target_pos2,
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

	return true, time_micros
end


jumpdrive.update_formspec = function(meta, pos)

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

		"list[current_player;main;0,5;8,4;]" ..

		-- listring stuff
		"listring[]")
end

jumpdrive.write_to_book = function(pos, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if inv:contains_item("main", {name="default:book", count=1}) then
		local stack = inv:remove_item("main", {name="default:book", count=1})

		local new_stack = ItemStack("default:book_written")

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
	local player_name = meta:get_string("owner")

	if inv:contains_item("main", {name="default:book_written", count=1}) then
		local stack = inv:remove_item("main", {name="default:book_written", count=1})
		local stackMeta = stack:get_meta()

		local text = stackMeta:get_string("text")
		local data = minetest.deserialize(text)

		if data == nil then
			-- put book back, it may contain other information
			inv:add_item("main", stack)
			-- alert player
			if nil ~= player_name then
				minetest.chat_send_player(player_name, "Invalid data")
			end
			return
		end

		local x = tonumber(data.x)
		local y = tonumber(data.y)
		local z = tonumber(data.z)

		if x == nil or y == nil or z == nil then
			-- put book back, it may contain other information
			inv:add_item("main", stack)
			-- alert player
			if nil ~= player_name then
				minetest.chat_send_player(player_name, "Invalid coordinates")
			end
			return
		end

		meta:set_int("x", jumpdrive.sanitize_coord(x))
		meta:set_int("y", jumpdrive.sanitize_coord(y))
		meta:set_int("z", jumpdrive.sanitize_coord(z))

		-- put book back
		inv:add_item("main", stack)
	elseif inv:contains_item("main", {name="missions:wand_position", count=1}) then
		local stack = inv:remove_item("main", {name="missions:wand_position", count=1})
		local stackMeta = stack:get_meta()

		local text = stackMeta:get_string("pos")
		local target_pos = minetest.string_to_pos(text)

		if nil == target_pos then
			-- put wand back, I don't see a way to corrupt a wand atm
			inv:add_item("main", stack)
			return
		end

		local x = target_pos.x
		local y = target_pos.y
		local z = target_pos.z

		if x == nil or y == nil or z == nil then
			-- put wand back, I don't see a way to corrupt a wand atm
			inv:add_item("main", stack)
			return
		end

		meta:set_int("x", jumpdrive.sanitize_coord(x))
		meta:set_int("y", jumpdrive.sanitize_coord(y))
		meta:set_int("z", jumpdrive.sanitize_coord(z))

		-- put wand back
		inv:add_item("main", stack)
	end
end

jumpdrive.reset_coordinates = function(pos)
	local meta = minetest.get_meta(pos)

	meta:set_int("x", pos.x)
	meta:set_int("y", pos.y)
	meta:set_int("z", pos.z)

end
