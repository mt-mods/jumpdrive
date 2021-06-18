
minetest.register_on_mods_loaded(function()
	for node, def in pairs(minetest.registered_nodes) do
		if def.groups and def.groups.travelnet == 1 then
			minetest.override_item(node, {
				on_movenode = function(from_pos, to_pos)
					local meta = minetest.get_meta(to_pos);
					minetest.log("action", "[jumpdrive] Restoring travelnet @ " .. to_pos.x .. "/" .. to_pos.y .. "/" .. to_pos.z)

					local owner_name = meta:get_string( "owner" );
					local station_name = meta:get_string( "station_name" );
					local station_network = meta:get_string( "station_network" );
					local networks = travelnet.get_networks(owner_name)

					if networks and networks[station_network] and networks[station_network][station_name] then
						networks[station_network][station_name].pos = to_pos
						travelnet.set_networks(owner_name, networks)
					end
				end
			})
		end
	end
end)
