Class = require 'hump.class'
Vector = require 'hump.vector'

Entity = Class
{
	name = "Entity",
	inherits = {},
	function(self)
		self.id = 0
		self.position = Vector.zero()
		self.rotation = 0
		self.scale = Vector.one()
	end
}

function Entity:update(dt)
end

function Entity:render()
end

function add_entity(entity)
    if globals.entities == nil then return nil end

    if entity == nil or entity.id ~= 0 then
        return nil
    end

    entity.id = globals.currentId;
    globals.entities[entity.id] = entity
    globals.currentId = globals.currentId + 1

    return entity
end

function remove_entity(entity)
    if globals.entities == nil then return nil end

    if entity == nil then
        return nil
    end

    local result = globals.entities[entity.id]

    if result ~= nil then
        table.remove(globals.entities, result.id)
    end

    return result
end

function remove_entity_id(id)
    if globals.entities == nil then return nil end

    local result = globals.entities[id]

    if result ~= nil then
        table.remove(globals.entities, id)
    end

    return result
end