
minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",

	tiles = {"jumpdrive.png"},

	tube = {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("main", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			stack = stack:peek_item(1)

			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {bottom = 1}
	},

	connects_to = {"group:technic_hv_cable"},
	connect_sides = {"bottom", "top", "left", "right", "front", "back"},

	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3,tubedevice=1, tubedevice_receiver=1,technic_machine = 1, technic_hv = 1},

	sounds = default.node_sound_glass_defaults(),

	digiline = {
		receptor = {action = function() end},
		effector = {
			action = jumpdrive.digiline_effector
		},
	},

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("x", pos.x)
		meta:set_int("y", pos.y)
		meta:set_int("z", pos.z)
		meta:set_int("radius", 5)
		meta:set_int("powerstorage", 0)

		local inv = meta:get_inventory()
		inv:set_size("main", 8)

		meta:set_int("HV_EU_input", 0)
		meta:set_int("HV_EU_demand", 0)

		jumpdrive.update_formspec(meta, pos)
	end,

	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		local name = player:get_player_name()

		return inv:is_empty("main") and not minetest.is_protected(pos, name)
	end,

	technic_run = function(pos, node)
		local meta = minetest.get_meta(pos)
		local eu_input = meta:get_int("HV_EU_input")
		local demand = meta:get_int("HV_EU_demand")
		local store = meta:get_int("powerstorage")

		meta:set_string("infotext", "Power: " .. eu_input .. "/" .. demand .. " Store: " .. store)

		if store < jumpdrive.config.powerstorage then
			-- charge
			meta:set_int("HV_EU_demand", jumpdrive.config.powerrequirement)
			store = store + eu_input
			meta:set_int("powerstorage", math.min(store, jumpdrive.config.powerstorage))
		else
			-- charged
			meta:set_int("HV_EU_demand", 0)
		end
	end,

	on_receive_fields = function(pos, formname, fields, sender)

		local meta = minetest.get_meta(pos);

		if not sender then
			return
		end

		if minetest.is_protected(pos, sender:get_player_name()) then
			-- not allowed
			return
		end

		if fields.read_book then
			jumpdrive.read_from_book(pos)
			jumpdrive.update_formspec(meta, pos)
			return
		end

		if fields.reset then
			jumpdrive.reset_coordinates(pos)
			jumpdrive.update_formspec(meta, pos)
			return
		end

		if fields.write_book then
			jumpdrive.write_to_book(pos, sender)
			return
		end

		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);
		local radius = tonumber(fields.radius);

		if x == nil or y == nil or z == nil or radius == nil or radius < 1 then
			return
		end

		local max_radius = jumpdrive.config.max_radius

		if radius > max_radius then
			minetest.chat_send_player(sender:get_player_name(), "Invalid jump: max-radius=" .. max_radius)
			return
		end

		-- update coords
		meta:set_int("x", jumpdrive.sanitize_coord(x))
		meta:set_int("y", jumpdrive.sanitize_coord(y))
		meta:set_int("z", jumpdrive.sanitize_coord(z))
		meta:set_int("radius", radius)
		jumpdrive.update_formspec(meta, pos)

		if fields.jump then
			jumpdrive.execute_jump(pos, sender)
		end

		if fields.show then
			local success, msg = jumpdrive.simulate_jump(pos, sender, true)
			if not success then
				minetest.chat_send_player(sender:get_player_name(), msg)
				return
			end
			minetest.chat_send_player(sender:get_player_name(), "Simulation successful")
		end

	end,

	on_punch = function(pos, node, puncher)

		if minetest.is_protected(pos, puncher:get_player_name()) then
			return
		end

		local meta = minetest.get_meta(pos);
		local radius = meta:get_int("radius")

		jumpdrive.show_marker(pos, radius, "green")
	end
})

minetest.register_craft({
	output = 'jumpdrive:engine',
	recipe = {
		{'jumpdrive:backbone', 'default:steelblock', 'jumpdrive:backbone'},
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
		{'jumpdrive:backbone', 'default:steelblock', 'jumpdrive:backbone'}
	}
})

technic.register_machine("HV", "jumpdrive:engine", technic.receiver)
