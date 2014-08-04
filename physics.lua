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

        self.inCells = {}
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

function BoundingBox:top_left()
    return Vector(self:left(), self:top())
end

function BoundingBox:top_right()
    return Vector(self:right(), self:top())
end

function BoundingBox:bottom_left()
    return Vector(self:left(), self:bottom())
end

function BoundingBox:bottom_right()
    return Vector(self:right(), self:bottom())
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
    local left = self:left() * game.screen.scale
    local right = self:right() * game.screen.scale
    local top = self:top() * game.screen.scale
    local bottom = self:bottom() * game.screen.scale

    if self:is_colliding() then
        love.graphics.setColor(255, 0, 0)
    else
        love.graphics.setColor(0, 255, 0)
    end

    love.graphics.rectangle("line",
                            left,
                            top,
                            self.width * game.screen.scale,
                            self.height * game.screen.scale)
    
    love.graphics.setColor(0, 0, 0, 127)
    love.graphics.rectangle("fill", left, top, self.width * 2, self.height * 2)
    love.graphics.setColor(0, 255, 0)
    for i, c in ipairs(self.inCells) do
        local x = left
        local y = top
        if i == 2 then x = right - 20 end
        if i == 3 then y = bottom - 20 end
        if i == 4 then x = right - 20; y = bottom - 20 end
        love.graphics.print(c, x, y)
    end
end

Physics = Class {
    name = "Physics",
    inherits = {},
    function(self, width, height, cellWidth, cellHeight)
        self.colliders = {}
        self.cells = {}
        self.currentId = 1

        self.width = width
        self.height = height
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.cellRows = math.ceil(self.height / self.cellHeight)
        self.cellCols = math.ceil(self.width / self.cellWidth)

        for i = 1, self.cellCols * self.cellRows do
            table.insert(self.cells, {})
            local row = math.floor((i - 1) / self.cellCols)
            local col = (i - 1) % self.cellCols

            local r = self.cellRows - row
            self.cells[i].bounds = {
                x = col * self.cellWidth,
                y = game.screen.height - r * self.cellHeight,
                w = self.cellWidth,
                h = self.cellHeight,
            }
        end
    end
}

function Physics:register(collider)
    collider.id = self.currentId
    self.currentId = self.currentId + 1
    table.insert(self.colliders, collider)
    self:calc_cells(collider)
end

function Physics:cells_updated(collider)
    local collCells = self:determine_cells(collider)

    local ct1 = {}
    local ct2 = {}

    for _, ci in pairs(collCells) do
        ct1[ci] = true
    end

    for _, ci in pairs(collider.inCells) do
        ct2[ci] = true
    end

    for ci, _ in pairs(ct1) do
        if not ct2[ci] then
            return true
        end
    end

    for ci, _ in pairs(ct2) do
        if not ct1[ci] then
            return true
        end
    end

    return false
end

function Physics:calc_cells(collider)
    if not self:cells_updated(collider) then
        return
    end

    for _, c in ipairs(collider.inCells) do
        local index = 0
        for i, v in ipairs(self.cells[c]) do
            if v == collider then
                index = i
                break
            end
        end
        if index > 0 then
            for i, coll in ipairs(self.cells[c]) do
                if i ~= index then
                    if coll.activeCollisions[collider.id] then
                        coll:on_exit(collider)
                        collider:on_exit(coll)
                    end
                end
            end
            table.remove(self.cells[c], index)
        end
    end

    local collCells = self:determine_cells(collider)
    collider.inCells = {}
    for _, c in ipairs(collCells) do
        table.insert(self.cells[c], collider)
        table.insert(collider.inCells, c)
    end
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

function Physics:cell_at_point(point)
    if point.x < 0 or point.x > self.width or
       point.y < -self.height or point.y > game.screen.height then
       return 0
    end

    local x = math.floor(point.x / self.cellWidth)
    local y = math.floor((game.screen.height - point.y) / self.cellHeight)

    return (y * self.cellCols + x) + 1
end

function Physics:determine_cells(collider)
    local tl = collider:top_left()
    local tr = collider:top_right()
    local bl = collider:bottom_left()
    local br = collider:bottom_right()

    local c = {}

    local c1 = self:cell_at_point(tl)
    if c1 > 0 then c[c1] = true end

    local c2 = self:cell_at_point(tr)
    if c2 > 0 then c[c2] = true end

    local c3 = self:cell_at_point(bl)
    if c3 > 0 then c[c3] = true end

    local c4 = self:cell_at_point(br)
    if c4 > 0 then c[c4] = true end

    local result = {}
    for k, v in pairs(c) do
        if v then
            table.insert(result, k)
        end
    end

    return result
end

function Physics:update_collisions()
    -- for i = 1, #self.colliders - 1 do
    --     for j = 2, #self.colliders do
    --         local c1 = self.colliders[i]
    --         local c2 = self.colliders[j]

    --         if c1.enabled and c2.enabled and not (c1.static and c2.static) then
    --             local intersects = c1:intersects(c2)
    --             if c1.activeCollisions[c2.id] then
    --                 if intersects then
    --                     c1:on_stay(c2)
    --                     c2:on_stay(c1)
    --                 else
    --                     c1:on_exit(c2)
    --                     c2:on_exit(c1)
    --                 end
    --             else
    --                 if intersects then
    --                     c1:on_enter(c2)
    --                     c2:on_enter(c1)
    --                 end
    --             end
    --         end
    --     end
    -- end

    game.collChecks = 0

    for _, cell in ipairs(self.cells) do
        local len = #cell
        for i = 1, len - 1 do
            for j = 2, len do
                local c1 = cell[i]
                local c2 = cell[j]

                if c1.enabled and c2.enabled and not (c1.static and c2.static) then
                    game.collChecks = game.collChecks + 1
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

    self:update_colliders()
end

function Physics:update_colliders(statics)
    for _, c in ipairs(self.colliders) do
        if not c.static or statics then
            self:calc_cells(c)
        end
    end
end

function Physics:debug_draw()
    for _, c in pairs(self.colliders) do
        c:debug_draw()
    end

    love.graphics.setColor(255, 255, 0)
    for _, cell in ipairs(self.cells) do
        love.graphics.rectangle("line",
                                cell.bounds.x * game.screen.scale,
                                cell.bounds.y * game.screen.scale,
                                cell.bounds.w * game.screen.scale,
                                cell.bounds.h * game.screen.scale)
    end
end
