---@class MinimalUnitFrames
local addonName, addon = ...

local playerFrame, targetFrame, targetoftargetFrame, petFrame, petTargetFrame
local eventFrame = CreateFrame("Frame")
local hiddenFrame = CreateFrame("Frame")

hiddenFrame:Hide()

--- Rehides a frame
---@param frame any Frame
local function rehideFrame(frame)
    frame:Hide()
end

--- Hides the specified blizzard frames
---@param ... any Frame
local function hideBlizzardFrames(...)
    for i = 1, select("#", ...) do
        local frame = select(i, ...)
        if frame then
            UnregisterUnitWatch(frame)
            frame:UnregisterAllEvents()
            frame:Hide()
            frame:SetParent(hiddenFrame)
            frame:HookScript("OnShow", rehideFrame)

            if frame.manabar then
                frame.manabar:UnregisterAllEvents()
            end
            if frame.healthbar then
                frame.healthbar:UnregisterAllEvents()
            end
            if frame.powerBarAlt then
                frame.powerBarAlt:UnregisterAllEvents()
            end
        end
    end
end

--- Hides the specified blizzard frames
local function SecureHideBlizzardFrames()
    hideBlizzardFrames(PlayerFrame, PlayerFrameAlternateManaBar)
    hideBlizzardFrames(TargetFrame, ComboFrame, TargetFrameToT)
    hideBlizzardFrames(FocusFrame, FocusFrameToT)
    hideBlizzardFrames(PetFrame)

    UIParent:UnregisterEvent("PLAYER_ENTERING_WORLD")
    UIParent:UnregisterEvent("PLAYER_TARGET_CHANGED")
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

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame.nameText = frame:CreateFontString(nil, "OVERLAY")
    frame.nameText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font), MinimalUnitFramesDB.fontSize, MinimalUnitFramesDB.fontStyle)
    frame.nameText:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 2)
    frame.nameText:SetTextColor(1, 1, 1)

    frame.levelText = frame:CreateFontString(nil, "OVERLAY")
    frame.levelText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font), MinimalUnitFramesDB.fontSize, MinimalUnitFramesDB.fontStyle)
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
    frame.healthBar:SetStatusBarTexture(addon.Util.FetchMedia("textures", MinimalUnitFramesDB.barTexture))

    frame.powerBar = CreateFrame("StatusBar", nil, frame.barsFrame)
    frame.powerBar:SetStatusBarTexture(addon.Util.FetchMedia("textures", MinimalUnitFramesDB.barTexture))

    if unit == "player" and addon.ClassResources then
        frame.resourceBar = addon.ClassResources:CreateResourceBar(frame)
        frame.resourceBar:Hide()
    end

    frame.healthText = frame.healthBar:CreateFontString(nil, "OVERLAY")
    frame.healthText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font), MinimalUnitFramesDB.fontSize, MinimalUnitFramesDB.fontStyle)
    frame.healthText:SetPoint("CENTER", frame.healthBar, "CENTER")
    frame.healthText:SetTextColor(1, 1, 1)

    frame.powerText = frame.powerBar:CreateFontString(nil, "OVERLAY")
    frame.powerText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font), MinimalUnitFramesDB.fontSize, MinimalUnitFramesDB.fontStyle)
    frame.powerText:SetPoint("CENTER", frame.powerBar, "CENTER")
    frame.powerText:SetTextColor(1, 1, 1)

    frame.absorbBar = CreateFrame("StatusBar", nil, frame.healthBar)
    frame.absorbBar:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")
    frame.absorbBar:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT")
    frame.absorbBar:SetStatusBarTexture(addon.Util.FetchMedia("textures", MinimalUnitFramesDB.barTexture))
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
        self:SetBackdropColor(unpack(MinimalUnitFramesDB.bgHovered))
        if MinimalUnitFramesDB.showBorder then
            self.barsFrame:SetBackdropBorderColor(unpack(MinimalUnitFramesDB.borderHovered))
        end
        self.barsFrame:SetBackdropColor(unpack(MinimalUnitFramesDB.bgHovered))
    end)
    frame:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0.5)
        if MinimalUnitFramesDB.showBorder then
            self.barsFrame:SetBackdropBorderColor(unpack(MinimalUnitFramesDB.border))
        else
            self.barsFrame:SetBackdropBorderColor(0, 0, 0, 0)
        end
        self.barsFrame:SetBackdropColor(unpack(MinimalUnitFramesDB.bg))
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
    addon.UpdateFrameStrata(frame, unit)
    addon.UpdateFramePosition(frame, unit)
    addon.UpdateFrame(frame, unit)
    frame:Show()

    if unit == "player" and addon.CombatText then
        addon.CombatText:CreateCombatFeedback(frame)
        frame:RegisterEvent("UNIT_COMBAT")
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:HookScript("OnEvent", function(self, event, ...)
            if MinimalUnitFramesDB.showPlayerCombatFeedback then
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
        frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
    elseif unit == "target" then
        frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
    elseif unit == "targettarget" then
        frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
    elseif unit == "pet" then
        frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
    elseif unit == "pettarget" then
        frame.healthBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, true)))
    end
    frame.powerBar:SetStatusBarColor(unpack(addon.Util.GetBarColor(unit, false)))

    frame.nameText:SetText(UnitName(unit))
    frame.levelText:SetText(UnitLevel(unit))

    if addon.Auras and addon.Auras.Update then
        addon.Auras:Update(frame, unit)
    end

    if addon.ClassResources and unit == "player" and MinimalUnitFramesDB.showPlayerClassResources and addon.ClassResources:HasClassResources() then
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
    local xPos, yPos, anchor, anchoredTo
    if unit == "player" then
        xPos = MinimalUnitFramesDB.playerXPos or addon.Config.defaultConfig.playerXPos
        yPos = MinimalUnitFramesDB.playerYPos or addon.Config.defaultConfig.playerYPos
        anchor = MinimalUnitFramesDB.playerAnchor or addon.Config.defaultConfig.playerAnchor
    elseif unit == "target" then
        xPos = MinimalUnitFramesDB.targetXPos or addon.Config.defaultConfig.targetXPos
        yPos = MinimalUnitFramesDB.targetYPos or addon.Config.defaultConfig.targetYPos
        anchor = MinimalUnitFramesDB.targetAnchor or addon.Config.defaultConfig.targetAnchor
        anchoredTo = MinimalUnitFramesDB.targetAnchoredTo or "Screen"
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

    frame:ClearAllPoints()
    if unit == "target" and anchoredTo == "Player Frame" then
        local playerFrame = addon.playerFrame
        local playerAnchor = MinimalUnitFramesDB.playerAnchor or addon.Config.defaultConfig.playerAnchor
        local oppositeAnchor = {
            TOPLEFT = "TOPRIGHT",
            TOPRIGHT = "TOPLEFT",
            BOTTOMLEFT = "BOTTOMRIGHT",
            BOTTOMRIGHT = "BOTTOMLEFT",
            TOP = "BOTTOM",
            BOTTOM = "TOP",
            LEFT = "RIGHT",
            RIGHT = "LEFT",
            CENTER = "CENTER"
        }
        frame:SetPoint(anchor, playerFrame, oppositeAnchor[playerAnchor], xPos, yPos)
    else
        frame:SetPoint(anchor, UIParent, anchor, xPos, yPos)
    end
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
    local anchor = MinimalUnitFramesDB[unit .. "Anchor"]
    local xPos = MinimalUnitFramesDB[unit .. "XPos"]
    local yPos = MinimalUnitFramesDB[unit .. "YPos"]

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

        -- Special check for pet frame
        if unit == "pet" then
            shouldShow = showOption and UnitExists("pet")
        end

        if InCombatLockdown() then
            if shouldShow then
                frame:Show()
                addon.UpdateFrame(frame, unit)
            end
        else
            if shouldShow then
                frame:Show()
                addon.UpdateFrame(frame, unit)
            else
                frame:Hide()
            end
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

    if addon.ClassResources and MinimalUnitFramesDB.showPlayerClassResources and addon.ClassResources:HasClassResources() then
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

    --- Loads a module if the condition is true
    ---@param moduleName string
    ---@param condition boolean
    local function LoadModuleIfEnabled(moduleName, condition)
        if condition then
            local success = addon.Util.LoadModule(moduleName)
            if not success then
                print("Failed to load " .. moduleName .. " module. Some features may not work correctly.")
            end
        end
    end

    LoadModuleIfEnabled("Auras", MinimalUnitFramesDB.showPlayerBuffs or MinimalUnitFramesDB.showPlayerDebuffs or MinimalUnitFramesDB.showTargetBuffs or MinimalUnitFramesDB.showTargetDebuffs)
    LoadModuleIfEnabled("ClassResources", MinimalUnitFramesDB.showPlayerClassResources)
    LoadModuleIfEnabled("CombatText", MinimalUnitFramesDB.showPlayerCombatFeedback)

    -- Create frames
    playerFrame = CreateUnitFrame("player")
    targetFrame = CreateUnitFrame("target")
    targetoftargetFrame = CreateUnitFrame("targetoftarget")
    petFrame = CreateUnitFrame("pet")
    petTargetFrame = CreateUnitFrame("pettarget")

    -- Update frame properties
    addon.UpdateFrameSize(playerFrame, "player")
    addon.UpdateFrameSize(targetFrame, "target")
    addon.UpdateFrameSize(targetoftargetFrame, "targetoftarget")
    addon.UpdateFrameSize(petFrame, "pet")
    addon.UpdateFrameSize(petTargetFrame, "pettarget")

    addon.UpdateFramePowerBarVisibility("player")
    addon.UpdateFramePowerBarVisibility("target")
    addon.UpdateFramePowerBarVisibility("targetoftarget")
    addon.UpdateFramePowerBarVisibility("pet")
    addon.UpdateFramePowerBarVisibility("pettarget")

    addon.UpdateFramePosition(playerFrame, "player")
    addon.UpdateFramePosition(targetFrame, "target")
    addon.UpdateFramePosition(targetoftargetFrame, "targetoftarget")
    addon.UpdateFramePosition(petFrame, "pet")
    addon.UpdateFramePosition(petTargetFrame, "pettarget")

    addon.UpdateFrameStrata(playerFrame, "player")
    addon.UpdateFrameStrata(targetFrame, "target")
    addon.UpdateFrameStrata(targetoftargetFrame, "targetoftarget")
    addon.UpdateFrameStrata(petFrame, "pet")
    addon.UpdateFrameStrata(petTargetFrame, "pettarget")

    SetupFrame(playerFrame, "player")
    SetupFrame(targetFrame, "target")
    SetupFrame(targetoftargetFrame, "targetoftarget")
    SetupFrame(petFrame, "pet")
    SetupFrame(petTargetFrame, "pettarget")

    addon.playerFrame = playerFrame
    addon.targetFrame = targetFrame
    addon.targetoftargetFrame = targetoftargetFrame
    addon.petFrame = petFrame
    addon.petTargetFrame = petTargetFrame

    addon.UpdateBorderVisibility()
    addon.UpdateBarTexture()
    addon.UpdateFont()
    addon.UpdateFrameTextVisibility()
    addon.UpdateLevelTextVisibility()
    addon.UpdateFrameBackdropVisibility()
    addon.UpdateFramesVisibility()

    if addon.CombatText then
        addon.CombatText:UpdateVisibility()
    end

    SecureHideBlizzardFrames()
    C_Timer.After(1, SecureHideBlizzardFrames) -- Call again after a delay to ensure frames are hidden
    hooksecurefunc("UIParent_ManageFramePositions", SecureHideBlizzardFrames)
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
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
        C_Timer.After(0.1, function()
            SecureHideBlizzardFrames()
            addon.UpdateAllFrames()
        end)
    elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_UPDATE" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        local unit = arg1
        if unit == "player" then
            addon.UpdateFrame(playerFrame, "player")
        elseif unit == "target" then
            addon.UpdateFrame(targetFrame, "target")
        elseif unit == "targettarget" then
            addon.UpdateFrame(targetoftargetFrame, "targetoftarget")
        elseif unit == "pet" then
            addon.UpdateFrame(petFrame, "pet")
        elseif unit == "pettarget" then
            addon.UpdateFrame(petTargetFrame, "pettarget")
        end
    elseif event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGET" then
        addon.UpdateFrame(addon.targetFrame, "target")
        addon.UpdateFrame(addon.targetoftargetFrame, "targettarget")
        addon.UpdateFramesVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        addon.UpdateFramesVisibility()
        addon.UpdateAllFrames()
        C_Timer.After(0.1, function()
            addon.UpdateFramesVisibility()
            if addon.CombatText then
                addon.CombatText:UpdateVisibility()
            end
        end)
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
    elseif event == "UNIT_PET" then
        addon.UpdateFrame(petFrame, "pet")
        addon.UpdateFrame(petTargetFrame, "pettarget")
        addon.UpdateFramesVisibility()
    elseif event == "UNIT_NAME_UPDATE" then
        local unit = arg1
        if unit == "player" or unit == "target" or unit == "targettarget" or unit == "pet" or unit == "pettarget" then
            addon.UpdateFrame(_G["Minimal" .. unit .. "Frame"], unit)
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

-- Register events
for _, event in ipairs(addon.Config.eventGroups.general) do
    eventFrame:RegisterEvent(event)
end
for _, event in ipairs(addon.Config.eventGroups.unit) do
    eventFrame:RegisterUnitEvent(event, unpack(addon.Config.unitTypes))
end
eventFrame:SetScript("OnEvent", OnEvent)
