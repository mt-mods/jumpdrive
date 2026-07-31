
local c_air = minetest.get_content_id("air")

function jumpdrive.clear_area(pos1, pos2)
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(pos1, pos2)
	local source_area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local source_data = manip:get_data()


	for z=pos1.z, pos2.z do
	for y=pos1.y, pos2.y do
	for x=pos1.x, pos2.x do

		local source_index = source_area:index(x, y, z)
		source_data[source_index] = c_air
	end
	end
	end

	manip:set_data(source_data)
	manip:write_to_map()

	-- remove metadata
	local target_meta_pos_list = minetest.find_nodes_with_meta(pos1, pos2)
	for _,target_pos in pairs(target_meta_pos_list) do
		local target_meta = minetest.get_meta(target_pos)
		target_meta:from_table(nil)
	end
end

function jumpdrive.sanitize_coord(coord)
	return math.max( math.min( coord, 31000 ), -31000 )
end

-- get pos object from pos
function jumpdrive.get_meta_pos(pos)
	local meta = minetest.get_meta(pos);
	return vector.new(meta:get_int("x"), meta:get_int("y"), meta:get_int("z"))
end

-- set pos object from pos
function jumpdrive.set_meta_pos(pos, target)
	local meta = minetest.get_meta(pos);
	meta:set_int("x", target.x)
	meta:set_int("y", target.y)
	meta:set_int("z", target.z)
end

-- get offset from meta
function jumpdrive.get_radius(pos)
	local meta = minetest.get_meta(pos);
	return math.max(math.min(meta:get_int("radius"), jumpdrive.config.max_radius), 1)
end

-- calculates the power requirements for a jump
-- params: radius, distance, sourcePos, targetPos
function jumpdrive.calculate_power(radius, distance)
	return 10 * distance * radius
end


-- preflight check, for overriding
-- params: source, destination, radius, playername
function jumpdrive.preflight_check()
	return { success=true }
end

function jumpdrive.reset_coordinates(pos)
	local meta = minetest.get_meta(pos)

	meta:set_int("x", pos.x)
	meta:set_int("y", pos.y)
	meta:set_int("z", pos.z)

end

function jumpdrive.get_mapblock_from_pos(pos)
	return vector.divide(pos, 16):floor()
end

jumpdrive.digiline_rules = {
	-- digilines.rules.default
	vector.new(1, 0, 0), vector.new(-1, 0, 0), -- along x beside
	vector.new(0, 0, 1), vector.new( 0, 0,-1), -- along z beside
	vector.new(1, 1, 0), vector.new(-1, 1, 0), -- 1 node above along x diagonal
	vector.new(0, 1, 1), vector.new( 0, 1,-1), -- 1 node above along z diagonal
	vector.new(1,-1, 0), vector.new(-1,-1, 0), -- 1 node below along x diagonal
	vector.new(0,-1, 1), vector.new( 0,-1,-1), -- 1 node below along z diagonal
	-- added rules for digi cable
	vector.new(0, 1, 0),vector.new(0, -1, 0), -- along y above and below
}
