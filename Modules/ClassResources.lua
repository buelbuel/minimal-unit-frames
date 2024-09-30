---@class ClassResources
local addonName, addon = ...
local ClassResources = {}
addon.ClassResources = ClassResources

local media = addon.Util.FetchMedia
local formatBarText = addon.Util.FormatBarText

--- Initializes the class resources
function ClassResources:Initialize()
    if self:HasClassResources() then
        self:UpdateClassResources()
    end
end

--- Checks if the player has class resources
function ClassResources:HasClassResources()
    local _, class = UnitClass("player")
    return class == "MONK" or class == "EVOKER" or class == "DEATHKNIGHT" or class == "WARLOCK" or class == "PALADIN" or class == "ROGUE" or class == "DRUID" or class == "PRIEST" or class == "MAGE"
end

--- Updates the class resources
function ClassResources:UpdateClassResources()
    if not addon.playerFrame then
        return
    end

    local resourceBar = addon.playerFrame.resourceBar

    if not MinimalUnitFramesDB.enableClassResources or not self:HasClassResources() then
        if resourceBar then
            resourceBar:Hide()
        end
    else
        if resourceBar then
            resourceBar.dividers = nil
        end
        self:UpdateResourceBar(addon.playerFrame, "player")
    end

    addon.UpdateFrameSize(addon.playerFrame, "player")
end

