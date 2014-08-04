Class = require 'hump.class'
Vector = require 'hump.vector'

Hud = Class {
	name = "Hud",
	function(self, bird)
		self.bird = bird
	end
}

function Hud:render()
	if self.bird == nil then
		return
	end

	self:draw_bar(5, game.screen.windowHeight - 30, 200, 25, self.bird.glidePower / self.bird.maxGlidePower)
end

function Hud:draw_bar(x, y, w, h, perc)
	love.graphics.setColor(0, 0, 0, 127)
	love.graphics.rectangle("fill", x, y, w, h)

	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", x, y, w, h)

	love.graphics.setColor(255, 255, 0)
	love.graphics.rectangle("fill", x + 2, y + 2, (w - 4) * perc, h - 4)
end