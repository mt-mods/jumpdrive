local pos1 = vector.new(-50, -10, -50)
local pos2 = vector.new(50, 50, 50)

mtt.emerge_area(pos1, pos2)

mtt.register("basic move-test", function(callback)
	local source_pos1 = vector.new(0, 0, 0)
	local source_pos2 = vector.new(5, 5, 5)
	local target_pos1 = vector.new(10, 10, 10)
	local target_pos2 = vector.new(15, 15, 15)

	core.get_voxel_manip(source_pos1, source_pos1)
	local src_node = core.get_node(source_pos1)

	areas:add("dummy", "landscape", source_pos1, source_pos2)
	areas:save()

	assert(not core.is_protected(source_pos1, "dummy"))
	assert(core.is_protected(source_pos1, "dummy2"))

	jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)

	assert(not core.is_protected(source_pos1, "dummy"))
	assert(not core.is_protected(source_pos1, "dummy2"))

	assert(not core.is_protected(target_pos1, "dummy"))
	assert(core.is_protected(target_pos1, "dummy2"))

	core.get_voxel_manip(target_pos1, target_pos1)
	local target_node = core.get_node(target_pos1)

	if target_node.name ~= src_node.name then
		error("moved node name does not match")
	end

	if target_node.param2 ~= src_node.param2 then
		error("moved param2 does not match")
	end

	callback()
end)

core.register_node("jumpdrive:mtt_meta_node", {
	description = "mtt metadata test node",
	groups = { dig_immediate = 3 },
})

-- records on_movenode invocations: { from_pos, to_pos, info }
local movenode_calls = {}

core.register_node("jumpdrive:mtt_movenode", {
	description = "mtt on_movenode test node",
	groups = { dig_immediate = 3 },
	on_movenode = function(from_pos, to_pos, info)
		table.insert(movenode_calls, { from_pos = from_pos, to_pos = to_pos, info = info })
	end
})

mtt.register("move metadata", function(callback)
	local source_pos1 = vector.new(-40, 0, -40)
	local source_pos2 = vector.new(-35, 5, -35)
	local target_pos1 = vector.new(-30, 0, -40)
	local target_pos2 = vector.new(-25, 5, -35)
	local delta = vector.subtract(target_pos1, source_pos1)

	core.get_voxel_manip(source_pos1, source_pos2)
	core.get_voxel_manip(target_pos1, target_pos2)

	-- node with fields and inventory
	local meta_pos = vector.new(-38, 2, -38)
	core.set_node(meta_pos, { name = "jumpdrive:mtt_meta_node" })
	local meta = core.get_meta(meta_pos)
	meta:set_string("text", "hello")
	meta:set_int("count", 42)
	meta:set_float("ratio", 1.5)
	meta:set_string("secret", "hidden")
	meta:mark_as_private("secret")
	local inv = meta:get_inventory()
	inv:set_size("main", 8)
	inv:set_stack("main", 3, "jumpdrive:mtt_meta_node 5")

	-- source node without meta
	local plain_pos = vector.new(-37, 2, -37)
	core.set_node(plain_pos, { name = "jumpdrive:mtt_meta_node" })

	-- stale metadata in the target area, at a position that has no meta in the source
	local stale_target_pos = vector.add(vector.new(-36, 4, -36), delta)
	core.set_node(stale_target_pos, { name = "jumpdrive:mtt_meta_node" })
	core.get_meta(stale_target_pos):set_string("stale", "yes")

	jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)

	core.get_voxel_manip(source_pos1, source_pos2)
	core.get_voxel_manip(target_pos1, target_pos2)

	-- fields and inventory arrive at the target
	local target_meta_pos = vector.add(meta_pos, delta)
	assert(core.get_node(target_meta_pos).name == "jumpdrive:mtt_meta_node")
	local target_meta = core.get_meta(target_meta_pos)
	assert(target_meta:get_string("text") == "hello", "string field not moved")
	assert(target_meta:get_int("count") == 42, "int field not moved")
	assert(target_meta:get_float("ratio") == 1.5, "float field not moved")
	assert(target_meta:get_string("secret") == "hidden", "private field not moved")

	local target_inv = target_meta:get_inventory()
	assert(target_inv:get_size("main") == 8, "inventory size not moved")
	local stack = target_inv:get_stack("main", 3)
	assert(stack:get_name() == "jumpdrive:mtt_meta_node" and stack:get_count() == 5, "inventory stack not moved")
	assert(target_inv:get_stack("main", 1):is_empty(), "unexpected stack in inventory")

	-- source meta is cleared
	local source_meta = core.get_meta(meta_pos)
	assert(next(source_meta:to_table().fields) == nil, "source fields not cleared")
	assert(source_meta:get_inventory():get_size("main") == 0, "source inventory not cleared")
	assert(core.get_node(meta_pos).name == "air", "source node not cleared")

	-- node without meta stays without meta
	local plain_target_pos = vector.add(plain_pos, delta)
	assert(core.get_node(plain_target_pos).name == "jumpdrive:mtt_meta_node")
	assert(next(core.get_meta(plain_target_pos):to_table().fields) == nil, "plain node gained meta")

	-- stale target meta is gone
	assert(next(core.get_meta(stale_target_pos):to_table().fields) == nil, "stale target meta not cleared")

	-- no non-empty meta is left in the source
	-- (empty meta objects may exist, get_meta() creates them on access)
	for _, pos in ipairs(core.find_nodes_with_meta(source_pos1, source_pos2)) do
		local t = core.get_meta(pos):to_table()
		assert(next(t.fields) == nil, "meta fields left in source @ " .. core.pos_to_string(pos))
		for _, list in pairs(t.inventory) do
			for _, leftover in ipairs(list) do
				assert(leftover:is_empty(), "inventory left in source @ " .. core.pos_to_string(pos))
			end
		end
	end

	callback()
