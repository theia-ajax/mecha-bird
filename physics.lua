Class = require 'hump.class'
Vector = require 'hump.vector'

local min = math.min
local max = math.max

BoundingBox = Class {
	name = "BoundingBox",
	inherits = {},
	function(self, entity, w, h, offset)
		self.anchor = nil

		if entity ~= nil then
			self.anchor = entity
		end

		self.offset = offset or Vector(0, 0)
		self.width = w or 0
		self.height = h or 0

		self.enabled = true

		-- static colliders are assumed to not move and thus do not 
		-- interact with other static colliders
		self.static = false

		self.activeCollisions = {}
		self.collisionCount = 0
		self.id = 0
	end
}

function BoundingBox:attach(entity)
	if entity ~= nil then
		self.anchor = entity
	end
end

function BoundingBox:center()
	if self.anchor == nil then
		return self.offset:clone()
	end

	return Vector(self.anchor.position.x + self.offset.x,
		          self.anchor.position.y + self.offset.y)
end

function BoundingBox:left()
	return self:center().x - self.width / 2
end

function BoundingBox:right()
	return self:center().x + self.width / 2
end

function BoundingBox:top()
	return self:center().y - self.height / 2
end

function BoundingBox:bottom()
	return self:center().y + self.height / 2
end

function BoundingBox:distance_to(other)
	local a = max(max(other:left() - self:right(),
					  self:left() - other:right()), 0)
	local b = max(max(other:top() - self:bottom(),
		              self:top() - other:bottom()), 0)

	if a == 0 then
		return b
	elseif b == 0 then
		return a 
	else
		return math.sqrt(a*a + b*b)
	end
end

function BoundingBox:intersects(other)
	return self:right() >= other:left() and
	   	   self:left() <= other:right() and
	       self:bottom() >= other:top() and
	       self:top() <= other:bottom()
end

function BoundingBox:on_enter(other)
	self.activeCollisions[other.id] = true
	self.collisionCount = self.collisionCount + 1

	if self.anchor ~= nil then
		self.anchor:on_collision_enter(other)
	end
end

function BoundingBox:on_stay(other)
	if self.anchor ~= nil then
		self.anchor:on_collision_stay(other)
	end
end

function BoundingBox:on_exit(other)
	self.activeCollisions[other.id] = false
	self.collisionCount = self.collisionCount - 1

	if self.anchor ~= nil then
		self.anchor:on_collision_exit(other)
	end
end

function BoundingBox:is_colliding()
	return self.collisionCount > 0
end

function BoundingBox:debug_draw()
	local left = self:left()
	local right = self:right()
	local top = self:top()
	local bottom = self:bottom()

	if self:is_colliding() then
		love.graphics.setColor(255, 0, 0)
	else
		love.graphics.setColor(0, 255, 0)
	end

	love.graphics.line(left, top,
					   right, top,
					   right, bottom,
					   left, bottom,
					   left, top)
end

Physics = Class {
	name = "Physics",
	inherits = {},
	function(self)
		self.colliders = {}
		self.currentId = 1
	end
}

function Physics:register(collider)
	collider.id = self.currentId
	self.currentId = self.currentId + 1
	table.insert(self.colliders, collider)
end

function Physics:unregister(collider)
	local index = 0
	for i, c in ipairs(self.colliders) do
		if c.id == collider.id then
			index = i
			break
		end
	end

	if index > 0 then
		table.remove(self.colliders, index)
	end
end

function Physics:update_collisions()
	for i = 1, #self.colliders - 1 do
		for j = 2, #self.colliders do
			local c1 = self.colliders[i]
			local c2 = self.colliders[j]

			if c1.enabled and c2.enabled and not (c1.static and c2.static) then
				local intersects = c1:intersects(c2)
				if c1.activeCollisions[c2.id] then
					if intersects then
						c1:on_stay(c2)
						c2:on_stay(c1)
					else
						c1:on_exit(c2)
						c2:on_exit(c1)
					end
				else
					if intersects then
						c1:on_enter(c2)
						c2:on_enter(c1)
					end
				end
			end
		end
	end
end

function Physics:debug_draw()
	for _, c in pairs(self.colliders) do
		c:debug_draw()
	end
end