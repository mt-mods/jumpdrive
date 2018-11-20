

local c_air = minetest.get_content_id("air")


-- moves the source to the target area
-- no protection- or overlap checking is done here
jumpdrive.move = function(source_pos1, source_pos2, target_pos1, target_pos2)

	minetest.log("action", "[jumpdrive] initiating jump (" .. minetest.pos_to_string(source_pos1) .. "-" .. minetest.pos_to_string(source_pos2) .. 
		") (" .. minetest.pos_to_string(target_pos1) .. "-" .. minetest.pos_to_string(target_pos2) .. ")")

	-- step 1: copy via voxel manip
	-- https://dev.minetest.net/VoxelManip#Examples

	-- delta between source and target
	local delta_vector = vector.subtract(target_pos1, source_pos1)

	-- center of source
	local source_center = vector.add(source_pos1, vector.divide(vector.subtract(source_pos2, source_pos1), 2))
	minetest.log("action", "[jumpdrive] source-center: " .. minetest.pos_to_string(source_center))

	-- read source
	local source_manip = minetest.get_voxel_manip()
	local e1, e2 = source_manip:read_from_map(source_pos1, source_pos2)
	local source_area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local source_data = source_manip:get_data()
	local source_param1 = source_manip:get_light_data()
	local source_param2 = source_manip:get_param2_data()

	minetest.log("action", "[jumpdrive] read source-data")

	local t0 = minetest.get_us_time()

	-- write target
	local target_manip = minetest.get_voxel_manip()
	e1, e2 = target_manip:read_from_map(target_pos1, target_pos2)
	local target_area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local target_data = target_manip:get_data()
	local target_param1 = target_manip:get_light_data()
	local target_param2 = target_manip:get_param2_data()

	minetest.log("action", "[jumpdrive] read target-data");

	for z=source_pos1.z, source_pos2.z do
	for y=source_pos1.y, source_pos2.y do
	for x=source_pos1.x, source_pos2.x do

		local source_index = source_area:index(x, y, z)
		local target_index = target_area:index(x+delta_vector.x, y+delta_vector.y, z+delta_vector.z)

		-- copy block id
		target_data[target_index] = source_data[source_index]

		-- copy params
		target_param1[target_index] = source_param1[source_index]
		target_param2[target_index] = source_param2[source_index]
	end
	end
	end


	target_manip:set_data(target_data)
	target_manip:set_light_data(target_param1)
	target_manip:set_param2_data(target_param2)
	--target_manip:calc_lighting()
	target_manip:write_to_map()
	target_manip:update_map()

	local t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step I took " .. (t1 - t0) .. " us")

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
	t0 = minetest.get_us_time()

	local meta_pos_list = minetest.find_nodes_with_meta(source_pos1, source_pos2)
	for _,source_pos in pairs(meta_pos_list) do
		local target_pos = vector.add(source_pos, delta_vector)

		local source_meta = minetest.get_meta(source_pos):to_table()
		minetest.get_meta(target_pos):from_table(source_meta)

		jumpdrive.node_compat(source_id, source_pos, target_pos)
	end

	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step II took " .. (t1 - t0) .. " us")


	t0 = minetest.get_us_time()

	-- step 3: execute target region compat code
	jumpdrive.target_region_compat(target_pos1, target_pos2)

	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step III took " .. (t1 - t0) .. " us")


	-- step 4: move objects
	t0 = minetest.get_us_time()
	local all_objects = minetest.get_objects_inside_radius(source_center, 20);
	for _,obj in ipairs(all_objects) do

		local objPos = obj:get_pos()

		local xMatch = objPos.x >= source_pos1.x and objPos.x <= source_pos2.x
		local yMatch = objPos.y >= source_pos1.y and objPos.y <= source_pos2.y
		local zMatch = objPos.z >= source_pos1.z and objPos.z <= source_pos2.z

		local isPlayer = obj:is_player()

		if xMatch and yMatch and zMatch and not isPlayer then
			minetest.log("action", "[jumpdrive] object:  @ " .. minetest.pos_to_string(objPos))

			-- coords in range
			local entity = obj:get_luaentity()

			-- if obj:get_attach() == nil then
			-- https://github.com/minetest-mods/technic/blob/488f80d95095efeae38e08884b5ba34724e1bf71/technic/machines/other/frames.lua#L150
			if not entity then
				minetest.log("action", "[jumpdrive] moving object")
				obj:set_pos( vector.add(objPos, delta_vector) )

			elseif entity.name == "__builtin:item" then
				minetest.log("action", "[jumpdrive] moving dropped item")
				obj:set_pos( vector.add(objPos, delta_vector) )

			else
				minetest.log("action", "[jumpdrive] removing entity: " .. entity.name)
				obj:remove()

			end
		end
	end

	-- move players
	for _,player in ipairs(minetest.get_connected_players()) do
		local playerPos = player:get_pos()

		local xMatch = playerPos.x >= source_pos1.x and playerPos.x <= source_pos2.x
		local yMatch = playerPos.y >= source_pos1.y and playerPos.y <= source_pos2.y
		local zMatch = playerPos.z >= source_pos1.z and playerPos.z <= source_pos2.z

		if xMatch and yMatch and zMatch and player:is_player() then
			minetest.log("action", "[Jumpdrive] moving player: " .. player:get_player_name())
			player:moveto( vector.add(playerPos, delta_vector), false);
		end
	end

	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step IV took " .. (t1 - t0) .. " us")


	-- step 5: clear source area with voxel manip
	t0 = minetest.get_us_time()

	for z=source_pos1.z, source_pos2.z do
	for y=source_pos1.y, source_pos2.y do
	for x=source_pos1.x, source_pos2.x do

		local source_index = source_area:index(x, y, z)
		source_data[source_index] = c_air
	end
	end
	end

	source_manip:set_data(source_data)
	--source_manip:calc_lighting()
	source_manip:write_to_map()
	source_manip:update_map()

	t1 = minetest.get_us_time()
	minetest.log("action", "[jumpdrive] step V took " .. (t1 - t0) .. " us")



end
