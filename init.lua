
jumpdrive = {
	config = {
		-- technic EU storage value
		powerstorage = 100000,

		-- charge value in EU
		powerrequirement = 2500,

		-- allow jumping into material
		-- TODO minetest.settings:
		allow_jumping_into_material = minetest.setting_getbool("jumpdrive_allow_jumping_into_material") or false,

		-- fuel item and count
		power_item = "default:mese_crystal",
		power_item_count = 1,

		-- allowed radius
		max_radius = 20
	}
}

local MP = minetest.get_modpath("jumpdrive")

dofile(MP.."/marker.lua")
dofile(MP.."/common.lua")
dofile(MP.."/engine.lua")
dofile(MP.."/travelnet_compat.lua")
dofile(MP.."/elevator_compat.lua")

print("[OK] Jumpdrive")