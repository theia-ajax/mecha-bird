Timer = require 'hump.timer'

function split_str(str, delimeter)
    local result = {}
    for w in str:gmatch(pattern) do table.insert(result, w) end
    return result
end

function split_str_whitespace(str)
    local result = {}
    for w in str:gmatch("%S+") do table.insert(result, w) end
    return result
end

function trim_str(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

string.split = split_str_whitespace
string.trim = trim_str

function console_print_intro(name, version)
    print(" "..name.." v"..version.." ".._VERSION)
    print()
    print(" <Escape> or ~ leaves the console. Call quit() or exit() to quit.")
    print(" Try hitting <Tab> to complete your current input.")
    print(" Type help() for commands and usage")
    print()
end

quit = love.event.quit
exit = quit

_print = print
print = function(...)
    game.console:print(...)
    _print(...)
end

function set_screen_scale(scale)
    game.screen.windowWidth = game.screen.width * scale
    game.screen.windowHeight = game.screen.height * scale

    game.screen.scale = scale

    love.window.setMode(game.screen.windowWidth, game.screen.windowHeight)
end

function restart()
    os.execute("love .")
    quit()
end
