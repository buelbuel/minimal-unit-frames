---@class Util
local addonName, addon = ...
local Util = {}
addon.Util = Util

local CONFIG = addon.Config

--- Fetches a media file
---@param type string
---@param key string
function Util.FetchMedia(mediaType, name)
    if mediaType and name and addon.Config.media[mediaType] and addon.Config.media[mediaType][name] then
        return addon.Config.media[mediaType][name]
    end
    return nil
end

--- Formats a value
---@param value number
function Util.ValueFormat(value)
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    else
        return tostring(value)
    end
end

--- Formats a time
---@param time number
function Util.TimeFormat(time)
    if time >= 3600 then
        return format("%d:%02d:%02d", time / 3600, (time % 3600) / 60, time % 60)
    elseif time >= 60 then
        return format("%d:%02d", time / 60, time % 60)
    elseif time < 10 then
        return format("%.1f", time)
    else
        return format("%.0f", time)
    end
end

--- Returns the keys of a table
---@param table table
function addon.Util.GetTableKeys(table)
    local keys = {}
    for k in pairs(table) do
        keys[#keys + 1] = k
    end
    return keys
end
