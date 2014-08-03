Timer = require 'hump.timer'

function split_str(str, delimeter)
    local result = {}
    local fpat = "(.-)" .. delimeter
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(result, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(result, cap)
    end
    return result
end

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
print = function(...) game.console:print(...) end

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