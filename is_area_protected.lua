local has_areas_mod = minetest.get_modpath("areas")
local has_protector_mod = minetest.get_modpath("protector")

local protector_radius = (tonumber(minetest.setting_get("protector_radius")) or 5)

jumpdrive.is_area_protected = function(pos1, pos2, playername)

	if has_protector_mod then
		local radius_vector = {x=protector_radius, y=protector_radius, z=protector_radius}
		local protectors = minetest.find_nodes_in_area(
			vector.subtract(pos1, radius_vector),
			vector.add(pos2, radius_vector),
			{"protector:protect", "protector:protect2"}
		)

		if protectors then
			for _,pos in pairs(protectors) do
				if minetest.is_protected(pos, playername) then
					return true
				end
			end
		end
	end

	if has_areas_mod then
		if not areas:canInteractInArea(pos1, pos2, playername, true) then
			-- player can't interact
			return true
		end
	end

	-- no protection
	return false
end
