
local function unhash_pos(hash)
		local pos = {}
		local list = string.split(hash, ':')
		pos.x = tonumber(list[1])
		pos.y = tonumber(list[2])
		pos.z = tonumber(list[3])
		return pos
end

local function hash_pos(pos)
		return math.floor(pos.x + 0.5) .. ':' ..
				math.floor(pos.y + 0.5) .. ':' ..
				math.floor(pos.z + 0.5)
end

local function is_valid_beacon(name)
	if name == "telemosaic:beacon"
			or name == "telemosaic:beacon_err"
			or name == "telemosaic:beacon_disabled"
			or name == "telemosaic:beacon_protected"
			or name == "telemosaic:beacon_err_protected"
			or name == "telemosaic:beacon_disabled_protected" then
		return true
	end
	return false
end

jumpdrive.telemosaic_compat = function(source_pos, target_pos, source_pos1, source_pos2, delta_vector)

	-- delegate to compat
	minetest.log("action", "[jumpdrive] Trying to rewire telemosaic at " .. minetest.pos_to_string(target_pos))

	local local_meta = minetest.get_meta(target_pos)
	local remote_hash = local_meta:get_string('telemosaic:dest')

	if remote_hash ~= nil and remote_hash ~= '' then
		local remote_pos = unhash_pos(remote_hash)

		minetest.load_area(remote_pos)
		local node = minetest.get_node(remote_pos)

		if not is_valid_beacon(node.name) then
			-- no beacon found, check if it was moved
			local xMatch = remote_pos.x >= source_pos1.x and remote_pos.x <= source_pos2.x
			local yMatch = remote_pos.y >= source_pos1.y and remote_pos.y <= source_pos2.y
			local zMatch = remote_pos.z >= source_pos1.z and remote_pos.z <= source_pos2.z

			if not (xMatch and yMatch and zMatch) then
				return -- outside of moved area
			end

			remote_pos = vector.add(remote_pos, delta_vector)
			minetest.load_area(remote_pos)
			node = minetest.get_node(remote_pos)

			if not is_valid_beacon(node.name) then
				return -- no beacon anywhere
			end
		end

		local remote_meta = minetest.get_meta(remote_pos)
		local remote_dest = remote_meta:get_string('telemosaic:dest')

		if remote_dest == hash_pos(source_pos) then
			-- remote beacon points to this beacon, update link
			minetest.log("action", "[jumpdrive] rewiring telemosaic at " .. minetest.pos_to_string(remote_pos) ..
					" to " .. minetest.pos_to_string(target_pos))

			remote_meta:set_string("telemosaic:dest", hash_pos(target_pos))
		end
	end
end
