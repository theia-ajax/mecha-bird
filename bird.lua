Vector = require 'hump.vector'
Class = require 'hump.class'
require 'entity'
require 'sprite'
require 'physics'

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

		self.onGround = false
		self.killY = globals.screen.height + 128

		self.collider = BoundingBox(self, 64, 64, Vector(32, 32))
		globals.physics:register(self.collider)
	end
}

function Bird:reset()
	self.gravity = 1000
	self.velocity = Vector.new(200, 0)
	
	self.position.x = 32
	self.position.y = 300

	self.jumpPressed = false

	self.onGround = false
end

function Bird:update(dt)
	if globals.debug and false then
		local left = love.keyboard.isDown("left")
		local right = love.keyboard.isDown("right")

		if not left and not right then
			self.velocity.x = 0
		end
		if left and not right then
			self.velocity.x = -200
		end
		if not left and right then
			self.velocity.x = 200
		end

		globals.camera:move(self.velocity.x * dt, 0)
	end

	if not self.jumpPressed and love.keyboard.isDown("z") then
		self.jumpPressed = true
		self.onGround = false
		self.velocity.y = -500
	end

	if not love.keyboard.isDown("z") then
		self.jumpPressed = false
	end

	self.velocity.y = self.velocity.y + self.gravity * dt

	if self.onGround then
		self.velocity.y = 0
	end

	local vel = self.velocity * dt
	self.position = self.position + vel

	if self.position.y > self.killY then
		self:reset()
	end

	self.sprite:update()
end

function Bird:on_collision_enter(other)
	self.position.y = other.anchor.position.y - 64
	self.onGround = true
end

function Bird:on_collision_exit(other)
	if not self.collider:is_colliding() then
		self.onGround = false
	end
end

function Bird:render()
	self.sprite:render()
end