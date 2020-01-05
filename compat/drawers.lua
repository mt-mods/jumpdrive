
function jumpdrive.drawers_compat(target_pos1, target_pos2)
	minetest.after(1.0, function()
		local nodes = minetest.find_nodes_in_area(target_pos1, target_pos2, {"group:drawer"})
		for _, pos in ipairs(nodes) do
			drawers.spawn_visuals(pos)
		end
	end)
end
