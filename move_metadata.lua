
-- invoked from move.lua
jumpdrive.move_metadata = function(source_pos1, source_pos2, delta_vector)
	local meta_pos_list = minetest.find_nodes_with_meta(source_pos1, source_pos2)
	for _,source_pos in pairs(meta_pos_list) do
		local target_pos = vector.add(source_pos, delta_vector)

		local source_meta = minetest.get_meta(source_pos):to_table()
		minetest.get_meta(target_pos):from_table(source_meta)

		local node = minetest.get_node(source_pos)

		jumpdrive.node_compat(node.name, source_pos, target_pos)
	end

end