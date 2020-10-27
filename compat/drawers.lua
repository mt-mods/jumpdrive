
assert(type(drawers.spawn_visuals) == "function")

-- refresh drawers in new area after jump
minetest.register_on_mods_loaded(function()
	for nodename, nodedef in pairs(minetest.registered_nodes) do
		if nodedef.groups and nodedef.groups.drawer then
			minetest.override_item(nodename, {
				on_movenode = function(_, to_pos)
					minetest.after(1, function()
						drawers.spawn_visuals(to_pos)
					end)
				end
			})
		end
	end
end)
