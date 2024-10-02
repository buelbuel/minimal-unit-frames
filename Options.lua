---@class Options
local addonName, addon = ...

optionsPanel = CreateFrame("Frame", "MinimalUnitFramesOptionsPanel", UIParent)
optionsPanel.name = "Minimal Unit Frames"
optionsPanel:Hide()

--- Creates a scrollable frame
---@param parent any Frame
---@return any Frame, any Frame
local function CreateScrollableFrame(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 40)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetScrollChild(content)

    return scrollFrame, content
end

--- Creates a checkbox
---@param parent any Frame
---@param label string
---@param description string
---@param onClick function
---@return any Frame
local function CreateCheckbox(parent, label, description, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    check.Text:SetText(label)
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
    UIDropDownMenu_SetText(dropdown, default or "")

    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, item in ipairs(items) do
            info.text = item
            info.func = function()
                UIDropDownMenu_SetText(dropdown, item)
                onChange(item)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, Initialize)

    local labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
    labelText:SetText(label)

    return dropdown
end

--- Creates an input element
---@param parent any Frame
---@param label string
---@param tooltip string
---@param callback function
---@param yOffset number
---@param defaultValue string
local function CreateInputElement(parent, label, tooltip, onTextChanged, initialValue)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(250, 40)

    local labelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    labelText:SetText(label)

    local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox:SetSize(200, 20)
    editBox:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 5, -5)
    editBox:SetAutoFocus(false)
    editBox:SetText(initialValue or "")

    editBox:SetScript("OnEnterPressed", function(self)
        onTextChanged(self:GetText())
        self:ClearFocus()
    end)

    editBox:SetScript("OnEscapePressed", function(self)
        self:SetText(initialValue or "")
        self:ClearFocus()
    end)

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(label, 1, 1, 1)
        GameTooltip:AddLine(tooltip, nil, nil, nil, true)
        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    return frame
end

--- Creates an option element
---@param parent any Frame
---@param elementType string
---@param label string
---@param tooltip string
---@param onClick function
---@param yOffset number
---@param initialValue any
---@param options table
local function CreateOptionElement(parent, elementType, label, tooltip, onClick, initialValue, options)
    local element

    if elementType == "Checkbox" then
        element = CreateCheckbox(parent, label, tooltip, onClick)
        element:SetChecked(initialValue)
    elseif elementType == "Slider" then
        element = CreateSlider(parent, label, tooltip, options.min or 0, options.max or 100, options.step or 1, onClick)
        element:SetValue(initialValue or options.min or 0)
    elseif elementType == "Dropdown" then
        element = CreateDropdown(parent, label, options.items or {}, initialValue or "", onClick)
    elseif elementType == "Button" then
        element = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        element:SetText(label)
        element:SetWidth(150)
        element:SetHeight(25)
        element:SetScript("OnClick", onClick)
    elseif elementType == "Input" then
        element = CreateInputElement(parent, label, tooltip, onClick, initialValue)
    end

    if element then
        element:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, parent.lastElementOffset or 0)
        element:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        element:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        local offset = elementType == "Checkbox" and 30 or 50
        parent.lastElementOffset = (parent.lastElementOffset or 0) - offset
    end

    return element
end

