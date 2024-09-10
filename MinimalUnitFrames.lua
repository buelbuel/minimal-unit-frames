---@class MinimalUnitFrames
local addonName, addon = ...

MinimalUnitFramesDB = MinimalUnitFramesDB or {}
MinimalUnitFramesDB.locked = MinimalUnitFramesDB.locked == nil and true or MinimalUnitFramesDB.locked
MinimalUnitFramesDB.barTexture = MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture

local DEFAULT_CONFIG = addon.Config.defaultConfig
local media = addon.Util.FetchMedia
local formatValue = addon.Util.ValueFormat
local playerFrame, targetFrame, targettargetFrame, petFrame, petTargetFrame
local eventFrame = CreateFrame("Frame")

--- Gets the bar color based on class and power type
---@param unit string
---@param isHealth boolean
local function GetBarColor(unit, isHealth)
    if isHealth then
        local _, class = UnitClass(unit)
        local colors = addon.Config.classColors
        return colors[class] or {1, 1, 1}
    else
        local _, powerType = UnitPowerType(unit)
        local powerColors = addon.Config.powerColors
        return powerColors[powerType] or {1, 1, 1}
    end
end

--- Handles events to ensure Blizzard frames are hidden
---@param self any UnitFrame
---@param event string
---@param ... any
local function EventFrame_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_REGEN_ENABLED" or event == "GROUP_ROSTER_UPDATE" then
        C_Timer.After(0.1, function()
            addon.ToggleBlizzardFrames(MinimalUnitFramesDB.showBlizzardFrames)
            UpdateFrame(playerFrame, "player")
            if UnitExists("target") then
                UpdateFrame(targetFrame, "target")
                if MinimalUnitFramesDB.showTargetTarget then
                    UpdateFrame(targettargetFrame, "targettarget")
                end
            end
            if UnitExists("pet") then
                UpdateFrame(petFrame, "pet")
                if MinimalUnitFramesDB.showPetTarget and UnitExists("pettarget") then
                    UpdateFrame(petTargetFrame, "pettarget")
                end
            end
        end)
    elseif event == "UNIT_PET" then
        local unit = ...
        if unit == "player" then
            if UnitExists("pet") then
                UpdateFrame(petFrame, "pet")
                if MinimalUnitFramesDB.showPetTarget and UnitExists("pettarget") then
                    UpdateFrame(petTargetFrame, "pettarget")
                end
            else
                petFrame:Hide()
                petTargetFrame:Hide()
            end
        end
    end
end

--- Updates the frame
---@param frame any UnitFrame
---@param unit string
local function UpdateFrame(frame, unit)
    if not frame then
        return
    end

    if UnitIsDeadOrGhost(unit) then
        health = 0
        power = 0
    end
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)
    local healthColor = GetBarColor(unit, true)
    local powerColor = GetBarColor(unit, false)
    local absorb = UnitGetTotalAbsorbs(unit) or 0
    local statusTextDisplay = GetCVar("statusTextDisplay")
    local Auras = _G["MinimalUnitFrames_Auras"]

    local function FormatBarText(current, max)
        if UnitIsDeadOrGhost(unit) then
            return "Dead"
        elseif max == 0 then
            return "0/0"
        elseif statusTextDisplay == "NUMERIC" then
            return formatValue(current) .. " / " .. formatValue(max)
        elseif statusTextDisplay == "PERCENT" then
            return max > 0 and math.floor((current / max) * 100) .. "%" or "0%"
        elseif statusTextDisplay == "BOTH" then
            local numericText = formatValue(current) .. " / " .. formatValue(max)
            local percentText = max > 0 and math.floor((current / max) * 100) .. "%" or "0%"
            return numericText .. " " .. percentText
        else
            return ""
        end
    end

    frame.healthText:SetText(FormatBarText(health, maxHealth))
    frame.powerText:SetText(FormatBarText(power, maxPower))
    frame.absorbBar:SetWidth(frame.healthBar:GetWidth() * (absorb / maxHealth))
    frame.absorbBar:SetMinMaxValues(0, maxHealth)
    frame.absorbBar:SetValue(absorb)
    frame.healthBar:SetMinMaxValues(0, maxHealth)
    frame.healthBar:SetValue(health)
    frame.powerBar:SetMinMaxValues(0, maxPower)
    frame.powerBar:SetValue(power)
    frame.healthBar:SetStatusBarColor(unpack(healthColor))
    frame.powerBar:SetStatusBarColor(unpack(powerColor))
    frame.nameText:SetText(UnitName(unit))
    frame.levelText:SetText(UnitLevel(unit))
    if Auras and Auras.Update then
        Auras:Update(frame, unit)
    end
