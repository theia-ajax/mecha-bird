Vector = require 'hump.vector'
Timer = require 'hump.timer'
Camera = require 'hump.camera'
require 'bird'
require 'tile'

function love.load()
	globals = {}

	globals.fps = 0
	globals.dt = 0

	globals.camera = Camera(400, 300)

	pxToMeter = 128
	love.physics.setMeter(pxToMeter)
	globals.world = love.physics.newWorld(0, 9.8 * pxToMeter, true)

	globals.entities = {}

	local bird = Bird(1)
	table.insert(globals.entities, bird)

	globals.furthestTile = nil
	for i = 1, 20 do
		local tile = Tile(i + 100, "assets/groundtop.png")
		tile.position.x = (i - 1) * 64
		tile.position.y = 600 - 64
		table.insert(globals.entities, tile)

		if globals.furthestTile == nil or tile.position.x > globals.furthestTile.position.x then
			globals.furthestTile = tile
		end
	end
	
	Timer.addPeriodic(0.05, function() globals.fps = 1 / globals.dt end)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push('quit')
	end
end

function love.update(dt)
	globals.dt = dt

	globals.camera:move(200 * dt, 0)

	for k, v in pairs(globals.entities) do
		v:update(dt)
	end

	globals.world:update(dt)
	
	-- local look = globals.player:get_component("CPositionable").position
	-- globals.camera:lookAt(math.floor(look.x), math.floor(look.y))
	
	Timer.update(dt)
end

function love.draw()
	globals.camera:attach()

	for k, v in pairs(globals.entities) do
		v:render()
	end

	globals.camera:detach()

	love.graphics.print("FPS : "..string.format("%.0f", globals.fps), 5, 5)
end