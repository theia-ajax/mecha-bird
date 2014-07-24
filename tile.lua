Class = require 'hump.class'
Vector = require 'hump.vector'
require 'entity'
require 'sprite'

Tile = Class
{
	name = "tile",
	inherits = { Entity },
	function(self, id, filename)
		Entity.construct(self)

		self.sprite = Sprite(filename, self)

		self.width = self.sprite.width
		self.height = self.sprite.height

		self.wrap = false
	end
}

function Tile:update(dt)
	self.sprite:update()

	if self.wrap then
		if self.position.x <= globals.camera.x - 470 then
			self.position.x = furthestTile.position.x + 70
			furthestTile = self
		end
	end
end

function Tile:render()
	self.sprite:render()
end