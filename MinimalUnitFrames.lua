---@class MinimalUnitFrames
local addonName, addon = ...

MinimalUnitFramesDB = MinimalUnitFramesDB or {}
MinimalUnitFramesDB.showBorder = MinimalUnitFramesDB.showBorder or addon.Config.defaultConfig.showBorder
MinimalUnitFramesDB.showFrameBackdrop = MinimalUnitFramesDB.showFrameBackdrop or addon.Config.defaultConfig.showFrameBackdrop

local playerFrame, targetFrame, targetoftargetFrame, petFrame, petTargetFrame
local eventFrame = CreateFrame("Frame")

--- Hides the default Blizzard frames
local function SecureHideBlizzardFrames()
    local framesToHide = {PlayerFrame, TargetFrame, FocusFrame, PetFrame}

    --- Hides a frame
    ---@param frame any Frame
    local function hideFrame(frame)
        if frame then
            UnregisterUnitWatch(frame)
            frame:UnregisterAllEvents()
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", -400, 500)

            local healthBar = frame.healthBar or _G[frame:GetName() .. "HealthBar"]
            if healthBar then
                healthBar:UnregisterAllEvents()
            end
        end
    end

    for _, frame in ipairs(framesToHide) do
        hideFrame(frame)
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
    addon.UpdateFrame(frame, unit)
end

--- Creates a unit frame
---@param unit string
local function CreateUnitFrame(unit)
    local frame = CreateFrame("Button", "Minimal" .. unit .. "Frame", UIParent, "SecureUnitButtonTemplate,BackdropTemplate")

    frame:SetSize(addon.Config.defaultConfig.width, addon.Config.defaultConfig.height)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame.nameText = frame:CreateFontString(nil, "OVERLAY")
    frame.nameText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    frame.nameText:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 2)
    frame.nameText:SetTextColor(1, 1, 1)

    frame.levelText = frame:CreateFontString(nil, "OVERLAY")
    frame.levelText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    frame.levelText:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 2)
    frame.levelText:SetTextColor(1, 1, 1)

    frame.barsFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.barsFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.barsFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    if MinimalUnitFramesDB.showFrameBackdrop then
        frame.barsFrame:SetBackdrop(addon.Config.frameBackdrop.options)
        frame.barsFrame:SetBackdropColor(unpack(addon.Config.frameBackdrop.colors.bg))
        if MinimalUnitFramesDB.showBorder then
            frame.barsFrame:SetBackdropBorderColor(unpack(addon.Config.frameBackdrop.colors.border))
        else
            frame.barsFrame:SetBackdropBorderColor(0, 0, 0, 0)
        end
    end

    frame.healthBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    frame.healthBar:SetStatusBarTexture(addon.Util.FetchMedia("textures", MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture))

    frame.powerBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    frame.powerBar:SetStatusBarTexture(addon.Util.FetchMedia("textures", MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture))

    if unit == "player" then
        frame.resourceBar = addon.ClassResources:CreateResourceBar(frame)
        frame.resourceBar:Hide()
    end

    frame.healthText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.healthText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    frame.healthText:SetPoint("CENTER", frame.healthBar, "CENTER")
    frame.healthText:SetTextColor(1, 1, 1)

    frame.powerText = frame.powerBar:CreateFontString(nil, "OVERLAY")
    frame.powerText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    frame.powerText:SetPoint("CENTER", frame.powerBar, "CENTER")
    frame.powerText:SetTextColor(1, 1, 1)

    frame.absorbBar = CreateFrame("StatusBar", nil, frame.healthBar)
    frame.absorbBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")
    frame.absorbBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT")
    frame.absorbBar:SetStatusBarTexture(addon.Util.FetchMedia("textures", MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture))
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
    if addon.Auras and addon.Auras.Create then
        addon.Auras:Create(frame)
    end
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            local unitId = ...
            if unitId == unit and addon.Auras and addon.Auras.Update then
                addon.Auras:Update(self, unit)
            end
        end
    end)
    frame:RegisterUnitEvent("UNIT_AURA", unit)

    -- Update Frame position and strata
    frame:SetFrameStrata(MinimalUnitFramesDB.strata or addon.Config.defaultConfig.strata)
    addon.UpdateFramePosition(frame, unit)
    addon.UpdateFrame(frame, unit)
    frame:Show()

    if unit == "player" then
        addon.CombatText:CreateCombatFeedback(frame)
        frame:RegisterEvent("UNIT_COMBAT")
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:HookScript("OnEvent", function(self, event, ...)
            if MinimalUnitFramesDB.showCombatFeedback then
                addon.CombatText:OnEvent(self, event, ...)
            end
        end)
    end

    return frame
end

