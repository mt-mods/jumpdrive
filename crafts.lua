
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
      {'default:mese_block', 'default:steelblock', 'default:mese_block'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'default:mese_block', 'default:steelblock', 'default:mese_block'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'technic:composite_plate', 'technic:wrought_iron_dust', 'technic:composite_plate'},
      {'default:mese_block', 'technic:machine_casing', 'default:mese_block'},
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
      {'default:mese_block', 'default:steelblock', 'default:mese_block'},
      {'default:steelblock', 'default:steelblock', 'default:steelblock'},
      {'default:mese_block', 'default:steelblock', 'default:mese_block'}
    }
  })

  minetest.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
      {'technic:composite_plate', 'technic:wrought_iron_dust', 'technic:composite_plate'},
      {'default:mese_block', 'technic:machine_casing', 'default:mese_block'},
      {'technic:copper_coil', 'technic:hv_cable', 'technic:copper_coil'}
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
