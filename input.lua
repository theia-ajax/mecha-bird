Class = require 'hump.class'

Input = Class {
    name = "input",
    inherits = {},
    function(self)
        self.oldState = {}
        self.newState = {}

        self.buttons = {}

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
    if not self.enabled then return end

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

function Input:add_button(button, ...)
    assert(self.buttons[button] == nil, "Button \'"..button.."\' already exists.")
    
    self.buttons[button] = {}
    for _, k in ipairs({...}) do
        table.insert(self.buttons[button], k)
    end
end

function Input:button(button)
    assert(self.buttons[button] ~= nil, "Button \'"..button.."\' does not exist.")

    for _, k in ipairs(self.buttons[button]) do
        if self:key(k) then
            return true
        end
    end

    return false
end

function Input:button_down(button)
    assert(self.buttons[button] ~= nil, "Button \'"..button.."\' does not exist.")

    local downCount = 0
    local justDownCount = 0
    for _, k in ipairs(self.buttons[button]) do
        if self:key(k) then
            downCount = downCount + 1
        end
        if self:key_down(k) then
            justDownCount = justDownCount + 1
        end
    end

    return justDownCount > 0 and justDownCount == downCount
end

function Input:button_up(button)
    assert(self.buttons[button] ~= nil, "Button \'"..button.."\' does not exist.")

    local upCount = 0
    local justUpCount = 0
    for _, k in ipairs(self.buttons[button]) do
        if not self:key(k) then
            upCount = upCount + 1
        end
        if self:key_up(k) then
            justUpCount = justUpCount + 1
        end
    end

    return justUpCount > 0 and upCount == #self.buttons[button]
end
