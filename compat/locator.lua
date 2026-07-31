
for i=1,3 do
	core.override_item("locator:beacon_" .. i, {
		on_movenode = function(from_pos, to_pos)
			local meta = core.get_meta(to_pos)
			locator.remove_beacon(from_pos)
			locator.update_beacon(to_pos, meta)
		end
	})
end