end

--- Sets up the frame
---@param frame any UnitFrame
---@param unit string
local function SetupFrame(frame, unit)
    frame:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        if MinimalUnitFramesDB.showBorder then
            self.barsFrame:SetBackdropBorderColor(1, 1, 0, 1)
        end
        self.barsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    end)
    frame:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0.5)
        if MinimalUnitFramesDB.showBorder then
            self.barsFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        else
            self.barsFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 0)
        end
        self.barsFrame:SetBackdropColor(0, 0, 0, 0.5)
    end)
    UpdateFrame(frame, unit)
end

--- Creates a unit frame
---@param unit string
local function CreateUnitFrame(unit)
    local frame = CreateFrame("Button", "Minimal" .. unit .. "Frame", UIParent, "SecureUnitButtonTemplate,BackdropTemplate")
    frame.config = DEFAULT_CONFIG

    frame:SetSize(addon.Config.defaultConfig.width, addon.Config.defaultConfig.height)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame.nameText = frame:CreateFontString(nil, "OVERLAY")
    frame.nameText:SetFont(media("font", addon.Config.defaultConfig.font), frame.config.fontsize, frame.config.fontstyle)
    frame.nameText:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 2)
    frame.nameText:SetTextColor(1, 1, 1)

    frame.levelText = frame:CreateFontString(nil, "OVERLAY")
    frame.levelText:SetFont(media("font", addon.Config.defaultConfig.font), frame.config.fontsize, frame.config.fontstyle)
    frame.levelText:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 2)
    frame.levelText:SetTextColor(1, 1, 1)

    frame.barsFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.barsFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.barsFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.barsFrame:SetBackdrop(addon.Config.frameBackdrop.options)
    frame.barsFrame:SetBackdropColor(unpack(addon.Config.frameBackdrop.colors.bg))
    if MinimalUnitFramesDB.showBorder then
        frame.barsFrame:SetBackdropBorderColor(unpack(addon.Config.frameBackdrop.colors.border))
    else
        frame.barsFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    frame.healthBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    frame.healthBar:SetPoint("TOPLEFT", frame.barsFrame, "TOPLEFT", 5, -5)
    frame.healthBar:SetPoint("TOPRIGHT", frame.barsFrame, "TOPRIGHT", -5, -5)
    frame.healthBar:SetHeight(frame.config.height * 0.5)
    frame.healthBar:SetStatusBarTexture(media("statusbar", MinimalUnitFramesDB.barTexture or frame.config.barTexture))

    frame.powerBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -1)
    frame.powerBar:SetPoint("BOTTOMRIGHT", frame.barsFrame, "BOTTOMRIGHT", -5, 5)
    frame.powerBar:SetStatusBarTexture(media("statusbar", MinimalUnitFramesDB.barTexture or frame.config.barTexture))

    frame.healthText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.healthText:SetFont(media("font", addon.Config.defaultConfig.font), frame.config.fontsize, frame.config.fontstyle)
    frame.healthText:SetPoint("CENTER", frame.healthBar, "CENTER")
    frame.healthText:SetTextColor(1, 1, 1)

    frame.powerText = frame.powerBar:CreateFontString(nil, "OVERLAY")
    frame.powerText:SetFont(media("font", addon.Config.defaultConfig.font), frame.config.fontsize, frame.config.fontstyle)
    frame.powerText:SetPoint("CENTER", frame.powerBar, "CENTER")
    frame.powerText:SetTextColor(1, 1, 1)

    frame.absorbBar = CreateFrame("StatusBar", nil, frame.healthBar)
    frame.absorbBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")
    frame.absorbBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT")
    frame.absorbBar:SetStatusBarTexture(media("statusbar", MinimalUnitFramesDB.barTexture or frame.config.barTexture))
    frame.absorbBar:SetStatusBarColor(0.7, 0.7, 1, 0.6)
    frame.absorbBar:SetReverseFill(true)
    frame.absorbBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 1)

    frame.unit = unit
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:RegisterForClicks("AnyUp")

    -- Hover functions
    frame:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(addon.Config.frameBackdrop.colors.bgHovered))
        if MinimalUnitFramesDB.showBorder then
            self.barsFrame:SetBackdropBorderColor(unpack(addon.Config.frameBackdrop.colors.borderHovered))
        end
        self.barsFrame:SetBackdropColor(unpack(addon.Config.frameBackdrop.colors.bgHovered))
    end)
    frame:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0.5)
        if MinimalUnitFramesDB.showBorder then
            self.barsFrame:SetBackdropBorderColor(unpack(addon.Config.frameBackdrop.colors.border))
        else
            self.barsFrame:SetBackdropBorderColor(0, 0, 0, 0)
        end
        self.barsFrame:SetBackdropColor(unpack(addon.Config.frameBackdrop.colors.bg))
    end)

    -- Auras
    local Auras = _G["MinimalUnitFrames_Auras"]
    if Auras and Auras.Create then
        Auras:Create(frame)
    end
    frame:RegisterUnitEvent("UNIT_AURA", unit)
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            local unitId = ...
            if unitId == unit and Auras and Auras.Update then
                Auras:Update(self, unit)
            end
        end
    end)

    -- Update Frame position and strata
    frame:SetFrameStrata(MinimalUnitFramesDB.strata)
    addon.UpdateFramePosition(frame, unit)
    UpdateFrame(frame, unit)
    frame:Show()

    return frame
