Class = require 'hump.class'
Vector = require 'hump.vector'

local min = math.min
local max = math.max

BoundingBox = Class {
    name = "BoundingBox",
    inherits = {},
    function(self, entity, w, h, offset, layer)
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
        self.layer = layer or "default"

        self.inCells = {}
    end
}

function BoundingBox:attach(entity)
    if entity ~= nil then
        self.anchor = entity
    end
end

function BoundingBox:set_layer(physics, layer)
    if physics.layerMatrix[layer] == nil then
        return
    end

    self.layer = layer
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
    if self.anchor ~= nil and other.anchor ~= nil then
        if self.anchor.tag == other.anchor.tag then
            return
        end
    end

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

    local cl, cr, ct, cb = game.camera:bounds_lrtb()
    if left < cl and right > cr and top < ct and bottom > cb then
        return
    end

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
    love.graphics.rectangle("fill", left, top,
                            self.width * game.screen.scale,
                            self.height * game.screen.scale)
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

        self:buildLayerMatrix("data/physlayers.txt")
    end
}

function Physics:buildLayerMatrix(filename)
    self.layerMatrix = {}
    self.layers = {}

    print("Loading physics data: "..filename)
    if not love.filesystem.isFile(filename) then
        print("File not found: "..filename)
        print("Reverting physics to default layer data.")        
        self.layerMatrix["default"] = {}
        self.layerMatrix["default"]["default"] = 1
        return
    end

    local firstLine = true
    for line in love.filesystem.lines(filename) do
        if firstLine then
            firstLine = false

            local layers = string.split(string.trim(line))
            for _, l in ipairs(layers) do
                table.insert(self.layers, l)
                self.layerMatrix[l] = {}
            end
        else
            tokens = string.split(line)
            local layer = ""
            for i, t in ipairs(tokens) do
                if i == 1 then
                    layer = t
                else
                    local num = tonumber(t)
                    self.layerMatrix[layer][self.layers[i - 1]] = num
                    self.layerMatrix[self.layers[i - 1]][layer] = num
                end
            end
        end
    end
end

function Physics:layers_collide(lyr1, lyr2)
    if lyr1 == nil or lyr2 == nil then
        return true
    end

    if self.layerMatrix == nil then
        return true
    end

    if self.layerMatrix[lyr1] == nil or self.layerMatrix[lyr2] == nil then
        return true
    end

    return self.layerMatrix[lyr1][lyr2] > 0
end

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
    -- find the index of the collider
    local index = 0
    for i, c in ipairs(self.colliders) do
        if c.id == collider.id then
            index = i
            break
        end
    end

    if index > 0 then
        -- call exit on all colliders currently being collided with
        for id, active in pairs(collider.activeCollisions) do
            if active then
                self:collider_by_id(id):on_exit(collider)
            end
        end

        -- remove the collider from all cells it is in
        for _, cell in ipairs(collider.inCells) do
            for i, c in ipairs(self.cells[cell]) do
                if c.id == collider.id then
                    table.remove(self.cells[cell], i)
                    break
                end
            end
        end

        -- remove the collider
        table.remove(self.colliders, index)
    end
end

function Physics:collider_by_id(id)
    local index = 0
    for i, c in ipairs(self.colliders) do
        if c.id == id then
            return self.colliders[i]
        end
    end
end

function Physics:cell_at_point(point)
    if point.x < 0 or point.x > self.width or
       point.y < -self.height or point.y > game.screen.height then
       return 0
    end

    local x = math.floor(point.x / self.cellWidth)
    local y = math.floor((game.screen.height - point.y) / self.cellHeight)

    local cell = (y * self.cellCols + x) + 1
    
    if cell > #self.cells then
        return -1
    else
        return cell
    end
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

                if self:valid_collision(c1, c2) then
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

function Physics:valid_collision(c1, c2)
    return c1.enabled and c2.enabled and not (c1.static and c2.static) and 
           self:layers_collide(c1.layer, c2.layer)
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

    local cl, cr, ct, cb = game.camera:bounds_lrtb()

    love.graphics.setColor(255, 255, 0)
    for _, cell in ipairs(self.cells) do
        local bl = cell.bounds.x * game.screen.scale
        local br = (cell.bounds.x + cell.bounds.w) * game.screen.scale
        local bt = cell.bounds.y * game.screen.scale
        local bb = (cell.bounds.y + cell.bounds.h) * game.screen.scale

        if bl >= cl or br <= cr or bt >= ct or bb <= cb then
            love.graphics.rectangle("line",
                                    cell.bounds.x * game.screen.scale,
                                    cell.bounds.y * game.screen.scale,
                                    cell.bounds.w * game.screen.scale,
                                    cell.bounds.h * game.screen.scale)
        end
    end
end
