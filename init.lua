
minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",
	tiles = {"bluebeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "jumpdrive:engine",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[8,9;]" ..
			"field[1,1;1,1;x;X;0]" ..
			"field[2,1;1,1;y;Y;50]" ..
			"field[3,1;1,1;z;Z;0]" ..
			"field[4,1;1,1;radius;Radius;10]" ..
			"button_exit[1,2;2,1;jump;Jump]" ..
			"list[current_player;main;0,5;8,4;]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);
		local radius = tonumber(fields.radius);

		local pos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
		local pos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};


		--[[
		-- works without meta..

		local path = minetest.get_worldpath() .. "/schems"
		-- Create directory if it does not already exist
		minetest.mkdir(path)

		local filename = path .. "/jumpdrive_" .. sender:get_player_name() .. ".mts"

		minetest.create_schematic(pos1, pos2, nil, filename, nil);

		local newpos = {x=pos.x-radius+x, y=pos.y-radius+y, z=pos.z-radius+z}

		minetest.place_schematic(newpos, filename, nil, nil, true);
		]]--

		local ix = pos.x+radius
		while ix >= pos.x-radius do
			local iy = pos.y+radius
			while iy >= pos.y-radius do
				local iz = pos.z+radius
				while iz >= pos.z-radius do
					local oldPos = {x=ix, y=iy, z=iz}
					local newPos = {x=ix+x, y=iy+y, z=iz+z}

					local node = minetest.get_node(oldPos) -- Obtain current node
					local meta = minetest.get_meta(oldPos):to_table() -- Get metadata of current node
					minetest.remove_node(oldPos) -- Remove current node

					minetest.set_node(newPos, node) -- Move node to new position
					minetest.get_meta(newPos):from_table(meta) -- Set metadata of new node

					iz = iz - 1
				end
				iy = iy - 1
			end
			ix = ix - 1
		end

		local playerpos = sender:getpos();
		local newplayerpos = {x=playerpos.x+x, y=playerpos.y+y, z=playerpos.z+z}

		sender:moveto(newplayerpos);
		
	end
})

print("[OK] Jumpdrive")
