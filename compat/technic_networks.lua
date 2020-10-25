
local vecadd = vector.add
local poshash = minetest.hash_node_position
local cables = technic.cables
local machines = technic.machine_tiers

-- Function to move technic network to another position
local network_node_arrays = {"PR_nodes","BA_nodes","RE_nodes"}
local function move_network(net, delta)
	for _,tblname in ipairs(network_node_arrays) do
		local tbl = network[tblname]
		for i=#tbl,1,-1 do
			tbl[i] = vecadd(tbl[i], delta)
		end
	end
	local new_net_id = vecadd(technic.network2pos(net.id), delta)
	local all_nodes = net.all_nodes
	for old_node_id, old_pos in pairs(all_nodes) do
		local new_pos = vecadd(old_pos, delta)
		local node_id = poshash(new_pos)
		cables[old_node_id] = nil
		new_all_nodes[node_id] = new_pos
		cables[node_id] = new_net_id
	end
	net.all_nodes = new_all_nodes
end

local function add_edge_cable_net(pos, size, delta, t)
	-- Find connected positions outside edge of box from given position
	-- NOTE: At source position firt found would be enough but not at target
	local x = pos.x == 0 and -1 or (pos.x == size.x and 1)
	local y = pos.y == 0 and -1 or (pos.y == size.y and 1)
	local z = pos.z == 0 and -1 or (pos.z == size.z and 1)
	if x then
		local v = vecadd(vecadd(pos, {x=x,y=0,z=0}),delta)
		local net_id = cables[poshash(v)]
		if net_id then t[net_id] = true end
	end
	if y then
		local v = vecadd(vecadd(pos, {x=0,y=y,z=0}),delta)
		local net_id = cables[poshash(v)]
		if net_id then t[net_id] = true end
	end
	if z then
		local v = vecadd(vecadd(pos, {x=0,y=0,z=z}),delta)
		local net_id = cables[poshash(v)]
		if net_id then t[net_id] = true end
	end
end

jumpdrive.technic_network_compat = function(source_pos1, source_pos2, target_pos1, delta_vector)
	-- Check for technic mod compatibility
	if not technic.remove_network or not technic.networks then return end

	-- search results
	local jump_networks = {} -- jumped fully contained networks
	local edge_networks = {} -- networks crossing jumped area edge

	-- search for networks in area
	local size = vector.apply(vector.subtract(source_pos1, source_pos2),math.abs)
	for x=0,size.x do
		for y=0,size.y do
			for z=0,size.z do
				local local_pos = {x=x,y=y,z=z}
				local src_pos = vecadd(source_pos1, local_pos)
				local net_id = cables[poshash(src_pos)]
				if net_id then
					-- Add to (dirty) jumped networks
					jump_networks[net_id] = true
					if x==0 or x==size.x or y==0 or y==size.y or z==0 or z==size.z then
						-- Candidate for edge network, check neighbors across border
						add_edge_cable_net(local_pos, size, source_pos1, edge_networks)
						add_edge_cable_net(local_pos, size, target_pos1, edge_networks)
					end
				elseif x==0 or x==size.x or y==0 or y==size.y or z==0 or z==size.z then
					-- Check for unconnected nodes that might connect to network at target location
					local name = minetest.get_node(src_pos).name
					if machines[name] or technic.get_cable_tier(name) then
						add_edge_cable_net(local_pos, size, target_pos1, edge_networks)
					end
				end
			end
		end
	end
	for net_id, _ in pairs(edge_networks) do
		-- Remove edge networks to create contained networks list
		jump_networks[net_id] = nil
		-- And clean up network crossing jumped area edges
		technic.remove_network(net_id)
	end
	for net_id, _ in pairs(jump_networks) do
		-- Move fully contained networks with jumpdrive
		local net = technic.networks[net_id]
		if net then
			move_network(net, delta_vector)
		end
	end
end
