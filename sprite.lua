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

function Sprite:render(r, g, b)
    local px = self.position.x * game.screen.scale
    local py = self.position.y * game.screen.scale

    local rot = self.rotation

    local sx = self.scale.x * game.screen.scale
    local sy = self.scale.y * game.screen.scale

    -- TODO later
    local ox = 0
    local oy = 0

    r = r or 255
    g = g or 255
    b = b or 255

    love.graphics.setColor(r, g, b)
    love.graphics.draw(self.image, px, py, rot, sx, sy, ox, oy)
end