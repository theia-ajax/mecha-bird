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

        self:reset()

        self.killY = game.screen.height + 128

        self.collider = BoundingBox(self, 32, 32, Vector(16, 16))
        game.physics:register(self.collider)

        self.tag = "bird"
    end
}

function Bird:reset()
    self.velocity = Vector.new(200, 0)
    
    self.position.x = 50 * game.screen.scale
    self.position.y = 0 * game.screen.scale

    self.jumpPressed = false

    self.onGround = false
end

function Bird:update(dt)
    if game.debug.bird then
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

        game.camera:move(self.velocity.x * dt, 0)
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
    if other.anchor.tag == "ground" then
        if self.position.y > other.anchor.position.y - other.anchor.sprite.height / 2 + (8 * game.screen.scale) then
            self:reset()
        else
            self.position.y = other.anchor.position.y - 32
            self.onGround = true
            self.sprite:update()
        end
    elseif other.anchor.tag == "lava" then
        self:reset()
    end
end

function Bird:on_collision_exit(other)
    if not self.collider:is_colliding() then
        self.onGround = false
    end
end

function Bird:render()
    self.sprite:render()
end