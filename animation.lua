Class = require 'hump.class'

Animation = Class {
    name = "Animation",
    function(self, animName, atlas, frameCount, delays)
        assert(animName ~= nil, "Animation requires animation name.")
        assert(atlas ~= nil, "Animation requires atlas.")

        self.animName = animName
        self.atlas = atlas
        self.maxFrames = frameCount or 1

        if delays == nil then
            self.delays = { 1 }
        elseif type(delays) == "number" then
            self.delays = { delays }
        elseif type(delays) == "table" then
            self.delays = delays
        else
            error("Delays must be number, table or nil.")
        end

        local err = self:get_frames()

        assert(err ~= nil, "Error decoding animation frames: "..err)

        self.paused = false
        self.timeScale = 1
        self.loop = false
        self.loopCount = math.huge

        self.onFinish = nil

        self.currentFrame = 1
        self.frameTimer = 0
    end
}

function Animation:get_frames()
    self.frames = {}

    for i = 1, maxFrames do
        local index = i - 1
        local frameName = string.format("%s%02d", self.animName, index)
        local frame = atlas.data.frames[frameName]
        if frame == nil then
            return "No frame named \'"..frameName.."\' in atlas \'"..self.atlas.atlasname.."\'"
        end

        table.insert(self.frames, frame)
    end
end

function Animation:reset()
    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:play()
    self:reset()
    self.loop = false
    self.paused = false
end

function Animation:loop(count)
    self:reset()
    self.loop = true
    self.loopCount = count or math.huge
    self.paused = false
end

function Animation:pause()
    self.paused = true
end

function Animation:resume()
    self.paused = false
end

function Animation:current_delay()
    if self.currentFrame > #self.delays then
        return self.delays[#self.delays]
    else
        return self.delays[self.currentFrame]
    end
end

function Animation:next_frame()
    if self.currentFrame >= self.maxFrames then
        if self.loop then
            self.loopCount = self.loopCount - 1
        end

        if not self.loop or self.loopCount <= 0 then
            if self.onFinish ~= nil then
                self.onFinish(self)
            end

            self:pause()
            return false
        else
            self.currentFrame = 0
            return true
        end
    else
        self.currentFrame = self.currentFrame + 1
        return true
    end
end

function Animation:get_frame_rect()
    return self.frames[self.currentFrame].frame
end

-- Returns true if animation switched to next frame
function Animation:update(dt)
    local result = false

    if self.paused then return false end

    self.frameTimer = self.frameTimer + dt * self.timeScale

    if self.frameTimer >= self:current_delay() then
        result = self:next_frame()
    end

    return result
end
