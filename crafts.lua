
if core.get_modpath("technic") then
  -- technic enabled crafts
  core.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
      {'jumpdrive:backbone', 'technic:blue_energy_crystal', 'jumpdrive:backbone'},
      {'jumpdrive:warp_device', 'technic:hv_transformer', 'jumpdrive:warp_device'},
      {'technic:copper_coil', 'technic:hv_cable', 'technic:copper_coil'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
      {'default:mese', 'default:steelblock', 'default:mese'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'default:mese', 'default:steelblock', 'default:mese'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'technic:composite_plate', 'technic:wrought_iron_dust', 'technic:composite_plate'},
      {'default:mese', 'technic:machine_casing', 'default:mese'},
      {'technic:copper_coil', 'technic:hv_cable', 'technic:copper_coil'}
    }
  })
  core.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
      {'technic:carbon_plate', 'mesecons_luacontroller:luacontroller0000', 'technic:control_logic_unit'},
      {'jumpdrive:backbone', 'technic:machine_casing', 'jumpdrive:backbone'},
      {'basic_materials:stainless_steel_wire', 'default:steelblock', 'basic_materials:stainless_steel_wire'}
    }
  })

elseif core.get_modpath("mcl_core") then
  -- mineclone crafts
  core.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
      {'jumpdrive:backbone', 'mcl_core:ironblock', 'jumpdrive:backbone'},
      {'mcl_core:ironblock', 'mcl_core:ironblock', 'mcl_core:ironblock'},
      {'jumpdrive:backbone', 'mcl_core:ironblock', 'jumpdrive:backbone'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
      {'mesecons_torch:redstoneblock', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock'},
      {'mcl_core:ironblock', 'mcl_core:ironblock', 'mcl_core:ironblock'},
      {'mesecons_torch:redstoneblock', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'mesecons:wire_00000000_off', 'mcl_core:diamond', 'mesecons:wire_00000000_off'},
      {'mesecons_torch:redstoneblock', 'mcl_core:ironblock', 'mesecons_torch:redstoneblock'},
      {'mesecons:wire_00000000_off', 'mcl_core:diamond', 'mesecons:wire_00000000_off'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
      {'jumpdrive:engine', 'mcl_core:ironblock', 'jumpdrive:engine'},
      {'mcl_core:ironblock', 'mcl_core:ironblock', 'mcl_core:ironblock'},
      {'jumpdrive:engine', 'mcl_core:ironblock', 'jumpdrive:engine'}
    }
  })
elseif core.get_modpath("default") then
  -- minetest_game crafts
  core.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
      {'jumpdrive:backbone', 'default:steelblock', 'jumpdrive:backbone'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'jumpdrive:backbone', 'default:steelblock', 'jumpdrive:backbone'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
      {'default:mese', 'default:steelblock', 'default:mese'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'default:mese', 'default:steelblock', 'default:mese'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'default:mese_crystal', 'default:diamond', 'default:mese_crystal'},
      {'default:mese', 'default:steelblock', 'default:mese'},
      {'default:mese_crystal', 'default:diamond', 'default:mese_crystal'}
    }
  })

  core.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
      {'jumpdrive:engine', 'default:steelblock', 'jumpdrive:engine'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'jumpdrive:engine', 'default:steelblock', 'jumpdrive:engine'}
    }
  })
end
