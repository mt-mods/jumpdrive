
local has_travelnet_mod = minetest.get_modpath("travelnet")
local has_technic_mod = minetest.get_modpath("technic")
local has_elevator_mod = minetest.get_modpath("elevator")


minetest.register_node("jumpdrive:engine", {
	description = "Jumpdrive",
	tiles = {"jumpdrive.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3,technic_machine = 1, technic_hv = 1},
	drop = "jumpdrive:engine",
	sounds = default.node_sound_glass_defaults(),

	mesecons = {effector = {
		action_on = function (pos, node)
			jumpdrive.execute_jump(pos)
		end
	}},

	connects_to = {"group:technic_hv_cable"},
	connect_sides = {"bottom", "top", "left", "right", "front", "back"},

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("x", pos.x)
		meta:set_int("y", pos.y)
		meta:set_int("z", pos.z)
		meta:set_int("xplus", 5)
		meta:set_int("yplus", 5)
		meta:set_int("zplus", 5)
		meta:set_int("xminus", 5)
		meta:set_int("yminus", 5)
		meta:set_int("zminus", 5)
		meta:set_int("powerstorage", 0)

		local inv = meta:get_inventory()
		inv:set_size("main", 8)

		if has_technic_mod then
			meta:set_int("HV_EU_input", 0)
			meta:set_int("HV_EU_demand", 0)
		end

		jumpdrive.update_formspec(meta)
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
			meta:set_int("powerstorage", store)
		else
			-- charged
			meta:set_int("HV_EU_demand", 0)
		end
	end,

	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		-- TODO: check owner

		local meta = minetest.get_meta(pos);

		if fields.read_book then
			jumpdrive.read_from_book(pos)
			return
		end

		if fields.reset then
			jumpdrive.reset_coordinates(pos)
			return
		end

		if fields.write_book then
			jumpdrive.write_to_book(pos, sender)
			return
		end

		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);

		local xplus = tonumber(fields.xplus);
		local yplus = tonumber(fields.yplus);
		local zplus = tonumber(fields.zplus);
		local xminus = tonumber(fields.xminus);
		local yminus = tonumber(fields.yminus);
		local zminus = tonumber(fields.zminus);

		if x == nil or y == nil or z == nil then
			return
		end

		if xplus == nil or yplus == nil or zplus == nil or xminus == nil or yminus == nil or zminus == nil then
			return
		end

		if xplus < 0 or xminus < 0 or yplus < 0 or yminus < 0 or zplus < 0 or zminus < 0 then
			minetest.chat_send_player(sender:get_player_name(), "negative offsets not allowed!")
			return
		end

		local max_blocks = jumpdrive.config.max_blocks

		local blocks = (xplus + xminus + 1) * (yplus + yminus + 1) * (zplus + zminus + 1)

		if blocks > max_blocks then
			minetest.chat_send_player(sender:get_player_name(), "Invalid jump: max-blocks=" .. max_blocks .. ", you got: " .. blocks)
			return
		end

		-- update coords
		meta:set_int("x", x)
		meta:set_int("y", y)
		meta:set_int("z", z)
		meta:set_int("xplus", xplus)
		meta:set_int("yplus", yplus)
		meta:set_int("zplus", zplus)
		meta:set_int("xminus", xminus)
		meta:set_int("yminus", yminus)
		meta:set_int("zminus", zminus)
		jumpdrive.update_formspec(meta)

		if fields.jump then
			local start = os.clock()
			local success = jumpdrive.execute_jump(pos, sender)

			local diff = os.clock() - start

			if success then
				minetest.chat_send_player(sender:get_player_name(), "Jump executed in " .. diff .. " s")
			end
		end

		if fields.show then
			jumpdrive.simulate_jump(pos)
		end
		
	end
})

if has_technic_mod then
	technic.register_machine("HV", "jumpdrive:engine", technic.receiver)
end

local engine_craft_side = "default:diamond"
local engine_craft_center = "default:mese_block"
local engine_craft_bottom = "default:mese_crystal"
local engine_craft_top = "default:mese_crystal_fragment"

if has_technic_mod then
	-- technic enabled recipe
	engine_craft_center = "technic:blue_energy_crystal"
	engine_craft_top = "technic:hv_transformer"
	engine_craft_bottom = "technic:machine_casing"
end


minetest.register_craft({
	output = 'jumpdrive:engine',
	recipe = {
		{'', engine_craft_top, ''},
		{engine_craft_side, engine_craft_center, engine_craft_side},
		{'', engine_craft_bottom, ''}
	}
})


