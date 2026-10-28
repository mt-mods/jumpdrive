
-- invoked from move.lua
jumpdrive.move_metadata = function(source_pos1, source_pos2, delta_vector)


	local target_pos1 = vector.add(source_pos1, delta_vector)
	local target_pos2 = vector.add(source_pos2, delta_vector)

	-- check if there is some "stale" metadata in the target area
	local target_meta_pos_list = core.find_nodes_with_meta(target_pos1, target_pos2)
	for _,target_pos in pairs(target_meta_pos_list) do
		core.log("warning", "[jumpdrive] clearing spurious meta in " .. core.pos_to_string(target_pos))
		local target_meta = core.get_meta(target_pos)
		target_meta:from_table(nil)
	end

	local meta_pos_list = core.find_nodes_with_meta(source_pos1, source_pos2)
	for _,source_pos in pairs(meta_pos_list) do
		local target_pos = vector.add(source_pos, delta_vector)

		local source_meta = core.get_meta(source_pos)
		local source_table = source_meta:to_table()

		-- copy metadata to target
		core.get_meta(target_pos):from_table(source_table)

		local node = core.get_node(source_pos)

		jumpdrive.node_compat(node.name, source_pos, target_pos, source_pos1, source_pos2, delta_vector)

		-- clear metadata in source
		source_meta:from_table(nil)
	end

	jumpdrive.commit_node_compat()

end