--- Creates the options panel
---@param frame any Frame
local function CreateOptions(frame)
    if frame.initialized then
        return
    end

    local content = CreateFrame("Frame", nil, frame)
    content:SetSize(frame:GetWidth() - 30, frame:GetHeight() - 50)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -35)

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    title:SetText("Minimal Unit Frames Options")

    local tabNames = {"General", "Player", "Target", "Target of Target", "Pet", "Pet Target"}

    content.tabs = {}
    content.tabContents = {}

    -- Create tabs
    for i, tabName in ipairs(tabNames) do
        local tab = CreateFrame("Button", nil, content, "PanelTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(tabName)
        tab:SetScript("OnClick", function(self)
            PanelTemplates_SetTab(content, self:GetID())
            for _, tabContent in ipairs(content.tabContents) do
                tabContent:Hide()
            end
            content.tabContents[self:GetID()]:Show()
        end)
        tab:SetPoint("TOPLEFT", content, "BOTTOMLEFT", (i - 1) * 80, 0)
        content.tabs[i] = tab

        local tabContent = CreateFrame("Frame", nil, content)
        tabContent:SetSize(content:GetWidth(), content:GetHeight() - 30)
        tabContent:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -30)
        tabContent:Hide()
        content.tabContents[i] = tabContent

        local scrollFrame, scrollContent = CreateScrollableFrame(tabContent)
        content.tabContents[i].scrollFrame = scrollFrame
        content.tabContents[i].scrollContent = scrollContent
    end

    content.numTabs = #tabNames
    PanelTemplates_SetNumTabs(content, content.numTabs)
    PanelTemplates_SetTab(content, 1)

    content.tabContents[1]:Show()

    -- *********************
    -- General Options
    -- *********************
    local generalOptions = content.tabContents[1].scrollContent
    local leftColumn = CreateFrame("Frame", nil, generalOptions)
    leftColumn:SetSize(generalOptions:GetWidth() / 2 - 10, generalOptions:GetHeight())
    leftColumn:SetPoint("TOPLEFT", generalOptions, "TOPLEFT", 0, 0)

    local rightColumn = CreateFrame("Frame", nil, generalOptions)
    rightColumn:SetSize(generalOptions:GetWidth() / 2 - 10, generalOptions:GetHeight())
    rightColumn:SetPoint("TOPRIGHT", generalOptions, "TOPRIGHT", 0, 0)

    -- General Options (Left Column)
    CreateOptionElement(leftColumn, "Checkbox", "Show Border", "Display border around unit frames", function(self)
        MinimalUnitFramesDB.showBorder = self:GetChecked()
        addon.UpdateBorderVisibility()
    end, MinimalUnitFramesDB.showBorder)

    CreateOptionElement(leftColumn, "Checkbox", "Enable Class Resources", "Display class-specific resource bars", function(self)
        MinimalUnitFramesDB.enableClassResources = self:GetChecked()
        if MinimalUnitFramesDB.enableClassResources then
            addon.Util.LoadModule("ClassResources")
        end
        if addon.ClassResources then
            addon.ClassResources:UpdateClassResources()
        end
    end, MinimalUnitFramesDB.enableClassResources)

    CreateOptionElement(leftColumn, "Checkbox", "Show Frame Backdrop", "Display backdrop behind unit frames", function(self)
        MinimalUnitFramesDB.showFrameBackdrop = self:GetChecked()
        addon.UpdateFrameBackdropVisibility()
    end, MinimalUnitFramesDB.showFrameBackdrop)

    -- General Options (Right Column)
    CreateOptionElement(rightColumn, "Dropdown", "Bar Texture", "Select the texture for health and power bars", function(value)
        MinimalUnitFramesDB.barTexture = value
        addon.UpdateBarTexture()
    end, MinimalUnitFramesDB.barTexture, {
        items = addon.Util.GetMediaList("textures")
    })

    CreateOptionElement(rightColumn, "Dropdown", "Font", "Select the font for unit frames", function(value)
        MinimalUnitFramesDB.font = value
        addon.UpdateFont()
        addon.UpdateAllFrames()
        if addon.CombatText then
            addon.CombatText:UpdateCombatFeedbackFontSize()
        end
    end, MinimalUnitFramesDB.font, {
        items = addon.Util.GetMediaList("fonts")
    })

    CreateOptionElement(rightColumn, "Dropdown", "Font Style", "Select the font style for unit frames", function(value)
        MinimalUnitFramesDB.fontStyle = value
        addon.UpdateFont()
        addon.UpdateAllFrames()
        if addon.CombatText then
            addon.CombatText:UpdateCombatFeedbackFontSize()
        end
    end, MinimalUnitFramesDB.fontStyle, {
        items = addon.Util.GetMediaList("fontStyles")
    })

    CreateOptionElement(rightColumn, "Slider", "Font Size", "Adjust the font size for unit frames", function(self, value)
        MinimalUnitFramesDB.fontSize = value
        addon.UpdateFont()
        if addon.CombatText then
            addon.CombatText:UpdateCombatFeedbackFontSize()
        end
    end, MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, {
        min = 8,
        max = 24,
        step = 1
    })

    CreateOptionElement(rightColumn, "Button", "Reset Options", "Reset all options to default values", function()
        StaticPopup_Show("MINIMAL_UNIT_FRAMES_RESET_CONFIRM")
    end)

    -- *********************
    -- Player Frame Options
    -- *********************
    local playerOptions = content.tabContents[2].scrollContent
    local playerLeftColumn = CreateFrame("Frame", nil, playerOptions)
    playerLeftColumn:SetSize(playerOptions:GetWidth() / 2 - 10, playerOptions:GetHeight())
    playerLeftColumn:SetPoint("TOPLEFT", playerOptions, "TOPLEFT", 0, 0)

    local playerRightColumn = CreateFrame("Frame", nil, playerOptions)
    playerRightColumn:SetSize(playerOptions:GetWidth() / 2 - 10, playerOptions:GetHeight())
    playerRightColumn:SetPoint("TOPRIGHT", playerOptions, "TOPRIGHT", 0, 0)

    -- Player Frame Options (Left Column)
    CreateOptionElement(playerLeftColumn, "Checkbox", "Use Player Class Colors", "Use class colors for player health bar", function(self)
        MinimalUnitFramesDB.useClassColorsPlayer = self:GetChecked()
        addon.UpdateFrame(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.useClassColorsPlayer)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Frame", "Display Player frame", function(self)
        MinimalUnitFramesDB.showPlayerFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, MinimalUnitFramesDB.showPlayerFrame)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Power Bar", "Display power bar on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("player")
    end, MinimalUnitFramesDB.showPlayerPowerBar)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Frame Text", "Display text on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("player")
    end, MinimalUnitFramesDB.showPlayerFrameText)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Level Text", "Display level text on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("player")
    end, MinimalUnitFramesDB.showPlayerLevelText)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Buffs", "Display buffs on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerBuffs = self:GetChecked()
        if MinimalUnitFramesDB.showPlayerBuffs then
            addon.Util.LoadModule("Auras")
        end
        if addon.Auras then
            addon.UpdateFramesVisibility()
        end
    end, MinimalUnitFramesDB.showPlayerBuffs)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Debuffs", "Display debuffs on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerDebuffs = self:GetChecked()
        if MinimalUnitFramesDB.showPlayerDebuffs then
            addon.Util.LoadModule("Auras")
        end
        if addon.Auras then
            addon.UpdateFramesVisibility()
        end
    end, MinimalUnitFramesDB.showPlayerDebuffs)

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Combat Feedback", "Display combat feedback text", function(self)
        MinimalUnitFramesDB.showCombatFeedback = self:GetChecked()
        if MinimalUnitFramesDB.showCombatFeedback then
            addon.Util.LoadModule("CombatText")
        end
        if addon.CombatText then
            addon.CombatText:UpdateVisibility()
        end
    end, MinimalUnitFramesDB.showCombatFeedback)

    CreateOptionElement(playerLeftColumn, "Dropdown", "Player Frame Strata", "Set the strata of the Player frame", function(value)
        MinimalUnitFramesDB.playerStrata = value
        addon.UpdateFrameStrata(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.playerStrata, {
        items = addon.Util.GetMediaList("stratas")
    })

    CreateOptionElement(playerLeftColumn, "Dropdown", "Player Anchor Point", "Set the anchor point of the Player frame", function(value)
        MinimalUnitFramesDB.playerAnchor = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.playerAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    CreateOptionElement(playerLeftColumn, "Input", "Player Aura Whitelist", "Enter comma-separated aura names to always show", function(value)
        MinimalUnitFramesDB.playerAuraWhitelist = addon.Util.SplitString(value, ",")
        addon.UpdateAllFrames()
    end, table.concat(MinimalUnitFramesDB.playerAuraWhitelist or {}, ","))

    CreateOptionElement(playerLeftColumn, "Input", "Player Aura Blacklist", "Enter comma-separated aura names to never show", function(value)
        MinimalUnitFramesDB.playerAuraBlacklist = addon.Util.SplitString(value, ",")
        addon.UpdateAllFrames()
    end, table.concat(MinimalUnitFramesDB.playerAuraBlacklist or {}, ","))

    CreateOptionElement(playerLeftColumn, "Slider", "Combat Feedback Font Size", "Adjust the font size for combat feedback", function(self, value)
        MinimalUnitFramesDB.combatFeedbackFontSize = value
        addon.CombatText:UpdateCombatFeedbackFontSize()
    end, MinimalUnitFramesDB.combatFeedbackFontSize or addon.Config.combatFeedbackConfig.fontSize, {
        min = 8,
        max = 72,
        step = 1
    })

    CreateOptionElement(playerLeftColumn, "Dropdown", "Combat Feedback Anchor", "Set the anchor point for combat feedback", function(value)
        addon.Config.combatFeedbackConfig.anchorPoint = value
        addon.CombatText:CreateCombatFeedback(addon.playerFrame)
    end, addon.Config.combatFeedbackConfig.anchorPoint, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    CreateOptionElement(playerLeftColumn, "Dropdown", "Player Aura Anchor", "Set the anchor point for player auras", function(value)
        MinimalUnitFramesDB.playerAuraAnchor = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerAuraAnchor or "BOTTOMLEFT", {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Aura X Offset", "Adjust the horizontal offset of player auras", function(self, value)
        MinimalUnitFramesDB.playerAuraXOffset = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerAuraXOffset or 0, {
        min = -100,
        max = 100,
        step = 1
    })

    -- Player Frame Options (Right Column)
    CreateOptionElement(playerRightColumn, "Slider", "Player Width", "Adjust the width of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerWidth = value
        addon.UpdateFrameSize(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.playerWidth, {
        min = 50,
        max = 400,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Height", "Adjust the height of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerHeight = value
        addon.UpdateFrameSize(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.playerHeight, {
        min = 20,
        max = 200,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player X Position", "Adjust the horizontal position of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerXPos = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.playerXPos, {
        min = -800,
        max = 800,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Y Position", "Adjust the vertical position of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerYPos = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end, MinimalUnitFramesDB.playerYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Buff Size", "Adjust the size of player buff icons", function(self, value)
        MinimalUnitFramesDB.playerBuffSize = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerBuffSize or addon.Config.auraConfig.player.buffs.size, {
        min = 10,
        max = 50,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Debuff Size", "Adjust the size of player debuff icons", function(self, value)
        MinimalUnitFramesDB.playerDebuffSize = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerDebuffSize or addon.Config.auraConfig.player.debuffs.size, {
        min = 10,
        max = 50,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Buffs Per Row", "Adjust the number of buffs per row for player", function(self, value)
        MinimalUnitFramesDB.playerBuffsPerRow = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerBuffsPerRow or addon.Config.auraConfig.player.buffs.perRow, {
        min = 1,
        max = 20,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Debuffs Per Row", "Adjust the number of debuffs per row for player", function(self, value)
        MinimalUnitFramesDB.playerDebuffsPerRow = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerDebuffsPerRow or addon.Config.auraConfig.player.debuffs.perRow, {
        min = 1,
        max = 20,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Buff Limit", "Set the maximum number of buffs to display", function(self, value)
        MinimalUnitFramesDB.playerBuffLimit = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerBuffLimit or 32, {
        min = 0,
        max = 40,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Debuff Limit", "Set the maximum number of debuffs to display", function(self, value)
        MinimalUnitFramesDB.playerDebuffLimit = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerDebuffLimit or 16, {
        min = 0,
        max = 40,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Checkbox", "Show Buff Stack Text", "Display stack count on buffs", function(self)
        MinimalUnitFramesDB.playerShowAuraStackText = self:GetChecked()
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerShowAuraStackText)

    CreateOptionElement(playerLeftColumn, "Slider", "Buff Stack Text Size", "Adjust the size of buff stack text", function(self, value)
        MinimalUnitFramesDB.playerAuraStackTextSize = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerAuraStackTextSize or addon.Config.auraConfig.player.buffs.stackTextSize, {
        min = 6,
        max = 20,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Dropdown", "Buff Stack Text Anchor", "Set the anchor point for buff stack text", function(value)
        MinimalUnitFramesDB.playerAuraStackTextAnchor = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerAuraStackTextAnchor or addon.Config.auraConfig.player.buffs.stackTextAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    CreateOptionElement(playerRightColumn, "Slider", "Combat Feedback X Offset", "Adjust the horizontal offset of combat feedback", function(self, value)
        addon.Config.combatFeedbackConfig.xOffset = value
        addon.CombatText:CreateCombatFeedback(addon.playerFrame)
    end, addon.Config.combatFeedbackConfig.xOffset, {
        min = -100,
        max = 100,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Combat Feedback Y Offset", "Adjust the vertical offset of combat feedback", function(self, value)
        addon.Config.combatFeedbackConfig.yOffset = value
        addon.CombatText:CreateCombatFeedback(addon.playerFrame)
    end, addon.Config.combatFeedbackConfig.yOffset, {
        min = -100,
        max = 100,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Combat Feedback Duration", "Set the duration of combat feedback text", function(self, value)
        addon.Config.combatFeedbackConfig.duration = value
    end, addon.Config.combatFeedbackConfig.duration, {
        min = 0.5,
        max = 5,
        step = 0.1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Combat Feedback Fade Duration", "Set the fade-out duration of combat feedback text", function(self, value)
        addon.Config.combatFeedbackConfig.fadeOutDuration = value
    end, addon.Config.combatFeedbackConfig.fadeOutDuration, {
        min = 0.1,
        max = 2,
        step = 0.1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Aura Y Offset", "Adjust the vertical offset of player auras", function(self, value)
        MinimalUnitFramesDB.playerAuraYOffset = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerAuraYOffset or 0, {
        min = -100,
        max = 100,
        step = 1
    })

    CreateOptionElement(playerRightColumn, "Slider", "Player Aura Vertical Spacing", "Adjust the vertical space between buff and debuff rows", function(self, value)
        MinimalUnitFramesDB.playerAuraVerticalSpacing = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.playerAuraVerticalSpacing or 2, {
        min = 0,
        max = 20,
        step = 1
    })

    -- *********************
    -- Target Frame Options
    -- *********************
    local targetOptions = content.tabContents[3].scrollContent
    local targetLeftColumn = CreateFrame("Frame", nil, targetOptions)
    targetLeftColumn:SetSize(targetOptions:GetWidth() / 2 - 10, targetOptions:GetHeight())
    targetLeftColumn:SetPoint("TOPLEFT", targetOptions, "TOPLEFT", 0, 0)

    local targetRightColumn = CreateFrame("Frame", nil, targetOptions)
    targetRightColumn:SetSize(targetOptions:GetWidth() / 2 - 10, targetOptions:GetHeight())
    targetRightColumn:SetPoint("TOPRIGHT", targetOptions, "TOPRIGHT", 0, 0)

    -- Target Frame Options (Left Column)
    CreateOptionElement(targetLeftColumn, "Checkbox", "Use Target Class Colors", "Use class colors for target health bar", function(self)
        MinimalUnitFramesDB.useClassColorsTarget = self:GetChecked()
        addon.UpdateFrame(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.useClassColorsTarget)

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Frame", "Display Target frame", function(self)
        MinimalUnitFramesDB.showTargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, MinimalUnitFramesDB.showTargetFrame)

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Power Bar", "Display power bar on Target frame", function(self)
        MinimalUnitFramesDB.showTargetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("target")
    end, MinimalUnitFramesDB.showTargetPowerBar)

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Text", "Display text on Target frame", function(self)
        MinimalUnitFramesDB.showTargetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("target")
    end, MinimalUnitFramesDB.showTargetFrameText)

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Level Text", "Display level text on Target frame", function(self)
        MinimalUnitFramesDB.showTargetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("target")
    end, MinimalUnitFramesDB.showTargetLevelText)

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Buffs", "Display buffs on Target frame", function(self)
        MinimalUnitFramesDB.showTargetBuffs = self:GetChecked()
        if MinimalUnitFramesDB.showTargetBuffs then
            addon.Util.LoadModule("Auras")
        end
        if addon.Auras then
            addon.UpdateFramesVisibility()
        end
    end, MinimalUnitFramesDB.showTargetBuffs)

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Debuffs", "Display debuffs on Target frame", function(self)
        MinimalUnitFramesDB.showTargetDebuffs = self:GetChecked()
        if MinimalUnitFramesDB.showTargetDebuffs then
            addon.Util.LoadModule("Auras")
        end
        if addon.Auras then
            addon.UpdateFramesVisibility()
        end
    end, MinimalUnitFramesDB.showTargetDebuffs)

    CreateOptionElement(targetLeftColumn, "Dropdown", "Target Frame Strata", "Set the strata of the Target frame", function(value)
        MinimalUnitFramesDB.targetStrata = value
        addon.UpdateFrameStrata(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetStrata, {
        items = addon.Util.GetMediaList("stratas")
    })

    CreateOptionElement(targetLeftColumn, "Dropdown", "Anchored To", "Choose where to anchor the Target frame", function(value)
        MinimalUnitFramesDB.targetAnchoredTo = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetAnchoredTo or "Screen", {
        items = {"Screen", "Player Frame"}
    })

    CreateOptionElement(targetLeftColumn, "Dropdown", "Target Anchor Point", "Set the anchor point of the Target frame", function(value)
        MinimalUnitFramesDB.targetAnchor = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })
    CreateOptionElement(targetLeftColumn, "Dropdown", "Target Aura Anchor", "Set the anchor point for target auras", function(value)
        MinimalUnitFramesDB.targetAuraAnchor = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetAuraAnchor or "BOTTOMLEFT", {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Target Frame Options (Right Column)
    CreateOptionElement(targetRightColumn, "Slider", "Target Width", "Adjust the width of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetWidth = value
        addon.UpdateFrameSize(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetWidth, {
        min = 50,
        max = 400,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Height", "Adjust the height of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetHeight = value
        addon.UpdateFrameSize(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetHeight, {
        min = 20,
        max = 200,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target X Position", "Adjust the horizontal position of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetXPos = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetXPos, {
        min = -800,
        max = 800,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Y Position", "Adjust the vertical position of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetYPos = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, MinimalUnitFramesDB.targetYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Buff Size", "Adjust the size of target buff icons", function(self, value)
        MinimalUnitFramesDB.targetBuffSize = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetBuffSize or addon.Config.auraConfig.target.buffs.size, {
        min = 10,
        max = 50,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Debuff Size", "Adjust the size of target debuff icons", function(self, value)
        MinimalUnitFramesDB.targetDebuffSize = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetDebuffSize or addon.Config.auraConfig.target.debuffs.size, {
        min = 10,
        max = 50,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Buffs Per Row", "Adjust the number of buffs per row for target", function(self, value)
        MinimalUnitFramesDB.targetBuffsPerRow = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetBuffsPerRow or addon.Config.auraConfig.target.buffs.perRow, {
        min = 1,
        max = 20,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Debuffs Per Row", "Adjust the number of debuffs per row for target", function(self, value)
        MinimalUnitFramesDB.targetDebuffsPerRow = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetDebuffsPerRow or addon.Config.auraConfig.target.debuffs.perRow, {
        min = 1,
        max = 20,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Buff Limit", "Set the maximum number of buffs to display", function(self, value)
        MinimalUnitFramesDB.targetBuffLimit = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetBuffLimit or 32, {
        min = 0,
        max = 40,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Debuff Limit", "Set the maximum number of debuffs to display", function(self, value)
        MinimalUnitFramesDB.targetDebuffLimit = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetDebuffLimit or 16, {
        min = 0,
        max = 40,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Aura X Offset", "Adjust the horizontal offset of target auras", function(self, value)
        MinimalUnitFramesDB.targetAuraXOffset = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetAuraXOffset or 0, {
        min = -100,
        max = 100,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Aura Y Offset", "Adjust the vertical offset of target auras", function(self, value)
        MinimalUnitFramesDB.targetAuraYOffset = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetAuraYOffset or 0, {
        min = -100,
        max = 100,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Slider", "Target Aura Vertical Spacing", "Adjust the vertical space between buff and debuff rows", function(self, value)
        MinimalUnitFramesDB.targetAuraVerticalSpacing = value
        addon.UpdateAllFrames()
    end, MinimalUnitFramesDB.targetAuraVerticalSpacing or 2, {
        min = 0,
        max = 20,
        step = 1
    })

    -- *********************
    -- Target of Target Frame Options
    -- *********************
    local totOptions = content.tabContents[4].scrollContent
    local totLeftColumn = CreateFrame("Frame", nil, totOptions)
    totLeftColumn:SetSize(totOptions:GetWidth() / 2 - 10, totOptions:GetHeight())
    totLeftColumn:SetPoint("TOPLEFT", totOptions, "TOPLEFT", 0, 0)

    local totRightColumn = CreateFrame("Frame", nil, totOptions)
    totRightColumn:SetSize(totOptions:GetWidth() / 2 - 10, totOptions:GetHeight())
    totRightColumn:SetPoint("TOPRIGHT", totOptions, "TOPRIGHT", 0, 0)

    -- Target of Target Frame Options (Left Column)
    CreateOptionElement(totLeftColumn, "Checkbox", "Use Target of Target Class Colors", "Use class colors for player health bar", function(self)
        MinimalUnitFramesDB.useClassColorsTargetoftarget = self:GetChecked()
        addon.UpdateFrame(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.useClassColorsTargetoftarget)

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Frame", "Display Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, MinimalUnitFramesDB.showTargetoftargetFrame)

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Power Bar", "Display power bar on Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("targetoftarget")
    end, MinimalUnitFramesDB.showTargetoftargetPowerBar)

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Text", "Display text on Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("targetoftarget")
    end, MinimalUnitFramesDB.showTargetoftargetFrameText)

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Level Text", "Display level text on Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("targetoftarget")
    end, MinimalUnitFramesDB.showTargetoftargetLevelText)

    CreateOptionElement(totLeftColumn, "Dropdown", "Target of Target Frame Strata", "Set the strata of the Target of Target frame", function(value)
        MinimalUnitFramesDB.targetoftargetStrata = value
        addon.UpdateFrameStrata(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.targetoftargetStrata, {
        items = addon.Util.GetMediaList("stratas")
    })

    CreateOptionElement(totLeftColumn, "Dropdown", "Target of Target Anchor Point", "Set the anchor point of the Target of Target frame", function(value)
        MinimalUnitFramesDB.targetoftargetAnchor = value
        addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.targetoftargetAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Target of Target Frame Options (Right Column)
    CreateOptionElement(totRightColumn, "Slider", "Target of Target Width", "Adjust the width of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetWidth = value
        addon.UpdateFrameSize(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.targetoftargetWidth, {
        min = 50,
        max = 400,
        step = 1
    })

    CreateOptionElement(totRightColumn, "Slider", "Target of Target Height", "Adjust the height of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetHeight = value
        addon.UpdateFrameSize(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.targetoftargetHeight, {
        min = 20,
        max = 200,
        step = 1
    })

    CreateOptionElement(totRightColumn, "Slider", "Target of Target X Position", "Adjust the horizontal position of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetXPos = value
        addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.targetoftargetXPos, {
        min = -800,
        max = 800,
        step = 1
    })

    CreateOptionElement(totRightColumn, "Slider", "Target of Target Y Position", "Adjust the vertical position of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetYPos = value
        addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    end, MinimalUnitFramesDB.targetoftargetYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    CreateOptionElement(targetRightColumn, "Input", "Target Aura Whitelist", "Enter comma-separated aura names or spell IDs to always show", function(value)
        MinimalUnitFramesDB.targetAuraWhitelist = addon.Util.SplitString(value, ",")
        addon.UpdateAllFrames()
    end, table.concat(MinimalUnitFramesDB.targetAuraWhitelist or {}, ","))

    CreateOptionElement(targetRightColumn, "Input", "Target Aura Blacklist", "Enter comma-separated aura names or spell IDs to never show", function(value)
        MinimalUnitFramesDB.targetAuraBlacklist = addon.Util.SplitString(value, ",")
        addon.UpdateAllFrames()
    end, table.concat(MinimalUnitFramesDB.targetAuraBlacklist or {}, ","))

    -- *********************
    -- Pet Frame Options
    -- *********************
    local petOptions = content.tabContents[5].scrollContent
    local petLeftColumn = CreateFrame("Frame", nil, petOptions)
    petLeftColumn:SetSize(petOptions:GetWidth() / 2 - 10, petOptions:GetHeight())
    petLeftColumn:SetPoint("TOPLEFT", petOptions, "TOPLEFT", 0, 0)

    local petRightColumn = CreateFrame("Frame", nil, petOptions)
    petRightColumn:SetSize(petOptions:GetWidth() / 2 - 10, petOptions:GetHeight())
    petRightColumn:SetPoint("TOPRIGHT", petOptions, "TOPRIGHT", 0, 0)

    -- Pet Frame Options (Left Column)
    CreateOptionElement(petLeftColumn, "Checkbox", "Use Pet Class Colors", "Use class colors for Pet health bar", function(self)
        MinimalUnitFramesDB.useClassColorsPet = self:GetChecked()
        addon.UpdateFrame(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.useClassColorsPet)

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Frame", "Display Pet frame", function(self)
        MinimalUnitFramesDB.showPetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, MinimalUnitFramesDB.showPetFrame)

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Power Bar", "Display power bar on Pet frame", function(self)
        MinimalUnitFramesDB.showPetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("pet")
    end, MinimalUnitFramesDB.showPetPowerBar)

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Frame Text", "Display text on Pet frame", function(self)
        MinimalUnitFramesDB.showPetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("pet")
    end, MinimalUnitFramesDB.showPetFrameText)

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Level Text", "Display level text on Pet frame", function(self)
        MinimalUnitFramesDB.showPetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("pet")
    end, MinimalUnitFramesDB.showPetLevelText)

    CreateOptionElement(petLeftColumn, "Dropdown", "Pet Frame Strata", "Set the strata of the Pet frame", function(value)
        MinimalUnitFramesDB.petStrata = value
        addon.UpdateFrameStrata(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.petStrata, {
        items = addon.Util.GetMediaList("stratas")
    })

    CreateOptionElement(petLeftColumn, "Dropdown", "Pet Anchor Point", "Set the anchor point of the Pet frame", function(value)
        MinimalUnitFramesDB.petAnchor = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.petAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Pet Frame Options (Right Column)
    CreateOptionElement(petRightColumn, "Slider", "Pet Width", "Adjust the width of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petWidth = value
        addon.UpdateFrameSize(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.petWidth, {
        min = 50,
        max = 400,
        step = 1
    })

    CreateOptionElement(petRightColumn, "Slider", "Pet Height", "Adjust the height of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petHeight = value
        addon.UpdateFrameSize(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.petHeight, {
        min = 20,
        max = 200,
        step = 1
    })

    CreateOptionElement(petRightColumn, "Slider", "Pet X Position", "Adjust the horizontal position of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petXPos = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.petXPos, {
        min = -800,
        max = 800,
        step = 1
    })

    CreateOptionElement(petRightColumn, "Slider", "Pet Y Position", "Adjust the vertical position of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petYPos = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end, MinimalUnitFramesDB.petYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    -- *********************
    -- Pet Target Frame Options
    -- *********************
    local petTargetOptions = content.tabContents[6].scrollContent
    local petTargetLeftColumn = CreateFrame("Frame", nil, petTargetOptions)
    petTargetLeftColumn:SetSize(petTargetOptions:GetWidth() / 2 - 10, petTargetOptions:GetHeight())
    targetLeftColumn:SetPoint("TOPLEFT", targetOptions, "TOPLEFT", 0, 0)

    local petTargetRightColumn = CreateFrame("Frame", nil, petTargetOptions)
    petTargetRightColumn:SetSize(petTargetOptions:GetWidth() / 2 - 10, petTargetOptions:GetHeight())
    petTargetRightColumn:SetPoint("TOPRIGHT", petTargetOptions, "TOPRIGHT", 0, 0)

    -- Pet Target Frame Options (Left Column)
    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Use Pet Target Class Colors", "Use class colors for player health bar", function(self)
        MinimalUnitFramesDB.useClassColorsPetTarget = self:GetChecked()
        addon.UpdateFrame(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.useClassColorsPetTarget)

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Frame", "Display Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, MinimalUnitFramesDB.showPetTargetFrame)

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Power Bar", "Display power bar on Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("pettarget")
    end, MinimalUnitFramesDB.showPetTargetPowerBar)

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Frame Text", "Display text on Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("pettarget")
    end, MinimalUnitFramesDB.showPetTargetFrameText)

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Level Text", "Display level text on Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("pettarget")
    end, MinimalUnitFramesDB.showPetTargetLevelText)

    CreateOptionElement(petTargetLeftColumn, "Dropdown", "Pet Target Frame Strata", "Set the strata of the Pet Target frame", function(value)
        MinimalUnitFramesDB.petTargetStrata = value
        addon.UpdateFrameStrata(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.petTargetStrata, {
        items = addon.Util.GetMediaList("stratas")
    })

    CreateOptionElement(petTargetLeftColumn, "Dropdown", "Pet Target Anchor Point", "Set the anchor point of the Pet Target frame", function(value)
        MinimalUnitFramesDB.petTargetAnchor = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.petTargetAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Pet Target Frame Options (Right Column)
    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target Width", "Adjust the width of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetWidth = value
        addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.petTargetWidth, {
        min = 50,
        max = 400,
        step = 1
    })

    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target Height", "Adjust the height of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetHeight = value
        addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.petTargetHeight, {
        min = 20,
        max = 200,
        step = 1
    })

    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target X Position", "Adjust the horizontal position of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetXPos = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.petTargetXPos, {
        min = -800,
        max = 800,
        step = 1
    })

    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target Y Position", "Adjust the vertical position of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetYPos = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end, MinimalUnitFramesDB.petTargetYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    frame.initialized = true
end

--- Feeds the options panel to the Blizzard options panel
---@param frame any Frame
local function FeedToBlizzPanel(frame)
    CreateOptions(frame)
    if frame.initialized then
        local content = frame
        if content and content.tabs then
            PanelTemplates_SetTab(content, 1)
            for i, tabContent in ipairs(content.tabContents) do
                if i == 1 then
                    tabContent:Show()
                else
                    tabContent:Hide()
                end
            end
        end
    end
end

--- Creates the Blizzard options panel
---@param name string
---@param parent string
local function AddToBlizzOptions(name, parent)
    local frame = CreateFrame("Frame")
    frame.name = name
    frame.parent = parent
    frame.initialized = false
    frame:SetScript("OnShow", FeedToBlizzPanel)

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

--- Reset options dialog
StaticPopupDialogs["MINIMAL_UNIT_FRAMES_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset all Minimal Unit Frames options to default values? This will reload the UI.",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        MinimalUnitFramesDB = nil
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

local mainOptionsFrame = AddToBlizzOptions("Minimal Unit Frames")
