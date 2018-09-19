local c_air = minetest.get_content_id("air")

local has_vacuum_mod = minetest.get_modpath("vacuum")
-- TODO: what about ignore?

local c_vacuum
if has_vacuum_mod then
	c_vacuum = minetest.get_content_id("vacuum:vacuum")
else
	c_vacuum = c_air
end

jumpdrive.is_area_empty = function(pos1, pos2)
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local data = manip:get_data()

	for z=pos1.z, pos2.z do
	for y=pos1.y, pos2.y do
	for x=pos1.x, pos2.x do

		local index = area:index(x, y, z)
		local id = data[index]

		if id ~= c_air and id ~= c_vacuum then
			-- not air or vacuum
			return false
		end
	end
	end
	end

	-- only air and vacuum nodes found
	return true
end