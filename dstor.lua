---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 05/03/2022 6:57 AM
---

Dstor         = {}
Dstor.__index = Dstor

function filter_column(store, column)
    for kk, item in pairs(store) do
        if kk == column then
            return {
                [column] = item
            }
        end
    end
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
        local out = {}
        for k, value in pairs(self._store) do

            if column and type(value) == 'table' then
                out[k] = filter_column(value, column)
            elseif not column then
                out[k] = value
            end

        end
        return out
    end

    local out = {}
    for k, value in pairs(self._store) do
        local pattern              = '^' .. keyInTable .. '%.'
        local indexStart, indexEnd = k:find(pattern)

        if indexStart then
            local theKey = k:sub(indexEnd + 1)

            if column and type(value) == 'table' then
                if value[column] then
                    out[theKey] = filter_column(value, column)
                end
            elseif not column then
                out[theKey] = value
            end
        end

    end

    return out
end

