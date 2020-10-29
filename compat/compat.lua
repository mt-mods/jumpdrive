local MP = minetest.get_modpath("jumpdrive")

local has_technic_mod = minetest.get_modpath("technic")
local has_locator_mod = minetest.get_modpath("locator")
local has_display_mod = minetest.get_modpath("display_api")
local has_pipeworks_mod = minetest.get_modpath("pipeworks")
local has_beds_mod = minetest.get_modpath("beds")
local has_ropes_mod = minetest.get_modpath("ropes")
local has_sethome_mod = minetest.get_modpath("sethome")
local has_areas_mod = minetest.get_modpath("areas")
local has_drawers_mod = minetest.get_modpath("drawers")
local has_textline_mod = minetest.get_modpath("textline")

if minetest.get_modpath("travelnet") then
	dofile(MP.."/compat/travelnet.lua")
end

if minetest.get_modpath("elevator") then
	dofile(MP.."/compat/elevator.lua")
end

if has_technic_mod then
	dofile(MP.."/compat/anchor.lua")
	dofile(MP.."/compat/technic_networks.lua")
end

if has_locator_mod then
	dofile(MP.."/compat/locator.lua")
end

if has_drawers_mod then
	dofile(MP.."/compat/drawers.lua")
end

if has_display_mod then
	dofile(MP.."/compat/signs.lua")
end

if has_textline_mod then
	dofile(MP.."/compat/textline.lua")
end

if has_areas_mod then
	dofile(MP.."/compat/areas.lua")
end

if has_sethome_mod then
	dofile(MP.."/compat/sethome.lua")
end

if has_ropes_mod then
	dofile(MP.."/compat/ropes.lua")
end

dofile(MP.."/compat/telemosaic.lua")
dofile(MP.."/compat/beds.lua")

if has_pipeworks_mod then
	dofile(MP.."/compat/teleporttube.lua")
end

jumpdrive.node_compat = function(name, source_pos, target_pos, source_pos1, source_pos2, delta_vector)

	if has_pipeworks_mod and string.find(name, "^pipeworks:teleport_tube") then
		jumpdrive.teleporttube_compat(source_pos, target_pos)

	elseif name == "telemosaic:beacon" or name == "telemosaic:beacon_err"
			or name == "telemosaic:beacon_disabled" or name == "telemosaic:beacon_protected"
			or name == "telemosaic:beacon_err_protected" or name == "telemosaic:beacon_disabled_protected" then
		jumpdrive.telemosaic_compat(source_pos, target_pos, source_pos1, source_pos2, delta_vector)

	end
end

jumpdrive.commit_node_compat = function()
	if has_pipeworks_mod then
		jumpdrive.teleporttube_compat_commit()
	end
end


jumpdrive.target_region_compat = function(source_pos1, source_pos2, target_pos1, target_pos2, delta_vector)
	-- sync compat functions

	if has_beds_mod then
		jumpdrive.beds_compat(target_pos1, target_pos2, delta_vector)
	end

end
