Vector = require 'hump.vector'
Class = require 'hump.class'
require 'entity'
require 'sprite'

Bird = Class
{
	name = "Bird",
	inherits = { Entity },
	function(self, id)
		Entity.construct(self)

		self.sprite = Sprite("assets/bird.png", self)

		self.gravity = 1000
		self.velocity = Vector.new(200, 0)
		
		self.position.x = 32
		self.position.y = 300

		self.jumpPressed = false

		self.floor = globals.screen.height - 134
	end
}

function Bird:update(dt)
	if not self.jumpPressed and love.keyboard.isDown("z") then
		self.jumpPressed = true
		self.velocity.y = -500
	end

	if not love.keyboard.isDown("z") then
		self.jumpPressed = false
	end

	self.velocity.y = self.velocity.y + self.gravity * dt

	local vel = self.velocity * dt
	self.position = self.position + vel

	if self.position.y > self.floor then
		self.velocity.y = 0
		self.position.y = self.floor
	end

	self.sprite:update()
end

function Bird:render()
	self.sprite:render()
end