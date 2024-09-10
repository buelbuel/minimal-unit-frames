---@class Options
local addonName, addon = ...

optionsPanel = CreateFrame("Frame", "MinimalUnitFramesOptionsPanel", UIParent)
optionsPanel.name = "Minimal Unit Frames"
optionsPanel:Hide()

--- Creates a checkbox
---@param parent any Frame
---@param label string
---@param description string
---@param onClick function
---@return any rame
local function CreateCheckbox(parent, label, description, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    check.Text:SetText(label)
    check.tooltipText = label
    check.tooltipRequirement = description
    check:SetScript("OnClick", onClick)
    return check
end

--- Creates a slider
---@param parent any Frame
---@param label string
---@param description string
---@param minVal number
---@param maxVal number
---@param valStep number
---@param func function
local function CreateSlider(parent, label, description, minVal, maxVal, valStep, func)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(valStep)
    slider.Text:SetText(label)
    slider.tooltipText = label
    slider.tooltipRequirement = description
    slider.isUpdating = false
    slider:SetScript("OnValueChanged", function(self, value)
        if self.isUpdating then
            return
        end
        value = math.floor(value + 0.5)
        self.editBox:SetText(tostring(value))
        func(self, value)
    end)

    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetSize(50, 20)
    editBox:SetPoint("TOP", slider, "BOTTOM", 0, 0)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            slider.isUpdating = true
            slider:SetValue(value)
            slider.isUpdating = false
            func(slider, value)
        end
        self:ClearFocus()
    end)
    slider.editBox = editBox

    slider.SetValue = function(self, value)
        self.isUpdating = true
        getmetatable(self).__index.SetValue(self, value)
        self.editBox:SetText(tostring(math.floor(value + 0.5)))
        self.isUpdating = false
    end

    return slider
end

