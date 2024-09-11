---@class ClassResources
local addonName, addon = ...
local ClassResources = {}
addon.ClassResources = ClassResources

local CLASS_RESOURCES_CONFIG = addon.Config.classResourcesConfig
local media = addon.Util.FetchMedia
local formatBarText = addon.Util.FormatBarText

--- Creates a resource bar
---@param frame any UnitFrame
function ClassResources:CreateResourceBar(frame)
    local resourceBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    resourceBar:SetPoint("TOPLEFT", frame.powerBar, "BOTTOMLEFT", 0, -1)
    resourceBar:SetPoint("BOTTOMRIGHT", frame.barsFrame, "BOTTOMRIGHT", -5, 5)
    resourceBar:SetHeight(frame:GetHeight() * 0.25)
    resourceBar:SetStatusBarTexture(media("statusbar", MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture))
    resourceBar:Hide()

    resourceBar.text = resourceBar:CreateFontString(nil, "OVERLAY")
    resourceBar.text:SetFont(media("font", addon.Config.defaultConfig.font), addon.Config.defaultConfig.fontsize, addon.Config.defaultConfig.fontstyle)
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
    end

    if resourceType then
        frame.resourceBar:SetMinMaxValues(0, maxResource)
        frame.resourceBar:SetValue(currentResource)
        frame.resourceBar:SetStatusBarColor(unpack(resourceColor))

        if resourceType == "CHI" or resourceType == "ESSENCE" then
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
function ClassResources:UpdateTextVisibility(showText)
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
