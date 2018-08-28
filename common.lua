
local has_vacuum_mod = minetest.get_modpath("vacuum")
local has_travelnet_mod = minetest.get_modpath("travelnet")
local has_elevator_mod = minetest.get_modpath("elevator")
local has_locator_mod = minetest.get_modpath("locator")

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

-- checks if an area is protected
local is_area_protected = function(pos, radius, playername)

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
		for x=pos1.x,pos2.x do
			for y=pos1.y,pos2.y do
				for z=pos1.z,pos2.z do
					local ipos = {x=x, y=y, z=z}
					if minetest.is_protected(ipos, playername) then
						return true
					end
				end
			end
		end
	end

	return false --no protection found
end


-- checks if an area is empty
local is_area_empty = function(sourcePos, targetPos, radius)

	local sourcePos1 = {
		x=sourcePos.x - radius,
		y=sourcePos.y - radius,
		z=sourcePos.z - radius
	}

	local sourcePos2 = {
		x=sourcePos.x + radius,
		y=sourcePos.y + radius,
		z=sourcePos.z + radius
	}

	local targetPos1 = {
		x=targetPos.x - radius,
		y=targetPos.y - radius,
		z=targetPos.z - radius
	}

	local targetPos2 = {
		x=targetPos.x + radius,
		y=targetPos.y + radius,
		z=targetPos.z + radius
	}

	for x=targetPos1.x,targetPos2.x do
		for y=targetPos1.y,targetPos2.y do
			for z=targetPos1.z,targetPos2.z do
				local xOverlaps = x >= sourcePos1.x and x <= sourcePos2.x
				local yOverlaps = x >= sourcePos1.y and x <= sourcePos2.y
				local zOverlaps = x >= sourcePos1.z and x <= sourcePos2.z

				if xOverlaps and yOverlaps and zOverlaps then
					-- overlapping source/target, ignore
				else
					-- non-overlapping area, check contents
					local ipos = {x=x, y=y, z=z}
					local node = minetest.get_node(ipos)
					if node.name ~= "air" and node.name ~= "vacuum:vacuum" and node.name ~= "ignore" then
						return false
					end
				end
			end
		end
	end

	return true -- no blocks found
end


jumpdrive.simulate_jump = function(pos, player)
	local meta = minetest.get_meta(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)
	local radius = jumpdrive.get_radius(pos)
	local distance = vector.distance(pos, targetPos)

	jumpdrive.show_marker(targetPos, radius, "red")
	jumpdrive.show_marker(pos, radius, "green")


	local power_requirements = calculate_power(radius, distance)

	local power_item = jumpdrive.config.power_item
	local power_item_count = math.ceil(power_requirements / jumpdrive.config.power_item_value)

	local msg = "Fuel requirements: " .. power_item_count .. " " .. power_item

	minetest.chat_send_player(player:get_player_name(), msg)

	if minetest.find_node_near(targetPos, radius, "ignore", true) then
		minetest.chat_send_player(player:get_player_name(), "Warning: Jump-target is uncharted!")
	end

	if minetest.find_node_near(targetPos, radius, "vacuum:vacuum", true) then
		minetest.chat_send_player(player:get_player_name(), "Warning: Jump-target is in vacuum!")
	end

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
		return preflight_result
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

	-- check source for protection
	if is_area_protected(pos, radius, playername) then
		return {success=false, pos=pos, message="Jump-source is protected"}
	end

	-- check destination for protection
	if is_area_protected(targetPos, radius, playername) then
		return {success=false, pos=pos, message="Jump-target is protected"}
	end

	-- check destination for emptiness
	if not is_area_empty(pos, targetPos, radius) then
		return {success=false, pos=targetPos, message="Jump-target not empty!"}
	end

	-- skip fuel calc, if creative
	if minetest.check_player_privs(playername, {creative = true}) then
		return result
	end
	-- check inventory
	local inv = meta:get_inventory()
	local power_item = jumpdrive.config.power_item
	local power_item_count = math.ceil(power_requirements / jumpdrive.config.power_item_value)

	if not inv:contains_item("main", {name=power_item, count=power_item_count}) then
		local msg = "Not enough fuel for jump, expected " .. power_item_count .. " " .. power_item

		return {success=false, pos=pos, message=msg}
	end

	-- use power items
	inv:remove_item("main", {name=power_item, count=power_item_count})

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
	local pos1 = {x=targetPos.x-radius, y=targetPos.y-radius, z=targetPos.z-radius};
	local pos2 = {x=targetPos.x+radius, y=targetPos.y+radius, z=targetPos.z+radius};

	-- defer jumping until mapblock loaded
	minetest.emerge_area(pos1, pos2, function(blockpos, action, calls_remaining, param)
		if calls_remaining == 0 then
			jumpdrive.execute_jump_stage2(pos, player)
		end
	end);
