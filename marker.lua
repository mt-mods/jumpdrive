
jumpdrive.show_marker = function(pos, radius)
	-- TODO: mark whole outline
	minetest.add_entity({x=pos.x+radius, y=pos.y+radius, z=pos.z+radius}, "jumpdrive:marker")
	minetest.add_entity({x=pos.x+radius, y=pos.y+radius, z=pos.z-radius}, "jumpdrive:marker")
	minetest.add_entity({x=pos.x+radius, y=pos.y-radius, z=pos.z+radius}, "jumpdrive:marker")
	minetest.add_entity({x=pos.x+radius, y=pos.y-radius, z=pos.z-radius}, "jumpdrive:marker")

	minetest.add_entity({x=pos.x-radius, y=pos.y+radius, z=pos.z+radius}, "jumpdrive:marker")
	minetest.add_entity({x=pos.x-radius, y=pos.y+radius, z=pos.z-radius}, "jumpdrive:marker")
	minetest.add_entity({x=pos.x-radius, y=pos.y-radius, z=pos.z+radius}, "jumpdrive:marker")
	minetest.add_entity({x=pos.x-radius, y=pos.y-radius, z=pos.z-radius}, "jumpdrive:marker")
end

minetest.register_entity("jumpdrive:marker", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.05, y=1.05},
		textures = {
			"jump_sim_display.png",
			"jump_sim_display.png",
			"jump_sim_display.png",
			"jump_sim_display.png",
			"jump_sim_display.png",
			"jump_sim_display.png"
		},
		collisionbox = {-0.525, -0.525, -0.525, 0.525, 0.525, 0.525},
		physical = false,
	},

	on_activate = function(self, staticdata)
		minetest.after(5.0, 
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