end

--- Updates the border visibility
local function UpdateBorderVisibility()
    local frames = {addon.playerFrame, addon.targetFrame, addon.targettargetFrame, addon.petFrame, addon.petTargetFrame}
    for _, frame in ipairs(frames) do
        if frame and frame.barsFrame then
            if MinimalUnitFramesDB.showBorder then
                frame.barsFrame:SetBackdropBorderColor(unpack(addon.Config.frameBackdrop.colors.border))
            else
                frame.barsFrame:SetBackdropBorderColor(0, 0, 0, 0)
            end
        end
    end
end

--- Updates the frame size
---@param frame any UnitFrame
---@param unit string
local function UpdateFrameSize(frame, unit)
    local width, height
    if unit == "player" then
        width = MinimalUnitFramesDB.playerWidth or addon.Config.defaultConfig.width
        height = MinimalUnitFramesDB.playerHeight or addon.Config.defaultConfig.height
    elseif unit == "target" then
        width = MinimalUnitFramesDB.targetWidth or addon.Config.defaultConfig.width
        height = MinimalUnitFramesDB.targetHeight or addon.Config.defaultConfig.height
    elseif unit == "targettarget" then
        width = MinimalUnitFramesDB.targettargetWidth or addon.Config.defaultConfig.width
        height = MinimalUnitFramesDB.targettargetHeight or addon.Config.defaultConfig.height
    elseif unit == "pet" then
        width = MinimalUnitFramesDB.petWidth or addon.Config.defaultConfig.width
        height = MinimalUnitFramesDB.petHeight or addon.Config.defaultConfig.height
    elseif unit == "pettarget" then
        width = MinimalUnitFramesDB.petTargetWidth or addon.Config.defaultConfig.width
        height = MinimalUnitFramesDB.petTargetHeight or addon.Config.defaultConfig.height
    else
        width = addon.Config.defaultConfig.width
        height = addon.Config.defaultConfig.height
    end

    frame:SetSize(width, height)
    frame.healthBar:SetHeight(height * 0.5)
    frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -1)
    frame.powerBar:SetPoint("BOTTOMRIGHT", frame.barsFrame, "BOTTOMRIGHT", -5, 5)
end

