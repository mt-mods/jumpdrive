
-- stolen from: https://gitlab.com/VanessaE/homedecor_modpack/blob/master/itemframes/init.lua#L86

local facedir = {}

facedir[0] = {x = 0, y = 0, z = 1}
facedir[1] = {x = 1, y = 0, z = 0}
facedir[2] = {x = 0, y = 0, z = -1}
facedir[3] = {x = -1, y = 0, z = 0}

local tmp = {}

local update_item = function(pos, node)
	-- remove_item(pos, node) --already removed through jump
	local meta = minetest.get_meta(pos)
	if meta:get_string("item") ~= "" then
		if node.name == "itemframes:frame" then
			local posad = facedir[node.param2]
			if not posad then return end
			pos.x = pos.x + posad.x * 6.5 / 16
			pos.y = pos.y + posad.y * 6.5 / 16
			pos.z = pos.z + posad.z * 6.5 / 16
		elseif node.name == "itemframes:pedestal" then
			pos.y = pos.y + 12 / 16 + 0.33
		end
		tmp.nodename = node.name
		tmp.texture = ItemStack(meta:get_string("item")):get_name()
		local e = minetest.add_entity(pos,"itemframes:item")
		if node.name == "itemframes:frame" then
			local yaw = math.pi * 2 - node.param2 * math.pi / 2
			e:setyaw(yaw)
		end
	end
end


jumpdrive.itemframes_compat = function(pos1, pos2)

	local nodes = minetest.find_nodes_in_area(pos1, pos2, {"itemframes:pedestal", "itemframes:frame"})

	if nodes then
		for _,pos in pairs(nodes) do
			minetest.log("action", "[jumpdrive] updating itemframe @ " .. minetest.pos_to_string(pos))
			local node = minetest.get_node(pos)
			update_item(pos, node)
		end
	end


end