local bed_bottoms = {"beds:bed_bottom", "beds:fancy_bed_bottom"}

-- sanity checks
assert(beds)
assert(beds.spawn)
assert(beds.save_spawns)

-- Calculate a bed's middle position (where players would spawn)
local function calc_bed_middle(bed_pos, facedir)
	local dir = minetest.facedir_to_dir(facedir)
	local bed_middle = {
		x = bed_pos.x + dir.x / 2,
		y = bed_pos.y,
		z = bed_pos.z + dir.z / 2
	}
	return bed_middle
end

local bed_from_positions = {}


for _, nodename in ipairs(bed_bottoms) do
	-- override bed definitions
	minetest.override_item(nodename, {
		on_movenode = function(from_pos, to_pos)
			-- collect bed positions while jumping
			table.insert(bed_from_positions, from_pos)
		end
	})
end

-- executed after jump
jumpdrive.register_after_jump(function(from_area, to_area)
	local delta_vector = vector.subtract(to_area.pos1, from_area.pos1)
	local modified = false

	-- go over all collected bed positions
	for _, bed_pos in ipairs(bed_from_positions) do
		local facedir = minetest.get_node(bed_pos).param2
		local sleep_pos = calc_bed_middle(bed_pos, facedir)
		-- sleep position in target area
		local new_sleep_pos = vector.add(sleep_pos, delta_vector)

		for player_name, player_pos in pairs(beds.spawn) do
			if vector.equals(sleep_pos, player_pos) then
				-- player sleeps here, move position
				beds.spawn[player_name] = new_sleep_pos
				minetest.log("action", "[jumpdrive] Updated bed spawn for player " .. player_name)

				-- set modified flag to save afterwards
				modified = true
			end
		end
	end

	if modified then
		-- Tell beds mod to save the new spawns.
		beds.save_spawns()
	end

	-- clear collected bed positions
	bed_from_positions = {}
end)
