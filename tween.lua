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

local PI = math.pi
local TWO_PI = 2 * PI
local PI_OVER_2 = PI / 2

local sin = math.sin
local cos = math.cos
local pow = math.pow
local sqrt = math.sqrt

local function _nothing_() end

--[[

All tween functions must conform to 

t: Current time of the tween in seconds.
i: Initial value.
f: Desired final value.
d: Duration of the tween in seconds.

]]

local function linear(t, i, f, d)
    return (f - i) * t / d + i
end

local function ease_in_quad(t, i, f, d)
    local c = f - i
    t = t / d
    return c * t * t + i
end

local function ease_out_quad(t, i, f, d)
    local c = f - i
    t = t / d
    return -c * t * (t - 2) + i
end

local function ease_in_out_quad(t, i, f, d)
    local c = f - i
    t = t / (d / 2)
    if t < 1 then
        return c / 2 * t * t + i
    end
    t = t - 1
    return -c / 2 * (t * (t - 2) - 1) + i
end

local function ease_in_sin(t, i, f, d)
    local c = f - i
    return -c * sin(t / d * (TWO_PI)) + i
end

local function ease_out_sin(t, i, f, d)
    local c = f - i
    return c * sin(t / d * (TWO_PI)) + i
end

local function ease_in_out_sin(t, i, f, d)
    local c = f - i
    return -c / 2 * (cos(PI * t / d) - 1) + i
end

local function ease_in_expo(t, i, f, d)
    local c = f - i
    return c * pow(2, 10 * (t / d - 1)) + i
end

local function ease_out_expo(t, i, f, d)
    local c = f - i
    return c * (-pow(2, -10 * t / d) + 1) + i
end

local function ease_in_out_expo(t, i, f, d)
    local c = f - i
    t = t / (d / 2)
    if t < 1 then
        return c / 2 * pow(2, 10 * (t - 1)) + i
    end
    t = t - 1
    return c / 2 * (-pow(2, -10 * t) + 2) + i
end

local function ease_in_circ(t, i, f, d)
    local c = f - i
    t = t / d
    return -c * (sqrt(1 - t * t) - 1) + i
end

local function ease_out_circ(t, i, f, d)
    local c = f - i
    t = t / d
    t = t - 1
    return c * sqrt(1 - t * t) + i
end

local function ease_in_out_circ(t, i, f, d)
    local c = f - i
    t = t / (d / 2)
    if t < 1 then
        return -c / 2 * (sqrt(1 - t * t) - 1) + i
    end
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + i
end

local function parabolic(t, i, f, d)
    local c = f - i
    return ((-4 * (i + c)) / (d * d)) * t * (t - d)
end

local function bounce_out(t, i, f, d)
    local c = f - i
    t = t / d
    if t < (1 / 2.75) then
        return c * (7.5625 * t * t) + i
    elseif t < (2 / 2.75) then
        t = t - (1.5 / 2.75)
        return c * (7.5625 * t * t + .75) + i
    elseif t < (2.5 / 2.75) then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + .9375) + i
    else
        t = t - (2.625 / 2.75)
        return c * (7.5625 * t * t + .984375) + i
    end
end

local function bounce_in(t, i, f, d)
    local c = f - i
    return c - bounce_out(d - t, 0, f, d) + i
end

local function bounce_in_out(t, i, f, d)
    local c = f - i
    if (t < d / 2) then
        return bounce_in(t * 2, 0, f, d) * 0.5 + i
    else
        return bounce_out(t * 2 - d, 0, f, d) * 0.5 + c * 0.5 + i
    end
end

local function sin_wave(t, i, f, d)
    local c = f - i
    t = t / d
    return sin(t * TWO_PI) * (c / 2) + i + (c / 2)
end

local function cos_wave(t, i, f, d)
    local c = f - i
    t = t / d
    return cos(t * TWO_PI) * (c / 2) + i + (c / 2)
end

