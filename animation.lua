Class = require 'hump.class'

Animation = Class 
{
    name = "Animation",
    function(self, animName, atlas, frameCount, delays, priority)
        assert(animName ~= nil, "Animation requires animation name.")
        assert(atlas ~= nil, "Animation requires atlas.")

        self.animName = animName
        self.atlas = atlas
        self.maxFrames = frameCount or 1
        self.priority = priority or 0

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

        --assert(err == nil, "Error decoding animation frames: "..err)

        self.paused = true
        self.timeScale = 1
        self.loop = false
        self.loopCount = math.huge

        self.isFinished = false
        self.onFinish = nil

        self.currentFrame = 1
        self.frameTimer = 0
    end
}

function Animation:get_frames()
    self.frames = {}

    for i = 1, self.maxFrames do
        local index = i - 1
        local frameName = string.format("%s%02d", self.animName, index)
        local frame = self.atlas.data.frames[frameName]
        if frame == nil then
            return "No frame named \'"..frameName.."\' in atlas \'"..self.atlas.atlasname.."\'"
        end

        table.insert(self.frames, frame)
    end
end

function Animation:reset()
    self.isFinished = false
    self.currentFrame = 1
    self.frameTimer = 0
end

function Animation:play()
    self:reset()
    self.loop = false
    self.paused = false
end

function Animation:play_loop(count)
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

function Animation:stop()
    self:reset()
    self.paused = true
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

            self.isFinished = true
            self:pause()
            return false
        else
            self.currentFrame = 1
            return true
        end
    else
        self.currentFrame = self.currentFrame + 1
        return true
    end
end

function Animation:get_frame_rect()
    local f = self.frames[self.currentFrame]
    return f.frame, f.spriteSourceSize
end

-- Returns true if animation switched to next frame
function Animation:update(dt)
    local result = false

    if self.paused then return false end

    self.frameTimer = self.frameTimer + dt * self.timeScale

    if self.frameTimer >= self:current_delay() then
        result = self:next_frame()
        self.frameTimer = 0
    end

    return result
end

--[[
{
    "animName": {
        "frames": n,
        "delays": [
            1,
            2,
            ...,
            n
        ],
        "priority": 0
        // transitions?
    }
}
]]

AnimationController = Class 
{
    name = "AnimationController",
    function(self, atlas, animName)
        self.animations = {}

        local path = "assets/sheets/"..animName.."/"..animName.."_animations.json"
        local animData = load_json(path)

        for anim, data in pairs(animData) do
            self.animations[anim] = Animation(anim,
                                              atlas,
                                              animData.frames,
                                              animData.delays,
                                              animData.priority)
        end

        self.active = nil
    end
}

function AnimationController:animation_playable(animation)
    assert(self.animations[animation] ~= nil,
        "No animation found with name \'"..animation.."\'")

    if self.active ~= nil then
        if self.animations[animation] < self.active.priority then
            return false
        end
    end

    return true
end

function AnimationController:update_active(animation)
    if self.active ~= nil then
        self.active:stop()
    end
    self.active = self.animations[animation]
end

function AnimationController:play(animation)
    if self:animation_playable(animation) then
        self:update_active(animation)
        self.animations[animation]:play()
    end
end

function AnimationController:play_loop(animation, count)
    if self:animation_playable(animation) then
        self:update_active(animation)
        self.animations[animation]:play_loop(count)
    end
end

function AnimationController:get_frame_rect()
    assert(self.active ~= nil,
        "No active animation has been set.")

    return self.active:get_frame_rect()
end

function AnimationController:update(dt)
    if self.active ~= nil then
        self.active:update(dt)
    end
end