--- Updates the frame position
---@param frame any UnitFrame
---@param unit string
local function UpdateFramePosition(frame, unit)
    local xPos, yPos, anchor
    if unit == "player" then
        xPos = MinimalUnitFramesDB.playerXPos
        yPos = MinimalUnitFramesDB.playerYPos
        anchor = MinimalUnitFramesDB.playerAnchor
    elseif unit == "target" then
        xPos = MinimalUnitFramesDB.targetXPos
        yPos = MinimalUnitFramesDB.targetYPos
        anchor = MinimalUnitFramesDB.targetAnchor
    elseif unit == "targettarget" then
        xPos = MinimalUnitFramesDB.targettargetXPos
        yPos = MinimalUnitFramesDB.targettargetYPos
        anchor = MinimalUnitFramesDB.targettargetAnchor
    elseif unit == "pet" then
        xPos = MinimalUnitFramesDB.petXPos
        yPos = MinimalUnitFramesDB.petYPos
        anchor = MinimalUnitFramesDB.petAnchor
    elseif unit == "pettarget" then
        xPos = MinimalUnitFramesDB.petTargetXPos
        yPos = MinimalUnitFramesDB.petTargetYPos
        anchor = MinimalUnitFramesDB.petTargetAnchor
    end

    if frame and xPos and yPos and anchor then
        frame:ClearAllPoints()
        frame:SetPoint(anchor, UIParent, "CENTER", xPos, yPos)
    end
end

--- Updates the frame strata
---@param frame any UnitFrame
---@param unit string
local function UpdateFrameStrata(frame, unit)
    local strata = MinimalUnitFramesDB[unit .. "Strata"] or addon.Config.defaultConfig[unit .. "Strata"] or "MEDIUM"
    frame:SetFrameStrata(strata)
end

--- Updates the bar texture
local function UpdateBarTexture()
    local textureName = MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture
    local texture = media("statusbar", textureName)
    if not texture then
        texture = addon.Config.media.statusbar.Blizzard
    end

    playerFrame.healthBar:SetStatusBarTexture(texture)
    playerFrame.powerBar:SetStatusBarTexture(texture)
    playerFrame.absorbBar:SetStatusBarTexture(texture)
    targetFrame.healthBar:SetStatusBarTexture(texture)
    targetFrame.powerBar:SetStatusBarTexture(texture)
    targetFrame.absorbBar:SetStatusBarTexture(texture)
end

--- Updates the font
local function UpdateFont()
    local fontName = MinimalUnitFramesDB.font or addon.Config.defaultConfig.font
    local fontSize = MinimalUnitFramesDB.fontsize or addon.Config.defaultConfig.fontsize
    local fontStyle = MinimalUnitFramesDB.fontstyle or addon.Config.defaultConfig.fontstyle
    local font = media("font", fontName)
    if not font then
        font = addon.Config.media.font.FrizQuadrataTT
    end

    local function updateFontForFrame(frame)
        frame.nameText:SetFont(font, fontSize, fontStyle)
        frame.levelText:SetFont(font, fontSize, fontStyle)
        frame.healthText:SetFont(font, fontSize, fontStyle)
        frame.powerText:SetFont(font, fontSize, fontStyle)
    end

    updateFontForFrame(playerFrame)
    updateFontForFrame(targetFrame)
    updateFontForFrame(targettargetFrame)
    updateFontForFrame(petFrame)
    updateFontForFrame(petTargetFrame)
end

--- Updates the text visibility
---@param unit string
local function UpdateTextVisibility(unit)
    local function updateFrameText(frame, showText)
        frame.healthText:SetShown(showText)
        frame.powerText:SetShown(showText)
    end

    if unit == "player" or not unit then
        updateFrameText(playerFrame, MinimalUnitFramesDB.showPlayerText)
    end
    if unit == "target" or not unit then
        updateFrameText(targetFrame, MinimalUnitFramesDB.showTargetText)
    end
    if unit == "targettarget" or not unit then
        updateFrameText(targettargetFrame, MinimalUnitFramesDB.showTargetTargetText)
    end
    if unit == "pet" or not unit then
        updateFrameText(petFrame, MinimalUnitFramesDB.showPetText)
    end
    if unit == "pettarget" or not unit then
        updateFrameText(petTargetFrame, MinimalUnitFramesDB.showPetTargetText)
    end
