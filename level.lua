Class = require 'hump.class'
require 'entity'
require 'tile'
require 'util'

Level = Class {
    name = "Level",
    inherits = {},
    function(self)
        self.levelData = {}
        self.tiles = {}
        self.bgSprites = {}
        self.width = 0
        self.height = 0
        self.tileWidth = 0
        self.tileHeight = 0
        self.background = nil
    end
}

function Level:build(data)
    if data == nil then return end
    if data.assets == nil then return end

    self.width = data.width or 0
    self.height = data.height or 0
    self.tileWidth = data.tileWidth or 0
    self.tileHeight = data.tileHeight or 0

    if self.width <= 0 or self.height <= 0 or
       self.tileWidth <= 0 or self.tileHeight <= 0 then
        return
    end

    self.levelData = {}
    for i, v in ipairs(data) do
        self.levelData[i] = v

        local row = self.height - math.floor((i - 1) / self.width)
        local col = (i - 1) % self.width

        if v > 0 then
            local asset = data.assets[v]
            local file = asset.file
            local tag = asset.tag
            if asset ~= nil then
                local tile = Tile(file, tag)
                local x = col * self.tileWidth
                local y = game.screen.height - row * self.tileHeight
                tile.position.x = x
                tile.position.y = y
                add_entity(tile)
                table.insert(self.tiles, tile.id)
            end
        end
    end

    if data.assets.background ~= nil then
    	self.background = data.assets.background
        local maxBgs = 2
    	for i = 1, maxBgs do
    		local bgSprite = Sprite(data.assets.background)
    		bgSprite.position.x = bgSprite.width * (i - 1)
            table.insert(self.bgSprites, bgSprite)
    	end

        self.bgRight = self.bgSprites[2]
    end
end

function Level:load(filename)
    print("Loading level: "..filename)
    if not love.filesystem.isFile(filename) then
        print("File not found: "..filename)
        return
    end

    local commaPattern = ""

    local width = 0
    local height = 0

    local data = {}
    data.assets = {}

    local row = 0
    local col = 0

    for line in love.filesystem.lines(filename) do
    	local first = string.sub(line, 1, 1)
        if string.len(line) == 0 then
            -- nothing
        elseif first == "#" then
            local var = ""
            local eqIndex = 0
            local len = string.len(line)
            for j = 2, #line do
                local c = string.sub(line, j, j)
                if c == "=" then
                    eqIndex = j
                    break
                else
                    var = var .. c
                end
            end

            local s = split_str(string.sub(line, eqIndex + 1), ",")
            local value = tonumber(s[1])

            data[var] = value
        elseif first == ">" then
            local s = split_str(string.sub(line, 2), ",")
            table.insert(data.assets, { file = s[1], tag = s[2] })
        elseif first == "^" then
        	local s = split_str(string.sub(line, 2), ",")
        	data.assets.background = s[1]
        else
            row = row + 1
            for k, v in pairs(split_str(line, ",")) do
                col = col + 1
                local index = (row - 1) * width + (col - 1) + 1
                data[index] = tonumber(v)
            end 
            width = col
        end
        col = 0
    end
    height = row

    data.width = width
    data.height = height

    self:build(data)
end

function Level:cleanup()
    for k, t in pairs(self.tiles) do
        remove_entity_id(t)
    end

    self.tiles = {}
    self.levelData = {}
    self.width = 0
    self.height = 0
    self.tileWidth = 0
    self.tileHeight = 0
end

-- The ground height at horizontal position x
function Level:ground_height(x)
    if x < 0 or x > self.width * self.tileWidth then
        return game.screen.height
    end

    local col = math.floor(x / self.tileWidth)

    for row = 1, self.height do
        local r = row - 1
        local i = r * self.width + col + 1
        local t = self.levelData[i]
        if t > 0 then
            return game.screen.height - (self.height - r) * self.tileHeight
        end
    end

    return game.screen.height
end

function Level:update(dt)
    local left = game.camera.x - game.screen.windowWidth / 2
    for i, bg in ipairs(self.bgSprites) do
        local threshold = left - bg.width * game.screen.scale
        threshold = threshold / game.screen.scale
        if bg.position.x < threshold then
            bg.position.x = self.bgRight.position.x + self.bgRight.width
            self.bgRight = bg
        end
    end
end

function Level:reset()
    for i, bg in ipairs(self.bgSprites) do
        bg.position.x = bg.width * (i - 1)
        self.bgRight = bg
    end
end

function Level:render()
	for _, bg in ipairs(self.bgSprites) do
		bg:render()
	end
end