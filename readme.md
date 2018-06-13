Minetest jumpdrive
======

A simple [Jumpdrive](https://en.wikipedia.org/wiki/Jump_drive) for minetest

Take your buildings with you on your journey

* Github: [https://github.com/thomasrudin-mt/jumpdrive](https://github.com/thomasrudin-mt/jumpdrive)
* Forum topic: [https://forum.minetest.net/viewtopic.php?f=9&t=20073](https://forum.minetest.net/viewtopic.php?f=9&t=20073)

# Operation

* Place a 'jumpdrive:engine' into the center of your creation.
* Insert mese crystals as fuel for the jumps (optionally: connect to technic:hv network)
* Choose your target coordinates (should be air or ignore blocks)
* Select your cube-radius (from 1 to 19 blocks)
* Click "show" and check the green (source) and red (target) destination markers if everything is in range
* Click "jump"

# Compatibility

Optional dependencies:
* Mesecon interaction (execute jump on signal)
* Technic rechargeable (HV)
* Travelnet box (gets rewired after jump)
* Elevator (on_place gets called after jump)
* Locator (gets removed and added after each jump)

# Fuel

The engine accepts mese crystals (configurable in init.lua) or connects to a technic hv network, if enabled.
A crystal equals 1000 power units / EU

The fuel formula looks like this: **10 x radius x distance**

For example:
* Distance: 100 blocks
* Radius: 5 blocks
* Required energy: 10 x 5 x 100 = 5000 / 5 mese crystals

# Protection

The source and destination areas are checked for protection so you can't remove and jump into someone else's buildings.
There are currently no checks for plain populated areas (normal terrain) so you can jump happily into the mountains and make swiss cheese :)
A possible solution against this would be a global height or area restriction (see Preflight check).

# Crafting

Without technic mod:

![](screenshots/recipe.png?raw=true)

With technic mod:

![](screenshots/recipe_technic.png?raw=true)


# Screenshot

Interface:

![](screenshots/screenshot_20180507_200309.png?raw=true)

Example:

![](screenshots/screenshot_20180507_200203.png?raw=true)

# Advanced operation

## Coordinate bookmarking

You can place empty books into the drive inventory and write the coordinates to it with the "Write to book" button
The "Read from book" reads the coordinates from the next book in the inventory

# Settings

Settings in minetest.conf:

* **jumpdrive.maxradius** max radius of the jumpdrive (default: *20*)
* **jumpdrive.power_item_name** item that powers the drive (default: *default:mese_crystal*)
* **jumpdrive.power_item_value** power value of the item (default: *1000*)

Technic-relevant settings:

* **jumpdrive.powerstorage** power storage of the drive (default: *100000*)
* **jumpdrive.power_requirement** power requirement for chargin (default: *2500*)

# Lua api

## Preflight check

The preflight check can be overriden to execute additional checks:

```lua
jumpdrive.preflight_check = function(source, destination, radius, player)
	-- check for height limit, only space travel allowed
	if destination.y < 1000 then
		return { success=false, message="Atmospheric travel not allowed!" }
	end

	-- everything ok
	return { success=true }
end
```

# History

## Next

* preflight check with custom override
* Settings in mintest.conf
* vacuum compatibility (jump into vacuum with air filled vessel)

## 1.1

* improved performance
* Documentation
* Removed complicated cascade function

## 1.0

* Initial version
* Cascade operation (with issues)





