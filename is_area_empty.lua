local c_ignore = minetest.get_content_id("ignore")

local buildable_to_nodes = {}

minetest.after(4, function()
	local count = 0
	for name, node in pairs(minetest.registered_nodes) do
		if node.buildable_to then
			count = count + 1
			local id = minetest.get_content_id(name)
			buildable_to_nodes[id] = true
		end
	end
	minetest.log("action", "[jumpdrive] collected " .. count .. " nodes that are buildable_to")
end)



jumpdrive.is_area_empty = function(pos1, pos2)
	
	minetest.emerge_area({ -- generates or loads the area before checking emptiness
	x= pos1.x > 0 and pos1.x+16 or pos1.x-16, -- expands area by 16 in each axis to prevent border overlap 
	y= pos1.y > 0 and pos1.y+16 or pos1.y-16,
	z= pos1.z > 0 and pos1.z+16 or pos1.z-16
	}, {
	x= pos2.x > 0 and pos2.x+16 or pos2.x-16,
	y= pos2.y > 0 and pos2.y+16 or pos2.y-16,
	z= pos2.z > 0 and pos2.z+16 or pos2.z-16
	})

	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local data = manip:get_data()

	for z=pos1.z, pos2.z do
	for y=pos1.y, pos2.y do
	for x=pos1.x, pos2.x do

		local index = area:index(x, y, z)
		local id = data[index]

		if id == c_ignore then
			return false, "Uncharted"
		end

		if not buildable_to_nodes[id] then
			-- not buildable_to
			return false, "Occupied"
		end
	end
	end
	end

	-- only buildable_to nodes found
	return true, ""
end
