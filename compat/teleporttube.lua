
local teletubedef = minetest.registered_nodes["pipeworks:teleport_tube"]

-- https://gitlab.com/VanessaE/pipeworks/blob/master/teleport_tube.lua
jumpdrive.teleporttube_compat = function(from, to)

	teletubedef.on_destruct(from)

	-- local sender = pipeworks.create_fake_player({ name="" })

	-- teletubedef.on_receive_fields(pos,formname,fields,sender)
	-- TODO

end
