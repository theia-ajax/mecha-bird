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
        self.width = 0
        self.height = 0
        self.tileWidth = 0
        self.tileHeight = 0
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
			if asset ~= nil then
				local tile = Tile(asset)
				local x = col * self.tileWidth
				local y = globals.screen.height - row * self.tileHeight
				tile.position.x = x
				tile.position.y = y
				add_entity(tile)
				table.insert(self.tiles, tile.id)
			end
		end
	end
end

function Level:load(filename)
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
		print(line)
		if string.len(line) == 0 then
			-- nothing
		elseif string.sub(line, 1, 1) == "#" then
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
		elseif string.sub(line, 1, 1) == ">" then
			local s = split_str(string.sub(line, 2), ",")
			table.insert(data.assets, s[1])
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