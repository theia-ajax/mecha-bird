Class = require 'hump.class'
Vector = require 'hump.vector'
Camera = require 'hump.camera'
require 'bird'
require 'tile'
require 'level'
require 'util'
require 'physics'
require 'input'
require 'hud'
require 'tornado'
require 'background'

Game = Class {
    name = "Game",
    function(self, name, version)
        self.name = name
        self.version = version

        self.screen = {}
        self.debug = {}

        self.console = nil
        self.camera = nil

        self.fps = 0
        self.frames = 0
        self.collChecks = 0
        self.dt = 0

        self.currentId = 1
    end
}

function Game:initialize()
    self.screen.width = 1280
    self.screen.height = 720

    self.screen.windowWidth = love.graphics.getWidth()
    self.screen.windowHeight = love.graphics.getHeight()

    self.screen.scale = self.screen.windowWidth / self.screen.width

    consoleFont = love.graphics.newFont("assets/fonts/VeraMono.ttf", 12)
    self.console = Console.new(consoleFont,
                               self.screen.windowWidth,
                               200,
                               4,
                           function() self.input:enable() end)

    self.console.commands = {
        quit = quit,
        exit = exit,
    }
    console_print_intro(self.name, self.version)

    love.math.setRandomSeed(love.timer.getTime())

    self.debug.physics = false
    self.debug.bird = false

    self.camera = Camera(400, 300)

    self.physics = Physics(50000, 1000, 500, 500)

    self.entities = {}
    self.entities.lock = false

    self.levelName = "assets/levels/testlevel.txt"
    self.level = Level()
    self.level:load(self.levelName)

    local bird = Bird(1)
    add_entity(bird)
    self.bird = bird

    self.hud = Hud(bird)
    
    local tornadoCount = 0
    for i = 1, tornadoCount do
        local tornado = Tornado()
        tornado.position.x = i * 128
        tornado.position.y = love.math.random() * game.screen.height
        t = add_entity(tornado)
    end

    self.reset = function()
        bird:reset()
        self.level:reset()
        local look_x = self.bird.position.x + (self.screen.width / 2 - 50)
        local look_y = self.screen.height / 2
        self.camera:lookAt(look_x * self.screen.scale, look_y * self.screen.scale)
    end

    self.physics:update_colliders(true)

    self.input = Input()
    self.input:add_button("jump", "z", "lctrl", "lgui", " ")

    self.background = Background()
end

function Game:update(dt)
    self.dt = dt

    self.background:update(dt)

    for i, v in ipairs(self.entities) do
        v:update(dt)
    end

    -- self.level:update(dt)

    flush_dirty_entities()
    
    -- local look = self.player:get_component("CPositionable").position
    -- self.camera:lookAt(math.floor(look.x), math.floor(look.y))
    local look_x = self.bird.position.x + (self.screen.width / 2 - 50)
    local look_y = math.min(self.screen.height / 2, self.bird.position.y + (self.screen.height / 4))
    self.camera:lookAt(look_x * self.screen.scale, look_y * self.screen.scale)
    
    self.console:update(dt)
    Timer.update(dt)

    self.physics:update_collisions()

    self.input:update()
end

function Game:render()
    self.background:render()

    self.camera:attach()

    -- self.level:render()

    for i, v in ipairs(self.entities) do
        if v ~= nil then
            v:render()
        end
    end

    if self.debug.physics then
        self.physics:debug_draw()
    end

    self.camera:detach()

    self.hud:render()

    love.graphics.setColor(0, 0, 0, 127)
    love.graphics.rectangle("fill", 2, 2, 150, 60)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS : "..string.format("%.0f", self.fps), 5, 5)
    love.graphics.print("Collision Checks: "..string.format("%.0f", self.collChecks), 5, 25)
    love.graphics.print("Time of Day: "..game.background:time_string(), 5, 45)

    self.console:draw()

    self.frames = self.frames + 1
end

