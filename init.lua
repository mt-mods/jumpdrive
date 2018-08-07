
jumpdrive = {
	config = {
		-- technic EU storage value
		powerstorage = tonumber(minetest.settings:get("jumpdrive.powerstorage")) or 100000,

		-- charge value in EU
		powerrequirement = tonumber(minetest.settings:get("jumpdrive.power_requirement")) or 2500,

		-- fuel item and value
		power_item = minetest.settings:get("jumpdrive.power_item_name") or "default:mese_crystal",
		power_item_value = tonumber(minetest.settings:get("jumpdrive.power_item_value")) or 1000,

		-- allowed radius
		max_radius = tonumber(minetest.settings:get("jumpdrive.maxradius")) or 10
	}
}

local MP = minetest.get_modpath("jumpdrive")

dofile(MP.."/marker.lua")
dofile(MP.."/common.lua")
dofile(MP.."/engine.lua")
--dofile(MP.."/remote.lua")
dofile(MP.."/travelnet_compat.lua")
dofile(MP.."/elevator_compat.lua")
dofile(MP.."/locator_compat.lua")

print("[OK] Jumpdrive")
