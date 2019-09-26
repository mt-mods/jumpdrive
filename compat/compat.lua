local MP = minetest.get_modpath("jumpdrive")

local has_travelnet_mod = minetest.get_modpath("travelnet")
local has_technic_mod = minetest.get_modpath("technic")
local has_locator_mod = minetest.get_modpath("locator")
local has_elevator_mod = minetest.get_modpath("elevator")
local has_display_mod = minetest.get_modpath("display_api")
local has_pipeworks_mod = minetest.get_modpath("pipeworks")
local has_beds_mod = minetest.get_modpath("beds")
local has_ropes_mod = minetest.get_modpath("ropes")

dofile(MP.."/compat/travelnet.lua")
dofile(MP.."/compat/locator.lua")
dofile(MP.."/compat/elevator.lua")
dofile(MP.."/compat/signs.lua")
dofile(MP.."/compat/itemframes.lua")
dofile(MP.."/compat/anchor.lua")
dofile(MP.."/compat/telemosaic.lua")
dofile(MP.."/compat/beds.lua")
dofile(MP.."/compat/ropes.lua")

if has_pipeworks_mod then
	dofile(MP.."/compat/teleporttube.lua")
end


jumpdrive.node_compat = function(name, source_pos, target_pos)
	if (name == "locator:beacon_1" or name == "locator:beacon_2" or name == "locator:beacon_3") and has_locator_mod then
		jumpdrive.locator_compat(source_pos, target_pos)

	elseif has_technic_mod and name == "technic:admin_anchor" then
		jumpdrive.anchor_compat(source_pos, target_pos)

	elseif has_pipeworks_mod and string.find(name, "^pipeworks:teleport_tube") then
		jumpdrive.teleporttube_compat(source_pos, target_pos)

	elseif name == "telemosaic:beacon" or name == "telemosaic:beacon_protected" then
		jumpdrive.telemosaic_compat(source_pos, target_pos)

	end
end

jumpdrive.commit_node_compat = function()
	if has_pipeworks_mod then
		jumpdrive.teleporttube_compat_commit()
	end
end


jumpdrive.target_region_compat = function(pos1, pos2, delta_vector)
	if has_travelnet_mod then
		jumpdrive.travelnet_compat(pos1, pos2)
	end

	if has_elevator_mod then
		jumpdrive.elevator_compat(pos1, pos2)
	end

	if has_display_mod then
		jumpdrive.signs_compat(pos1, pos2)
	end

	if has_beds_mod then
		jumpdrive.beds_compat(pos1, pos2, delta_vector)
	end

	if has_ropes_mod then
		jumpdrive.ropes_compat(pos1, pos2, delta_vector)
	end
end

