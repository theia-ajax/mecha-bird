Vector = require 'hump.vector'
Timer = require 'hump.timer'
Camera = require 'hump.camera'
Console = require 'console.console'
require 'game'
require 'bird'
require 'tile'
require 'level'
require 'util'
require 'physics'
require 'input'
require 'hud'

function love.load()
    game = Game("MechaBird", "0.1.0")
    game:initialize()

    Timer.addPeriodic(1, function()
        game.fps = game.frames
        game.frames = 0
    end)
end

function love.keypressed(key, unicode)
    if key == "escape" then
        love.event.quit()
    end

    if key == "r" then
        game.level:cleanup()
        game.level:load(game.levelName)
    end

    if key == "b" then
        game.bird:reset()
    end

    if key == '`' then
        game.console:focus()
        game.input:disable()
    end

    game.input:key_pressed(key)
end

function love.keyreleased(key)
    game.input:key_released(key)
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:render()
    
end
