
jumpdrive.show_marker = function(pos, radius, color)
	-- TODO: mark whole outline
	local entity = "jumpdrive:marker_" .. color

	minetest.add_entity({x=pos.x+radius, y=pos.y+radius, z=pos.z+radius}, entity)
	minetest.add_entity({x=pos.x+radius, y=pos.y+radius, z=pos.z-radius}, entity)
	minetest.add_entity({x=pos.x+radius, y=pos.y-radius, z=pos.z+radius}, entity)
	minetest.add_entity({x=pos.x+radius, y=pos.y-radius, z=pos.z-radius}, entity)

	minetest.add_entity({x=pos.x-radius, y=pos.y+radius, z=pos.z+radius}, entity)
	minetest.add_entity({x=pos.x-radius, y=pos.y+radius, z=pos.z-radius}, entity)
	minetest.add_entity({x=pos.x-radius, y=pos.y-radius, z=pos.z+radius}, entity)
	minetest.add_entity({x=pos.x-radius, y=pos.y-radius, z=pos.z-radius}, entity)
end

local register_marker = function(color)
	local texture = "marker_" .. color .. ".png"

	minetest.register_entity("jumpdrive:marker_" .. color, {
		initial_properties = {
			visual = "cube",
			visual_size = {x=1.05, y=1.05},
			textures = {
				texture,
				texture,
				texture,
				texture,
				texture,
				texture
			},
			collisionbox = {-0.525, -0.525, -0.525, 0.525, 0.525, 0.525},
			physical = false,
		},

		on_activate = function(self, staticdata)
			minetest.after(8.0, 
				function(self) 
					self.object:remove()
				end,
				self)
		end,
	
		on_rightclick=function(self, clicker)
			self.object:remove()
		end,
	
		on_punch = function(self, hitter)
			self.object:remove()
		end,
	})
end

register_marker("red")
register_marker("green")
register_marker("blue")