
jumpdrive = {
	config = {
		-- allowed radius
		max_radius = tonumber(minetest.settings:get("jumpdrive.maxradius")) or 15
	},

	blacklist = {}
}

local MP = minetest.get_modpath("jumpdrive")

dofile(MP.."/technic_run.lua")
dofile(MP.."/bookmark.lua")
dofile(MP.."/formspec.lua")
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
dofile(MP.."/fleet_functions.lua")
dofile(MP.."/fleet_controller.lua")
dofile(MP.."/blacklist.lua")

if minetest.get_modpath("pipeworks") then
	dofile(MP.."/override/teleport_tube.lua")
end

if minetest.get_modpath("monitoring") then
	-- enable metrics
	dofile(MP.."/metrics.lua")
end

print("[OK] Jumpdrive")
