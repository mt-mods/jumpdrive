
local textline_def = minetest.registered_nodes["textline:lcd"]
assert(textline_def)
assert(textline_def.after_place_node)

-- refresh textline entities after the jump
minetest.override_item("textline:lcd", {
	on_movenode = function(from_pos, to_pos)
		minetest.after(1, function()
			textline_def.after_place_node(to_pos)
		end)
	end
})
