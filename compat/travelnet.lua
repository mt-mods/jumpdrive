jumpdrive.travelnet_compat = function(pos)

	local meta = minetest.get_meta(pos);
	minetest.log("action", "[jumpdrive] Restoring travelnet @ " .. pos.x .. "/" .. pos.y .. "/" .. pos.z)

	local owner_name = meta:get_string( "owner" );
	local station_name = meta:get_string( "station_name" );
	local station_network = meta:get_string( "station_network" );

	if (travelnet.targets[owner_name]
	 and travelnet.targets[owner_name][station_network]
	 and travelnet.targets[owner_name][station_network][station_name]) then

		travelnet.targets[owner_name][station_network][station_name].pos = pos

		if travelnet.save_data ~= nil then
			travelnet.save_data()
		end
	end
end
