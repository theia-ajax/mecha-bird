Vector = require 'hump.vector'
Timer = require 'hump.timer'
Camera = require 'hump.camera'
Console = require 'console.console'
require 'bird'
require 'tile'
require 'level'
require 'util'
require 'physics'
require 'input'

function love.load()
    game = {}

    game.name = "MechaBird"
    game.version = "0.1.0"

    game.screen = {}
    game.screen.width = 640
    game.screen.height = 360

    game.screen.windowWidth = love.graphics.getWidth()
    game.screen.windowHeight = love.graphics.getHeight()

    game.screen.scale = game.screen.windowWidth / game.screen.width;

    consoleFont = love.graphics.newFont("assets/fonts/VeraMono.ttf", 12)
    game.console = Console.new(consoleFont,
                               game.screen.windowWidth,
                               200,
                               4,
                               function() game.input:enable() end)
    game.console.commands = { 
        quit = quit,
        exit = exit,
    }
    console_print_intro(game.name, game.version)

    game.debug = {}
    game.debug.physics = false
    game.debug.bird = false
    
    game.fps = 0
    game.dt = 0

    game.currentId = 1

    game.camera = Camera(400, 300)

    game.physics = Physics(10000, 500, 500, 250)

    game.entities = {}
    game.entities.lock = false

    game.levelName = "assets/levels/testlevel.csv"
    game.level = Level()
    game.level:load(game.levelName)

    local bird = Bird(1)
    add_entity(bird)
    game.bird = bird
    
    game.reset = function()
        bird:reset()
        game.level:reset()
        local look_x = game.bird.position.x + (game.screen.width / 2 - 50)
        local look_y = game.screen.height / 2
        game.camera:lookAt(look_x * game.screen.scale, look_y * game.screen.scale)
    end

    Timer.addPeriodic(0.05, function() game.fps = 1 / game.dt end)

    game.physics:update_colliders(true)

    game.input = Input()
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
    game.dt = dt

    for i, v in ipairs(game.entities) do
        v:update(dt)
    end

    game.level:update(dt)

    flush_dirty_entities()
    
    -- local look = game.player:get_component("CPositionable").position
    -- game.camera:lookAt(math.floor(look.x), math.floor(look.y))
    local look_x = game.bird.position.x + (game.screen.width / 2 - 50)
    local look_y = game.screen.height / 2
    game.camera:lookAt(look_x * game.screen.scale, look_y * game.screen.scale)
    
    game.console:update(dt)
    Timer.update(dt)

    game.physics:update_collisions()

    game.input:update()
end

function love.draw()
    game.camera:attach()

    game.level:render()

    for i, v in ipairs(game.entities) do
        if v ~= nil then
            v:render()
        end
    end

    if game.debug.physics then
        game.physics:debug_draw()
    end

    game.camera:detach()

    love.graphics.setColor(0, 0, 0, 127)
    love.graphics.rectangle("fill", 2, 2, 70, 20)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS : "..string.format("%.0f", game.fps), 5, 5)

    game.console:draw()
end