end

--- Updates the frames visibility
local function UpdateFramesVisibility()
    local frames = {{
        frame = addon.playerFrame,
        unit = "player"
    }, {
        frame = addon.targetFrame,
        unit = "target"
    }, {
        frame = addon.targettargetFrame,
        unit = "targettarget"
    }, {
        frame = addon.petFrame,
        unit = "pet"
    }, {
        frame = addon.petTargetFrame,
        unit = "pettarget"
    }}

    for _, frameInfo in ipairs(frames) do
        local showOption = MinimalUnitFramesDB["show" .. frameInfo.unit:gsub("^%l", string.upper) .. "Frame"]
        if UnitExists(frameInfo.unit) and showOption then
            addon.ToggleFrameVisibility(frameInfo.frame, true)
            UpdateFrame(frameInfo.frame, frameInfo.unit)
        else
            addon.ToggleFrameVisibility(frameInfo.frame, false)
        end
    end
end

--- Toggles the visibility of a frame
---@param frame any UnitFrame
---@param show boolean
local function ToggleFrameVisibility(frame, show)
    if show then
        frame:Show()
        frame:RegisterAllEvents()
    else
        frame:Hide()
        frame:UnregisterAllEvents()
    end
end

--- Toggles the visibility of Blizzard frames
---@param show boolean
local function ToggleBlizzardFrames(show)
    local function SetFrameState(frame)
        if show then
            frame:Show()
            frame:RegisterAllEvents()
        else
            frame:Hide()
            frame:UnregisterAllEvents()
        end
    end

    SetFrameState(PlayerFrame)
    SetFrameState(TargetFrame)
    SetFrameState(FocusFrame)

    if show then
        if UnitExists("target") then
            TargetFrame:Show()
        else
            TargetFrame:Hide()
        end
        if UnitExists("focus") then
            FocusFrame:Show()
        else
            FocusFrame:Hide()
        end

        for i = 1, MAX_BOSS_FRAMES do
            local bossFrame = _G["Boss" .. i .. "TargetFrame"]
            if bossFrame then
                if UnitExists("boss" .. i) then
                    bossFrame:Show()
                else
                    bossFrame:Hide()
                end
            end
        end
    end
end

addon.UpdateBorderVisibility = UpdateBorderVisibility
addon.UpdateFrameSize = UpdateFrameSize
addon.UpdateFramePosition = UpdateFramePosition
addon.UpdateFrameStrata = UpdateFrameStrata
addon.UpdateBarTexture = UpdateBarTexture
addon.UpdateFont = UpdateFont
addon.UpdateTextVisibility = UpdateTextVisibility
addon.UpdateFramesVisibility = UpdateFramesVisibility
addon.ToggleFrameVisibility = ToggleFrameVisibility
addon.ToggleBlizzardFrames = ToggleBlizzardFrames

