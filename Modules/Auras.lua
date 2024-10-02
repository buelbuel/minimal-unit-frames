---@class Auras
local addonName, addon = ...
local Auras = {}
addon.Auras = Auras

--- Creates an aura button
---@param parent any UnitFrame
---@param index number
---@param isDebuff boolean
local function CreateAuraButton(parent, index, isDebuff, unit)
    local config = isDebuff and addon.Config.auraConfig[unit].debuffs or addon.Config.auraConfig[unit].buffs
    local size = isDebuff and MinimalUnitFramesDB[unit .. "DebuffSize"] or MinimalUnitFramesDB[unit .. "BuffSize"] or config.size
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints(true)

    button.mask = button:CreateMaskTexture()
    button.mask:SetAllPoints(button.icon)
    button.mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    button.icon:AddMaskTexture(button.mask)

    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetAllPoints(true)
    button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    button.border:SetVertexColor(isDebuff and 1 or 0, 0, 0, 1)

    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), tonumber(config.stackTextSize) or MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    button.count:ClearAllPoints()
    button.count:SetPoint(config.stackTextAnchor or "BOTTOMRIGHT", button, config.stackTextAnchor or "BOTTOMRIGHT", config.stackTextXOffset or -1, config.stackTextYOffset or 1)

    button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    button.cooldown:SetDrawEdge(false)
    button.cooldown:SetDrawSwipe(true)
    button.cooldown:SetSwipeColor(0, 0, 0, 0.8)
    button.cooldown:SetHideCountdownNumbers(not config.showCooldownText)

    button.count:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), config.stackTextSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    button.count:ClearAllPoints()
    button.count:SetPoint(config.stackTextAnchor, button, config.stackTextAnchor, config.stackTextXOffset, config.stackTextYOffset)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitAura(self:GetParent():GetParent().unit, self:GetID(), self:GetParent().filter)
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)

    return button
end

--- Updates an aura button
---@param button any Button
---@param name string
---@param icon string
---@param count number
---@param duration number
---@param expirationTime number
---@param debuffType string
---@param isDebuff boolean
local function UpdateAuraButton(button, name, icon, count, duration, expirationTime, debuffType, isDebuff, unit)
    local config = isDebuff and addon.Config.auraConfig[unit].debuffs or addon.Config.auraConfig[unit].buffs
    button.icon:SetTexture(icon)

    if count > 1 and MinimalUnitFramesDB[unit .. "ShowAuraStackText"] then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:Hide()
    end

    local fontPath = addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font)
    local fontSize = MinimalUnitFramesDB[unit .. "AuraStackTextSize"] or config.stackTextSize
    local fontStyle = MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle
    button.count:SetFont(fontPath, fontSize, fontStyle)

    button.count:ClearAllPoints()
    local anchor = MinimalUnitFramesDB[unit .. "AuraStackTextAnchor"] or config.stackTextAnchor
    button.count:SetPoint(anchor, button, anchor, config.stackTextXOffset, config.stackTextYOffset)

    if duration and duration > 0 then
        button.cooldown:SetCooldown(expirationTime - duration, duration)
        button.cooldown:Show()
    else
        button.cooldown:Hide()
    end
    button.cooldown:SetHideCountdownNumbers(not config.showCooldownText)

    if isDebuff then
        local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
        button.border:SetVertexColor(color.r, color.g, color.b)
    else
        button.border:SetVertexColor(1, 1, 1)
    end

    button:Show()
end

--- Updates the aura buttons
---@param frame any UnitFrame
---@param unit string
---@param filter string
---@param config table
---@param isDebuff boolean
local function UpdateAuras(frame, unit, filter, isDebuff)
    if not C_UnitAuras then
        return false
    end

    frame.auras[filter].filter = filter
    local index = 1
    local hasAuras = false
    local config = addon.Config.auraConfig[unit] or addon.Config.auraConfig.player
    local size = MinimalUnitFramesDB[unit .. (isDebuff and "DebuffSize" or "BuffSize")] or (isDebuff and config.debuffs.size or config.buffs.size)
    local perRow = MinimalUnitFramesDB[unit .. (isDebuff and "DebuffsPerRow" or "BuffsPerRow")] or (isDebuff and config.debuffs.perRow or config.buffs.perRow)
    local limit = MinimalUnitFramesDB[unit .. (isDebuff and "DebuffLimit" or "BuffLimit")] or (isDebuff and config.debuffs.maxDisplay or config.buffs.maxDisplay) or 40
    local whitelist = MinimalUnitFramesDB[unit .. "AuraWhitelist"] or {}
    local blacklist = MinimalUnitFramesDB[unit .. "AuraBlacklist"] or {}

    local auraCount = 0
    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
        if not auraData then
            break
        end
        if (auraCount < limit) and (not next(whitelist) or whitelist[auraData.name] or whitelist[tostring(auraData.spellId)]) and (not blacklist[auraData.name] and not blacklist[tostring(auraData.spellId)]) then
            local button = frame.auras[filter][index] or CreateAuraButton(frame.auras[filter], index, isDebuff, unit)
            frame.auras[filter][index] = button
            button:SetID(i)
            UpdateAuraButton(button, auraData.name, auraData.icon, auraData.applications, auraData.duration, auraData.expirationTime, auraData.dispelName, isDebuff, unit)

            button:SetSize(size, size)
            local row = math.floor((index - 1) / perRow)
            local col = (index - 1) % perRow
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame.auras[filter], "TOPLEFT", col * (size + 2), -row * (size + 2))

            button:Show()
            hasAuras = true
            index = index + 1
            auraCount = auraCount + 1
        end
    end

    for i = index, #frame.auras[filter] do
        frame.auras[filter][i]:Hide()
    end

    return hasAuras, auraCount
