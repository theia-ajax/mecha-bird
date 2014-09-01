Class = require 'hump.class'
Assets = require 'assets'
require 'util'

Atlas = Class
{
    name = "Atlas",
    function(self, atlasname)
        self.atlasname = atlasname

        self.data = load_json(string.format("%s.json", atlasname))
        local imageFile = get_path(atlasname)..self.data.meta.image
        self.image = Assets.load_image(imageFile)
    end
}

function Atlas:get_frame(framename)
    assert(self.data.frames[framename] ~= nil,
        "No frame with name \'"..framename.."\' could be found.")
    return self.data.frames[framename]
end

function Atlas:get_frame_rect(framename)
    return self:get_frame(framename).frame
end

function Atlas:get_anim_frame(name, index)
    return get_frame(string.format("%s%02d", name, index))
end

function Atlas:get_anim_frame_rect(name, index)
    return get_anim_frame(name, index).frame
end