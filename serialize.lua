
-- serialize to in-memory format
function jumpdrive.serialize(pos1, pos2)
  -- read source
  local manip = minetest.get_voxel_manip()
  local e1, e2 = manip:read_from_map(pos1, pos2)
  local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
  local data = manip:get_data()
  local param1 = manip:get_light_data()
  local param2 = manip:get_param2_data()
  local meta = {}

  local meta_pos_list = minetest.find_nodes_with_meta(pos1, pos2)
  for _,source_pos in pairs(meta_pos_list) do
		local source_meta = minetest.get_meta(source_pos)
    meta[source_pos] = source_meta:to_table()
  end

  return {
    data = data,
    param1 = param1,
    param2 = param2,
    meta = meta
  }
end

-- deserialize from in-memory format
function jumpdrive.deserialize(pos1, pos2, data)
end
