

local c_air = minetest.get_content_id("air")

-- moves the source to the target area
-- no protection- or overlap checking is done here
jumpdrive.move = function(source_pos1, source_pos2, target_pos1, target_pos2)

	minetest.log("action", "[jumpdrive] initiating jump")
	local t0 = minetest.get_us_time()

	-- step 1: copy via voxel manip
	-- https://dev.minetest.net/VoxelManip#Examples

	-- delta between source and target
	local delta_vector = vector.subtract(target_pos1, source_pos1)

	-- center of source
	local  source_center = vector.add(source_pos1, vector.divide(vector.subtract(source_pos2, source_pos1), 2))

	-- read source
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(source_pos1, source_pos2)
	local source_area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local source_data = manip:get_data()

	-- write target
	e1, e2 = manip:read_from_map(target_pos1, target_pos2)
	local target_area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local target_data = manip:get_data()

	for z=source_pos1.z, source_pos2.z do
	for y=source_pos1.y, source_pos2.y do
	for x=source_pos1.x, source_pos2.x do

		local source_index = source_area:index(x, y, z)
		local target_index = target_area:index(x+delta_vector.x, y+delta_vector.y, z+delta_vector.z)

		-- copy block id
		target_data[target_index] = source_data[source_index]
	end
	end
	end


	manip:set_data(target_data)
	manip:write_to_map()
	manip:update_map()
	--[[
	perf stats
		just copying blocks without meta:
			radius=10: around 30ms
		copying with meta (ALL meta):
			radius=10: from 50 to 100 ms
		copying with meta (NO air meta):
			radius=10: around 50ms
		copying with meta and players (randomly):
			radius=10: from 50 to 200ms
	--]]


	-- step 2: check meta and copy if needed
	for z=source_pos1.z, source_pos2.z do
	for y=source_pos1.y, source_pos2.y do
	for x=source_pos1.x, source_pos2.x do

		local source_index = source_area:index(x, y, z)

		if source_data[source_index] == c_air then
			-- no meta copying for air
			-- TODO: optimize to check somehow for existing meta
		else
			-- copy meta
			local source_pos = {x=x, y=y, z=z}
			local target_pos = vector.add(source_pos, delta_vector)

			local source_meta = minetest.get_meta(source_pos):to_table()
			-- TODO: check if meta populated
			minetest.get_meta(target_pos):from_table(source_meta)
		end
	end
	end
	end

	-- step 3: execute compat code
	-- TODO

	-- step 4: move objects
	local all_objects = minetest.get_objects_inside_radius(source_center, delta_vector.x * 1.5);
	for _,obj in ipairs(all_objects) do

		local objPos = obj:get_pos()

		local xMatch = objPos.x >= source_pos1.x or objPos.x <= source_pos2.x
		local yMatch = objPos.y >= source_pos1.y or objPos.y <= source_pos2.y
		local zMatch = objPos.z >= source_pos1.z or objPos.z <= source_pos2.z

		local isPlayer = obj:is_player()

		if xMatch and yMatch and zMatch and not isPlayer then
			-- coords in range
			if obj:get_attach() == nil then
				-- object not attached

				minetest.log("action", "[jumpdrive] moving object @ " .. objPos.x .. "/" .. objPos.y .. "/" .. objPos.z)
				obj:set_pos( vector.add(objPos, delta_vector) )
			end
		end
	end

	-- move players
	for _,player in ipairs(minetest.get_connected_players()) do
		local playerPos = player:get_pos()

		local xMatch = playerPos.x >= source_pos1.x or playerPos.x <= source_pos2.x
		local yMatch = playerPos.y >= source_pos1.y or playerPos.y <= source_pos2.y
		local zMatch = playerPos.z >= source_pos1.z or playerPos.z <= source_pos2.z

		if xMatch and yMatch and zMatch and player:is_player() then
			minetest.log("action", "[Jumpdrive] moving player: " .. player:get_player_name())
			player:moveto( vector.add(playerPos, delta_vector), false);
		end
	end

	-- step 5: clear source area with voxel manip
	e1, e2 = manip:read_from_map(source_pos1, source_pos2)
	source_area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	source_data = manip:get_data()


	for z=source_pos1.z, source_pos2.z do
	for y=source_pos1.y, source_pos2.y do
	for x=source_pos1.x, source_pos2.x do

		local source_index = source_area:index(x, y, z)
		source_data[source_index] = c_air
	end
	end
	end

	manip:set_data(source_data)
	manip:write_to_map()
	manip:update_map()


	local t1 = minetest.get_us_time()
	local time_micros = t1 - t0
	minetest.log("action", "[jumpdrive] jump took " .. time_micros .. " us")

end