--- Initializes the addon
local function InitializeAddon()
    if not MinimalUnitFramesDB then
        MinimalUnitFramesDB = {}
    end

    MinimalUnitFramesDB.showTargetTarget = MinimalUnitFramesDB.showTargetTarget or addon.Config.defaultConfig.showTargetTarget
    MinimalUnitFramesDB.showPet = MinimalUnitFramesDB.showPet or addon.Config.defaultConfig.showPet
    MinimalUnitFramesDB.showPetTarget = MinimalUnitFramesDB.showPetTarget or addon.Config.defaultConfig.showPetTarget
    MinimalUnitFramesDB.showPlayerBuffs = MinimalUnitFramesDB.showPlayerBuffs or addon.Config.defaultConfig.showPlayerBuffs
    MinimalUnitFramesDB.showTargetBuffs = MinimalUnitFramesDB.showTargetBuffs or addon.Config.defaultConfig.showTargetBuffs
    MinimalUnitFramesDB.showPlayerDebuffs = MinimalUnitFramesDB.showPlayerDebuffs or addon.Config.defaultConfig.showPlayerDebuffs
    MinimalUnitFramesDB.showTargetDebuffs = MinimalUnitFramesDB.showTargetDebuffs or addon.Config.defaultConfig.showTargetDebuffs

    MinimalUnitFramesDB.showPlayerText = MinimalUnitFramesDB.showPlayerText or addon.Config.defaultConfig.showPlayerText
    MinimalUnitFramesDB.showTargetText = MinimalUnitFramesDB.showTargetText or addon.Config.defaultConfig.showTargetText
    MinimalUnitFramesDB.showTargetTargetText = MinimalUnitFramesDB.showTargetTargetText or addon.Config.defaultConfig.showTargetTargetText
    MinimalUnitFramesDB.showPetText = MinimalUnitFramesDB.showPetText or addon.Config.defaultConfig.showPetText
    MinimalUnitFramesDB.showPetTargetText = MinimalUnitFramesDB.showPetTargetText or addon.Config.defaultConfig.showPetTargetText

    MinimalUnitFramesDB.playerWidth = MinimalUnitFramesDB.playerWidth or addon.Config.defaultConfig.width
    MinimalUnitFramesDB.playerHeight = MinimalUnitFramesDB.playerHeight or addon.Config.defaultConfig.height
    MinimalUnitFramesDB.playerXPos = MinimalUnitFramesDB.playerXPos or addon.Config.defaultConfig.playerXPos
    MinimalUnitFramesDB.playerYPos = MinimalUnitFramesDB.playerYPos or addon.Config.defaultConfig.playerYPos
    MinimalUnitFramesDB.playerStrata = MinimalUnitFramesDB.playerStrata or addon.Config.defaultConfig.playerStrata
    MinimalUnitFramesDB.playerAnchor = MinimalUnitFramesDB.playerAnchor or addon.Config.defaultConfig.playerAnchor

    MinimalUnitFramesDB.targetWidth = MinimalUnitFramesDB.targetWidth or addon.Config.defaultConfig.width
    MinimalUnitFramesDB.targetHeight = MinimalUnitFramesDB.targetHeight or addon.Config.defaultConfig.height
    MinimalUnitFramesDB.targetXPos = MinimalUnitFramesDB.targetXPos or addon.Config.defaultConfig.targetXPos
    MinimalUnitFramesDB.targetYPos = MinimalUnitFramesDB.targetYPos or addon.Config.defaultConfig.targetYPos
    MinimalUnitFramesDB.targetStrata = MinimalUnitFramesDB.targetStrata or addon.Config.defaultConfig.targetStrata
    MinimalUnitFramesDB.targetAnchor = MinimalUnitFramesDB.targetAnchor or addon.Config.defaultConfig.targetAnchor

    MinimalUnitFramesDB.targettargetWidth = MinimalUnitFramesDB.targettargetWidth or addon.Config.defaultConfig.width
    MinimalUnitFramesDB.targettargetHeight = MinimalUnitFramesDB.targettargetHeight or addon.Config.defaultConfig.height
    MinimalUnitFramesDB.targettargetXPos = MinimalUnitFramesDB.targettargetXPos or addon.Config.defaultConfig.targettargetXPos
    MinimalUnitFramesDB.targettargetYPos = MinimalUnitFramesDB.targettargetYPos or addon.Config.defaultConfig.targettargetYPos
    MinimalUnitFramesDB.targettargetStrata = MinimalUnitFramesDB.targettargetStrata or addon.Config.defaultConfig.targettargetStrata
    MinimalUnitFramesDB.targettargetAnchor = MinimalUnitFramesDB.targettargetAnchor or addon.Config.defaultConfig.targettargetAnchor

    MinimalUnitFramesDB.petWidth = MinimalUnitFramesDB.petWidth or addon.Config.defaultConfig.width
    MinimalUnitFramesDB.petHeight = MinimalUnitFramesDB.petHeight or addon.Config.defaultConfig.height
    MinimalUnitFramesDB.petXPos = MinimalUnitFramesDB.petXPos or addon.Config.defaultConfig.petXPos
    MinimalUnitFramesDB.petYPos = MinimalUnitFramesDB.petYPos or addon.Config.defaultConfig.petYPos
    MinimalUnitFramesDB.petStrata = MinimalUnitFramesDB.petStrata or addon.Config.defaultConfig.petStrata
    MinimalUnitFramesDB.petAnchor = MinimalUnitFramesDB.petAnchor or addon.Config.defaultConfig.petAnchor

    MinimalUnitFramesDB.petTargetWidth = MinimalUnitFramesDB.petTargetWidth or addon.Config.defaultConfig.width
    MinimalUnitFramesDB.petTargetHeight = MinimalUnitFramesDB.petTargetHeight or addon.Config.defaultConfig.height
    MinimalUnitFramesDB.petTargetXPos = MinimalUnitFramesDB.petTargetXPos or addon.Config.defaultConfig.petTargetXPos
    MinimalUnitFramesDB.petTargetYPos = MinimalUnitFramesDB.petTargetYPos or addon.Config.defaultConfig.petTargetYPos
    MinimalUnitFramesDB.petTargetStrata = MinimalUnitFramesDB.petTargetStrata or addon.Config.defaultConfig.petTargetStrata
    MinimalUnitFramesDB.petTargetAnchor = MinimalUnitFramesDB.petTargetAnchor or addon.Config.defaultConfig.petTargetAnchor

    MinimalUnitFramesDB.showBorder = MinimalUnitFramesDB.showBorder or addon.Config.defaultConfig.showBorder
    MinimalUnitFramesDB.showBlizzardFrames = MinimalUnitFramesDB.showBlizzardFrames or addon.Config.defaultConfig.showBlizzardFrames
    MinimalUnitFramesDB.showPlayerFrame = MinimalUnitFramesDB.showPlayerFrame or addon.Config.defaultConfig.showPlayerFrame
    MinimalUnitFramesDB.showTargetFrame = MinimalUnitFramesDB.showTargetFrame or addon.Config.defaultConfig.showTargetFrame
    MinimalUnitFramesDB.showTargettargetFrame = MinimalUnitFramesDB.showTargettargetFrame or addon.Config.defaultConfig.showTargettargetFrame
    MinimalUnitFramesDB.showPetFrame = MinimalUnitFramesDB.showPetFrame or addon.Config.defaultConfig.showPetFrame
    MinimalUnitFramesDB.showPetTargetFrame = MinimalUnitFramesDB.showPetTargetFrame or addon.Config.defaultConfig.showPetTargetFrame

    MinimalUnitFramesDB.font = MinimalUnitFramesDB.font or addon.Config.defaultConfig.font
    MinimalUnitFramesDB.fontsize = MinimalUnitFramesDB.fontsize or addon.Config.defaultConfig.fontsize
    MinimalUnitFramesDB.fontstyle = MinimalUnitFramesDB.fontstyle or addon.Config.defaultConfig.fontstyle

    playerFrame = CreateUnitFrame("player")
    targetFrame = CreateUnitFrame("target")
    targettargetFrame = CreateUnitFrame("targettarget")
    petFrame = CreateUnitFrame("pet")
    petTargetFrame = CreateUnitFrame("pettarget")

    addon.playerFrame = playerFrame
    addon.targetFrame = targetFrame
    addon.targettargetFrame = targettargetFrame
    addon.petFrame = petFrame
    addon.petTargetFrame = petTargetFrame

    UpdateFrameSize(addon.playerFrame, "player")
    UpdateFrameSize(addon.targetFrame, "target")
    UpdateFrameSize(addon.targettargetFrame, "targettarget")
    UpdateFrameSize(addon.petFrame, "pet")
    UpdateFrameSize(addon.petTargetFrame, "pettarget")

    UpdateFramePosition(addon.playerFrame, "player")
    UpdateFramePosition(addon.targetFrame, "target")
    UpdateFramePosition(addon.targettargetFrame, "targettarget")
    UpdateFramePosition(addon.petFrame, "pet")
    UpdateFramePosition(addon.petTargetFrame, "pettarget")

    UpdateFrameStrata(addon.playerFrame, "player")
    UpdateFrameStrata(addon.targetFrame, "target")
    UpdateFrameStrata(addon.targettargetFrame, "targettarget")
    UpdateFrameStrata(addon.petFrame, "pet")
    UpdateFrameStrata(addon.petTargetFrame, "pettarget")

    UpdateBorderVisibility()
    UpdateBarTexture()
    UpdateFont()
    UpdateTextVisibility()

    SetupFrame(playerFrame, "player")
    SetupFrame(targetFrame, "target")
    SetupFrame(targettargetFrame, "targettarget")
    SetupFrame(petFrame, "pet")
    SetupFrame(petTargetFrame, "pettarget")

    playerFrame:Show()
    targetFrame:Hide()
    targettargetFrame:Hide()
    petFrame:Hide()
    petTargetFrame:Hide()

    addon.ToggleFrameVisibility(targettargetFrame, MinimalUnitFramesDB.showTargettargetFrame)
    addon.ToggleFrameVisibility(petFrame, MinimalUnitFramesDB.showPet)
    addon.ToggleFrameVisibility(petTargetFrame, MinimalUnitFramesDB.showPetTarget)
    addon.ToggleBlizzardFrames(MinimalUnitFramesDB.showBlizzardFrames)
    TargetFrame:HookScript("OnShow", function(self)
        if not MinimalUnitFramesDB.showBlizzardFrames then
            C_Timer.After(0, function()
                addon.ToggleBlizzardFrames(false)
            end)
        end
    end)