--- Updates the frame
---@param frame any UnitFrame
---@param unit string
function addon.UpdateFrame(frame, unit)
    if not frame then
        return
    end

    if unit == "targetoftarget" then
        unit = "targettarget"
    end

    --- Sets the value of a status bar
    ---@param statusBar any StatusBar
    ---@param value number
    ---@param maxValue number
    local function SafeSetValue(statusBar, value, maxValue)
        if not InCombatLockdown() then
            statusBar:SetMinMaxValues(0, maxValue)
            statusBar:SetValue(value)
        else
            C_Timer.After(0, function()
                statusBar:SetMinMaxValues(0, maxValue)
                statusBar:SetValue(value)
            end)
        end
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)
    local absorb = UnitGetTotalAbsorbs(unit) or 0

    SafeSetValue(frame.healthBar, health, maxHealth)
    SafeSetValue(frame.powerBar, power, maxPower)
    SafeSetValue(frame.absorbBar, absorb, maxHealth)

    frame.healthText:SetText(addon.Util.FormatBarText(health, maxHealth, unit))
    frame.powerText:SetText(addon.Util.FormatBarText(power, maxPower, unit))
    frame.absorbBar:SetWidth(frame.healthBar:GetWidth() * (absorb / maxHealth))

    if unit == "player" then
        if MinimalUnitFramesDB.useClassColorsPlayer then
            frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
        else
            frame.healthBar:SetStatusBarColor(unpack(addon.Config.defaultConfig.customColorPlayer))
        end
    elseif unit == "target" then
        if MinimalUnitFramesDB.useClassColorsTarget then
            frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
        else
            frame.healthBar:SetStatusBarColor(unpack(addon.Config.defaultConfig.customColorTarget))
        end
    elseif unit == "targettarget" then
        if MinimalUnitFramesDB.useClassColorsTargetoftarget then
            local color = addon.Util.GetBarColor(unit, true)
            frame.healthBar:SetStatusBarColor(unpack(color))
        else
            frame.healthBar:SetStatusBarColor(unpack(addon.Config.defaultConfig.customColorTargetoftarget))
        end
    elseif unit == "pet" then
        if MinimalUnitFramesDB.useClassColorsPet then
            frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
        else
            frame.healthBar:SetStatusBarColor(unpack(addon.Config.defaultConfig.customColorPet))
        end
    elseif unit == "pettarget" then
        if MinimalUnitFramesDB.useClassColorsPetTarget then
            frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
        else
            frame.healthBar:SetStatusBarColor(unpack(addon.Config.defaultConfig.customColorPetTarget))
        end
    end
    frame.powerBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, false)))

    frame.nameText:SetText(UnitName(unit))
    frame.levelText:SetText(UnitLevel(unit))

    if addon.Auras and addon.Auras.Update then
        addon.Auras:Update(frame, unit)
    end

    if addon.ClassResources and unit == "player" and MinimalUnitFramesDB.enableClassResources and addon.ClassResources:HasClassResources() then
        addon.ClassResources:UpdateResourceBar(frame, unit)
    end

    if UnitExists(unit) or unit == "player" then
        frame:Show()
    else
        frame:Hide()
    end
end

