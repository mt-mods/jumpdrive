
local vecadd = vector.add
local poshash = minetest.hash_node_position
local get_node = minetest.get_node
local cables = technic and technic.cables
local machines = technic and technic.machine_tiers

-- Check for technic mod compatibility, compatible with technic plus
if not technic or not technic.remove_network or not technic.networks or not cables or not machines then
	minetest.log("warning", "[jumpdrive] Incompatible technic mod loaded")
	jumpdrive.technic_network_compat = function() end
	return
end

-- Function to move technic network to another position
local network_node_arrays = {"PR_nodes","BA_nodes","RE_nodes"}
local function move_network(net, delta)
	for _,tblname in ipairs(network_node_arrays) do
		local tbl = net[tblname]
		for i=#tbl,1,-1 do
			tbl[i] = vecadd(tbl[i], delta)
		end
	end
	local new_net_id = poshash(vecadd(technic.network2pos(net.id), delta))
	local new_all_nodes = {}
	local all_nodes = net.all_nodes
	for old_node_id, old_pos in pairs(all_nodes) do
		local new_pos = vecadd(old_pos, delta)
		local node_id = poshash(new_pos)
		cables[old_node_id] = nil
		cables[node_id] = new_net_id
		new_all_nodes[node_id] = new_pos
	end
	net.all_nodes = new_all_nodes
end

local function vecadd2(a, b, c)
	return {
		x = a.x + b.x + c.x,
		y = a.y + b.y + c.y,
		z = a.z + b.z + c.z,
	}
end

local function add_edge_cable_net(pos, size, delta, t)
	-- Find connected positions outside edge of box from given position
	-- NOTE: At source position first found would be enough but not at target
	local x = pos.x == 0 and -1 or (pos.x == size.x and 1)
	local y = pos.y == 0 and -1 or (pos.y == size.y and 1)
	local z = pos.z == 0 and -1 or (pos.z == size.z and 1)
	if x then
		local v = vecadd2(pos, {x=x,y=0,z=0}, delta)
		local net_id = cables[poshash(v)]
		if net_id then t[net_id] = true end
	end
	if y then
		local v = vecadd2(pos, {x=0,y=y,z=0}, delta)
		local net_id = cables[poshash(v)]
		if net_id then t[net_id] = true end
	end
	if z then
		local v = vecadd2(pos, {x=0,y=0,z=z}, delta)
		local net_id = cables[poshash(v)]
		if net_id then t[net_id] = true end
	end
	return x, y, z
end

jumpdrive.technic_network_compat = function(source_pos1, source_pos2, target_pos1, delta_vector)

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
					-- Add to (dirty) jumped fully contained networks
					jump_networks[net_id] = true
				end
				if x==0 or x==size.x or y==0 or y==size.y or z==0 or z==size.z then
					-- Candidate for border crossing network, check neighbors across border
					if net_id then
						-- Inside network is active, check outside for active and inactive
						local dir_x, dir_y, dir_z = add_edge_cable_net(local_pos, size, source_pos1, edge_networks)
						if dir_x then
							local name = get_node(vecadd2(local_pos, target_pos1, {x=dir_x,y=0,z=0})).name
							if machines[name] or technic.get_cable_tier(name) then edge_networks[net_id] = true end
						end
						if dir_y then
							local name = get_node(vecadd2(local_pos, target_pos1, {x=0,y=dir_y,z=0})).name
							if machines[name] or technic.get_cable_tier(name) then edge_networks[net_id] = true end
						end
						if dir_z then
							local name = get_node(vecadd2(local_pos, target_pos1, {x=0,y=0,z=dir_z})).name
							if machines[name] or technic.get_cable_tier(name) then edge_networks[net_id] = true end
						end
					else
						-- Inside is inactive, check outside for active
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
