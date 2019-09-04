
jumpdrive = {
	config = {
		-- technic EU storage value
		powerstorage = tonumber(minetest.settings:get("jumpdrive.powerstorage")) or 1000000,

		-- charge value in EU
		powerrequirement = tonumber(minetest.settings:get("jumpdrive.power_requirement")) or 2500,

		-- allowed radius
		max_radius = tonumber(minetest.settings:get("jumpdrive.maxradius")) or 15
	},

	blacklist = {}
}

local MP = minetest.get_modpath("jumpdrive")

dofile(MP.."/marker.lua")
dofile(MP.."/compat/compat.lua")
dofile(MP.."/is_area_empty.lua")
dofile(MP.."/is_area_protected.lua")

dofile(MP.."/move_objects.lua")
dofile(MP.."/move_metadata.lua")
dofile(MP.."/move_nodetimers.lua")
dofile(MP.."/move.lua")

dofile(MP.."/mapgen.lua")
dofile(MP.."/common.lua")
dofile(MP.."/digiline.lua")
dofile(MP.."/engine.lua")
dofile(MP.."/backbone.lua")
dofile(MP.."/fleet_functions.lua")
dofile(MP.."/fleet_controller.lua")
dofile(MP.."/blacklist.lua")

if minetest.get_modpath("monitoring") then
	-- enable metrics
	dofile(MP.."/metrics.lua")
end

print("[OK] Jumpdrive")
