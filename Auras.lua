---@class Auras
local addonName, addon = ...
local Auras = {}
addon.Auras = Auras

local media = addon.Util.FetchMedia

--- Creates an aura button
---@param parent any UnitFrame
---@param index number
local function CreateAuraButton(parent, index, isDebuff)
    local config = isDebuff and addon.Config.auraConfig.debuffs or addon.Config.auraConfig.buffs
    local size = config.size
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
    button.count:SetFont(media("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    button.count:SetPoint("BOTTOMRIGHT", -1, 1)

    button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    button.cooldown:SetDrawEdge(false)
    button.cooldown:SetDrawSwipe(true)
    button.cooldown:SetSwipeColor(0, 0, 0, 0.8)
    button.cooldown:SetHideCountdownNumbers(not config.showCooldownText)

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
local function UpdateAuraButton(button, name, icon, count, duration, expirationTime, debuffType, isDebuff)
    local config = isDebuff and addon.Config.auraConfig.debuffs or addon.Config.auraConfig.buffs
    button.icon:SetTexture(icon)
    button.count:SetText(count > 1 and count or "")

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
local function UpdateAuras(frame, unit, filter, config, isDebuff)
    if not C_UnitAuras then
        return false
    end

    frame.auras[filter].filter = filter
    local index = 1
    local hasAuras = false
    local size = MinimalUnitFramesDB[unit .. "AuraButtonSize"] or config.size
    local perRow = MinimalUnitFramesDB[unit .. "AuraButtonsPerRow"] or config.perRow

    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)

        if not auraData then
            break
        end

        local button = frame.auras[filter][index] or CreateAuraButton(frame.auras[filter], index, isDebuff)
        frame.auras[filter][index] = button
        button:SetID(i)
        UpdateAuraButton(button, auraData.name, auraData.icon, auraData.applications, auraData.duration, auraData.expirationTime, auraData.dispelName, isDebuff)

        button:SetSize(size, size)
        button:SetPoint("TOPLEFT", frame.auras[filter], "TOPLEFT", ((index - 1) % perRow) * (size + 2), -math.floor((index - 1) / perRow) * (size + 2))

        button:Show()
        hasAuras = true
        index = index + 1
    end

    for i = index, #frame.auras[filter] do
        frame.auras[filter][i]:Hide()
    end

    local auraCount = index - 1
    return hasAuras, auraCount
end

--- Creates the aura frames
---@param frame any UnitFrame
function Auras:Create(frame)
    local buffWidth = addon.Config.auraConfig.buffs.size * addon.Config.auraConfig.buffs.perRow + (addon.Config.auraConfig.buffs.perRow - 1) * 2
    local buffHeight = addon.Config.auraConfig.buffs.size * addon.Config.auraConfig.buffs.maxRows + (addon.Config.auraConfig.buffs.maxRows - 1) * 2
    local debuffWidth = addon.Config.auraConfig.debuffs.size * addon.Config.auraConfig.debuffs.perRow + (addon.Config.auraConfig.debuffs.perRow - 1) * 2
    local debuffHeight = addon.Config.auraConfig.debuffs.size * addon.Config.auraConfig.debuffs.maxRows + (addon.Config.auraConfig.debuffs.maxRows - 1) * 2

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
        hasBuffs, buffCount = UpdateAuras(frame, unit, "HELPFUL", addon.Config.auraConfig.buffs, false)
    end

    local hasDebuffs, debuffCount = false, 0
    if (unit == "player" and MinimalUnitFramesDB.showPlayerDebuffs) or (unit == "target" and MinimalUnitFramesDB.showTargetDebuffs) then
        hasDebuffs, debuffCount = UpdateAuras(frame, unit, "HARMFUL", addon.Config.auraConfig.debuffs, true)
    end

    local buffSize = MinimalUnitFramesDB[unit .. "AuraButtonSize"] or addon.Config.auraConfig.buffs.size
    local buffSpacing = 2
    local perRow = MinimalUnitFramesDB[unit .. "AuraButtonsPerRow"] or addon.Config.auraConfig.buffs.perRow
    local buffRows = math.ceil(buffCount / perRow)

    if hasBuffs then
        frame.auras.HARMFUL:SetPoint("TOPLEFT", frame.auras.HELPFUL, "BOTTOMLEFT", 0, -buffSpacing)
    else
        frame.auras.HARMFUL:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    end

    frame.auras.HELPFUL:SetHeight(buffRows * (buffSize + buffSpacing))
    frame.auras.HELPFUL:SetShown(hasBuffs)
    frame.auras.HARMFUL:SetShown(hasDebuffs)
end
