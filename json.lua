-- json.lua
-- JSON library for encoding/decoding JSON in Lua

local json = {}

function json.encode(tbl)
    local function encode(tbl)
        local result = {}

        for k, v in pairs(tbl) do
            local key = type(k) == 'string' and '"' .. k .. '":' or ''
            local value = type(v) == 'table' and encode(v) or type(v) == 'string' and '"' .. v .. '"' or tostring(v)
            table.insert(result, key .. value)
        end

        return '{' .. table.concat(result, ',') .. '}'
    end

    return encode(tbl)
end

function json.decode(jsonString)
    local f, err = load("return " .. jsonString)
    if f then
        return f()
    else
        error("Error decoding JSON: " .. err)
    end
end

return json
