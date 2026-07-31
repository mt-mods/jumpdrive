
local textline_def = core.registered_nodes["textline:lcd"]
assert(textline_def)

-- refresh textline entities after the jump
core.override_item("textline:lcd", {
	on_movenode = function(from_pos, to_pos)
		local delta_vector = vector.subtract(to_pos, from_pos)
		local objects = core.get_objects_inside_radius(from_pos, 0.5)
		for _,object in ipairs(objects) do
			local entity = object:get_luaentity()
			if entity and entity.name == "textline:text" then
				object:set_pos(vector.add(object:get_pos(), delta_vector))
			end
		end
	end
})
