
minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",
	tiles = {"bluebeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "jumpdrive:engine"
})

print("[OK] Jumpdrive")
