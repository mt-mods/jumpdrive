
local nodedef = minetest.registered_nodes["elevator:motor"]

minetest.override_item("elevator:motor", {
	on_movenode = function(from_pos, to_pos)
		minetest.log("action", "[jumpdrive] Restoring elevator @ " .. to_pos.x .. "/" .. to_pos.y .. "/" .. to_pos.z)
		nodedef.after_place_node(to_pos, nil, nil)
	end
})
