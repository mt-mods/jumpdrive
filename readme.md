Minetest jumpdrive
======

A simple (Jumpdrive)[https://en.wikipedia.org/wiki/Jump_drive] for minetest
Convert your buildings to working spacecrafts and jump them around the map

# Operation

* Place a 'jumpdrive:engine' into the center of your creation.
* Insert mese crystals as fuel for the jumps
* Choose your target coordinates (should be air or ignore blocks)
* Select your cube-radius (from 1 to 19 blocks)
* Set Cascade button to "ON" (Workaround for now)
* Click "jump"

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

