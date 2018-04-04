
local add_pos = function(pos1, pos2)
	return {x=pos1.x+pos2.x, y=pos1.y+pos2.y, z=pos1.z+pos2.z}
end

minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",
	tiles = {"jumpdrive.png"},
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

		if x == nil or y == nil or z == nil or radius == nil then
			return
		end

		local offsetPos = {x=x, y=y, z=z}
		local meta = minetest.get_meta(pos)


		if minetest.get_modpath("protector") and not protector.can_dig(radius, pos, sender, true, 0) then
			meta:set_string("infotext", "Jump aborted: proteced area!")
			return
		end


		local minjumpdistance = radius * 2

		if math.abs(x) <= minjumpdistance and math.abs(y) <= minjumpdistance and math.abs(z) <= minjumpdistance then
			meta:set_string("infotext", "Jump too short!")
			return
		end

		local pos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
		local pos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};

		meta:set_string("infotext", "Jump in progress...")


		minetest.get_voxel_manip():read_from_map(pos1, pos2)

		local ix = pos.x+radius
		while ix >= pos.x-radius do
			local iy = pos.y+radius
			while iy >= pos.y-radius do
				local iz = pos.z+radius
				while iz >= pos.z-radius do
					local oldPos = {x=ix, y=iy, z=iz}
					local newPos = {x=ix+x, y=iy+y, z=iz+z}

					local node = minetest.get_node(oldPos) -- Obtain current node

					print("x=" .. ix .. " y=" .. iy .. " z=" .. iz .. " name=" .. node.name)

					if node.name == "air" or node.name == "ignore" then
						break
					end

					local meta = minetest.get_meta(oldPos):to_table() -- Get metadata of current node
					minetest.remove_node(oldPos) -- Remove current node

					local newNode = minetest.get_node(newPos)
					if newNode.name == "ignore" then
						minetest.get_voxel_manip():read_from_map(newPos, newPos)
						newNode = minetest.get_node(newPos)
					end

					minetest.set_node(newPos, node) -- Move node to new position
					minetest.get_meta(newPos):from_table(meta) -- Set metadata of new node

					iz = iz - 1
				end
				iy = iy - 1
			end
			ix = ix - 1
		end

		local newjumpnodepos = add_pos(pos, offsetPos)
		local newjumpnodemeta = minetest.get_meta(newjumpnodepos)
		newjumpnodemeta:set_string("infotext", "Jump complete!")

		local playerpos = sender:getpos();
		local newplayerpos = add_pos(playerpos, offsetPos)

		sender:moveto(newplayerpos);


		
	end
})

print("[OK] Jumpdrive")
