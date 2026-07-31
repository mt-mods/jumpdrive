assert(type(display_api.update_entities) == "function")

-- refresh signs in new area after jump
core.register_on_mods_loaded(function()
	for nodename, nodedef in pairs(core.registered_nodes) do
		if nodedef.groups and nodedef.groups.display_api then
			core.override_item(nodename, {
				on_movenode = function(_, to_pos)
					core.after(1, function()
						display_api.update_entities(to_pos)
					end)
				end
			})
		end
	end
end)
