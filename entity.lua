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
        self.destroy = false
	end
}

function Entity:update(dt)
end

function Entity:render()
end

function Entity:on_collision_enter(other)
end

function Entity:on_collision_stay(other)
end

function Entity:on_collision_exit(other)
end

function Entity:on_cleanup()
end

function add_entity(entity)
    if globals.entities == nil then return nil end

    if globals.entities.lock then
        flush_dirty_entities()
    end

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
        result.destroy = true
    end

    globals.entities.lock = true

    return result
end

function remove_entity_id(id)
    if globals.entities == nil then return nil end

    local result = globals.entities[id]

    if result ~= nil then
        result.destroy = true
    end

    globals.entities.lock = true

    return result
end

function flush_dirty_entities()
    for i = #globals.entities, 1, -1 do
        if globals.entities[i] ~= nil and globals.entities[i].destroy then
            local e = table.remove(globals.entities, i)
            if e ~= nil then
                e:on_cleanup()
            end
            globals.currentId = globals.currentId - 1
        end
    end

    globals.entities.lock = false
end