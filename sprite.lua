Vector = require 'hump.vector'
Class = require 'hump.class'
require 'entity'

Sprite = Class
{
    name = "Sprite",
    inherits = {},
    function(self, image, entity, srcRect)
        self.entity = entity
        self.attachToEntity = false

        if self.entity ~= nil then
            self.attachToEntity = true
        end

        self.position = Vector.zero()
        self.rotation = 0
        self.scale = Vector.one()

        self.image = image
        assert(self.image ~= nil, "Cannot create sprite with nil image.")

        local iw, ih = self.image:getDimensions()

        self.quad = love.graphics.newQuad(0, 0, iw, ih, iw, ih)

        self.source = { x = 0, y = 0, w = iw, h = ih }
        self:set_source(srcRect)
    end
}

function Sprite:set_source(srcRect)
    if srcRect == nil then return end

    self.source.x = srcRect.x
    self.source.y = srcRect.y
    self.source.w = srcRect.w
    self.source.h = srcRect.h
        
    self.quad:setViewport(self.source.x, self.source.y,
                          self.source.w, self.source.h)
end

function Sprite:get_width()
    return self.source.w
end

function Sprite:get_height()
    return self.source.h
end

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
    love.graphics.draw(self.image, self.quad, px, py, rot, sx, sy, ox, oy)
end