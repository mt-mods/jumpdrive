
local nodedef = core.registered_nodes["elevator:motor"]

core.override_item("elevator:motor", {
	on_movenode = function(_, to_pos)
		core.log("action", "[jumpdrive] Restoring elevator @ " .. to_pos.x .. "/" .. to_pos.y .. "/" .. to_pos.z)
		nodedef.after_place_node(to_pos, nil, nil)
	end
})
