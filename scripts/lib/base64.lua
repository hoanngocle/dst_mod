-- Small self-contained Base64 codec for world-generation map payloads.
--
-- This module intentionally has no dependency on taomap or any other mod.
-- It is Lua 5.1-compatible and exposes the encode/decode API used by
-- modworldgenmain.lua.

local base64 = {}
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local lookup = {}

for i = 1, #alphabet do
    lookup[alphabet:sub(i, i)] = i - 1
end

function base64.encode(data)
    local encoded = {}
    local length = #data

    for i = 1, length, 3 do
        local a = data:byte(i)
        local b = data:byte(i + 1)
        local c = data:byte(i + 2)
        local value = a * 0x10000 + (b or 0) * 0x100 + (c or 0)

        local first = math.floor(value / 0x40000) % 64
        local second = math.floor(value / 0x1000) % 64
        local third = math.floor(value / 0x40) % 64
        local fourth = value % 64

        if b == nil then
            encoded[#encoded + 1] = alphabet:sub(first + 1, first + 1)
                .. alphabet:sub(second + 1, second + 1)
                .. "=="
        elseif c == nil then
            encoded[#encoded + 1] = alphabet:sub(first + 1, first + 1)
                .. alphabet:sub(second + 1, second + 1)
                .. alphabet:sub(third + 1, third + 1)
                .. "="
        else
            encoded[#encoded + 1] = alphabet:sub(first + 1, first + 1)
                .. alphabet:sub(second + 1, second + 1)
                .. alphabet:sub(third + 1, third + 1)
                .. alphabet:sub(fourth + 1, fourth + 1)
        end
    end

    return table.concat(encoded)
end

function base64.decode(encoded)
    local clean = encoded:gsub("%s", "")
    if #clean % 4 ~= 0 then
        error("Invalid Base64 length")
    end

    local decoded = {}
    for i = 1, #clean, 4 do
        local first_char = clean:sub(i, i)
        local second_char = clean:sub(i + 1, i + 1)
        local third_char = clean:sub(i + 2, i + 2)
        local fourth_char = clean:sub(i + 3, i + 3)

        local first = lookup[first_char]
        local second = lookup[second_char]
        if first == nil or second == nil then
            error("Invalid Base64 character")
        end

        local third = third_char == "=" and 0 or lookup[third_char]
        local fourth = fourth_char == "=" and 0 or lookup[fourth_char]
        if third == nil or fourth == nil then
            error("Invalid Base64 character")
        end
        if third_char == "=" and fourth_char ~= "=" then
            error("Invalid Base64 padding")
        end

        local value = first * 0x40000 + second * 0x1000 + third * 0x40 + fourth
        decoded[#decoded + 1] = string.char(math.floor(value / 0x10000) % 256)
        if third_char ~= "=" then
            decoded[#decoded + 1] = string.char(math.floor(value / 0x100) % 256)
        end
        if fourth_char ~= "=" then
            decoded[#decoded + 1] = string.char(value % 256)
        end
    end

    return table.concat(decoded)
end

return base64
