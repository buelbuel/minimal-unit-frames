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

---@param mediaType string
---@return table
function Util.GetMediaList(mediaType)
    local list = {}
    if addon.Config.media[mediaType] then
        for key, _ in pairs(addon.Config.media[mediaType]) do
            table.insert(list, key)
        end
    end
    return list
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

--- Formats a bar text
---@param current number
---@param max number
---@param unit string
---@param isClassResource boolean
function Util.FormatBarText(current, max, unit, isClassResource)
    local statusTextDisplay = GetCVar("statusTextDisplay")

    if UnitIsDeadOrGhost(unit) then
        return "Dead"
    elseif max == 0 then
        return "0/0"
    elseif isClassResource then
        return Util.ValueFormat(current) .. " / " .. Util.ValueFormat(max)
    elseif statusTextDisplay == "NUMERIC" then
        return Util.ValueFormat(current) .. " / " .. Util.ValueFormat(max)
    elseif statusTextDisplay == "PERCENT" then
        return max > 0 and math.floor((current / max) * 100) .. "%" or "0%"
    elseif statusTextDisplay == "BOTH" then
        local numericText = Util.ValueFormat(current) .. " / " .. Util.ValueFormat(max)
        local percentText = max > 0 and math.floor((current / max) * 100) .. "%" or "0%"
        return numericText .. " " .. percentText
    else
        return ""
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

--- Gets the bar color based on class and power type
---@param unit string
---@param isHealth boolean
function addon.Util.GetBarColor(unit, isHealth)
    if unit == "targetoftarget" then
        unit = "targettarget"
    end
    if isHealth then
        local _, class = UnitClass(unit)
        local colors = addon.Config.classColors
        local color = colors[class] or addon.Config.classColors.DEFAULT
        return color
    else
        local _, powerType = UnitPowerType(unit)
        local powerColors = addon.Config.powerColors
        local color = powerColors[powerType] or addon.Config.powerColors.DEFAULT
        return color
    end
end

--- Returns the frame dimensions
---@param unit string
---@return number, number
function addon.Util.GetFrameDimensions(unit)
    local width, height
    if unit == "player" then
        width = MinimalUnitFramesDB.playerWidth or addon.Config.defaultConfig.playerWidth
        height = MinimalUnitFramesDB.playerHeight or addon.Config.defaultConfig.playerHeight
    elseif unit == "target" then
        width = MinimalUnitFramesDB.targetWidth or addon.Config.defaultConfig.targetWidth
        height = MinimalUnitFramesDB.targetHeight or addon.Config.defaultConfig.targetHeight
    elseif unit == "targetoftarget" then
        width = MinimalUnitFramesDB.targetoftargetWidth or addon.Config.defaultConfig.targetoftargetWidth
        height = MinimalUnitFramesDB.targetoftargetHeight or addon.Config.defaultConfig.targetoftargetHeight
    elseif unit == "pet" then
        width = MinimalUnitFramesDB.petWidth or addon.Config.defaultConfig.petWidth
        height = MinimalUnitFramesDB.petHeight or addon.Config.defaultConfig.petHeight
    elseif unit == "pettarget" then
        width = MinimalUnitFramesDB.petTargetWidth or addon.Config.defaultConfig.petTargetWidth
        height = MinimalUnitFramesDB.petTargetHeight or addon.Config.defaultConfig.petTargetHeight
    else
        width = addon.Config.defaultConfig.width
        height = addon.Config.defaultConfig.height
    end
    return width, height
end

--- Loads a module
---@param moduleName string
function addon.Util.LoadModule(moduleName)
    if addon[moduleName] then
        return true
    end

    local addonName = "MinimalUnitFrames_" .. moduleName
    local loaded, reason = LoadAddOn(addonName)

    if not loaded then
        if reason == "MISSING" then
            print("Module " .. moduleName .. " is missing. Please ensure it's installed and enabled in the AddOns menu.")
        elseif reason == "DISABLED" then
            print("Module " .. moduleName .. " is disabled. Please enable it in the AddOns menu.")
        else
            print("Failed to load " .. moduleName .. " module: " .. tostring(reason))
        end
        return false
    end

    if addon[moduleName] and addon[moduleName].Initialize then
        addon[moduleName]:Initialize()
    elseif not addon[moduleName] then
        print("Module " .. moduleName .. " loaded but not initialized. Check the module file for errors.")
        return false
    end
    return true
end