end

--- Creates the aura frames
---@param frame any UnitFrame
function Auras:Create(frame)
    local buffWidth = 24 * 8 + (8 - 1) * 2
    local buffHeight = 24 * 8 + (8 - 1) * 2
    local debuffWidth = 32 * 8 + (8 - 1) * 2
    local debuffHeight = 32 * 8 + (2 - 1) * 2

    frame.auras = {
        HELPFUL = CreateFrame("Frame", nil, frame),
        HARMFUL = CreateFrame("Frame", nil, frame)
    }
    frame.auras.HELPFUL:SetSize(buffWidth, buffHeight)
    frame.auras.HARMFUL:SetSize(debuffWidth, debuffHeight)
    frame.auras.HELPFUL:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    frame.auras.HARMFUL:SetPoint("TOPLEFT", frame.auras.HELPFUL, "BOTTOMLEFT", 0, -2)
    frame.auras.HELPFUL:Show()
    frame.auras.HARMFUL:Show()
end

--- Updates the aura buttons
---@param frame any UnitFrame
---@param unit string
function Auras:Update(frame, unit)
    if not frame.auras or not C_UnitAuras then
        return
    end

    local hasBuffs, buffCount = false, 0
    if (unit == "player" and MinimalUnitFramesDB.showPlayerBuffs) or (unit == "target" and MinimalUnitFramesDB.showTargetBuffs) then
        hasBuffs, buffCount = UpdateAuras(frame, unit, "HELPFUL", false)
    end

    local hasDebuffs, debuffCount = false, 0
    if (unit == "player" and MinimalUnitFramesDB.showPlayerDebuffs) or (unit == "target" and MinimalUnitFramesDB.showTargetDebuffs) then
        hasDebuffs, debuffCount = UpdateAuras(frame, unit, "HARMFUL", true)
    end

    local config = addon.Config.auraConfig[unit] or addon.Config.auraConfig.player
    local buffSize = MinimalUnitFramesDB[unit .. "BuffSize"] or config.buffs.size
    local debuffSize = MinimalUnitFramesDB[unit .. "DebuffSize"] or config.debuffs.size
    local buffPerRow = MinimalUnitFramesDB[unit .. "BuffsPerRow"] or config.buffs.perRow
    local debuffPerRow = MinimalUnitFramesDB[unit .. "DebuffsPerRow"] or config.debuffs.perRow
    local verticalSpacing = MinimalUnitFramesDB[unit .. "AuraVerticalSpacing"] or config.verticalSpacing or 2

    local buffRows = math.ceil(buffCount / buffPerRow)
    local debuffRows = math.ceil(debuffCount / debuffPerRow)

    local xOffset = MinimalUnitFramesDB[unit .. "AuraXOffset"] or config.xOffset or 0
    local yOffset = MinimalUnitFramesDB[unit .. "AuraYOffset"] or config.yOffset or 0
    local anchor = MinimalUnitFramesDB[unit .. "AuraAnchor"] or config.anchorPoint or "BOTTOMLEFT"

    frame.auras.HELPFUL:ClearAllPoints()
    frame.auras.HELPFUL:SetPoint(anchor, frame, anchor, xOffset, yOffset)
    frame.auras.HELPFUL:SetSize(buffPerRow * buffSize, buffRows * buffSize)

    frame.auras.HARMFUL:ClearAllPoints()
    if hasBuffs then
        frame.auras.HARMFUL:SetPoint(anchor, frame.auras.HELPFUL, "BOTTOMLEFT", 0, -verticalSpacing)
    else
        frame.auras.HARMFUL:SetPoint(anchor, frame, anchor, xOffset, yOffset)
    end
    frame.auras.HARMFUL:SetSize(debuffPerRow * debuffSize, debuffRows * debuffSize)

    frame.auras.HELPFUL:SetShown(hasBuffs)
    frame.auras.HARMFUL:SetShown(hasDebuffs)
end

function addon.Auras:UpdateAllAuras()
    for _, unit in ipairs({"player", "target", "pet"}) do
        local frame = addon[unit .. "Frame"]
        if frame and frame.auras then
            self:Update(frame, unit)
        end
    end
end
