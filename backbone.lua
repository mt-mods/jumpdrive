

minetest.register_node("jumpdrive:backbone", {
	description = "Jumpdrive Backbone",

	tiles = {"jumpdrive_backbone.png"},
	groups = {cracky=3,oddly_breakable_by_hand=3,handy=1,pickaxey=1},
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.9,
	sounds = jumpdrive.sounds.node_sound_glass_defaults(),
	light_source = 13
})
