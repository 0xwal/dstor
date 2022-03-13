---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 05/03/2022 6:57 AM
---

Dstor         = {}
Dstor.__index = Dstor

function get_only_specific_column(store, column)
    return {
        [column] = store[column]
    }
end

function parse_key(key)
    local startIndex, lastIndex = key:find('[%.]?(%*)[%.]?')
    if not startIndex then
        return false, key
    end

    if key:sub(1, 1) == '*' then
        return true, nil, key:sub(lastIndex + 1)
    end

    local keyInTable = key:sub(1, startIndex - 1)
    if #key == lastIndex then
        return true, keyInTable, nil
    end
    local column = key:sub(lastIndex + 1)
    return true, keyInTable, column
end

function resolve_all_data(store, column)
    local out = {}
    for k, value in pairs(store) do

        if column and type(value) == 'table' then
            out[k] = get_only_specific_column(value, column)
        elseif not column then
            out[k] = value
        end

    end
    return out
end

function string_start_with(haystack, needle)
    local haystackLength = #haystack
    local needleLength   = #(needle or {})
    if needleLength > haystackLength then
        return nil
    end

    for i = 1, needleLength do
        local haystackChar = string.sub(haystack, i, i)
        local needleChar   = string.sub(needle, i, i)
        if needleChar ~= haystackChar then
            return nil
        end
    end

    return 1, needleLength
end

function resolve_data_by_key(store, column, key)
    local out = {}
    for k, value in pairs(store) do
        local needle               = key .. '.'
        local indexStart, indexEnd = string_start_with(k, needle)

        if indexStart then
            local theKey = k:sub(indexEnd + 1)

            if column and type(value) == 'table' then
                if value[column] then
                    out[theKey] = get_only_specific_column(value, column)
                end
            elseif not column then
                out[theKey] = value
            end
        end

    end
    return out
end

function Dstor.new()
    local this  = setmetatable({}, Dstor)
    this._store = {}
    return this
end

function Dstor:set(key, value)
    self._store[key] = value
end

function Dstor:get(key)
    if key == '*' then
        return self._store
    end

    local hasStar, keyInTable, column = parse_key(key)

    if not hasStar then
        return self._store[key]
    end

    if hasStar and not keyInTable then
        return resolve_all_data(self._store, column)
    end

    return resolve_data_by_key(self._store, column, keyInTable)
end

function Dstor:unset(key)
    self:set(key, nil)
end
