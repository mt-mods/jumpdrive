
-- add a position offset
local add_pos = function(pos1, pos2)
	return {x=pos1.x+pos2.x, y=pos1.y+pos2.y, z=pos1.z+pos2.z}
end

local update_formspec = function(meta)
	meta:set_string("formspec", "size[8,5;]" ..
		"field[2,1;2,1;radius;Search Radius;" .. meta:get_int("radius") .. "]" ..
		"field[5,1;2,1;step;Step;" .. meta:get_int("step") .. "]" ..

		"button_exit[1,2;2,1;xplus;X+]" ..
		"button_exit[1,3;2,1;xminus;X-]" ..

		"button_exit[3,2;2,1;yplus;Y+]" ..
		"button_exit[3,3;2,1;yminus;Y-]" ..

		"button_exit[5,2;2,1;zplus;Z+]" ..
		"button_exit[5,3;2,1;zminus;Z-]")
end

local do_step_jump = function(pos, radius, player, relpos)

	local pos1 = {x=pos.x-radius, y=pos.y-radius, z=pos.z-radius};
	local pos2 = {x=pos.x+radius, y=pos.y+radius, z=pos.z+radius};

	local jumpdrives = minetest.find_nodes_in_area(pos1, pos2, "jumpdrive:engine")

	for _,otherPos in ipairs(jumpdrives) do
		local otherMeta = minetest.get_meta(otherPos)

		if otherMeta:get_int("cascade") == 1 then
			-- cascade enabled

			-- update pos
			local targetPos = jumpdrive.get_meta_pos(otherPos)
			jumpdrive.set_meta_pos(otherPos, add_pos(targetPos, relpos))
			jumpdrive.update_formspec(otherMeta)
			jumpdrive.execute_jump(otherPos, player)

			return
		end

	end
end

minetest.register_node("jumpdrive:remote", {
	description = "Jumpdrive Remote",
	tiles = {"jumpdrive_remote.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3,technic_machine = 1, technic_hv = 1},
	drop = "jumpdrive:remote",
	sounds = default.node_sound_glass_defaults(),

	mesecons = {effector = {
		action_on = function (pos, node)
		end
	}},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("radius", 5)
		meta:set_int("step", 50)
		update_formspec(meta)
	end,

	on_receive_fields = function(pos, formname, fields, sender)

		local radius = tonumber(fields.radius);
		local step = tonumber(fields.step);

		if radius == nil or radius < 1 or step == nil or step < 1 then
			return
		end

		local meta = minetest.get_meta(pos);
		meta:set_int("radius", radius)
		meta:set_int("step", step)
		update_formspec(meta)

		if fields.xplus then
			do_step_jump(pos, radius, sender, {x=step, y=0, z=0})
		end
		
		if fields.xminus then
			do_step_jump(pos, radius, sender, {x=-step, y=0, z=0})
		end
		
		if fields.yplus then
			do_step_jump(pos, radius, sender, {x=0, y=step, z=0})
		end
		
		if fields.yminus then
			do_step_jump(pos, radius, sender, {x=0, y=-step, z=0})
		end
		
		if fields.zplus then
			do_step_jump(pos, radius, sender, {x=0, y=0, z=step})
		end
		
		if fields.zminus then
			do_step_jump(pos, radius, sender, {x=0, y=0, z=-step})
		end
		
	end
})

minetest.register_craft({
	output = 'jumpdrive:engine',
	recipe = {
		{'', 'default:mese_crystal_fragment', ''},
		{'default:diamond', 'jumpdrive:engine', 'default:diamond'},
		{'', 'default:mese_crystal', ''}
	}
})


