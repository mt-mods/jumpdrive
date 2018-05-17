Minetest jumpdrive
======

A simple [Jumpdrive](https://en.wikipedia.org/wiki/Jump_drive) for minetest
Convert your buildings to working spacecrafts and jump them around the map

* Github: [https://github.com/thomasrudin-mt/jumpdrive](https://github.com/thomasrudin-mt/jumpdrive)
* Forum topic: [https://forum.minetest.net/viewtopic.php?f=9&t=20073](https://forum.minetest.net/viewtopic.php?f=9&t=20073)

# Operation

* Place a 'jumpdrive:engine' into the center of your creation.
* Insert mese crystals as fuel for the jumps
* Choose your target coordinates (should be air or ignore blocks)
* Select your cube-radius (from 1 to 19 blocks)
* Set Cascade button to "ON" (Workaround for now)
* Click "show" and check the green (source) and red (target) destination markers if everything is in range
* Click "jump"

# Compatibility

* Mesecon interaction (execute jump)
* Technic rechargeable (HV)
* Travelnet box (gets rewired after jump)
* Elevator (on_place gets called after jump)


# Screenshot

![](screenshots/screenshot_20180507_200309.png?raw=true)

# Advanced operation

* Place multiple engines in the radius of each other and enable the cascade mode
* Execute jump and it will execute all engines relative to each other to the target
* Write and read coordinates to books

# TODO

* Fix "Cascade" mode
* Performance (for-iterations)
* Dead objects after jumps

