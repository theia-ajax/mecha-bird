Vector = require 'hump.vector'
Class = require 'hump.class'
require 'entity'

Sprite = Class
{
	name = "Sprite",
	inherits = {},
	function(self, filename, entity)
		self.entity = entity
		self.attachToEntity = false

		if self.entity ~= nil then
			self.attachToEntity = true
		end

		self.position = Vector.zero()
		self.rotation = 0
		self.scale = Vector.one()

		self.image = love.graphics.newImage(filename)

		self.width = 0
		self.height = 0

		if self.image ~= nil then
			self.width = self.image:getWidth()
			self.height = self.image:getHeight()
		end
	end
}

function Sprite:update()
	if self.entity == nil or not self.attachToEntity then return end

	self.position.x = self.entity.position.x
	self.position.y = self.entity.position.y

	self.rotation = self.entity.rotation

	self.scale.x = self.entity.scale.x
	self.scale.y = self.entity.scale.y
end

function Sprite:render()
	local px = self.position.x
	local py = self.position.y

	local r = self.rotation

	local sx = self.scale.x
	local sy = self.scale.y

	-- TODO later
	local ox = 0
	local oy = 0

	love.graphics.draw(self.image, px, py, r, sx, sy, ox, oy)
end