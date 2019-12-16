
jumpdrive.areas_compat = function(pos1, pos2, delta_vector)
  local list = areas:getAreasIntersectingArea(pos1, pos2)

  for id, area in pairs(list) do
    local xMatch = area.pos1.x >= pos1.x and area.pos2.x <= pos2.x
    local yMatch = area.pos1.y >= pos1.y and area.pos2.y <= pos2.y
    local zMatch = area.pos1.z >= pos1.z and area.pos2.z <= pos2.z

    if xMatch and yMatch and zMatch then
      minetest.log("action", "[jumpdrive] moving area " .. id)

      areas:move(
        id,
        vector.add(area.pos1, delta_vector),
        vector.add(area.pos2, delta_vector)
      )
    end
  end
end
