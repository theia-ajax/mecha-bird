Class = require 'hump.class'

Input = Class {
    name = "input",
    inherits = {},
    function(self)
        self.oldState = {}
        self.newState = {}

        self.enabled = true
    end
}

function Input:key_pressed(key)
    self.newState[key] = true
end

function Input:key_released(key)
    self.newState[key] = false
end

function Input:update()
    for k, v in pairs(self.newState) do
        self.oldState[k] = v
    end
end

function Input:key(key)
    return self.newState[key] and self.enabled
end

function Input:key_down(key)
    return self.newState[key] and not self.oldState[key] and self.enabled
end

function Input:key_up(key)
    return not self.newState[key] and self.oldState[key] and self.enabled
end

function Input:enable()
    self.enabled = true
end

function Input:disable()
    self.enabled = false
end