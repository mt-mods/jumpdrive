assert(type(display_api.update_entities) == "function")

-- refresh signs in new area after jump
minetest.register_on_mods_loaded(function()
	for nodename, nodedef in pairs(minetest.registered_nodes) do
		if nodedef.groups and nodedef.groups.display_api then
			minetest.override_item(nodename, {
				on_movenode = function(_, to_pos)
					minetest.after(1, function()
						display_api.update_entities(to_pos)
					end)
				end
			})
		end
	end
end)