end

--- Handles events
---@param self any UnitFrame
---@param event string
---@param arg1 string
---@param ... any
local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MinimalUnitFrames" then
        InitializeAddon()
        eventFrame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitExists("target") then
            targetFrame:Show()
            UpdateFrame(targetFrame, "target")
            if not MinimalUnitFramesDB.showBlizzardFrames then
                TargetFrame:Hide()
            end
        else
            targetFrame:Hide()
        end
        UpdateFramesVisibility()
    elseif event == "UNIT_PET" and arg1 == "player" then
        UpdateFramesVisibility()
    elseif event == "UNIT_TARGET" then
        if arg1 == "pet" or arg1 == "target" then
            UpdateFramesVisibility()
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_UPDATE" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_LEVEL" or event == "UNIT_NAME_UPDATE" then
        if arg1 == "player" then
            UpdateFrame(playerFrame, "player")
        elseif arg1 == "target" and UnitExists("target") then
            UpdateFrame(targetFrame, "target")
        elseif arg1 == "pet" and UnitExists("pet") then
            UpdateFrame(petFrame, "pet")
        elseif arg1 == "targettarget" and UnitExists("targettarget") then
            UpdateFrame(targettargetFrame, "targettarget")
        elseif arg1 == "pettarget" and UnitExists("pettarget") then
            UpdateFrame(petTargetFrame, "pettarget")
        end
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        if arg1 == "player" then
            UpdateFrame(playerFrame, "player")
        elseif arg1 == "target" and UnitExists("target") then
            UpdateFrame(targetFrame, "target")
        end
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_REGEN_ENABLED" or event == "GROUP_ROSTER_UPDATE" then
        C_Timer.After(0.1, function()
            addon.ToggleBlizzardFrames(MinimalUnitFramesDB.showBlizzardFrames)
            UpdateFrame(playerFrame, "player")
            if UnitExists("target") then
                UpdateFrame(targetFrame, "target")
            end
            UpdateFramesVisibility()
        end)
    end
end

-- Slash commands
SLASH_MINIMALUNITFRAMES1 = "/muf"
SlashCmdList["MINIMALUNITFRAMES"] = function(msg)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory("Minimal Unit Frames")
    else
        InterfaceOptionsFrame_OpenToCategory("Minimal Unit Frames")
    end
end

-- Register events to the event frame
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
eventFrame:RegisterEvent("UNIT_LEVEL")
eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
eventFrame:RegisterEvent("CVAR_UPDATE")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
eventFrame:RegisterEvent("UNIT_MAXPOWER")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
eventFrame:RegisterEvent("RUNE_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("UNIT_TARGET")
eventFrame:SetScript("OnEvent", OnEvent)
