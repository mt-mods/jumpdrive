
-- NOTE: This only updates telemosaic pairs where each targets the other.
--       Currently daisy chains are not updated neither multiple telemosaics
--       pointing to the jumped one.

-- Older versions of [telemosaic] used 'hashed' pos strings.
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

-- Newer versions of [telemosaic] use core.pos_to_string().
-- These functions verify which version is being used and react accordingly.
local function unpack_pos(hash_or_pos_string)
	if type(hash_or_pos_string) ~= 'string' or hash_or_pos_string == '' then
		return nil, nil
	end

	local uses_hash = hash_or_pos_string:find(":") and true or false
	if uses_hash then
		local pos = unhash_pos(hash_or_pos_string)
		if pos.x and pos.y and pos.z then
			return pos, uses_hash
		end
		return nil, nil
	else
		return core.string_to_pos(hash_or_pos_string), uses_hash
	end
end

local function pack_pos(pos, use_hash)
	if use_hash then
		return hash_pos(pos)
	else
		return core.pos_to_string(pos)
	end
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
	core.log("action", "[jumpdrive] Trying to rewire telemosaic at " .. core.pos_to_string(target_pos))

	local local_meta = core.get_meta(target_pos)
	local remote_pos = unpack_pos(local_meta:get_string('telemosaic:dest'))
	if not remote_pos then
		return
	end

	core.load_area(remote_pos)
	local node = core.get_node(remote_pos)

	if not is_valid_beacon(node.name) then
		-- no beacon found, check if it was moved
		local xMatch = remote_pos.x >= source_pos1.x and remote_pos.x <= source_pos2.x
		local yMatch = remote_pos.y >= source_pos1.y and remote_pos.y <= source_pos2.y
		local zMatch = remote_pos.z >= source_pos1.z and remote_pos.z <= source_pos2.z

		if not (xMatch and yMatch and zMatch) then
			return -- outside of moved area
		end

		remote_pos = vector.add(remote_pos, delta_vector)
		core.load_area(remote_pos)
		node = core.get_node(remote_pos)

		if not is_valid_beacon(node.name) then
			return -- no beacon anywhere
		end
	end

	local remote_meta = core.get_meta(remote_pos)
	local remote_dest, uses_hash = unpack_pos(remote_meta:get_string('telemosaic:dest'))

	if core.pos_to_string(remote_dest) == core.pos_to_string(source_pos) then
		-- remote beacon points to this beacon, update link
		core.log("action", "[jumpdrive] rewiring telemosaic at " ..
			core.pos_to_string(remote_pos) .. " to " ..
			core.pos_to_string(target_pos))

		remote_meta:set_string("telemosaic:dest", pack_pos(target_pos, uses_hash))
	end
end
