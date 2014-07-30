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
        self.scale = Vector.one() * 0.5
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
    if game.entities == nil then return nil end

    if game.entities.lock then
        flush_dirty_entities()
    end

    if entity == nil or entity.id ~= 0 then
        return nil
    end

    entity.id = game.currentId;
    game.entities[entity.id] = entity
    game.currentId = game.currentId + 1

    return entity
end

function remove_entity(entity)
    if game.entities == nil then return nil end

    if entity == nil then
        return nil
    end

    local result = game.entities[entity.id]

    if result ~= nil then
        result.destroy = true
    end

    game.entities.lock = true

    return result
end

function remove_entity_id(id)
    if game.entities == nil then return nil end

    local result = game.entities[id]

    if result ~= nil then
        result.destroy = true
    end

    game.entities.lock = true

    return result
end

function flush_dirty_entities()
    for i = #game.entities, 1, -1 do
        if game.entities[i] ~= nil and game.entities[i].destroy then
            local e = table.remove(game.entities, i)
            if e ~= nil then
                e:on_cleanup()
            end
            game.currentId = game.currentId - 1
        end
    end

    game.entities.lock = false
end