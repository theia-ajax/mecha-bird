local tokens = {}

tokens.quote = '\"'
tokens.comma = ','
tokens.colon = ':'
tokens.leftBracket = '['
tokens.rightBracket = ']'
tokens.leftBrace = '{'
tokens.rightBrace = '}'

local types = {
    none = 0,
    syntax = 1,
    number = 2,
    string = 3,
    boolean = 4
}

local function print_error(err)
    print(string.format("Error parsing JSON: %s", err))
end

local function gen_error(err, index)
    return string.format("%s at index %d.", err, index)
end

local function toboolean(v)
    return (type(v) == "string" and v == "true") or
           (type(v) == "number" and v ~= 0) or
           (type(v) == "boolean" and v)
end

local function is_whitespace(str)
    local c = 0
    for w in str:gmatch("%S+") do c = c + 1 end
    return c == 0
end

local function is_token(str)
    for k, v in pairs(tokens) do
        if str == v then
            return true, v
        end
    end

    return false, nil
end

local function is_char(str)
    local s = str:lower()
    local alphabet = "abcdefghijklmnopqrstuvwxyz"
    return alphabet:find(s) ~= nil
end

local function is_num(str)
    local num_chars = "0123456789-."
    return num_chars:find(str) ~= nil
end

local function is_valid_string_char(str)
    return str ~= tokens.quote and str ~= tokens.comma and not is_whitespace(str)
end

local function next_token(str, index)
    local len = string.len(str)

    local frontIndex = index
    local backIndex = index

    while frontIndex <= len do
        local front = str:sub(frontIndex, backIndex)

        if is_token(front) then
            return { value = front, __type = types.syntax }, frontIndex + 1
        elseif is_char(front) then
            while backIndex <= len and
                  is_valid_string_char(str:sub(backIndex, backIndex)) do
                backIndex = backIndex + 1
            end
            backIndex = backIndex - 1
            local token = str:sub(frontIndex, backIndex)
            local tokenType = types.string
            if token == "true" or token == "false" then
                token = toboolean(token)
                tokenType = types.boolean
            end
            return { value = token, __type = tokenType }, backIndex + 1
        elseif is_num(front) then
            while backIndex <= len and is_num(str:sub(backIndex, backIndex)) do
                backIndex = backIndex + 1
            end
            backIndex = backIndex - 1
            local token = tonumber(str:sub(frontIndex, backIndex))
            return { value = token, __type = types.number }, backIndex + 1
        elseif is_whitespace(front) then
            frontIndex = frontIndex + 1
            backIndex = backIndex + 1
        else
            return nil, nil, gen_error("Unexpected character", front)
        end
    end

    return nil, frontIndex
end

local function parse_string(str, index)
    local lquote, index, err = next_token(str, index)

    if err ~= nil then return nil, nil, err end

    if lquote.value ~= tokens.quote then
        return nil, nil, gen_error("Expected opening quote", index)
    end

    local strToken, index, err = next_token(str, index)

    if err ~= nil then return nil, nil, err end
    if strToken.__type ~= types.string then
        return nil, nil, gen_error("Expected string", index)
    end

    local rquote, index, err = next_token(str, index)

    if err ~= nil then return nil, nil, err end

    if rquote.value ~= tokens.quote then
        return nil, nil, gen_error("Expected closing quote", index)
    end

    return strToken.value, index
end

local function parse_value(str, index)
    local token, i, err = next_token(str, index)

    if err ~= nil then return nil, nil, err end

    if token.__type == types.syntax then
        if token.value == tokens.quote then
            token, i, err = parse_string(str, index)

            if err ~= nil then return nil, nil, err end
        else
            return nil, nil, gen_error("Not a valid value token", index)
        end
    end

    return token.value, i
end

local function parse_array(str, index)
    local result = {}
    local foundComma = true

    while true do
        local token, i, err = next_token(str, index)

        if err ~= nil then return nil, nil, err end

        if token.value == tokens.comma then
            index = i
            foundComma = true
        elseif token.value == tokens.rightBracket then

            -- REMOVE THIS TO IGNORE TRALING COMMAS
            if foundComma then
                return nil, nil, gen_error("Trailing comma", index)
            end

            index = i
            return result, i
        else
            if not foundComma then
                return nil, nil, gen_error("Expected comma", index)
            end

            foundComma = false

            local next, i, err = next_token(str, index)
            local value = nil
            if next.__type == types.syntax then
                if next.value == tokens.leftBracket then
                    value, index, err = parse_array(str, index)
                elseif next.value == tokesn.leftBrace then
                    value, index, err = parse_object(str, index)
                else
                    return nil, nil, gen_error("Unexpected symbol", index)
                end
            else
                value, index, err = parse_value(str, index)
            end

            if err ~= nil then return nil, nil, err end

            table.insert(result, value)
        end
    end
end

local function parse_object(str, index)
    local result = {}
    local foundComma = true

    while true do
        local token, i, err = next_token(str, index)

        if err ~= nil then return nil, nil, err end

        if token.value == tokens.comma then
            index = i
            foundComma = true
        elseif token.value == tokens.rightBrace then

            -- REMOVE THIS TO IGNORE TRALING COMMAS
            if foundComma then
                return nil, nil, gen_error("Trailing comma", index)
            end

            index = i
            return result, i
        else
            if not foundComma then
                return nil, nil, gen_error("Expected comma", index)
            end

            foundComma = false

            local key = nil
            key, index, err = parse_string(str, index)

            if err ~= nil then return nil, nil, err end

            local colon = nil
            colon, index, err = next_token(str, index)
            if err ~= nil then return nil, nil, err end
            if colon.value ~= tokens.colon then
                return nil, nil, gen_error("Expected colon", index)
            end

            local next, i, err = next_token(str, index)
            local value = nil
            if next.__type == types.syntax then
                if next.value == tokens.leftBracket then
                    value, index, err = parse_array(str, i)
                elseif next.value == tokens.leftBrace then
                    value, index, err = parse_object(str, i)
                elseif next.value == tokens.quote then
                    value, index, err = parse_string(str, index)
                else
                    return nil, nil, gen_error("Unexpected symbol "..next.value, index)
                end
            else
                value, index, err = parse_value(str, index)
            end

            if err ~= nil then return nil, nil, err end

            result[key] = value
        end
    end
end

local function decode(jsonstr)
    token, index, err = next_token(jsonstr, 1)

    if err ~= nil then
        print_error(err)
        return nil
    end

    result = nil

    if token.__type == types.syntax then
        if token.value == tokens.leftBrace then
            result, index, err = parse_object(jsonstr, 2)
        elseif token.value == tokens.leftBracket then
            result, index, err = parse_array(jsonstr, 2)
        end
    else
        print_error("Not a valid JSON object.")
    end

    if err ~= nil then
        print_error(err)
        return nil
    end

    return result
end

local function encode(object)
end

return {
    encode = encode,
    decode = decode,

    -- aliases
    parse = decode
}