--- Creates a dropdown menu
---@param parent any Frame
---@param label string
---@param items table
---@param default string
---@param onChange function
---@return any Frame
local function CreateDropdown(parent, label, items, default, onChange)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetText(dropdown, default)

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        for _, item in ipairs(items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item
            info.func = function()
                UIDropDownMenu_SetText(dropdown, item)
                onChange(item)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    labelText:SetText(label)

    return dropdown
end

--- Feeds the options panel to the Blizzard options panel
---@param frame any Frame
local function FeedToBlizPanel(frame)
    if frame.initialized then
        return
    end

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 16, 1000)
    scrollFrame:SetScrollChild(content)
    scrollFrame:SetClipsChildren(true)
    content.bg = content:CreateTexture(nil, "BACKGROUND")
    content.bg:SetAllPoints(true)

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Minimal Unit Frames Options")

    -- *********************
    -- Show Blizzard Frames Checkbox
    -- *********************
    local showBlizzardFramesCheck = CreateCheckbox(content, "Show Blizzard Frames", "Display default Blizzard unit frames", function(self)
        MinimalUnitFramesDB.showBlizzardFrames = self:GetChecked()
        addon.ToggleBlizzardFrames(self:GetChecked())
    end)
    showBlizzardFramesCheck:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    showBlizzardFramesCheck:SetChecked(MinimalUnitFramesDB.showBlizzardFrames)

    -- Show Border Checkbox
    local showBorderCheck = CreateCheckbox(content, "Show Border", "Display border around unit frames", function(self)
        MinimalUnitFramesDB.showBorder = self:GetChecked()
        addon.UpdateBorderVisibility()
    end)
    showBorderCheck:SetPoint("TOPLEFT", showBlizzardFramesCheck, "BOTTOMLEFT", 0, -8)
    showBorderCheck:SetChecked(MinimalUnitFramesDB.showBorder)

    -- *********************
    -- Bar Texture Dropdown
    -- *********************
    local barTextureDropdown = CreateDropdown(content, "Bar Texture", addon.Util.GetTableKeys(addon.Config.media.statusbar), MinimalUnitFramesDB.barTexture or addon.Config.defaultConfig.barTexture,
        function(value)
            MinimalUnitFramesDB.barTexture = value
            addon.UpdateBarTexture()
        end)
    barTextureDropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 300, -32)

    -- Font Dropdown
    local fontDropdown = CreateDropdown(content, "Font", addon.Util.GetTableKeys(addon.Config.media.font), MinimalUnitFramesDB.font or addon.Config.defaultConfig.font, function(value)
        MinimalUnitFramesDB.font = value
        addon.UpdateFont()
    end)
    fontDropdown:SetPoint("TOPLEFT", barTextureDropdown, "BOTTOMLEFT", 0, -16)

    -- Font Style Dropdown
    local fontStyleDropdown = CreateDropdown(content, "Font Style", {"NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME"}, MinimalUnitFramesDB.fontstyle or addon.Config.defaultConfig.fontstyle,
        function(value)
            MinimalUnitFramesDB.fontstyle = value
            addon.UpdateFont()
        end)
    fontStyleDropdown:SetPoint("TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -16)

    -- Font Size Slider
    local fontSizeSlider = CreateSlider(content, "Font Size", "Adjust the font size", 8, 24, 1, function(self, value)
        MinimalUnitFramesDB.fontsize = value
        addon.UpdateFont()
    end)
    fontSizeSlider:SetPoint("TOPLEFT", fontStyleDropdown, "BOTTOMLEFT", 0, -16)
    fontSizeSlider:SetValue(MinimalUnitFramesDB.fontsize or addon.Config.defaultConfig.fontsize)

    -- *********************
    -- Player Frame Options
    -- *********************
    local playerOptionsTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    playerOptionsTitle:SetPoint("TOPLEFT", showBorderCheck, "BOTTOMLEFT", 0, -160)
    playerOptionsTitle:SetText("Player Frame Options")

    -- Player Frame Visibility Checkbox
    local playerFrameCheck = CreateCheckbox(content, "Player Frame", "Toggle visibility of Player Frame", function(self)
        MinimalUnitFramesDB.showPlayerFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end)
    playerFrameCheck:SetPoint("TOPLEFT", playerOptionsTitle, "TOPLEFT", 16, -40)
    playerFrameCheck:SetChecked(MinimalUnitFramesDB.showPlayerFrame)

    -- Player Show Text Checkbox
    local playerShowTextCheck = CreateCheckbox(content, "Show Player Text", "Display text on player frame", function(self)
        MinimalUnitFramesDB.showPlayerText = self:GetChecked()
        addon.UpdateTextVisibility("player")
    end)
    playerShowTextCheck:SetPoint("TOPLEFT", playerFrameCheck, "BOTTOMLEFT", 0, -16)
    playerShowTextCheck:SetChecked(MinimalUnitFramesDB.showPlayerText)

    -- Player Show Buffs Checkbox
    local playerShowBuffsCheck = CreateCheckbox(content, "Show Player Buffs", "Display buff icons on player frame", function(self)
        MinimalUnitFramesDB.showPlayerBuffs = self:GetChecked()
        addon.Config.auraConfig.buffs.playerEnabled = self:GetChecked()
        if addon.Auras and addon.Auras.Update then
            addon.Auras:Update(addon.playerFrame, "player")
        end
    end)
    playerShowBuffsCheck:SetPoint("TOPLEFT", playerShowTextCheck, "BOTTOMLEFT", 0, -16)
    playerShowBuffsCheck:SetChecked(MinimalUnitFramesDB.showPlayerBuffs)

    -- Player Show Debuffs Checkbox
    local playerShowDebuffsCheck = CreateCheckbox(content, "Show Player Debuffs", "Display debuff icons on player frame", function(self)
        MinimalUnitFramesDB.showPlayerDebuffs = self:GetChecked()
        addon.Config.auraConfig.debuffs.playerEnabled = self:GetChecked()
        if addon.Auras and addon.Auras.Update then
            addon.Auras:Update(addon.playerFrame, "player")
        end
    end)
    playerShowDebuffsCheck:SetPoint("TOPLEFT", playerShowBuffsCheck, "BOTTOMLEFT", 0, -8)
    playerShowDebuffsCheck:SetChecked(MinimalUnitFramesDB.showPlayerDebuffs)

    -- Player Frame Width Slider
    local playerWidthSlider = CreateSlider(content, "Width", "Adjust the width of the player frame", 100, 500, 1, function(self, value)
        MinimalUnitFramesDB.playerWidth = value
        addon.UpdateFrameSize(addon.playerFrame, "player")
    end)
    playerWidthSlider:SetPoint("TOPLEFT", playerShowDebuffsCheck, "BOTTOMLEFT", 0, -32)
    playerWidthSlider:SetValue(MinimalUnitFramesDB.playerWidth or addon.Config.defaultConfig.width)
    playerWidthSlider.editBox:SetText(tostring(MinimalUnitFramesDB.playerWidth or addon.Config.defaultConfig.width))
    optionsPanel.playerWidthSlider = playerWidthSlider

    -- Player Frame Height Slider
    local playerHeightSlider = CreateSlider(content, "Height", "Adjust the height of the player frame", 50, 200, 1, function(self, value)
        MinimalUnitFramesDB.playerHeight = value
        addon.UpdateFrameSize(addon.playerFrame, "player")
    end)
    playerHeightSlider:SetPoint("TOPLEFT", playerWidthSlider, "BOTTOMLEFT", 0, -48)
    playerHeightSlider:SetValue(MinimalUnitFramesDB.playerHeight or addon.Config.defaultConfig.height)
    playerHeightSlider.editBox:SetText(tostring(MinimalUnitFramesDB.playerHeight or addon.Config.defaultConfig.height))
    optionsPanel.playerHeightSlider = playerHeightSlider

    -- Player Frame X Position Slider
    local playerXPosSlider = CreateSlider(content, "X Position", "Adjust the X position of the player frame", -2000, 2000, 1, function(self, value)
        MinimalUnitFramesDB.playerXPos = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end)
    playerXPosSlider:SetPoint("TOPLEFT", playerHeightSlider, "BOTTOMLEFT", 0, -48)
    playerXPosSlider:SetValue(MinimalUnitFramesDB.playerXPos or addon.Config.defaultConfig.playerXPos)
    playerXPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.playerXPos or addon.Config.defaultConfig.playerXPos))
    optionsPanel.playerXPosSlider = playerXPosSlider

    -- Player Frame Y Position Slider
    local playerYPosSlider = CreateSlider(content, "Y Position", "Adjust the Y position of the player frame", -2000, 2000, 1, function(self, value)
        MinimalUnitFramesDB.playerYPos = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end)
    playerYPosSlider:SetPoint("TOPLEFT", playerXPosSlider, "BOTTOMLEFT", 0, -48)
    playerYPosSlider:SetValue(MinimalUnitFramesDB.playerYPos or addon.Config.defaultConfig.playerYPos)
    playerYPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.playerYPos or addon.Config.defaultConfig.playerYPos))
    optionsPanel.playerYPosSlider = playerYPosSlider

    -- Player Frame Strata Dropdown
    local playerStrataDropdown = CreateDropdown(content, "Frame Strata", {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"},
        MinimalUnitFramesDB.playerStrata or "MEDIUM", function(value)
            MinimalUnitFramesDB.playerStrata = value
            addon.UpdateFrameStrata(addon.playerFrame)
        end)
    playerStrataDropdown:SetPoint("TOPLEFT", playerYPosSlider, "BOTTOMLEFT", -28, -48)

    -- Player Frame Anchor Dropdown
    local playerAnchorDropdown = CreateDropdown(content, "Anchor Point", {"TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT"},
        MinimalUnitFramesDB.playerAnchor or "CENTER", function(value)
            MinimalUnitFramesDB.playerAnchor = value
            addon.UpdateFramePosition(addon.playerFrame, "player")
        end)
    playerAnchorDropdown:SetPoint("TOPLEFT", playerStrataDropdown, "BOTTOMLEFT", 0, -32)

    -- *********************
    -- Target Frame Options
    -- *********************
    local targetOptionsTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    targetOptionsTitle:SetPoint("TOPLEFT", showBorderCheck, "BOTTOMLEFT", 300, -160)
    targetOptionsTitle:SetText("Target Frame Options")

    -- Target Frame Visibility Checkbox
    local targetFrameCheck = CreateCheckbox(content, "Target Frame", "Toggle visibility of Target Frame", function(self)
        MinimalUnitFramesDB.showTargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end)
    targetFrameCheck:SetPoint("TOPLEFT", targetOptionsTitle, "TOPLEFT", 16, -70)
    targetFrameCheck:SetChecked(MinimalUnitFramesDB.showTargetFrame)

    -- Target Show Text Checkbox
    local targetShowTextCheck = CreateCheckbox(content, "Show Target Text", "Display text on target frame", function(self)
        MinimalUnitFramesDB.showTargetText = self:GetChecked()
        addon.UpdateTextVisibility("target")
    end)
    targetShowTextCheck:SetPoint("TOPLEFT", targetFrameCheck, "BOTTOMLEFT", 0, -16)
    targetShowTextCheck:SetChecked(MinimalUnitFramesDB.showTargetText)

    -- Target Show Buffs Checkbox
    local targetShowBuffsCheck = CreateCheckbox(content, "Show Target Buffs", "Display buff icons on target frame", function(self)
        MinimalUnitFramesDB.showTargetBuffs = self:GetChecked()
        addon.Config.auraConfig.buffs.targetEnabled = self:GetChecked()
        if addon.Auras and addon.Auras.Update then
            addon.Auras:Update(addon.targetFrame, "target")
        end
    end)
    targetShowBuffsCheck:SetPoint("TOPLEFT", targetShowTextCheck, "BOTTOMLEFT", 0, -16)
    targetShowBuffsCheck:SetChecked(MinimalUnitFramesDB.showTargetBuffs)

    -- Target Show Debuffs Checkbox
    local targetShowDebuffsCheck = CreateCheckbox(content, "Show Target Debuffs", "Display debuff icons on target frame", function(self)
        MinimalUnitFramesDB.showTargetDebuffs = self:GetChecked()
        addon.Config.auraConfig.debuffs.targetEnabled = self:GetChecked()
        if addon.Auras and addon.Auras.Update then
            addon.Auras:Update(addon.targetFrame, "target")
        end
    end)
    targetShowDebuffsCheck:SetPoint("TOPLEFT", targetShowBuffsCheck, "BOTTOMLEFT", 0, -8)
    targetShowDebuffsCheck:SetChecked(MinimalUnitFramesDB.showTargetDebuffs)

    -- Target Frame Width Slider
    local targetWidthSlider = CreateSlider(content, "Width", "Adjust the width of the target frame", 100, 500, 1, function(self, value)
        MinimalUnitFramesDB.targetWidth = value
        addon.UpdateFrameSize(addon.targetFrame, "target")
    end)
    targetWidthSlider:SetPoint("TOPLEFT", targetShowDebuffsCheck, "BOTTOMLEFT", 0, -32)
    targetWidthSlider:SetValue(MinimalUnitFramesDB.targetWidth or addon.Config.defaultConfig.width)
    targetWidthSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targetWidth or addon.Config.defaultConfig.width))
    optionsPanel.targetWidthSlider = targetWidthSlider

    -- Target Frame Height Slider
    local targetHeightSlider = CreateSlider(content, "Height", "Adjust the height of the target frame", 50, 200, 1, function(self, value)
        MinimalUnitFramesDB.targetHeight = value
        addon.UpdateFrameSize(addon.targetFrame, "target")
    end)
    targetHeightSlider:SetPoint("TOPLEFT", targetWidthSlider, "BOTTOMLEFT", 0, -48)
    targetHeightSlider:SetValue(MinimalUnitFramesDB.targetHeight or addon.Config.defaultConfig.height)
    targetHeightSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targetHeight or addon.Config.defaultConfig.height))
    optionsPanel.targetHeightSlider = targetHeightSlider

    -- Target Frame X Position Slider
    local targetXPosSlider = CreateSlider(content, "X Position", "Adjust the X position of the target frame", -2000, 2000, 1, function(self, value)
        MinimalUnitFramesDB.targetXPos = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end)
    targetXPosSlider:SetPoint("TOPLEFT", targetHeightSlider, "BOTTOMLEFT", 0, -48)
    targetXPosSlider:SetValue(MinimalUnitFramesDB.targetXPos or addon.Config.defaultConfig.targetXPos)
    targetXPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targetXPos or addon.Config.defaultConfig.targetXPos))
    optionsPanel.targetXPosSlider = targetXPosSlider

    -- Target Frame Y Position Slider
    local targetYPosSlider = CreateSlider(content, "Y Position", "Adjust the Y position of the target frame", -2000, 2000, 1, function(self, value)
        MinimalUnitFramesDB.targetYPos = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end)
    targetYPosSlider:SetPoint("TOPLEFT", targetXPosSlider, "BOTTOMLEFT", 0, -48)
    targetYPosSlider:SetValue(MinimalUnitFramesDB.targetYPos or addon.Config.defaultConfig.targetYPos)
    targetYPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targetYPos or addon.Config.defaultConfig.targetYPos))
    optionsPanel.targetYPosSlider = targetYPosSlider

    -- Target Frame Strata Dropdown
    local targetStrataDropdown = CreateDropdown(content, "Frame Strata", {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"},
        MinimalUnitFramesDB.targetStrata or "MEDIUM", function(value)
            MinimalUnitFramesDB.targetStrata = value
            addon.UpdateFrameStrata(addon.targetFrame)
        end)
    targetStrataDropdown:SetPoint("TOPLEFT", targetYPosSlider, "BOTTOMLEFT", -28, -48)

    -- Target Frame Anchor Dropdown
    local targetAnchorDropdown = CreateDropdown(content, "Anchor Point", {"TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT"},
        MinimalUnitFramesDB.targetAnchor or "CENTER", function(value)
            MinimalUnitFramesDB.targetAnchor = value
            addon.UpdateFramePosition(addon.targetFrame, "target")
        end)
    targetAnchorDropdown:SetPoint("TOPLEFT", targetStrataDropdown, "BOTTOMLEFT", 0, -32)

    -- *********************
    -- Target of Target Frame Options
    -- *********************
    local targettargetOptionsTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    targettargetOptionsTitle:SetPoint("TOPLEFT", playerAnchorDropdown, "BOTTOMLEFT", 32, -16)
    targettargetOptionsTitle:SetText("Target of Target Frame Options")

    -- Target of Target Frame Visibility Checkbox
    local targettargetFrameCheck = CreateCheckbox(content, "Target of Target Frame", "Toggle visibility of Target of Target Frame", function(self)
        MinimalUnitFramesDB.showTargettargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end)
    targettargetFrameCheck:SetPoint("TOPLEFT", targettargetOptionsTitle, "TOPLEFT", 16, -100)
    targettargetFrameCheck:SetChecked(MinimalUnitFramesDB.showTargettargetFrame)

    -- Targettarget Show Text Checkbox
    local targettargetShowTextCheck = CreateCheckbox(content, "Show Targettarget Text", "Display text on Targettarget frame", function(self)
        MinimalUnitFramesDB.showTargettargetText = self:GetChecked()
        addon.UpdateTextVisibility("targettarget")
    end)
    targettargetShowTextCheck:SetPoint("TOPLEFT", targettargetFrameCheck, "BOTTOMLEFT", 0, -16)
    targettargetShowTextCheck:SetChecked(MinimalUnitFramesDB.showTargettargetText)

    -- ToT Frame Width Slider
    local targettargetWidthSlider = CreateSlider(content, "Width", "Adjust the width of the ToT frame", 100, 500, 1, function(self, value)
        MinimalUnitFramesDB.targettargetWidth = value
        addon.UpdateFrameSize(addon.targettargetFrame, "targettarget")
    end)
    targettargetWidthSlider:SetPoint("TOPLEFT", targettargetShowTextCheck, "BOTTOMLEFT", 0, -32)
    targettargetWidthSlider:SetValue(MinimalUnitFramesDB.targettargetWidth or addon.Config.defaultConfig.width)
    targettargetWidthSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targettargetWidth or addon.Config.defaultConfig.width))

    -- ToT Frame Height Slider
    local targettargetHeightSlider = CreateSlider(content, "Height", "Adjust the height of the ToT frame", 50, 200, 1, function(self, value)
        MinimalUnitFramesDB.targettargetHeight = value
        addon.UpdateFrameSize(addon.targettargetFrame, "targettarget")
    end)
    targettargetHeightSlider:SetPoint("TOPLEFT", targettargetWidthSlider, "BOTTOMLEFT", 0, -48)
    targettargetHeightSlider:SetValue(MinimalUnitFramesDB.targettargetHeight or addon.Config.defaultConfig.height)
    targettargetHeightSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targettargetHeight or addon.Config.defaultConfig.height))

    -- ToT Frame X Position Slider
    local targettargetXPosSlider = CreateSlider(content, "X Position", "Adjust the horizontal position of the ToT frame", -500, 500, 1, function(self, value)
        MinimalUnitFramesDB.targettargetXPos = value
        addon.UpdateFramePosition(addon.targettargetFrame, "targettarget")
    end)
    targettargetXPosSlider:SetPoint("TOPLEFT", targettargetHeightSlider, "BOTTOMLEFT", 0, -48)
    targettargetXPosSlider:SetValue(MinimalUnitFramesDB.targettargetXPos or addon.Config.defaultConfig.targettargetXPos)
    targettargetXPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targettargetXPos or addon.Config.defaultConfig.targettargetXPos))

    -- ToT Frame Y Position Slider
    local targettargetYPosSlider = CreateSlider(content, "Y Position", "Adjust the vertical position of the ToT frame", -500, 500, 1, function(self, value)
        MinimalUnitFramesDB.targettargetYPos = value
        addon.UpdateFramePosition(addon.targettargetFrame, "targettarget")
    end)
    targettargetYPosSlider:SetPoint("TOPLEFT", targettargetXPosSlider, "BOTTOMLEFT", 0, -48)
    targettargetYPosSlider:SetValue(MinimalUnitFramesDB.targettargetYPos or addon.Config.defaultConfig.targettargetYPos)
    targettargetYPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.targettargetYPos or addon.Config.defaultConfig.targettargetYPos))

    -- ToT Frame Strata Dropdown
    local targettargetStrataDropdown = CreateDropdown(content, "Frame Strata", {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG"},
        MinimalUnitFramesDB.targettargetStrata or addon.Config.defaultConfig.targettargetStrata, function(value)
            MinimalUnitFramesDB.targettargetStrata = value
            addon.UpdateFrameStrata(addon.targettargetFrame)
        end)
    targettargetStrataDropdown:SetPoint("TOPLEFT", targettargetYPosSlider, "BOTTOMLEFT", -28, -48)

    -- ToT Frame Anchor Dropdown
    local targettargetAnchorDropdown = CreateDropdown(content, "Anchor Point", {"TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT"},
        MinimalUnitFramesDB.targettargetAnchor or addon.Config.defaultConfig.targettargetAnchor, function(value)
            MinimalUnitFramesDB.targettargetAnchor = value
            addon.UpdateFramePosition(addon.targettargetFrame, "targettarget")
        end)
    targettargetAnchorDropdown:SetPoint("TOPLEFT", targettargetStrataDropdown, "BOTTOMLEFT", 0, -32)

    -- *********************
    -- Pet Frame Options
    -- *********************
    local petOptionsTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    petOptionsTitle:SetPoint("TOPLEFT", targetAnchorDropdown, "BOTTOMLEFT", 32, -16)
    petOptionsTitle:SetText("Pet Frame Options")

    -- Pet Frame Visibility Checkbox
    local petFrameCheck = CreateCheckbox(content, "Pet Frame", "Toggle visibility of Pet Frame", function(self)
        MinimalUnitFramesDB.showPetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end)
    petFrameCheck:SetPoint("TOPLEFT", petOptionsTitle, "TOPLEFT", 16, -130)
    petFrameCheck:SetChecked(MinimalUnitFramesDB.showPetFrame)

    -- Pet Show Text Checkbox
    local petShowTextCheck = CreateCheckbox(content, "Show Pet Text", "Display text on pet frame", function(self)
        MinimalUnitFramesDB.showPetText = self:GetChecked()
        addon.UpdateTextVisibility("pet")
    end)
    petShowTextCheck:SetPoint("TOPLEFT", petFrameCheck, "BOTTOMLEFT", 0, -16)
    petShowTextCheck:SetChecked(MinimalUnitFramesDB.showPetText)

    -- Pet Frame Width Slider
    local petWidthSlider = CreateSlider(content, "Width", "Adjust the width of the pet frame", 100, 500, 1, function(self, value)
        MinimalUnitFramesDB.petWidth = value
        addon.UpdateFrameSize(addon.petFrame, "pet")
    end)
    petWidthSlider:SetPoint("TOPLEFT", petShowTextCheck, "BOTTOMLEFT", 0, -32)
    petWidthSlider:SetValue(MinimalUnitFramesDB.petWidth or addon.Config.defaultConfig.width)
    petWidthSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petWidth or addon.Config.defaultConfig.width))

    -- Pet Frame Height Slider
    local petHeightSlider = CreateSlider(content, "Height", "Adjust the height of the pet frame", 50, 200, 1, function(self, value)
        MinimalUnitFramesDB.petHeight = value
        addon.UpdateFrameSize(addon.petFrame, "pet")
    end)
    petHeightSlider:SetPoint("TOPLEFT", petWidthSlider, "BOTTOMLEFT", 0, -48)
    petHeightSlider:SetValue(MinimalUnitFramesDB.petHeight or addon.Config.defaultConfig.height)
    petHeightSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petHeight or addon.Config.defaultConfig.height))

    -- Pet Frame X Position Slider
    local petXPosSlider = CreateSlider(content, "X Position", "Adjust the horizontal position of the pet frame", -500, 500, 1, function(self, value)
        MinimalUnitFramesDB.petXPos = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end)
    petXPosSlider:SetPoint("TOPLEFT", petHeightSlider, "BOTTOMLEFT", 0, -48)
    petXPosSlider:SetValue(MinimalUnitFramesDB.petXPos or addon.Config.defaultConfig.petXPos)
    petXPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petXPos or addon.Config.defaultConfig.petXPos))

    -- Pet Frame Y Position Slider
    local petYPosSlider = CreateSlider(content, "Y Position", "Adjust the vertical position of the pet frame", -500, 500, 1, function(self, value)
        MinimalUnitFramesDB.petYPos = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end)
    petYPosSlider:SetPoint("TOPLEFT", petXPosSlider, "BOTTOMLEFT", 0, -48)
    petYPosSlider:SetValue(MinimalUnitFramesDB.petYPos or addon.Config.defaultConfig.petYPos)
    petYPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petYPos or addon.Config.defaultConfig.petYPos))

    -- Pet Frame Strata Dropdown
    local petStrataDropdown = CreateDropdown(content, "Frame Strata", {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG"}, MinimalUnitFramesDB.petStrata or addon.Config.defaultConfig.petStrata,
        function(value)
            MinimalUnitFramesDB.petStrata = value
            addon.UpdateFrameStrata(addon.petFrame)
        end)
    petStrataDropdown:SetPoint("TOPLEFT", petYPosSlider, "BOTTOMLEFT", -28, -48)

    -- Pet Frame Anchor Dropdown
    local petAnchorDropdown = CreateDropdown(content, "Anchor Point", {"TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT"},
        MinimalUnitFramesDB.petAnchor or addon.Config.defaultConfig.petAnchor, function(value)
            MinimalUnitFramesDB.petAnchor = value
            addon.UpdateFramePosition(addon.petFrame, "pet")
        end)
    petAnchorDropdown:SetPoint("TOPLEFT", petStrataDropdown, "BOTTOMLEFT", 0, -32)

    -- *********************
    -- Pet Target Frame Options
    -- *********************
    local petTargetOptionsTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    petTargetOptionsTitle:SetPoint("TOPLEFT", targettargetAnchorDropdown, "BOTTOMLEFT", 32, -16)
    petTargetOptionsTitle:SetText("Pet Target Frame Options")

    -- Pet Target Frame Visibility Checkbox
    local petTargetFrameCheck = CreateCheckbox(content, "Pet Target Frame", "Toggle visibility of Pet Target Frame", function(self)
        MinimalUnitFramesDB.showPettargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end)
    petTargetFrameCheck:SetPoint("TOPLEFT", petTargetOptionsTitle, "TOPLEFT", 16, -160)
    petTargetFrameCheck:SetChecked(MinimalUnitFramesDB.showPettargetFrame)

    -- Pet Target Show Text Checkbox
    local petTargetShowTextCheck = CreateCheckbox(content, "Show Pet Target Text", "Display text on pet target frame", function(self)
        MinimalUnitFramesDB.showPetTargetText = self:GetChecked()
        addon.UpdateTextVisibility("pettarget")
    end)
    petTargetShowTextCheck:SetPoint("TOPLEFT", petTargetFrameCheck, "BOTTOMLEFT", 0, -16)
    petTargetShowTextCheck:SetChecked(MinimalUnitFramesDB.showPetTargetText)

    -- Pet Target Frame Width Slider
    local petTargetWidthSlider = CreateSlider(content, "Width", "Adjust the width of the pet target frame", 100, 500, 1, function(self, value)
        MinimalUnitFramesDB.petTargetWidth = value
        addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")
    end)
    petTargetWidthSlider:SetPoint("TOPLEFT", petTargetShowTextCheck, "BOTTOMLEFT", 0, -32)
    petTargetWidthSlider:SetValue(MinimalUnitFramesDB.petTargetWidth or addon.Config.defaultConfig.width)
    petTargetWidthSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petTargetWidth or addon.Config.defaultConfig.width))

    -- Pet Target Frame Height Slider
    local petTargetHeightSlider = CreateSlider(content, "Height", "Adjust the height of the pet target frame", 50, 200, 1, function(self, value)
        MinimalUnitFramesDB.petTargetHeight = value
        addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")
    end)
    petTargetHeightSlider:SetPoint("TOPLEFT", petTargetWidthSlider, "BOTTOMLEFT", 0, -48)
    petTargetHeightSlider:SetValue(MinimalUnitFramesDB.petTargetHeight or addon.Config.defaultConfig.height)
    petTargetHeightSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petTargetHeight or addon.Config.defaultConfig.height))

    -- Pet Target Frame X Position Slider
    local petTargetXPosSlider = CreateSlider(content, "X Position", "Adjust the horizontal position of the pet target frame", -500, 500, 1, function(self, value)
        MinimalUnitFramesDB.petTargetXPos = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end)
    petTargetXPosSlider:SetPoint("TOPLEFT", petTargetHeightSlider, "BOTTOMLEFT", 0, -48)
    petTargetXPosSlider:SetValue(MinimalUnitFramesDB.petTargetXPos or addon.Config.defaultConfig.petTargetXPos)
    petTargetXPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petTargetXPos or addon.Config.defaultConfig.petTargetXPos))

    -- Pet Target Frame Y Position Slider
    local petTargetYPosSlider = CreateSlider(content, "Y Position", "Adjust the vertical position of the pet target frame", -500, 500, 1, function(self, value)
        MinimalUnitFramesDB.petTargetYPos = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end)
    petTargetYPosSlider:SetPoint("TOPLEFT", petTargetXPosSlider, "BOTTOMLEFT", 0, -48)
    petTargetYPosSlider:SetValue(MinimalUnitFramesDB.petTargetYPos or addon.Config.defaultConfig.petTargetYPos)
    petTargetYPosSlider.editBox:SetText(tostring(MinimalUnitFramesDB.petTargetYPos or addon.Config.defaultConfig.petTargetYPos))

    -- Pet Target Frame Strata Dropdown
    local petTargetStrataDropdown = CreateDropdown(content, "Frame Strata", {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG"},
        MinimalUnitFramesDB.petTargetStrata or addon.Config.defaultConfig.petTargetStrata, function(value)
            MinimalUnitFramesDB.petTargetStrata = value
            addon.UpdateFrameStrata(addon.petTargetFrame)
        end)
    petTargetStrataDropdown:SetPoint("TOPLEFT", petTargetYPosSlider, "BOTTOMLEFT", -28, -48)

    -- Pet Target Frame Anchor Dropdown
    local petTargetAnchorDropdown = CreateDropdown(content, "Anchor Point", {"TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "CENTER", "LEFT", "RIGHT"},
        MinimalUnitFramesDB.petTargetAnchor or addon.Config.defaultConfig.petTargetAnchor, function(value)
            MinimalUnitFramesDB.petTargetAnchor = value
            addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
        end)
    petTargetAnchorDropdown:SetPoint("TOPLEFT", petTargetStrataDropdown, "BOTTOMLEFT", 0, -32)

    frame.initialized = true
end

--- Creates the Blizzard options panel
---@param name string
---@param parent string
local function AddToBlizzOptions(name, parent)
    local frame = CreateFrame("Frame")
    frame.name = name
    frame.parent = parent
    frame:SetScript("OnShow", FeedToBlizPanel)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        if parent then
            local category = Settings.GetCategory(parent)
            if not category then
                error(("The parent category '%s' was not found"):format(parent), 2)
            end
            local subcategory = Settings.RegisterCanvasLayoutSubcategory(category, frame, name)
            frame.name = subcategory.ID
        else
            local category = Settings.RegisterCanvasLayoutCategory(frame, name)
            category.ID = name
            frame.name = name
            Settings.RegisterAddOnCategory(category)
        end
    else
        InterfaceOptions_AddCategory(frame)
    end

    return frame
end

local mainOptionsFrame = AddToBlizzOptions("Minimal Unit Frames")
