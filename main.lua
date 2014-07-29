Vector = require 'hump.vector'
Timer = require 'hump.timer'
Camera = require 'hump.camera'
require 'bird'
require 'tile'
require 'level'
require 'util'
require 'physics'

function love.load()
	globals = {}

	globals.screen = {}
	globals.screen.width = love.graphics.getWidth()
	globals.screen.height = love.graphics.getHeight()

	globals.debug = true
	
	globals.fps = 0
	globals.dt = 0

	globals.currentId = 1

	globals.camera = Camera(400, 300)

	globals.physics = Physics()

	pxToMeter = 128
	love.physics.setMeter(pxToMeter)
	globals.world = love.physics.newWorld(0, 9.8 * pxToMeter, true)

	globals.entities = {}
	globals.entities.lock = false

	local bird = Bird(1)
	add_entity(bird)
	globals.bird = bird

	globals.levelName = "assets/levels/testlevel.csv"
    globals.level = Level()
    globals.level:load(globals.levelName)
	
	Timer.addPeriodic(0.05, function() globals.fps = 1 / globals.dt end)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push('quit')
	end

	if key == "r" then
		globals.level:cleanup()
		globals.level:load(globals.levelName)
	end

	if key == "b" then
		globals.bird:reset()
	end
end

function love.update(dt)
	globals.dt = dt

	for i, v in ipairs(globals.entities) do
		v:update(dt)
	end

	flush_dirty_entities()

	globals.world:update(dt)
	
	-- local look = globals.player:get_component("CPositionable").position
	-- globals.camera:lookAt(math.floor(look.x), math.floor(look.y))
	globals.camera:lookAt(globals.bird.position.x + 350,
						  300)
	
	Timer.update(dt)

	globals.physics:update_collisions()
end

function love.draw()
	globals.camera:attach()

	for i, v in ipairs(globals.entities) do
		if v ~= nil then
			v:render()
		end
	end

	if globals.debug then
		globals.physics:debug_draw()
	end

	globals.camera:detach()

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("FPS : "..string.format("%.0f", globals.fps), 5, 5)
end
