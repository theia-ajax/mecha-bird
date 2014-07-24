local assert = assert

local function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

local color = {}
color.__index = color

local function new(r, g, b, a, byte)
	local bytecolor = true
	if byte ~= nil and byte == false then bytecolor = false end
	local alpha = 0
	if bytecolor then
		alpha = 255
	else
		alpha = 0
	end
	return setmetatable({r = r or 0, g = g or 0, b = b or 0, a = a or alpha, isbyte = bytecolor}, color)
end

local function iscolor(c)
	return getmetatable(c) == color
end

function color:clone()
	return new(self.r, self.g, self.b, self.a)
end

function color:unpack()
	return self.r, self.g, self.b, self.a
end

function color:saturate()
	self.r = clamp(self.r, self:minval(), self:maxval())
	self.g = clamp(self.g, self:minval(), self:maxval())
	self.b = clamp(self.b, self:minval(), self:maxval())
	self.a = clamp(self.a, self:minval(), self:maxval())
	return self
end

function color:maxval()
	if self.isbyte then
		return 255
	else
		return 1
	end
end

function color:minval()
	return 0
end

function color:tobyte()
	if self.isbyte then return self, false end

	return new(clamp(self.r * 255, 0, 255),
			   clamp(self.g * 255, 0, 255),
			   clamp(self.b * 255, 0, 255),
			   clamp(self.a * 255, 0, 255),
			   true), true
end

function color:tofloat()
	if not self.isbyte then return self, false end

	return new(clamp(self.r * 255, 0, 1.0),
			   clamp(self.g * 255, 0, 1.0),
			   clamp(self.b * 255, 0, 1.0),
			   clamp(self.a * 255, 0, 1.0),
			   false), true
end

function color:__tostring()
	return "( R: "..tonumber(self.r)..", G: "..tonumber(self.g)..", B: "..tonumber(self.b)..", A: "..tonumber(self.a).." )"
end

function color.__unm(a)
	return self
end

function color.__add(ca, cb)
	assert(iscolor(ca) and iscolor(cb), "Add: wrong argument types (<color> expected)")
	local a = ca:tobyte()
	local b = cb:tobyte()
	return new(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a):saturate()
end

function color.__sub(ca, cb)
	assert(iscolor(ca) and iscolor(cb), "Sub: wrong argument types (<color> expected)")
	local a = ca:tobyte()
	local b = cb:tobyte()
	return new(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a):saturate()
end

function color.__mul(ca, cb)
	local result, convert
	local a, b
	if type(a) == "number" then
		b, convert = cb:tofloat()
		result = new(b.r * a, b.g * a, b.b * a, b.a * a, false):saturate()
	elseif type(b) == "number then" then
		a, convert = ca:tofloat()
		result = new(a.r * a, b.g * a, b.b * a, b.a * a, false):saturate()
	else
		assert(iscolor(ca) and iscolor(cb), "Mul: wrong argument types (<vector> or <number> expected)")
		local c1, c2
		a, c1 = ca:tofloat()
		b, c2 = cb:tofloat()
		convert = c1 or c2
		result = new(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a, false):saturate()
	end
	if convert then
		result = result:tobyte()
	end
	return result
end

function color.__div(ca, cb)
	assert(false, "Div: I'm not even going to try to divide colors, you're lucky I let you multiply them")
end

function color.__eq(ca, cb)
	local a = ca:tobyte()
	local b = cb:tobyte()
	return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
end

local function lerp(ca, cb, t)
	assert(iscolor(ca) and iscolor(cb), "Lerp: wrong argument types (<color> expected)")

	local a = ca:tofloat()
	local b = cb:tofloat()

	local result = a + (b - 1) * t
	return result:tobyte()
end

return setmetatable({
						new = new,
						iscolor = iscolor,
						lerp = lerp,
						red = new(255, 0, 0, 255),
						green = new(0, 255, 0, 255),
						blue = new(0, 0, 255, 255),
						yellow = new(255, 255, 0, 255),
						magenta = new(255, 0, 255, 255),
						cyan = new(0, 255, 255, 255),
						white = new(255, 255, 255, 255),
						grey = new(127, 127, 127, 255),
						black = new(0, 0, 0, 255),
						clear = new(0, 0, 0, 0)
                    },
                    { __call = function(_, ...) return new(...) end })