tweenFunctions = {
    linear              = linear,
    ease_in_quad        = ease_in_quad,
    ease_out_quad       = ease_out_quad,
    ease_in_out_quad    = ease_in_out_quad,
    ease_in_sin         = ease_in_sin,
    ease_out_sin        = ease_out_sin,
    ease_in_out_sin     = ease_in_out_sin,
    ease_in_expo        = ease_in_expo,
    ease_out_expo       = ease_out_expo,
    ease_in_out_expo    = ease_in_out_expo,
    ease_in_circ        = ease_in_circ,
    ease_out_circ       = ease_out_circ,
    ease_in_out_circ    = ease_in_out_circ,
    parabolic           = parabolic,
    bounce_in           = bounce_in,
    bounce_out          = bounce_out,
    bounce_in_out       = bounce_in_out,
    sin_wave            = sin_wave,
    cos_wave            = cos_wave,
}

local Tween = {}
Tween.__index = Tween

local function new()
    return setmetatable({
        tweens = {},
        functions = tweenFunctions,
        currentTweenId = 0,
    },
    Tween)
end

local function tween_evaluate(tween)
    if tween.removeFlag then
        return tween.cachedValue
    end
    
    return tween.data.func(tween.currentTime,
                           tween.data.start,
                           tween.data.dest,
                           tween.data.time)
end

local function tween_update(tween, dt)
    if tween.paused then
        return
    end

    if not tween.data.reverse then
        tween.currentTime = tween.currentTime + dt
        if tween.currentTime >= tween.data.time then
            tween.playsRemaining = tween.playsRemaining - 1

            if tween.playsRemaining <= 0 then
                tween.currentTime = tween.data.time
                tween.cachedValue = tween_evaluate(tween)
                tween.removeFlag = true
                return
            end

            tween.currentTime = tween.currentTime - tween.data.time
        end
    else
        tween.currentTime = tween.currentTime - dt

        if tween.currentTime <= 0 then
            tween.playsRemaining = tween.playsRemaining - 1

            if tween.playsRemaining <= 0 then
                tween.currentTime = 0
                tween.cachedValue = tween_evaluate(tween)
                tween.removeFlag = true
                return
            end

            tween.currentTime = tween.currentTime + tween.data.time
        end
    end
end

local function new_tween(id, start, dest, time, func, reverse, count)
    local startTime = 0
    if reverse then
        startTime = time
    end

    return {
        id = id,
        data = {
            start = start,
            dest = dest,
            time = time,
            func = func,
            reverse = reverse,
            count = count
        },

        paused = false,
        currentTime = startTime,
        playsRemaining = count,
        removeFlag = false,
        cachedValue = nil,

        evaluate = function(self) return tween_evaluate(self) end,
        update = function(self, dt) tween_update(self, dt) end,
        play = function(self) self.paused = false end,
        pause = function(self) self.paused = true end,
        reset = function(self)
            if self.data.reverse then
                self.currentTime = self.data.time
            else
                self.currentTime = 0
            end
            self.playsRemaining = self.data.count
            self.removeFlag = false
            self.cachedValue = nil
        end
    }
end

function Tween:add(start, dest, time, func, reverse, count)
    assert(start ~= nil, "Must specify starting value.")
    assert(dest ~= nil, "Must specify destination value.")

    time = time or 1
    func = func or tweenFunctions.linear
    reverse = reverse or false
    count = count or math.huge

    self.currentTweenId = self.currentTweenId + 1
    local id = self.currentTweenId

    self.tweens[id] = new_tween(id, start, dest, time, func, reverse, count)
    return self.tweens[id]
end

function Tween:update(dt)
    local toRemove = {}

    for id, tween in pairs(self.tweens) do
        tween:update(dt)

        if tween.removeFlag then
            table.insert(toRemove, tween)
        end
    end

    for _, tween in ipairs(toRemove) do
        self.tweens[tween.id] = nil
    end
end

local default = new()

return setmetatable({
    new         = new,
    add         = function(...) return default:add(...) end,
    update      = function(...) return default:update(...) end,
    functions   = tweenFunctions,
}, {__call = new})