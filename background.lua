Vector = require 'hump.vector'
Class = require 'hump.class'
Timer = require 'hump.timer'
require 'util'
require 'sprite'

Background = Class {
	name = "Background",
	function(self)
		self.skyboxGradientFile = "assets/daynight.png"
		self.skyboxGradient = love.graphics.newImage(self.skyboxGradientFile)
		self.skyWidth, self.skyHeight = self.skyboxGradient:getDimensions()
		self.skyboxPosition = 50
		self.skyboxQuad = love.graphics.newQuad(self.skyboxPosition, 0,
												1, self.skyHeight,
												self.skyWidth, self.skyHeight)
		self.skyboxHeightScale = game.screen.height / self.skyHeight
		self.skyboxDelay = 2
		self.skyboxTick = Timer.addPeriodic(self.skyboxDelay,
											function() self:tick_skybox() end)
	end
}

function Background:tick_skybox()
	self.skyboxPosition = self.skyboxPosition + 1
	if self.skyboxPosition >= self.skyWidth then
		self.skyboxPosition = 0
	end

	self.skyboxQuad:setViewport(self.skyboxPosition, 0,
								1, self.skyHeight)
end


function Background:render()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.skyboxGradient,
					   self.skyboxQuad,
					   0, 0,
					   0,
					   game.screen.width, self.skyboxHeightScale)
end