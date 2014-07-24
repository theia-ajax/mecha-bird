Class = require 'hump.class'
Vector = require 'hump.vector'

Entity = Class
{
	name = "Entity",
	inherits = {},
	function(self, id)
		self.id = id or 0
		self.position = Vector.zero()
		self.rotation = 0
		self.scale = Vector.one()
	end
}

function Entity:update(dt)
end

function Entity:render()
end