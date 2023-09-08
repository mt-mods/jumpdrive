
local fuel_list = {}

jumpdrive.fuel = {}

jumpdrive.fuel.register = function(item_name, value)
  fuel_list[item_name] = value
end

jumpdrive.fuel.get_value = function(item_name)
  if not item_name then
    return 0
  end
  return fuel_list[item_name] or 0
end

if minetest.get_modpath("default") then
  jumpdrive.fuel.register("default:mese_crystal_fragment", 100)
  jumpdrive.fuel.register("default:mese_crystal", 900)
  jumpdrive.fuel.register("default:mese", 8100)
end

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mesecons") and minetest.get_modpath("mesecons_torch") then
   jumpdrive.fuel.register("mesecons:wire_00000000_off", 900)
  jumpdrive.fuel.register("mesecons_torch:redstoneblock", 8100)
end
