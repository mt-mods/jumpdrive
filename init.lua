
minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",
	tiles = {"bluebeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "jumpdrive:engine",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		-- meta:set_string("formspec", default.gui_bg .. default.gui_bg_img .. default.gui_slots)
		meta:set_string("formspec", "size[8,9;]" ..
			"list[current_player;main;0,5;8,4;]")
	end,
})

print("[OK] Jumpdrive")
