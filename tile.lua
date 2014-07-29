Class = require 'hump.class'
Vector = require 'hump.vector'
require 'entity'
require 'sprite'
require 'physics'

Tile = Class
{
    name = "tile",
    inherits = { Entity },
    function(self, filename)
        Entity.construct(self)

        self.sprite = Sprite(filename, self)

        self.width = self.sprite.width
        self.height = self.sprite.height

        self.wrap = false

        self.collider = BoundingBox(self, self.width, self.height, Vector(self.width / 2, self.height / 2))
        self.collider.static = true
        game.physics:register(self.collider)
    end
}

function Tile:update(dt)
    self.sprite:update()

    if self.wrap then
        if self.position.x <= game.camera.x - 470 then
            self.position.x = furthestTile.position.x + 70
            furthestTile = self
        end
    end
end

function Tile:render()
    self.sprite:render()
end

function Tile:on_cleanup()
    game.physics:unregister(self.collider)
end