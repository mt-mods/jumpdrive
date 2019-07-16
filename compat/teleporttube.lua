

-- https://gitlab.com/VanessaE/pipeworks/blob/master/teleport_tube.lua
jumpdrive.teleporttube_compat = function(from, to)
	if not pipeworks.tptube then
		-- only works with the patch from "./patches/pipeworks.patch"
		return
	end

	local from_hash = pipeworks.tptube.hash(from)
	local to_hash = pipeworks.tptube.hash(to)

	-- swap data
	local data = pipeworks.tptube.tp_tube_db[from_hash]
	pipeworks.tptube.tp_tube_db[from_hash] = nil
	pipeworks.tptube.tp_tube_db[to_hash] = data

end

jumpdrive.teleporttube_compat_commit = function()
	if not pipeworks.tptube then
		-- only works with the patch from "./patches/pipeworks.patch"
		return
	end

	pipeworks.tptube.save_tube_db()
end