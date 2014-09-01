--[[
The MIT License (MIT)

Copyright (c) 2014 Ted Dobyns

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local Assets = {}
Assets.__index = Assets

function Assets:load_image(filename, format)
    if self.assets.images[filename] ~= nil then
        return self.assets.images[filename]
    end

    local image = love.graphics.newImage(filename, format)
    assert(image ~= nil, "Asset "..filename.." not found.")

    self.assets.images[filename] = image
    return self.assets.images[filename]
end

local function new()
    return setmetatable({
        assets = {
            images = {}
        }
    }, Assets)
end

local default = new()

return setmetatable({
    new         = new,
    load_image  = function(...) return default:load_image(...) end,
}, { __call = new })