
jumpdrive = {
	config = {
		-- allowed radius
		max_radius = tonumber(core.settings:get("jumpdrive.max_radius")) or 15,
		max_area_radius = tonumber(core.settings:get("jumpdrive.max_area_radius")) or 25,

		-- max volume in nodes ( ((radius*2) + 1) ^ 3 )
		max_area_volume = tonumber(core.settings:get("jumpdrive.max_area_volume")) or 29791,

		-- base storage value
		powerstorage = tonumber(core.settings:get("jumpdrive.powerstorage")) or 1000000,

		-- base technic power requirement
		powerrequirement = tonumber(core.settings:get("jumpdrive.power_requirement")) or 2500,

		-- allow emerging area on "uncharted" error
		emerge_uncharted = core.settings:get_bool("jumpdrive.allow_emerge", false),
	},

	-- blacklisted nodes
	blacklist = {}
}

jumpdrive.sounds = {}

if core.get_modpath("default") then
	jumpdrive.sounds = default
end

if core.get_modpath("mcl_sounds") then
	jumpdrive.sounds = mcl_sounds
end

local MP = core.get_modpath("jumpdrive")

if core.get_modpath("technic") then
	dofile(MP.."/technic_run.lua")
end

-- common functions
dofile(MP.."/fuel.lua")
dofile(MP.."/upgrade.lua")
dofile(MP.."/bookmark.lua")
dofile(MP.."/infotext.lua")
dofile(MP.."/migrate.lua")
dofile(MP.."/hooks.lua")
dofile(MP.."/compat/compat.lua")
dofile(MP.."/is_area_empty.lua")
dofile(MP.."/is_area_protected.lua")

-- move logic
dofile(MP.."/move/move_objects.lua")
dofile(MP.."/move/move_mapdata.lua")
dofile(MP.."/move/move_metadata.lua")
dofile(MP.."/move/move_nodetimers.lua")
dofile(MP.."/move/move_players.lua")
dofile(MP.."/move/move.lua")

dofile(MP.."/mapgen.lua")
dofile(MP.."/common.lua")
dofile(MP.."/digiline.lua")
dofile(MP.."/backbone.lua")
dofile(MP.."/warp_device.lua")
dofile(MP.."/crafts.lua")

-- engine
dofile(MP.."/engine.lua")
dofile(MP.."/formspec.lua")
dofile(MP.."/jump.lua")

-- fleet
dofile(MP.."/fleet/fleet_functions.lua")
dofile(MP.."/fleet/fleet_digiline.lua")
dofile(MP.."/fleet/fleet_controller.lua")
dofile(MP.."/fleet/fleet_formspec.lua")

-- blacklist nodes
dofile(MP.."/blacklist.lua")


if core.get_modpath("monitoring") then
	-- enable metrics
	dofile(MP.."/metrics.lua")
end

if core.get_modpath("mtt") and mtt.enabled then
	dofile(MP.."/mtt.lua")
end

print("[OK] Jumpdrive")
