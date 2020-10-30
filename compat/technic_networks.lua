--
-- Compatibility hacks for technic plus new network system
--
-- More information:
-- https://github.com/mt-mods/technic/issues/100
--
-- See also proposal draft to actually move networks instead of rebuilding:
-- https://github.com/mt-mods/jumpdrive/pull/79
--

-- Check for technic mod version compatibility
if technic.remove_network and technic.pos2network and technic.machines then

	local function on_movenode(from_pos, to_pos, info)
		-- Destroy network caches at source location, inside jump area
		local src_net_id = technic.pos2network(from_pos)
		if src_net_id then
			technic.remove_network(src_net_id)
		end

		-- Destroy network caches at target location, outside jump area
		local edge = info.edge
		for axis, value in pairs(edge) do
			if value ~= 0 then
				local axis_dir = {x=0,y=0,z=0}
				axis_dir[axis] = value
				local edge_pos = vector.add(to_pos, axis_dir)
				local dst_net_id = technic.pos2network(edge_pos)
				if dst_net_id then
					technic.remove_network(dst_net_id)
				end
			end
		end
	end

	-- Collect groups for registered technic cables
	local cable_groups = {}
	for tier,_ in pairs(technic.machines) do
		cable_groups[("technic_%s_cable"):format(tier:lower())] = 1
	end

	local function is_network_node(name, def)
		if not def.groups then return end
		for group,_ in pairs(cable_groups) do
			if def.groups[group] then return true end
		end
		return def.groups["technic_machine"]
	end

	-- Inject on_movenode functionality but only if node does not already implement it
	for name, def in pairs(minetest.registered_nodes) do
		if not def.on_movenode and is_network_node(name, def) then
			minetest.override_item(name, { on_movenode = on_movenode })
		end
	end

end
