local MP = minetest.get_modpath("jumpdrive")

local has_travelnet_mod = minetest.get_modpath("travelnet")
local has_locator_mod = minetest.get_modpath("locator")
local has_elevator_mod = minetest.get_modpath("elevator")
local has_display_mod = minetest.get_modpath("display_api")
local has_itemframes_mod = minetest.get_modpath("itemframes")

dofile(MP.."/compat/travelnet.lua")
dofile(MP.."/compat/locator.lua")
dofile(MP.."/compat/elevator.lua")
dofile(MP.."/compat/signs.lua")
dofile(MP.."/compat/itemframes.lua")

local c_beacon1
local c_beacon2
local c_beacon3

if has_locator_mod then
	c_beacon1 = minetest.get_content_id("locator:beacon_1")
	c_beacon2 = minetest.get_content_id("locator:beacon_2")
	c_beacon3 = minetest.get_content_id("locator:beacon_3")
end

jumpdrive.node_compat = function(content_id, source_pos, target_pos)
	if not has_locator_mod then return end

	if content_id == c_beacon1 or content_id == c_beacon2 or content_id == c_beacon3 then
		jumpdrive.locator_compat(source_pos, target_pos)
	end
end

jumpdrive.target_region_compat = function(pos1, pos2)
	if has_travelnet_mod then
		local pos_list = minetest.find_nodes_in_area(pos1, pos2, {"travelnet:travelnet"})
		if pos_list then
			for _,pos in pairs(pos_list) do
				jumpdrive.travelnet_compat(pos)
			end
		end
	end

	if has_elevator_mod then
		jumpdrive.elevator_compat(pos1, pos2)
	end

	if has_display_mod then
		jumpdrive.signs_compat(pos1, pos2)
	end

	if has_itemframes_mod then
		--jumpdrive.itemframes_compat(pos1, pos2)
		-- does not work: enclosed tmp variable in on_activate :(
		--https://gitlab.com/VanessaE/homedecor_modpack/blob/master/itemframes/init.lua#L15
	end

end
