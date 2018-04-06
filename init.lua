
jumpdrive = {
	config = {
		-- technic EU storage value
		powerstorage = 100000,

		-- charge value in EU
		powerrequirement = 2500,

		-- allow jumping into material
		allow_jumping_into_material = minetest.setting_getbool("jumpdrive_allow_jumping_into_material") or false,

		-- fuel item and count
		power_item = "default:mese_crystal",
		power_item_count = 1,

		-- allowed distances
		max_distance = 200,
		max_radius = 10
	}
}

dofile(minetest.get_modpath("jumpdrive").."/jumpdrive.lua")
dofile(minetest.get_modpath("jumpdrive").."/travelnet_compat.lua")

print("[OK] Jumpdrive")