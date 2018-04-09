

jumpdrive.elevator_compat = function(pos)

	local def = minetest.registered_nodes["elevator:motor"]
	minetest.log("action", "[jumpdrive] Restoring elevator @ " .. pos.x .. "/" .. pos.y .. "/" .. pos.z)

	-- function(pos, placer, itemstack)
	def.after_place_node(pos, nil, nil)
	
end