end)

mtt.register("move on_movenode", function(callback)
	-- non-cubic area to make sure the axes aren't mixed up
	local source_pos1 = vector.new(20, 0, 20)
	local source_pos2 = vector.new(25, 6, 27)
	local delta = vector.new(0, 20, 0)
	local target_pos1 = vector.add(source_pos1, delta)
	local target_pos2 = vector.add(source_pos2, delta)

	core.get_voxel_manip(source_pos1, source_pos2)
	core.get_voxel_manip(target_pos1, target_pos2)

	-- from_pos -> expected edge
	local expected = {
		[vector.new(22, 3, 23)] = vector.new(0, 0, 0), -- interior
		[source_pos1] = vector.new(-1, -1, -1),
		[source_pos2] = vector.new(1, 1, 1),
		[vector.new(25, 3, 23)] = vector.new(1, 0, 0),
		[vector.new(22, 0, 23)] = vector.new(0, -1, 0),
		[vector.new(22, 3, 27)] = vector.new(0, 0, 1),
	}

	local count = 0
	for pos in pairs(expected) do
		core.set_node(pos, { name = "jumpdrive:mtt_movenode" })
		count = count + 1
	end

	-- node without on_movenode must not trigger anything
	core.set_node(vector.new(21, 1, 21), { name = "jumpdrive:mtt_meta_node" })

	movenode_calls = {}
	jumpdrive.move(source_pos1, source_pos2, target_pos1, target_pos2)

	assert(#movenode_calls == count,
		"expected " .. count .. " on_movenode calls, got " .. #movenode_calls)

	local seen = {}
	for _, call in ipairs(movenode_calls) do
		local key = core.pos_to_string(call.from_pos)
		seen[key] = true

		local edge
		for pos, e in pairs(expected) do
			if vector.equals(pos, call.from_pos) then
				edge = e
			end
		end
		assert(edge, "unexpected on_movenode call for " .. key)

		assert(vector.equals(call.to_pos, vector.add(call.from_pos, delta)),
			"wrong to_pos for " .. key .. ": " .. core.pos_to_string(call.to_pos))
		assert(vector.equals(call.info.edge, edge),
			"wrong edge for " .. key .. ": " .. core.pos_to_string(call.info.edge))
	end

	for pos in pairs(expected) do
		assert(seen[core.pos_to_string(pos)], "missing on_movenode call for " .. core.pos_to_string(pos))
	end

	callback()
end)
