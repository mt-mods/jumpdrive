
--https://github.com/minetest-mods/technic/blob/master/technic/machines/HV/forcefield.lua

jumpdrive.digiline_effector = function(pos, _, channel, msg)
	local set_channel = "jumpdrive" -- static channel for now

	local msgt = type(msg)

	if msgt ~= "table" then
		return
	end

	if channel ~= set_channel then
		return
	end

	local meta = minetest.get_meta(pos)

	local radius = jumpdrive.get_radius(pos)
	local targetPos = jumpdrive.get_meta_pos(pos)

	local distance = vector.distance(pos, targetPos)
	local power_req = jumpdrive.calculate_power(radius, distance, pos, targetPos)

	if msg.command == "get" then
		digilines.receptor_send(pos, digilines.rules.default, set_channel, {
			powerstorage = meta:get_int("powerstorage"),
			radius = radius,
			position = pos,
			target = targetPos,
			distance = distance,
			power_req = power_req
		})

	elseif msg.command == "reset" then
		meta:set_int("x", pos.x)
		meta:set_int("y", pos.y)
		meta:set_int("z", pos.z)
		jumpdrive.update_formspec(meta, pos)

	elseif msg.command == "set" then
		local value = tonumber(msg.value)

		if value == nil then
			-- not a number
			return
		end

		if msg.key == "x" then
			meta:set_int("x", value)
		elseif msg.key == "y" then
			meta:set_int("y", value)
		elseif msg.key == "z" then
			meta:set_int("z", value)
		elseif msg.key == "radius" then
			if value >= 1 and value <= jumpdrive.config.max_radius then
				meta:set_int("radius", value)
			end
		end


	elseif msg.command == "simulate" or msg.command == "show" then
		local success, resultmsg = jumpdrive.simulate_jump(pos)

		digilines.receptor_send(pos, digilines.rules.default, set_channel, {
			success=success,
			msg=resultmsg
		})

	elseif msg.command == "jump" then
		local success, time = jumpdrive.execute_jump(pos)

		local send_pos = pos
		if success then
			-- send new message in target pos
			send_pos = targetPos
		end

		digilines.receptor_send(send_pos, digilines.rules.default, set_channel, {
			success = success,
			time = time
		})
	end
end
