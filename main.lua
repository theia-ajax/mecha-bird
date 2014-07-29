Vector = require 'hump.vector'
Timer = require 'hump.timer'
Camera = require 'hump.camera'
Console = require 'console.console'
require 'bird'
require 'tile'
require 'level'
require 'util'
require 'physics'

function love.load()
    game = {}

    game.name = "MechaBird"
    game.version = "0.1.0"

    game.screen = {}
    game.screen.width = love.graphics.getWidth()
    game.screen.height = love.graphics.getHeight()

    consoleFont = love.graphics.newFont("assets/fonts/VeraMono.ttf", 12)
    game.console = Console.new(consoleFont,
                               game.screen.width,
                               200,
                               4,
                               console_disabled)
    console_print_intro(game.name, game.version)

    game.debug = true
    
    game.fps = 0
    game.dt = 0

    game.currentId = 1

    game.camera = Camera(400, 300)

    game.physics = Physics()

    game.entities = {}
    game.entities.lock = false

    local bird = Bird(1)
    add_entity(bird)
    game.bird = bird

    game.levelName = "assets/levels/testlevel.csv"
    game.level = Level()
    game.level:load(game.levelName)
    
    Timer.addPeriodic(0.05, function() game.fps = 1 / game.dt end)
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
    end
end

function love.update(dt)
    game.dt = dt

    for i, v in ipairs(game.entities) do
        v:update(dt)
    end

    flush_dirty_entities()

    game.world:update(dt)
    
    -- local look = game.player:get_component("CPositionable").position
    -- game.camera:lookAt(math.floor(look.x), math.floor(look.y))
    game.camera:lookAt(game.bird.position.x + 350,
                          300)
    
    game.console:update(dt)
    Timer.update(dt)

    game.physics:update_collisions()
end

function love.draw()
    game.camera:attach()

    for i, v in ipairs(game.entities) do
        if v ~= nil then
            v:render()
        end
    end

    if game.debug then
        game.physics:debug_draw()
    end

    game.camera:detach()

    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS : "..string.format("%.0f", game.fps), 5, 5)

    game.console:draw()
end
