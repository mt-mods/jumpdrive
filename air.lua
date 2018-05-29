-- jumpdrive buffer air (for vacuum jumps)

minetest.register_node("jumpdrive:air", {
	description = "Jumpdrive buffer air",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drawtype = "glasslike",
	tiles = {"jumpdrive_air.png"},
	groups = {not_in_creative_inventory=0},
	paramtype = "light",
	sunlight_propagates = true,
	on_timer = function(pos,elapsed)
		minetest.set_node(pos, {name="air"})
	end
})
