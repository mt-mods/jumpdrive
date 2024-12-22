
if minetest.get_modpath("technic") then
  -- technic enabled crafts
  minetest.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
      {'jumpdrive:backbone', 'technic:blue_energy_crystal', 'jumpdrive:backbone'},
      {'jumpdrive:warp_device', 'technic:hv_transformer', 'jumpdrive:warp_device'},
      {'technic:copper_coil', 'technic:hv_cable', 'technic:copper_coil'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
      {'default:mese', 'default:steelblock', 'default:mese'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'default:mese', 'default:steelblock', 'default:mese'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'technic:composite_plate', 'technic:wrought_iron_dust', 'technic:composite_plate'},
      {'default:mese', 'technic:machine_casing', 'default:mese'},
      {'technic:copper_coil', 'technic:hv_cable', 'technic:copper_coil'}
    }
  })
  minetest.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
      {'technic:carbon_plate', 'mesecons_luacontroller:luacontroller0000', 'technic:control_logic_unit'},
      {'jumpdrive:backbone', 'technic:machine_casing', 'jumpdrive:backbone'},
      {'basic_materials:stainless_steel_wire', 'default:steelblock', 'basic_materials:stainless_steel_wire'}
    }
  })

elseif minetest.get_modpath("mcl_core") then
  -- mineclone crafts
  minetest.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
      {'jumpdrive:backbone', 'mcl_core:ironblock', 'jumpdrive:backbone'},
      {'mcl_core:ironblock', 'mcl_core:ironblock', 'mcl_core:ironblock'},
      {'jumpdrive:backbone', 'mcl_core:ironblock', 'jumpdrive:backbone'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
      {'mesecons_torch:redstoneblock', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock'},
      {'mcl_core:ironblock', 'mcl_core:ironblock', 'mcl_core:ironblock'},
      {'mesecons_torch:redstoneblock', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'mesecons:wire_00000000_off', 'mcl_core:diamond', 'mesecons:wire_00000000_off'},
      {'mesecons_torch:redstoneblock', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock'},
      {'mesecons:wire_00000000_off', 'mcl_core:diamond', 'mesecons:wire_00000000_off'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
      {'jumpdrive:engine', 'mcl_core:ironblock', 'jumpdrive:engine'},
      {'mcl_core:ironblock', 'mcl_core:ironblock', 'mcl_core:ironblock'},
      {'jumpdrive:engine', 'mcl_core:ironblock', 'jumpdrive:engine'}
    }
  })
elseif minetest.get_modpath("default") then
  -- minetest_game crafts
  minetest.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
      {'jumpdrive:backbone', 'default:steelblock', 'jumpdrive:backbone'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'jumpdrive:backbone', 'default:steelblock', 'jumpdrive:backbone'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
      {'default:mese', 'default:steelblock', 'default:mese'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'default:mese', 'default:steelblock', 'default:mese'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'default:mese_crystal', 'default:diamond', 'default:mese_crystal'},
      {'default:mese', 'default:steelblock', 'default:mese'},
      {'default:mese_crystal', 'default:diamond', 'default:mese_crystal'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
      {'jumpdrive:engine', 'default:steelblock', 'jumpdrive:engine'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'jumpdrive:engine', 'default:steelblock', 'jumpdrive:engine'}
    }
  })
end
