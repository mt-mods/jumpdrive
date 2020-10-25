jumpdrive.switching_station_compat = function(source_pos, target_pos)
	if not technic.networks then return end

	-- clear network cache for both positions
	technic.networks[minetest.hash_node_position({ x = source_pos.x, y = source_pos.y-1, z = source_pos.z })] = nil
	technic.networks[minetest.hash_node_position({ x = target_pos.x, y = target_pos.y-1, z = target_pos.z })] = nil
end
