
local add_pos = function(pos1, pos2)
	return {x=pos1.x+pos2.x, y=pos1.y+pos2.y, z=pos1.z+pos2.z}
end

local move_block = function(from, to)
	local node = minetest.get_node(from) -- Obtain current node

	-- print("x=" .. ix .. " y=" .. iy .. " z=" .. iz .. " name=" .. node.name)

	if node.name == "air" or node.name == "ignore" then
		return
	end

	local meta = minetest.get_meta(from):to_table() -- Get metadata of current node
	minetest.remove_node(from) -- Remove current node

	local newNode = minetest.get_node(to)
	if newNode.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(to, to)
		newNode = minetest.get_node(to)
	end

	minetest.set_node(to, node) -- Move node to new position
	minetest.get_meta(to):from_table(meta) -- Set metadata of new node
end

local calculate_cost = function(pos, offsetPos, radius)
	local meta = minetest.get_meta(pos)

	local diameter = radius * 2
	local blocks = math.pow(diameter, 3)

	print("Would move " .. blocks .. " potential blocks")
end

local execute_jump = function(pos, offsetPos, radius)

	local pos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
	local pos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};

	minetest.get_voxel_manip():read_from_map(pos1, pos2)

	local ix = pos.x+radius
	while ix >= pos.x-radius do
		local iy = pos.y+radius
		while iy >= pos.y-radius do
			local iz = pos.z+radius
			while iz >= pos.z-radius do
				local oldPos = {x=ix, y=iy, z=iz}
				local newPos = add_pos(oldPos, offsetPos)

				move_block(oldPos, newPos)

				iz = iz - 1
			end
			iy = iy - 1
		end
		ix = ix - 1
	end

	local all_objects = minetest.get_objects_inside_radius(pos, radius);
	for _,obj in ipairs(all_objects) do
		obj:moveto( add_pos(obj:get_pos(), offsetPos) )
	end	

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
			"button_exit[3,2;2,1;calculate;Calculate]" ..
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
		local targetPos = add_pos(pos, offsetPos)
		local meta = minetest.get_meta(pos)

		if fields.jump then

			if minetest.get_modpath("protector") and not protector.can_dig(radius, targetPos, sender, true, 0) then
				meta:set_string("infotext", "Jump aborted: proteced area!")
				return
			end

			local minjumpdistance = radius * 2

			if math.abs(x) <= minjumpdistance and math.abs(y) <= minjumpdistance and math.abs(z) <= minjumpdistance then
				meta:set_string("infotext", "Jump too short!")
				return
			end

			execute_jump(pos, offsetPos, radius)

			print("Jump complete!")
		end

		if fields.calculate then
			calculate_cost(pos, offsetPos, radius)
		end
		
	end
})

print("[OK] Jumpdrive")
