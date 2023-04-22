
assert(type(travelnet.get_travelnets) == "function", "old travelnet-api found, please update the travelnet mod")

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

					local travelnets = travelnet.get_travelnets(owner_name)
					if (travelnets[owner_name]
						and travelnets[owner_name][station_network]
						and travelnets[owner_name][station_network][station_name]) then
							-- update station with new position
							travelnets[owner_name][station_network][station_name].pos = to_pos
							travelnet.set_travelnets(owner_name, travelnets)
					end
				end
			})
		end
	end
end)

jumpdrive.register_after_jump(function()
	if travelnet.save_data ~= nil then
		-- write data back to files
		travelnet.save_data()
	end
end)
