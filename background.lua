Vector = require 'hump.vector'
Class = require 'hump.class'
Timer = require 'hump.timer'
require 'util'
require 'sprite'

Background = Class {
	name = "Background",
	function(self)
		self.dayHours = 24
		self.time = 10
		self.timeScale = 2400
		self.kSecondsToHours = 1 / 3600

		self.skyboxGradientFile = "assets/daynight.png"
		self.skyboxGradient = love.graphics.newImage(self.skyboxGradientFile)
		self.skyWidth, self.skyHeight = self.skyboxGradient:getDimensions()
		self.skyboxQuad = love.graphics.newQuad(0, 0,
												1, self.skyHeight,
												self.skyWidth, self.skyHeight)
		self.skyboxHeightScale = game.screen.height / self.skyHeight
		self.skyboxDelay = 2

		self.colorMultFile = 'assets/daynightcolors.png'
		self.colorMultImage = love.graphics.newImage(self.colorMultFile)
		self.colorMultData = self.colorMultImage:getData()

		self.timeColors = {}
		for i = 0, self.colorMultData:getWidth() - 1 do
			local r, g, b = self.colorMultData:getPixel(i, 0)
			table.insert(self.timeColors, {r = r, g = g, b = b})
		end

		self.bgLayers = {}
		self:add_background_layer("assets/mountain.png", 8, 450)
		self:add_background_layer("assets/tree.png", 2, 400)
		
		self.multiplyColor = {
			r = 255,
			g = 255,
			b = 255
		}
	end
}

function Background:add_background_layer(file, ratio, anchor)
	table.insert(self.bgLayers, BackgroundLayer(file, ratio, anchor))
end

function Background:update(dt)
	self.time = self.time + dt * self.timeScale * self.kSecondsToHours

	while self.time >= self.dayHours do self.time = self.time - self.dayHours end
	while self.time < 0 do self.time = self.time + 24 end

	self:update_skybox()
	self:update_multiply_color()

	self:update_bg_layers(game.bird.position.x)
end

function Background:update_skybox()
	local timeRatio = self.time / self.dayHours
	local position = math.floor(timeRatio * self.skyWidth)

	self.skyboxQuad:setViewport(position, 0,
								1, self.skyHeight)
end

function Background:update_multiply_color()
	local timeRatio = self.time / self.dayHours
	local position = math.floor(timeRatio * #self.timeColors) + 1

	self.multiplyColor = self.timeColors[position]
end

function Background:update_bg_layers(position)
	for _, bg in ipairs(self.bgLayers) do
		bg:set_horizontal_position(position)
	end
end

function Background:render()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.skyboxGradient,
					   self.skyboxQuad,
					   0, 0,
					   0,
					   game.screen.width, self.skyboxHeightScale)

	self:render_bg_layers()
end

function Background:render_bg_layers()
	local r, g, b = self.multiplyColor.r,
					self.multiplyColor.g,
					self.multiplyColor.b

	for _, bg in ipairs(self.bgLayers) do
		bg:render(r, g, b)
	end
end

BackgroundLayer = Class {
	name = "BackgroundLayer",
	function(self, file, moveRatio, verticalAnchor)
		self.file = file
		self.moveRatio = moveRatio or 1
		self.verticalAnchor = verticalAnchor or 0

		self.image = love.graphics.newImage(self.file)
		self.image:setWrap("repeat", "repeat")

		self.width, self.height = self.image:getDimensions()
		self.quad = love.graphics.newQuad(0, 0,
										  game.screen.width,
										  self.height,
										  self.width,
										  self.height)
	end
}

function BackgroundLayer:set_horizontal_position(x)
	local sx = x / self.moveRatio

	self.quad:setViewport(sx, 0, game.screen.width, self.height)
end

function BackgroundLayer:render(r, g, b)
	r = r or 255
	g = g or 255
	b = b or 255

	love.graphics.setColor(r, g, b)
	love.graphics.draw(self.image, self.quad, 0, self.verticalAnchor)
end