

jumpdrive.migrate_engine_meta = function(pos, meta)

  -- previous version had no such variable in the metadata
  local max_store = meta:get_int("max_powerstorage")
  if max_store == 0 then
    meta:set_int("max_powerstorage", 1000000)
  end

  local power_requirement = meta:get_int("power_requirement")
  if power_requirement == 0 then
    meta:set_int("power_requirement", 2500)
  end
end
