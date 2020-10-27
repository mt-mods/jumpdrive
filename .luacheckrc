unused_args = false
allow_defined_top = true

ignore = {"512"}

globals = {
	"jumpdrive",

	-- write
	"travelnet",
	"pipeworks",
	"beds",
	"technic"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},
	"VoxelManip",

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump", "VoxelArea",

	-- Deps
	"unified_inventory", "default", "monitoring",
	"digilines",
	"mesecons",
	"mesecon",
	"locator",
	"display_api",
	"areas",
	"ropes",
	"sethome",
	"drawers",
	"player_monoids"
}