--- Creates a resource bar
---@param frame any UnitFrame
function ClassResources:CreateResourceBar(frame)
    local resourceBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    resourceBar:SetPoint("TOPLEFT", frame.powerBar, "BOTTOMLEFT", 0, -1)
    resourceBar:SetPoint("BOTTOMRIGHT", frame.barsFrame, "BOTTOMRIGHT", -5, 5)
    resourceBar:SetHeight(frame.powerBar:GetHeight())
    resourceBar:SetStatusBarTexture(media("textures", MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture))
    resourceBar:Hide()

    resourceBar.text = resourceBar:CreateFontString(nil, "OVERLAY")
    resourceBar.text:SetFont(media("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    resourceBar.text:SetPoint("CENTER", resourceBar, "CENTER")
    resourceBar.text:SetTextColor(1, 1, 1)
    resourceBar.text:SetJustifyH("CENTER")
    resourceBar.text:SetJustifyV("MIDDLE")

    return resourceBar
end

--- Updates the resource bar
---@param frame any UnitFrame
---@param unit string
function ClassResources:UpdateResourceBar(frame, unit)
    if not frame.resourceBar then
        return
    end

    local _, class = UnitClass(unit)
    local spec = GetSpecialization()

    if unit ~= "player" or not spec or not MinimalUnitFramesDB.enableClassResources then
        frame.resourceBar:Hide()
        addon.UpdateFrameSize(frame, unit)
        return
    end

    local resourceType, currentResource, maxResource, resourceColor

    if class == "MONK" then
        if spec == SPEC_MONK_WINDWALKER then
            resourceType = "CHI"
            currentResource = UnitPower(unit, Enum.PowerType.Chi)
            maxResource = UnitPowerMax(unit, Enum.PowerType.Chi)
            resourceColor = {0.0, 1.0, 0.59}
        elseif spec == SPEC_MONK_BREWMASTER then
            resourceType = "STAGGER"
            currentResource = UnitStagger(unit)
            maxResource = UnitHealthMax(unit)
            resourceColor = {0.52, 1.0, 0.52}
        end
    elseif class == "EVOKER" then
        resourceType = "ESSENCE"
        currentResource = UnitPower(unit, Enum.PowerType.Essence)
        maxResource = UnitPowerMax(unit, Enum.PowerType.Essence)
        resourceColor = {0.0, 0.8, 0.8}
    elseif class == "DEATHKNIGHT" then
        resourceType = "RUNES"
        currentResource = 0
        maxResource = 6
        resourceColor = {0.77, 0.12, 0.23}
        for i = 1, maxResource do
            if select(3, GetRuneCooldown(i)) then
                currentResource = currentResource + 1
            end
        end
    elseif class == "WARLOCK" then
        resourceType = "SOUL_SHARDS"
        currentResource = UnitPower(unit, Enum.PowerType.SoulShards)
        maxResource = UnitPowerMax(unit, Enum.PowerType.SoulShards)
        resourceColor = {0.58, 0.51, 0.79}
    elseif class == "PALADIN" then
        resourceType = "HOLY_POWER"
        currentResource = UnitPower(unit, Enum.PowerType.HolyPower)
        maxResource = UnitPowerMax(unit, Enum.PowerType.HolyPower)
        resourceColor = {0.95, 0.90, 0.60}
    elseif class == "ROGUE" or (class == "DRUID" and spec == SPEC_DRUID_FERAL) then
        resourceType = "COMBO_POINTS"
        currentResource = UnitPower(unit, Enum.PowerType.ComboPoints)
        maxResource = UnitPowerMax(unit, Enum.PowerType.ComboPoints)
        resourceColor = {1.00, 0.96, 0.41}
    elseif class == "DRUID" and spec == SPEC_DRUID_BALANCE then
        resourceType = "ASTRAL_POWER"
        currentResource = UnitPower(unit, Enum.PowerType.LunarPower)
        maxResource = UnitPowerMax(unit, Enum.PowerType.LunarPower)
        resourceColor = {0.30, 0.52, 0.90}
    elseif class == "PRIEST" and spec == SPEC_PRIEST_SHADOW then
        resourceType = "INSANITY"
        currentResource = UnitPower(unit, Enum.PowerType.Insanity)
        maxResource = UnitPowerMax(unit, Enum.PowerType.Insanity)
        resourceColor = {0.70, 0.40, 0.90}
    elseif class == "MAGE" and spec == SPEC_MAGE_ARCANE then
        resourceType = "ARCANE_CHARGES"
        currentResource = UnitPower(unit, Enum.PowerType.ArcaneCharges)
        maxResource = UnitPowerMax(unit, Enum.PowerType.ArcaneCharges)
        resourceColor = {0.41, 0.80, 0.94}
    end

    if resourceType then
        frame.resourceBar:SetMinMaxValues(0, maxResource)
        frame.resourceBar:SetValue(currentResource)
        frame.resourceBar:SetStatusBarColor(unpack(resourceColor))

        if resourceType == "CHI" or resourceType == "ESSENCE" or resourceType == "RUNES" or resourceType == "SOUL_SHARDS" or resourceType == "HOLY_POWER" or resourceType == "COMBO_POINTS" or resourceType == "ARCANE_CHARGES" then
            if frame.resourceBar.dividers then
                for _, divider in ipairs(frame.resourceBar.dividers) do
                    divider:Hide()
                    divider:ClearAllPoints()
                end
            end
            frame.resourceBar.dividers = {}

            for i = 1, maxResource - 1 do
                local divider = frame.resourceBar.dividers[i] or frame.resourceBar:CreateTexture(nil, "OVERLAY")
                divider:SetColorTexture(0, 0, 0, 1)
                divider:SetSize(1, frame.resourceBar:GetHeight())
                divider:SetPoint("LEFT", frame.resourceBar, "LEFT", (i / maxResource) * frame.resourceBar:GetWidth(), 0)
                divider:Show()
                frame.resourceBar.dividers[i] = divider
            end
        else
            if frame.resourceBar.dividers then
                for _, divider in ipairs(frame.resourceBar.dividers) do
                    divider:Hide()
                end
            end
        end

        local formattedText = formatBarText(currentResource, maxResource, unit, resourceType ~= "STAGGER")
        frame.resourceBar.text:SetText(string.format("%s", formattedText))
        frame.resourceBar:Show()
    else
        frame.resourceBar:Hide()
    end

    addon.UpdateFrameSize(frame, unit)
end

--- Updates the text visibility
---@param showText boolean
function ClassResources:UpdateFrameTextVisibility(showText)
    if self.resourceBar and self.resourceBar.text then
        if showText then
            self.resourceBar.text:Show()
        else
            self.resourceBar.text:Hide()
        end
    end
end

--- Updates the bar texture
---@param texture string
function ClassResources:UpdateBarTexture(texture)
    if self.resourceBar then
        self.resourceBar:SetStatusBarTexture(texture)
    end
end