--- Updates the border visibility
function addon.UpdateBorderVisibility()
    local frames = {addon.playerFrame, addon.targetFrame, addon.targetoftargetFrame, addon.petFrame, addon.petTargetFrame}
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
function addon.UpdateFrameSize(frame, unit)
    local width, height = addon.Util.GetFrameDimensions(unit)
    frame:SetSize(width, height)
    frame.barsFrame:SetSize(width, height)

    local hasResourceBar = frame.resourceBar and frame.resourceBar:IsShown()
    local showPowerBar = frame.powerBar:IsShown()
    local healthHeight, powerHeight, resourceHeight

    local availableHeight = height - 10

    if hasResourceBar then
        if showPowerBar then
            healthHeight = availableHeight * 0.5
            powerHeight = availableHeight * 0.25
            resourceHeight = availableHeight * 0.25
        else
            healthHeight = availableHeight * 0.75
            powerHeight = 0
            resourceHeight = availableHeight * 0.25
        end
    else
        if showPowerBar then
            healthHeight = availableHeight * 0.7
            powerHeight = availableHeight * 0.3
        else
            healthHeight = availableHeight
            powerHeight = 0
        end
        resourceHeight = 0
    end

    frame.healthBar:ClearAllPoints()
    frame.powerBar:ClearAllPoints()
    frame.healthBar:SetPoint("TOPLEFT", frame.barsFrame, "TOPLEFT", 5, -5)
    frame.healthBar:SetPoint("TOPRIGHT", frame.barsFrame, "TOPRIGHT", -5, -5)
    frame.healthBar:SetHeight(healthHeight)

    if showPowerBar then
        frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -1)
        frame.powerBar:SetPoint("TOPRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, -1)
        frame.powerBar:SetHeight(powerHeight)
    end

    if frame.resourceBar then
        frame.resourceBar:ClearAllPoints()
        if hasResourceBar then
            frame.resourceBar:SetPoint("TOPLEFT", showPowerBar and frame.powerBar or frame.healthBar, "BOTTOMLEFT", 0, -1)
            frame.resourceBar:SetPoint("TOPRIGHT", showPowerBar and frame.powerBar or frame.healthBar, "BOTTOMRIGHT", 0, -1)
            frame.resourceBar:SetHeight(resourceHeight)
            frame.resourceBar:Show()
        else
            frame.resourceBar:Hide()
        end
    end
end

--- Updates the frame position
---@param frame any UnitFrame
---@param unit string
function addon.UpdateFramePosition(frame, unit)
    ---@param frame any UnitFrame
    ---@param point string
    ---@param relativeFrame any
    ---@param relativePoint string
    ---@param offsetX number
    ---@param offsetY number
    local function SafeSetPoint(frame, point, relativeFrame, relativePoint, offsetX, offsetY)
        if not InCombatLockdown() then
            frame:ClearAllPoints()
            frame:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
        else
            C_Timer.After(0, function()
                if not InCombatLockdown() then
                    frame:ClearAllPoints()
                    frame:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
                end
            end)
        end
    end

    local xPos, yPos, anchor
    if unit == "player" then
        xPos = MinimalUnitFramesDB.playerXPos or addon.Config.defaultConfig.playerXPos
        yPos = MinimalUnitFramesDB.playerYPos or addon.Config.defaultConfig.playerYPos
        anchor = MinimalUnitFramesDB.playerAnchor or addon.Config.defaultConfig.playerAnchor
    elseif unit == "target" then
        xPos = MinimalUnitFramesDB.targetXPos or addon.Config.defaultConfig.targetXPos
        yPos = MinimalUnitFramesDB.targetYPos or addon.Config.defaultConfig.targetYPos
        anchor = MinimalUnitFramesDB.targetAnchor or addon.Config.defaultConfig.targetAnchor
    elseif unit == "targetoftarget" then
        xPos = MinimalUnitFramesDB.targetoftargetXPos or addon.Config.defaultConfig.targetoftargetXPos
        yPos = MinimalUnitFramesDB.targetoftargetYPos or addon.Config.defaultConfig.targetoftargetYPos
        anchor = MinimalUnitFramesDB.targetoftargetAnchor or addon.Config.defaultConfig.targetoftargetAnchor
    elseif unit == "pet" then
        xPos = MinimalUnitFramesDB.petXPos or addon.Config.defaultConfig.petXPos
        yPos = MinimalUnitFramesDB.petYPos or addon.Config.defaultConfig.petYPos
        anchor = MinimalUnitFramesDB.petAnchor or addon.Config.defaultConfig.petAnchor
    elseif unit == "pettarget" then
        xPos = MinimalUnitFramesDB.petTargetXPos or addon.Config.defaultConfig.petTargetXPos
        yPos = MinimalUnitFramesDB.petTargetYPos or addon.Config.defaultConfig.petTargetYPos
        anchor = MinimalUnitFramesDB.petTargetAnchor or addon.Config.defaultConfig.petTargetAnchor
    end

    local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
    local frameWidth, frameHeight = frame:GetSize()
    local point, relativeFrame, relativePoint, offsetX, offsetY

    if anchor == "LEFT" then
        point, relativeFrame, relativePoint = "LEFT", UIParent, "LEFT"
        offsetX, offsetY = xPos, yPos - screenHeight / 2 + frameHeight / 2
    elseif anchor == "RIGHT" then
        point, relativeFrame, relativePoint = "RIGHT", UIParent, "RIGHT"
        offsetX, offsetY = -xPos, yPos - screenHeight / 2 + frameHeight / 2
    elseif anchor == "TOP" then
        point, relativeFrame, relativePoint = "TOP", UIParent, "TOP"
        offsetX, offsetY = xPos - screenWidth / 2 + frameWidth / 2, -yPos
    elseif anchor == "BOTTOM" then
        point, relativeFrame, relativePoint = "BOTTOM", UIParent, "BOTTOM"
        offsetX, offsetY = xPos - screenWidth / 2 + frameWidth / 2, yPos
    elseif anchor == "TOPLEFT" then
        point, relativeFrame, relativePoint = "TOPLEFT", UIParent, "TOPLEFT"
        offsetX, offsetY = xPos, -yPos
    elseif anchor == "TOPRIGHT" then
        point, relativeFrame, relativePoint = "TOPRIGHT", UIParent, "TOPRIGHT"
        offsetX, offsetY = -xPos, -yPos
    elseif anchor == "BOTTOMLEFT" then
        point, relativeFrame, relativePoint = "BOTTOMLEFT", UIParent, "BOTTOMLEFT"
        offsetX, offsetY = xPos, yPos
    elseif anchor == "BOTTOMRIGHT" then
        point, relativeFrame, relativePoint = "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT"
        offsetX, offsetY = -xPos, yPos
    else
        point, relativeFrame, relativePoint = "CENTER", UIParent, "CENTER"
        offsetX, offsetY = xPos, yPos
    end

    SafeSetPoint(frame, point, relativeFrame, relativePoint, offsetX, offsetY)
end

--- Updates the frame strata
---@param frame any UnitFrame
---@param unit string
function addon.UpdateFrameStrata(frame, unit)
    if not frame then
        print("Error: Frame for unit '" .. unit .. "' does not exist.")
        return
    end
    local strataKey = unit:gsub(" ", ""):lower() .. "Strata"
    local strata = MinimalUnitFramesDB[strataKey] or addon.Config.defaultConfig[strataKey] or "MEDIUM"
    frame:SetFrameStrata(strata)
end

--- Updates the frame anchor
---@param frame any UnitFrame
---@param unit string
function addon.UpdateFrameAnchor(frame, unit)
    local anchor = MinimalUnitFramesDB[unit .. "Anchor"] or addon.Config.defaultConfig[unit .. "Anchor"] or "CENTER"
    local xPos = MinimalUnitFramesDB[unit .. "XPos"] or addon.Config.defaultConfig[unit .. "XPos"] or 0
    local yPos = MinimalUnitFramesDB[unit .. "YPos"] or addon.Config.defaultConfig[unit .. "YPos"] or 0

    frame:ClearAllPoints()
    frame:SetPoint(anchor, UIParent, "CENTER", xPos, yPos)
end

--- Updates the bar texture
function addon.UpdateBarTexture()
    local textureName = MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture
    local texture = addon.Util.FetchMedia("textures", textureName)
    if not texture then
        texture = addon.Util.FetchMedia("textures", addon.Config.defaultConfig.barTexture)
    end

    playerFrame.healthBar:SetStatusBarTexture(texture)
    playerFrame.powerBar:SetStatusBarTexture(texture)
    playerFrame.absorbBar:SetStatusBarTexture(texture)
    targetFrame.healthBar:SetStatusBarTexture(texture)
    targetFrame.powerBar:SetStatusBarTexture(texture)
    targetFrame.absorbBar:SetStatusBarTexture(texture)

    if playerFrame.resourceBar then
        playerFrame.resourceBar:SetStatusBarTexture(texture)
    end

    if addon.ClassResources and addon.ClassResources.UpdateBarTexture then
        addon.ClassResources:UpdateBarTexture(texture)
    end
end

--- Updates the font
function addon.UpdateFont()
    local fontName = MinimalUnitFramesDB.font or addon.Config.defaultConfig.font
    local fontSize = MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize
    local fontStyle = MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle
    local font = addon.Util.FetchMedia("fonts", fontName)
    if not font then
        font = addon.Util.FetchMedia("fonts", addon.Config.defaultConfig.font)
    end

    --- Updates the font for a frame
    ---@param frame any UnitFrame
    ---@param unit string
    local function updateFontForFrame(frame, unit)
        if frame.nameText then
            frame.nameText:SetFont(font, fontSize, fontStyle)
        end
        if frame.levelText then
            frame.levelText:SetFont(font, fontSize, fontStyle)
        end
        if frame.healthText then
            frame.healthText:SetFont(font, fontSize, fontStyle)
        end
        if frame.powerText then
            frame.powerText:SetFont(font, fontSize, fontStyle)
        end
        if frame.resourceBar and frame.resourceBar.text then
            frame.resourceBar.text:SetFont(font, fontSize, fontStyle)
        end
    end

    updateFontForFrame(addon.playerFrame)
    updateFontForFrame(addon.targetFrame)
    updateFontForFrame(addon.targetoftargetFrame)
    updateFontForFrame(addon.petFrame)
    updateFontForFrame(addon.petTargetFrame)

    if addon.ClassResources and addon.ClassResources.UpdateFont then
        addon.ClassResources:UpdateFont(font, fontSize, fontStyle)
    end

    if addon.playerFrame and addon.playerFrame.feedbackText then
        addon.playerFrame.feedbackText:SetFont(MinimalUnitFramesDB.font or addon.Config.defaultConfig.font, (MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize) * 1.5, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    end
end

--- Updates the text visibility
---@param unit string
function addon.UpdateFrameTextVisibility(unit)
    --- Update the visibility of the text on the frames
    ---@param frame any UnitFrame
    ---@param showText boolean
    ---TODO: Pet frame text is not working
    local function updateFrameText(frame, showText)
        frame.healthText:SetShown(showText)
        frame.powerText:SetShown(showText)
        if frame.resourceBar and frame.resourceBar.text then
            frame.resourceBar.text:SetShown(showText)
        end
    end

    if unit == "player" or not unit then
        updateFrameText(playerFrame, MinimalUnitFramesDB.showPlayerFrameText)
        if addon.ClassResources and addon.ClassResources.UpdateFrameTextVisibility then
            addon.ClassResources:UpdateFrameTextVisibility(MinimalUnitFramesDB.showPlayerFrameText)
        end
    end
    if unit == "target" or not unit then
        updateFrameText(targetFrame, MinimalUnitFramesDB.showTargetFrameText)
    end
    if unit == "targetoftarget" or not unit then
        updateFrameText(targetoftargetFrame, MinimalUnitFramesDB.showTargetoftargetFrameText)
    end
    if unit == "pet" or not unit then
        updateFrameText(petFrame, MinimalUnitFramesDB.showPetFrameText)
    end
    if unit == "pettarget" or not unit then
        updateFrameText(petTargetFrame, MinimalUnitFramesDB.showPetTargetFrameText)
    end
end

--- Updates the level text visibility
function addon.UpdateLevelTextVisibility()
    addon.playerFrame.levelText:SetShown(MinimalUnitFramesDB.showPlayerLevelText)
    addon.targetFrame.levelText:SetShown(MinimalUnitFramesDB.showTargetLevelText)
    addon.targetoftargetFrame.levelText:SetShown(MinimalUnitFramesDB.showTargetoftargetLevelText)
    addon.petFrame.levelText:SetShown(MinimalUnitFramesDB.showPetLevelText)
    addon.petTargetFrame.levelText:SetShown(MinimalUnitFramesDB.showPetTargetLevelText)
end

--- Updates the frame backdrop visibility
function addon.UpdateFrameBackdropVisibility()
    local frames = {playerFrame, targetFrame, targetoftargetFrame, petFrame, petTargetFrame}
    for _, frame in ipairs(frames) do
        if frame and frame.barsFrame then
            if MinimalUnitFramesDB.showFrameBackdrop then
                frame.barsFrame:SetBackdrop(addon.Config.frameBackdrop.options)
                frame.barsFrame:SetBackdropColor(unpack(addon.Config.frameBackdrop.colors.bg))
                if MinimalUnitFramesDB.showBorder then
                    frame.barsFrame:SetBackdropBorderColor(unpack(addon.Config.frameBackdrop.colors.border))
                else
                    frame.barsFrame:SetBackdropBorderColor(0, 0, 0, 0)
                end
            else
                frame.barsFrame:SetBackdrop(nil)
            end
        end
    end
end

--- Updates the frames visibility
function addon.UpdateFramesVisibility()
    --- Update the visibility of the frames
    ---@param frame any UnitFrame
    ---@param unit string
    ---TODO: Pet target frame visibility is not working
    local function updateFrameVisibility(frame, unit)
        if not frame then
            return
        end

        local unitKey = unit:gsub(" ", ""):lower()
        local showOption = MinimalUnitFramesDB["show" .. unitKey:gsub("^%l", string.upper) .. "Frame"]
        local shouldShow = showOption and (unit == "player" or UnitExists(unit == "targetoftarget" and "targettarget" or unit))

        if InCombatLockdown() then
            C_Timer.After(0.1, function()
                updateFrameVisibility(frame, unit)
            end)
            return
        end

        if shouldShow then
            frame:Show()
            addon.UpdateFrame(frame, unit)
        else
            frame:Hide()
        end
    end

    updateFrameVisibility(addon.playerFrame, "player")
    updateFrameVisibility(addon.targetFrame, "target")
    updateFrameVisibility(addon.targetoftargetFrame, "targetoftarget")
    updateFrameVisibility(addon.petFrame, "pet")
    updateFrameVisibility(addon.petTargetFrame, "pettarget")
end

--- Handles the target change
---TODO: There must be a more efficient way
function addon.HandleTargetChange()
    addon.UpdateFrame(addon.targetFrame, "target")
    addon.UpdateFrame(addon.targetoftargetFrame, "targetoftarget")
    addon.UpdateFramesVisibility()
end

--- Updates the frame power bar visibility
---@param unit string
function addon.UpdateFramePowerBarVisibility(unit)
    local frame = addon[unit .. "Frame"]
    if frame then
        local showPowerBarKey = "show" .. unit:gsub("^%l", string.upper) .. "PowerBar"
        local showPowerBar = MinimalUnitFramesDB[showPowerBarKey]
        if showPowerBar == nil then
            showPowerBar = addon.Config.defaultConfig[showPowerBarKey]
        end
        frame.powerBar:SetShown(showPowerBar)
        addon.UpdateFrameSize(frame, unit)
        addon.UpdateFrame(frame, unit)
    end
end

--- Forces an update of all frames
function addon.UpdateAllFrames()
    addon.UpdateFrame(playerFrame, "player")
    addon.UpdateFrame(targetFrame, "target")
    addon.UpdateFrame(targetoftargetFrame, "targetoftarget")
    addon.UpdateFrame(petFrame, "pet")
    addon.UpdateFrame(petTargetFrame, "pettarget")

    if addon.ClassResources and MinimalUnitFramesDB.enableClassResources and addon.ClassResources:HasClassResources() then
        addon.ClassResources:UpdateResourceBar(playerFrame, "player")
    end
end

--- Updates the combat text visibility
function addon.UpdateCombatTextVisibility()
    if addon.playerFrame then
        if MinimalUnitFramesDB.enablePlayerCombatText then
            addon.playerFrame.feedbackFrame:Show()
        else
            addon.playerFrame.feedbackFrame:Hide()
        end
    end
end

--- Initializes the addon
local function InitializeAddon()
    if not MinimalUnitFramesDB then
        MinimalUnitFramesDB = {}
    end

    -- Initialize default values if not present
    MinimalUnitFramesDB.barTexture = MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture
    MinimalUnitFramesDB.font = MinimalUnitFramesDB.font or addon.Config.defaultConfig.font
    MinimalUnitFramesDB.fontSize = MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize
    MinimalUnitFramesDB.fontStyle = MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle
    MinimalUnitFramesDB.showCombatFeedback = MinimalUnitFramesDB.showCombatFeedback or addon.Config.defaultConfig.showCombatFeedback

    MinimalUnitFramesDB.showPlayerBuffs = MinimalUnitFramesDB.showPlayerBuffs or addon.Config.defaultConfig.showPlayerBuffs
    MinimalUnitFramesDB.showTargetBuffs = MinimalUnitFramesDB.showTargetBuffs or addon.Config.defaultConfig.showTargetBuffs
    MinimalUnitFramesDB.showPlayerDebuffs = MinimalUnitFramesDB.showPlayerDebuffs or addon.Config.defaultConfig.showPlayerDebuffs
    MinimalUnitFramesDB.showTargetDebuffs = MinimalUnitFramesDB.showTargetDebuffs or addon.Config.defaultConfig.showTargetDebuffs

    MinimalUnitFramesDB.showPlayerPowerBar = MinimalUnitFramesDB.showPlayerPowerBar or addon.Config.defaultConfig.showPlayerPowerBar
    MinimalUnitFramesDB.showTargetPowerBar = MinimalUnitFramesDB.showTargetPowerBar or addon.Config.defaultConfig.showTargetPowerBar
    MinimalUnitFramesDB.showTargetoftargetPowerBar = MinimalUnitFramesDB.showTargetoftargetPowerBar or addon.Config.defaultConfig.showTargetoftargetPowerBar
    MinimalUnitFramesDB.showPetPowerBar = MinimalUnitFramesDB.showPetPowerBar or addon.Config.defaultConfig.showPetPowerBar
    MinimalUnitFramesDB.showPetTargetPowerBar = MinimalUnitFramesDB.showPetTargetPowerBar or addon.Config.defaultConfig.showPetTargetPowerBar

    MinimalUnitFramesDB.showPlayerFrameText = MinimalUnitFramesDB.showPlayerFrameText or addon.Config.defaultConfig.showPlayerFrameText
    MinimalUnitFramesDB.showTargetFrameText = MinimalUnitFramesDB.showTargetFrameText or addon.Config.defaultConfig.showTargetFrameText
    MinimalUnitFramesDB.showTargetoftargetFrameText = MinimalUnitFramesDB.showTargetoftargetFrameText or addon.Config.defaultConfig.showTargetoftargetFrameText
    MinimalUnitFramesDB.showPetFrameText = MinimalUnitFramesDB.showPetFrameText or addon.Config.defaultConfig.showPetFrameText
    MinimalUnitFramesDB.showPetTargetFrameText = MinimalUnitFramesDB.showPetTargetFrameText or addon.Config.defaultConfig.showPetTargetFrameText

    MinimalUnitFramesDB.showPlayerLevelText = MinimalUnitFramesDB.showPlayerLevelText or addon.Config.defaultConfig.showPlayerLevelText
    MinimalUnitFramesDB.showTargetLevelText = MinimalUnitFramesDB.showTargetLevelText or addon.Config.defaultConfig.showTargetLevelText
    MinimalUnitFramesDB.showTargetoftargetLevelText = MinimalUnitFramesDB.showTargetoftargetLevelText or addon.Config.defaultConfig.showTargetoftargetLevelText
    MinimalUnitFramesDB.showPetLevelText = MinimalUnitFramesDB.showPetLevelText or addon.Config.defaultConfig.showPetLevelText
    MinimalUnitFramesDB.showPetTargetLevelText = MinimalUnitFramesDB.showPetTargetLevelText or addon.Config.defaultConfig.showPetTargetLevelText

    MinimalUnitFramesDB.playerWidth = MinimalUnitFramesDB.playerWidth or addon.Config.defaultConfig.playerWidth
    MinimalUnitFramesDB.playerHeight = MinimalUnitFramesDB.playerHeight or addon.Config.defaultConfig.playerHeight
    MinimalUnitFramesDB.playerXPos = MinimalUnitFramesDB.playerXPos or addon.Config.defaultConfig.playerXPos
    MinimalUnitFramesDB.playerYPos = MinimalUnitFramesDB.playerYPos or addon.Config.defaultConfig.playerYPos
    MinimalUnitFramesDB.playerStrata = MinimalUnitFramesDB.playerStrata or addon.Config.defaultConfig.playerStrata
    MinimalUnitFramesDB.playerAnchor = MinimalUnitFramesDB.playerAnchor or addon.Config.defaultConfig.playerAnchor

    MinimalUnitFramesDB.targetWidth = MinimalUnitFramesDB.targetWidth or addon.Config.defaultConfig.targetWidth
    MinimalUnitFramesDB.targetHeight = MinimalUnitFramesDB.targetHeight or addon.Config.defaultConfig.targetHeight
    MinimalUnitFramesDB.targetXPos = MinimalUnitFramesDB.targetXPos or addon.Config.defaultConfig.targetXPos
    MinimalUnitFramesDB.targetYPos = MinimalUnitFramesDB.targetYPos or addon.Config.defaultConfig.targetYPos
    MinimalUnitFramesDB.targetStrata = MinimalUnitFramesDB.targetStrata or addon.Config.defaultConfig.targetStrata
    MinimalUnitFramesDB.targetAnchor = MinimalUnitFramesDB.targetAnchor or addon.Config.defaultConfig.targetAnchor

    MinimalUnitFramesDB.targetoftargetWidth = MinimalUnitFramesDB.targetoftargetWidth or addon.Config.defaultConfig.targetoftargetWidth
    MinimalUnitFramesDB.targetoftargetHeight = MinimalUnitFramesDB.targetoftargetHeight or addon.Config.defaultConfig.targetoftargetHeight
    MinimalUnitFramesDB.targetoftargetXPos = MinimalUnitFramesDB.targetoftargetXPos or addon.Config.defaultConfig.targetoftargetXPos
    MinimalUnitFramesDB.targetoftargetYPos = MinimalUnitFramesDB.targetoftargetYPos or addon.Config.defaultConfig.targetoftargetYPos
    MinimalUnitFramesDB.targetoftargetStrata = MinimalUnitFramesDB.targetoftargetStrata or addon.Config.defaultConfig.targetoftargetStrata
    MinimalUnitFramesDB.targetoftargetAnchor = MinimalUnitFramesDB.targetoftargetAnchor or addon.Config.defaultConfig.targetoftargetAnchor

    MinimalUnitFramesDB.petWidth = MinimalUnitFramesDB.petWidth or addon.Config.defaultConfig.petWidth
    MinimalUnitFramesDB.petHeight = MinimalUnitFramesDB.petHeight or addon.Config.defaultConfig.petHeight
    MinimalUnitFramesDB.petXPos = MinimalUnitFramesDB.petXPos or addon.Config.defaultConfig.petXPos
    MinimalUnitFramesDB.petYPos = MinimalUnitFramesDB.petYPos or addon.Config.defaultConfig.petYPos
    MinimalUnitFramesDB.petStrata = MinimalUnitFramesDB.petStrata or addon.Config.defaultConfig.petStrata
    MinimalUnitFramesDB.petAnchor = MinimalUnitFramesDB.petAnchor or addon.Config.defaultConfig.petAnchor

    MinimalUnitFramesDB.petTargetWidth = MinimalUnitFramesDB.petTargetWidth or addon.Config.defaultConfig.petTargetWidth
    MinimalUnitFramesDB.petTargetHeight = MinimalUnitFramesDB.petTargetHeight or addon.Config.defaultConfig.petTargetHeight
    MinimalUnitFramesDB.petTargetXPos = MinimalUnitFramesDB.petTargetXPos or addon.Config.defaultConfig.petTargetXPos
    MinimalUnitFramesDB.petTargetYPos = MinimalUnitFramesDB.petTargetYPos or addon.Config.defaultConfig.petTargetYPos
    MinimalUnitFramesDB.petTargetStrata = MinimalUnitFramesDB.petTargetStrata or addon.Config.defaultConfig.petTargetStrata
    MinimalUnitFramesDB.petTargetAnchor = MinimalUnitFramesDB.petTargetAnchor or addon.Config.defaultConfig.petTargetAnchor

    MinimalUnitFramesDB.showPlayerFrame = MinimalUnitFramesDB.showPlayerFrame ~= nil and MinimalUnitFramesDB.showPlayerFrame or addon.Config.defaultConfig.showPlayerFrame
    MinimalUnitFramesDB.showTargetFrame = MinimalUnitFramesDB.showTargetFrame ~= nil and MinimalUnitFramesDB.showTargetFrame or addon.Config.defaultConfig.showTargetFrame
    MinimalUnitFramesDB.showTargetoftargetFrame = MinimalUnitFramesDB.showTargetoftargetFrame ~= nil and MinimalUnitFramesDB.showTargetoftargetFrame or addon.Config.defaultConfig.showTargetoftargetFrame
    MinimalUnitFramesDB.showPetFrame = MinimalUnitFramesDB.showPetFrame ~= nil and MinimalUnitFramesDB.showPetFrame or addon.Config.defaultConfig.showPetFrame
    MinimalUnitFramesDB.showPetTargetFrame = MinimalUnitFramesDB.showPetTargetFrame ~= nil and MinimalUnitFramesDB.showPetTargetFrame or addon.Config.defaultConfig.showPetTargetFrame

    MinimalUnitFramesDB.useClassColorsPlayer = MinimalUnitFramesDB.useClassColorsPlayer or addon.Config.defaultConfig.useClassColorsPlayer
    MinimalUnitFramesDB.useClassColorsTarget = MinimalUnitFramesDB.useClassColorsTarget or addon.Config.defaultConfig.useClassColorsTarget
    MinimalUnitFramesDB.useClassColorsTargetoftarget = MinimalUnitFramesDB.useClassColorsTargetoftarget or addon.Config.defaultConfig.useClassColorsTargetoftarget
    MinimalUnitFramesDB.useClassColorsPet = MinimalUnitFramesDB.useClassColorsPet or addon.Config.defaultConfig.useClassColorsPet
    MinimalUnitFramesDB.useClassColorsPetTarget = MinimalUnitFramesDB.useClassColorsPetTarget or addon.Config.defaultConfig.useClassColorsPetTarget

    -- Create frames
    playerFrame = CreateUnitFrame("player")
    targetFrame = CreateUnitFrame("target")
    targetoftargetFrame = CreateUnitFrame("targetoftarget")
    petFrame = CreateUnitFrame("pet")
    petTargetFrame = CreateUnitFrame("pettarget")

    addon.playerFrame = playerFrame
    addon.targetFrame = targetFrame
    addon.targetoftargetFrame = targetoftargetFrame
    addon.petFrame = petFrame
    addon.petTargetFrame = petTargetFrame

    -- Update frame properties
    addon.UpdateFrameSize(addon.playerFrame, "player")
    addon.UpdateFrameSize(addon.targetFrame, "target")
    addon.UpdateFrameSize(addon.targetoftargetFrame, "targetoftarget")
    addon.UpdateFrameSize(addon.petFrame, "pet")
    addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")

    addon.UpdateFramePowerBarVisibility("player")
    addon.UpdateFramePowerBarVisibility("target")
    addon.UpdateFramePowerBarVisibility("targetoftarget")
    addon.UpdateFramePowerBarVisibility("pet")
    addon.UpdateFramePowerBarVisibility("pettarget")

    addon.UpdateFramePosition(addon.playerFrame, "player")
    addon.UpdateFramePosition(addon.targetFrame, "target")
    addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    addon.UpdateFramePosition(addon.petFrame, "pet")
    addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")

    addon.UpdateFrameStrata(addon.playerFrame, "player")
    addon.UpdateFrameStrata(addon.targetFrame, "target")
    addon.UpdateFrameStrata(addon.targetoftargetFrame, "targetoftarget")
    addon.UpdateFrameStrata(addon.petFrame, "pet")
    addon.UpdateFrameStrata(addon.petTargetFrame, "pettarget")

    addon.UpdateBorderVisibility()
    addon.UpdateBarTexture()
    addon.UpdateFont()
    addon.UpdateFrameTextVisibility()
    addon.UpdateLevelTextVisibility()
    addon.UpdateFrameBackdropVisibility()

    SetupFrame(addon.playerFrame, "player")
    SetupFrame(targetFrame, "target")
    SetupFrame(targetoftargetFrame, "targetoftarget")
    SetupFrame(petFrame, "pet")
    SetupFrame(petTargetFrame, "pettarget")

    addon.UpdateFramesVisibility()
    SecureHideBlizzardFrames()
    TargetFrame:HookScript("OnShow", function(self)
        C_Timer.After(0, SecureHideBlizzardFrames)
    end)
end

--- Handles events
---@param self any UnitFrame
---@param event string
---@param arg1 string
---@param arg2 string
---@param ... any
local function OnEvent(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "MinimalUnitFrames" then
        InitializeAddon()
        eventFrame:UnregisterEvent("ADDON_LOADED")
    elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_UPDATE" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_LEVEL" or event == "UNIT_NAME_UPDATE" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        if arg1 == "player" or arg1 == "target" or arg1 == "targettarget" or arg1 == "pet" or arg1 == "pettarget" then
            addon.UpdateFrame(addon[arg1 .. "Frame"], arg1)
        end
    elseif event == "CVAR_UPDATE" and arg1 == "STATUS_TEXT_DISPLAY" then
        ForceUpdateText()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        SecureHideBlizzardFrames()
        addon.UpdateFramesVisibility()
    elseif event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGET" then
        addon.UpdateFrame(addon.targetFrame, "target")
        addon.UpdateFrame(addon.targetoftargetFrame, "targettarget")
        addon.UpdateFramesVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" then
        addon.UpdateFramesVisibility()
        addon.UpdateAllFrames()
        C_Timer.After(0.1, addon.UpdateFramesVisibility)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UNIT_DISPLAYPOWER" then
        if arg1 == "player" then
            addon.UpdateFrame(playerFrame, "player")
        end
    elseif event == "UNIT_LEVEL" then
        addon.UpdateLevelTextVisibility()
        if arg1 == "player" or arg1 == "target" or arg1 == "targetoftarget" then
            addon.UpdateFrame(addon[arg1 .. "Frame"], arg1)
        end
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
        if arg1 == "player" then
            addon.ClassResources:UpdateResourceBar(playerFrame, "player")
        end
    end
end

-- Slash commands
SLASH_MINIMALUNITFRAMES1 = "/muf"
SLASH_MINIMALUNITFRAMES2 = "/minimalunitframes"
SlashCmdList["MINIMALUNITFRAMES"] = function(msg)
    if msg == "reset" then
        MinimalUnitFramesDB = nil
        ReloadUI()
    else
        if Settings and Settings.OpenToCategory then
            Settings.OpenToCategory("Minimal Unit Frames")
        else
            InterfaceOptionsFrame_OpenToCategory("Minimal Unit Frames")
        end
    end
end

-- Register events to the event frame
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CVAR_UPDATE")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_DISPLAYPOWER")
eventFrame:RegisterEvent("UNIT_LEVEL")
eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("UNIT_TARGET")
eventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
eventFrame:RegisterEvent("UNIT_MAXPOWER")
eventFrame:RegisterEvent("RUNE_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

eventFrame:RegisterUnitEvent("UNIT_HEALTH", "player", "target", "targettarget", "pet", "pettarget")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player", "target", "targettarget", "pet", "pettarget")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player", "target", "targettarget", "pet", "pettarget")
eventFrame:RegisterUnitEvent("UNIT_LEVEL", "player", "target", "targettarget", "pet", "pettarget")
eventFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", "player", "target", "targettarget", "pet", "pettarget")
eventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player", "target", "targettarget", "pet", "pettarget")

eventFrame:SetScript("OnEvent", OnEvent)
