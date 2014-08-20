Vector = require 'hump.vector'
Class = require 'hump.class'
require 'entity'
require 'sprite'
require 'physics'

Bird = Class
{
    name = "Bird",
    inherits = { Entity },
    function(self)
        Entity.construct(self)

        self.sprite = Sprite("assets/bird.png", self)

        self.speed = 400
        self.jumpPower = 1000
        self.gravity = 2000
        self.glideFall = 100
        self.maxJumps = 1

        self.maxGlidePower = 100
        self.glideRecoverRate = 20
        self.glideDecayRate = 40
        
        self:reset()

        self.killY = game.screen.height + 128

        self.collider = BoundingBox(self, 64, 64, Vector(32, 32))
        
        self.tag = "bird"
    end
}

function Bird:reset()
    self.velocity = Vector.new(self.speed, 0)
    
    self.position.x = 50 * game.screen.scale
    self.position.y = game.level:ground_height(self.position.x) - self.sprite.height * game.screen.scale
    
    self.onGround = false

    self.jumpCount = 0

    self.fallMode = "free"
    self.glidePower = self.maxGlidePower

    self.sprite:update()
end

function Bird:on_create()
    game.physics:register(self.collider)
    self.collider:set_layer(game.physics, "player")
end

function Bird:update(dt)
    if game.debug.bird then
        local left = love.keyboard.isDown("left")
        local right = love.keyboard.isDown("right")
        local up = love.keyboard.isDown("up")
        local down = love.keyboard.isDown("down")

        self.velocity.x = 0
        self.velocity.y = 0

        if left then self.velocity.x = self.velocity.x - 200 end
        if right then self.velocity.x = self.velocity.x + 200 end
        if up then self.velocity.y = self.velocity.y - 200 end
        if down then self.velocity.y = self.velocity.y + 200 end
    end

    if game.input:button_down("jump") and self.jumpCount < self.maxJumps then
        self.onGround = false
        self.velocity.y = -self.jumpPower
        self.jumpCount = self.jumpCount + 1
    end

    if game.input:button("jump") then
        if self.glidePower > 0 then
            self.fallMode = "glide"
        else
            self.fallMode = "free"
        end
    else
        self.fallMode = "free"
        self.glidePower = self.glidePower + self.glideRecoverRate * dt
        if self.glidePower > self.maxGlidePower then
            self.glidePower = self.maxGlidePower
        end
    end

    local gravity = self.gravity
    if game.debug.bird then gravity = 0 end
    self.velocity.y = self.velocity.y + gravity * dt
    
    if self.fallMode == "glide" then
        if self.velocity.y > self.glideFall then
            self.velocity.y = self.glideFall
            self.glidePower = self.glidePower - self.glideDecayRate * dt
            if self.glidePower < 0 then self.glidePower = 0 end
        else
            self.glidePower = self.glidePower + self.glideRecoverRate * dt
            if self.glidePower > self.maxGlidePower then
                self.glidePower = self.maxGlidePower
            end
        end
    end

    if self.onGround then
        self.velocity.y = 0
        self.jumpCount = 0
    end

    local vel = self.velocity * dt
    self.position = self.position + vel

    if self.position.y > self.killY then
        game:reset()
    end

    self.sprite:update()
end    

function Bird:on_collision_enter(other)
    if game.debug.bird then return end

    if other.anchor.tag == "ground" then
        local threshold = other:top() +
                          (8 * game.screen.scale)

        if self.collider:bottom() > threshold then
            game:reset()
        else
            self:snap_to_ground(other)
        end
    elseif other.anchor.tag == "lava" then
        game:reset()
    elseif other.anchor.tag == "tornado" then
        self.velocity.y = -other.anchor.liftPower
        self.glidePower = self.glidePower + 25
    end
end

function Bird:on_collision_exit(other)
    if not self.collider:is_colliding() then
        self.onGround = false
    end
end

function Bird:snap_to_ground(ground)
    self.position.y = ground.anchor.position.y - 64
    self.onGround = true
    self.sprite:update()
end

function Bird:render()
    self.sprite:render()
end