end

-- jump stage 2, after target emerge
jumpdrive.execute_jump_stage2 = function(pos, player)
	
	local radius = jumpdrive.get_radius(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)
	local offsetPos = {x=targetPos.x-pos.x, y=targetPos.y-pos.y, z=targetPos.z-pos.z}


	local pos1 = {x=targetPos.x-radius, y=targetPos.y-radius, z=targetPos.z-radius};
	local pos2 = {x=targetPos.x+radius, y=targetPos.y+radius, z=targetPos.z+radius};

	local sourcePos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
	local sourcePos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};


	minetest.log("action", "[jumpdrive] jumping to " .. targetPos.x .. "/" .. targetPos.y .. "/" .. targetPos.z .. " with radius " .. radius)
	local start = os.clock()

	-- move blocks

	local move_block = function(from, to)
		local node = minetest.get_node(from)
		local newNode = minetest.get_node(to)

		if node.name == "air" and newNode.name == "air" then
			-- source is air and target is air, skip block
			return
		end

		if has_vacuum_mod and node.name == "air" and newNode.name == "ignore" then
			-- fill air with buffer air
			minetest.set_node(to, {name="vacuum:air"})
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

		if has_locator_mod then
			if node.name == "locator:beacon_1" or node.name == "locator:beacon_2" or node.name == "locator:beacon_3" then
				-- rewire beacon
				jumpdrive.locator_compat(from, to)
			end
		end

	end

	local x_start = pos.x+radius
	local x_end = pos.x-radius
	local x_step = -1

	if offsetPos.x < 0 then
		-- backwards, invert step
		x_start = pos.x-radius
		x_end = pos.x+radius
		x_step = 1
	end

	local y_start = pos.y+radius
	local y_end = pos.y-radius
	local y_step = -1

	if offsetPos.y < 0 then
		-- backwards, invert step
		y_start = pos.y-radius
		y_end = pos.y+radius
		y_step = 1
	end

	local z_start = pos.z+radius
	local z_end = pos.z-radius
	local z_step = -1

	if offsetPos.z < 0 then
		-- backwards, invert step
		z_start = pos.z-radius
		z_end = pos.z+radius
		z_step = 1
	end

	for ix=x_start,x_end,x_step do
		for iy=y_start,y_end,y_step do
			for iz=z_start,z_end,z_step do
				local from = {x=ix, y=iy, z=iz}
				local to = add_pos(from, offsetPos)
				move_block(from, to)
			end
		end
	end

	if has_elevator_mod then
		jumpdrive.elevator_compat(pos1, pos2)
	end

	local all_objects = minetest.get_objects_inside_radius(pos, radius * 1.5);

	-- move objects
	for _,obj in ipairs(all_objects) do

		local objPos = obj:get_pos()

		local xMatch = objPos.x >= sourcePos1.x or objPos.x <= sourcePos2.x
		local yMatch = objPos.y >= sourcePos1.y or objPos.y <= sourcePos2.y
		local zMatch = objPos.z >= sourcePos1.z or objPos.z <= sourcePos2.z

		local isPlayer = obj:is_player()

		if xMatch and yMatch and zMatch and not isPlayer then
			-- coords in range

			if obj:get_attach() == nil then
				-- object not attached

				minetest.log("action", "[Jumpdrive] moving object @ " .. objPos.x .. "/" .. objPos.y .. "/" .. objPos.z)
				obj:set_pos( add_pos(objPos, offsetPos) )
			end
		end
	end

	-- move players
	for _,player in ipairs(minetest.get_connected_players()) do
		local playerPos = player:get_pos()

		local xMatch = playerPos.x >= sourcePos1.x or playerPos.x <= sourcePos2.x
		local yMatch = playerPos.y >= sourcePos1.y or playerPos.y <= sourcePos2.y
		local zMatch = playerPos.z >= sourcePos1.z or playerPos.z <= sourcePos2.z

		if xMatch and yMatch and zMatch and player:is_player() then
			minetest.log("action", "[Jumpdrive] moving player: " .. player:get_player_name())
			player:moveto( add_pos(playerPos, offsetPos), false);
		end
	end

	local diff = os.clock() - start
	minetest.chat_send_player(player:get_player_name(), "Jump executed in " .. diff .. " s")
	minetest.log("action", "[Jumpdrive] Jump executed in " .. diff .. " s")
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


jumpdrive.update_formspec = function(meta, pos)

	local spos = pos.x..','..pos.y..','..pos.z

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

		-- liststring stuff
		"listring[nodemeta:"..spos ..";main]"..
		"listring[current_player;main]")
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
		jumpdrive.update_formspec(meta, pos)

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
	jumpdrive.update_formspec(meta, pos)

end
