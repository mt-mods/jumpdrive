
jumpdrive = {
	config = {
		-- allowed radius
		max_radius = tonumber(minetest.settings:get("jumpdrive.maxradius")) or 10
	}
}

local MP = minetest.get_modpath("jumpdrive")

dofile(MP.."/marker.lua")
dofile(MP.."/compat/compat.lua")
dofile(MP.."/is_area_empty.lua")
dofile(MP.."/is_area_protected.lua")
dofile(MP.."/move.lua")
dofile(MP.."/common.lua")
dofile(MP.."/engine.lua")
--dofile(MP.."/remote.lua")

print("[OK] Jumpdrive")
