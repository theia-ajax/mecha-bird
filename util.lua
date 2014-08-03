Timer = require 'hump.timer'

function split_str(str, delimeter)
    local temp = {}
    local index = 0
    local last_index = string.len(str)

    while true do
        local i, e = string.find(str, "%"..delimeter, index)

        if i and e then
            local next_index = e + 1
            local word_bound = i - 1
            table.insert(temp, string.sub(str, index, word_bound))
            index = next_index
        else            
            if index > 0 and index <= last_index then
                table.insert(temp, string.sub(str, index, last_index))
            elseif index == 0 then
                temp = nil
            end
            break
        end
    end

    return temp
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