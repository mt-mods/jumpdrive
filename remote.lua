
local update_formspec = function(meta)
	local relButton = "Mode: Relative"
	if meta:get_int("relative") == 0 then
		relButton = "Mode: Absolute"
	end

	meta:set_string("formspec", "size[6,3;]" ..
		"field[0,1;2,1;x;X;" .. meta:get_int("x") .. "]" ..
		"field[2,1;2,1;y;Y;" .. meta:get_int("y") .. "]" ..
		"field[4,1;2,1;z;Z;" .. meta:get_int("z") .. "]" ..

		"button_exit[0,2;3,1;execute;Execute]" ..
		"button[3,2;3,1;toggleRelative;" .. relButton .. "]" ..
end

local execute_remote = function(pos, meta)
	-- TODO
end

local find_and_register_engine = function(pos, meta)
	-- TODO
end

minetest.register_node("jumpdrive:remote", {
	description = "Jumpdrive remote",
	tiles = {"jumpdrive_remote.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),

	mesecons = {effector = {
		action_on = function (pos, node)
			local meta = minetest.get_meta(pos)
			execute_remote(pos, meta)
		end
	}},

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("x", 0)
		meta:set_int("y", 0)
		meta:set_int("z", 0)
		meta:set_int("relative", 1)

		find_and_register_engine(pos, meta)
		update_formspec(meta)
	end,

	on_punch = function (pos, node, puncher)
		local meta = minetest.get_meta(pos)
		execute_remote(pos, meta)
	end,

	on_receive_fields = function(pos, formname, fields, sender)

		local meta = minetest.get_meta(pos);
		local owner = meta.get_string("owner")

		if sender and sender.get_player_name and sender:get_player_name() ~= owner then
			-- non-owner
			return
		end

		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);
		local toggleRelative = fields.toggleRelative;

		if x == nil or y == nil or z == nil then
			return
		end

		if toggleRelative then
			if meta:get_int("relative") == 0 then
				meta:set_int("relative", 1)
			else
				meta:set_int("relative", 0)
			end
		end

		-- update coords
		meta:set_int("x", x)
		meta:set_int("y", y)
		meta:set_int("z", z)
		
		update_formspec(meta)

		if fields.execute then
			execute_remote(pos, meta)
		end
		
	end
})