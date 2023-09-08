local has_technic = minetest.get_modpath("technic")

local inv_offset = 0
if has_technic then
	inv_offset = 1.25
end

local inv_width = 8

local mcl_fs = ""
local player_inv_fs = "list[current_player;main;0,".. 4.5+inv_offset .. ";8,4;]"

if minetest.get_modpath("mcl_formspec") then
   inv_width = 9
   mcl_fs = mcl_formspec.get_itemslot_bg(0,3.25,8,1)
   player_inv_fs = ""..
      "list[current_player;main;0,4.4;9,3;9]"..
      mcl_formspec.get_itemslot_bg(0,4.4,9,3)..
      "list[current_player;main;0,7.64;9,1;]"..
      mcl_formspec.get_itemslot_bg(0,7.64,9,1)
   if has_technic then
      mcl_fs = mcl_fs..
	 mcl_formspec.get_itemslot_bg(4,4.5,4,1)
   end
end

jumpdrive.update_formspec = function(meta)
	local formspec =
		"size["..inv_width.."," .. 9.3+inv_offset .. ";]" ..

		"field[0.3,0.5;2,1;x;X;" .. meta:get_int("x") .. "]" ..
		"field[2.3,0.5;2,1;y;Y;" .. meta:get_int("y") .. "]" ..
		"field[4.3,0.5;2,1;z;Z;" .. meta:get_int("z") .. "]" ..
		"field[6.3,0.5;2,1;radius;Radius;" .. meta:get_int("radius") .. "]" ..

		"button_exit[0,1;2,1;jump;Jump]" ..
		"button_exit[2,1;2,1;show;Show]" ..
		"button_exit[4,1;2,1;save;Save]" ..
		"button[6,1;2,1;reset;Reset]" ..

		"button[0,2;4,1;write_book;Write to book]" ..
		"button[4,2;4,1;read_book;Read from bookmark]" ..

		-- main inventory for fuel and books
		"list[context;main;0,3.25;8,1;]" ..

		-- player inventory
		player_inv_fs..

		-- digiline channel
		"field[4.3," .. 9.02+inv_offset ..";3.2,1;digiline_channel;Digiline channel;" ..
		(meta:get_string("channel") or "") .. "]" ..
		"button_exit[7," .. 8.7+inv_offset .. ";1,1;set_digiline_channel;Set]" ..

		-- listring stuff
		"listring[context;main]" ..
	        "listring[current_player;main]"..

	        -- mcl
	        mcl_fs

	if has_technic then
		formspec = formspec ..
			-- technic upgrades
			"label[3,4.7;Upgrades]" ..
			"list[context;upgrade;4,4.5;4,1;]"
	end

	meta:set_string("formspec", formspec)
end

