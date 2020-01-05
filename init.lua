
jumpdrive = {
	config = {
		-- allowed radius
		max_radius = tonumber(minetest.settings:get("jumpdrive.maxradius")) or 15,

		-- base storage value
		powerstorage = tonumber(minetest.settings:get("jumpdrive.powerstorage")) or 1000000,

		-- base technic power requirement
		powerrequirement = tonumber(minetest.settings:get("jumpdrive.power_requirement")) or 2500,
	},

	-- blacklisted nodes
	blacklist = {}
}

local MP = minetest.get_modpath("jumpdrive")

if minetest.get_modpath("technic") then
	dofile(MP.."/technic_run.lua")
end

if minetest.get_modpath("pipeworks") then
	dofile(MP.."/override/teleport_tube.lua")
end

dofile(MP.."/fuel.lua")
dofile(MP.."/upgrade.lua")
dofile(MP.."/bookmark.lua")
dofile(MP.."/formspec.lua")
dofile(MP.."/infotext.lua")
dofile(MP.."/migrate.lua")
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
dofile(MP.."/crafts.lua")
dofile(MP.."/fleet_functions.lua")
dofile(MP.."/fleet_controller.lua")
dofile(MP.."/blacklist.lua")

if minetest.get_modpath("monitoring") then
	-- enable metrics
	dofile(MP.."/metrics.lua")
end

if minetest.settings:get_bool("enable_jumpdrive_integration_test") then
        dofile(MP.."/integration_test.lua")
end

print("[OK] Jumpdrive")
