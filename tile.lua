Class = require 'hump.class'
Vector = require 'hump.vector'
require 'entity'
require 'sprite'

Tile = Class
{
	name = "tile",
	inherits = { Entity },
	function(self, id, filename)
		Entity.construct(self, id)

		self.sprite = Sprite(filename, self)

		self.width = 64
		self.height = 64

		self.wrap = true
	end
}

function Tile:update(dt)
	self.sprite:update()

	if self.wrap then
		if self.position.x <= globals.camera.x - 464 then
			self.position.x = globals.furthestTile.position.x + 64
			globals.furthestTile = self
		end
	end
end

function Tile:render()
	self.sprite:render()
end