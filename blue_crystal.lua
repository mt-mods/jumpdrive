

minetest.register_craftitem("jumpdrive:blue_mese_crystal", {
	description = "Blue mese crystal",
	inventory_image = "jumpdrive_blue_mese_crystal.png"
})

minetest.register_craftitem("jumpdrive:raw_blue_mese_crystal", {
	description = "Raw blue mese crystal",
	inventory_image = "jumpdrive_raw_blue_mese_crystal.png"
})

minetest.register_craft({
	type = "shapeless",
	output = "jumpdrive:raw_blue_mese_crystal",
	recipe = {"default:mese_crystal", "dye:blue"}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 30,
	output = "jumpdrive:blue_mese_crystal",
	recipe = "jumpdrive:raw_blue_mese_crystal",
})
