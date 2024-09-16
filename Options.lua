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
---@return any Frame
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

--- Creates a group of options
---@param parent any Frame
---@param title string
---@param yOffset number
---@return any Frame
local function CreateOptionGroup(parent, title, yOffset)
    local group = CreateFrame("Frame", nil, parent)
    group:SetSize(parent:GetWidth(), 30)
    group:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    return group
end

--- Creates an option element
---@param parent any Frame
---@param elementType string
---@param label string
---@param tooltip string
---@param onClick function
---@param yOffset number
---@param initialValue any
local function CreateOptionElement(parent, elementType, label, tooltip, onClick, yOffset, initialValue, options)
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
    end

    if element then
        element:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)
    end
    return element
end

--- Creates a group of options for a specific frame
---@param content any Frame
---@param frameName string
---@param yOffset number
---@return any Frame
local function CreateFrameOptions(content, frameName, yOffset)
    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetSize(content:GetWidth() / 2 - 10, content:GetHeight())
    leftColumn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetSize(content:GetWidth() / 2 - 10, content:GetHeight())
    rightColumn:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, yOffset)

    local leftY = 0
    local rightY = 0

    -- Left Column
    CreateOptionElement(leftColumn, "Checkbox", "Show " .. frameName .. " Frame", "Display " .. frameName .. " frame", function(self)
        MinimalUnitFramesDB["show" .. frameName .. "Frame"] = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, leftY, MinimalUnitFramesDB["show" .. frameName .. "Frame"])
    leftY = leftY - 30

    CreateOptionElement(leftColumn, "Checkbox", "Show " .. frameName .. " Text", "Display text on " .. frameName .. " frame", function(self)
        MinimalUnitFramesDB["show" .. frameName .. "Text"] = self:GetChecked()
        addon.UpdateFrameTextVisibility(string.lower(frameName))
    end, leftY, MinimalUnitFramesDB["show" .. frameName .. "Text"])
    leftY = leftY - 30

    CreateOptionElement(leftColumn, "Checkbox", "Show " .. frameName .. " Level Text", "Display level text on " .. frameName .. " frame", function(self)
        MinimalUnitFramesDB["show" .. frameName .. "LevelText"] = self:GetChecked()
        addon.UpdateLevelTextVisibility(string.lower(frameName))
    end, leftY, MinimalUnitFramesDB["show" .. frameName .. "LevelText"])
    leftY = leftY - 50

    CreateOptionElement(leftColumn, "Dropdown", "Frame Strata", "Set the strata of the " .. frameName .. " frame", function(value)
        MinimalUnitFramesDB[string.lower(frameName) .. "Strata"] = value
        addon.UpdateFrameStrata(addon[string.lower(frameName) .. "Frame"], string.lower(frameName))
    end, leftY, MinimalUnitFramesDB[string.lower(frameName) .. "Strata"], {
        items = addon.Util.GetMediaList("stratas")
    })
    leftY = leftY - 50

    CreateOptionElement(leftColumn, "Dropdown", "Anchor Point", "Set the anchor point of the " .. frameName .. " frame", function(value)
        MinimalUnitFramesDB[string.lower(frameName) .. "Anchor"] = value
        addon.UpdateFramePosition(addon[string.lower(frameName) .. "Frame"], string.lower(frameName))
    end, leftY, MinimalUnitFramesDB[string.lower(frameName) .. "Anchor"], {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Right Column
    CreateOptionElement(rightColumn, "Slider", "Width", "Adjust the width of the " .. frameName .. " frame", function(self, value)
        MinimalUnitFramesDB[string.lower(frameName) .. "Width"] = value
        addon.UpdateFrameSize(addon[string.lower(frameName) .. "Frame"], string.lower(frameName))
    end, rightY, MinimalUnitFramesDB[string.lower(frameName) .. "Width"], {
        min = 50,
        max = 400,
        step = 1
    })
    rightY = rightY - 50

    CreateOptionElement(rightColumn, "Slider", "Height", "Adjust the height of the " .. frameName .. " frame", function(self, value)
        MinimalUnitFramesDB[string.lower(frameName) .. "Height"] = value
        addon.UpdateFrameSize(addon[string.lower(frameName) .. "Frame"], string.lower(frameName))
    end, rightY, MinimalUnitFramesDB[string.lower(frameName) .. "Height"], {
        min = 20,
        max = 200,
        step = 1
    })
    rightY = rightY - 50

    CreateOptionElement(rightColumn, "Slider", "X Position", "Adjust the horizontal position of the " .. frameName .. " frame", function(self, value)
        MinimalUnitFramesDB[string.lower(frameName) .. "XPos"] = value
        addon.UpdateFramePosition(addon[string.lower(frameName) .. "Frame"], string.lower(frameName))
    end, rightY, MinimalUnitFramesDB[string.lower(frameName) .. "XPos"], {
        min = -800,
        max = 800,
        step = 1
    })
    rightY = rightY - 50

    CreateOptionElement(rightColumn, "Slider", "Y Position", "Adjust the vertical position of the " .. frameName .. " frame", function(self, value)
        MinimalUnitFramesDB[string.lower(frameName) .. "YPos"] = value
        addon.UpdateFramePosition(addon[string.lower(frameName) .. "Frame"], string.lower(frameName))
    end, rightY, MinimalUnitFramesDB[string.lower(frameName) .. "YPos"], {
        min = -600,
        max = 600,
        step = 1
    })
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

    local function CreateTab(parent, text, id)
        local tab = CreateFrame("Button", nil, parent, "PanelTabButtonTemplate")
        tab:SetID(id)
        tab:SetText(text)
        tab:SetScript("OnClick", function(self)
            PanelTemplates_SetTab(parent, self:GetID())
            for j, tabContent in ipairs(parent.tabContents) do
                if j == self:GetID() then
                    tabContent:Show()
                else
                    tabContent:Hide()
                end
            end
        end)
        return tab
    end

    for i, name in ipairs(tabNames) do
        local tab = CreateTab(content, name, i)
        if i == 1 then
            tab:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 5, 5)
        else
            tab:SetPoint("BOTTOMLEFT", content.tabs[i - 1], "BOTTOMRIGHT", -15, 0)
        end
        table.insert(content.tabs, tab)

        local tabContent = CreateFrame("Frame", nil, content)
        tabContent:SetSize(content:GetWidth() - 20, content:GetHeight() - 40)
        tabContent:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
        tabContent:Hide()
        table.insert(content.tabContents, tabContent)
    end

    content.numTabs = #tabNames
    PanelTemplates_SetNumTabs(content, content.numTabs)
    PanelTemplates_SetTab(content, 1)

    content.tabContents[1]:Show()

    -- *********************
    -- General Options
    -- *********************
    local generalOptions = content.tabContents[1]
    local leftColumn = CreateFrame("Frame", nil, generalOptions)
    leftColumn:SetSize(generalOptions:GetWidth() / 2 - 10, generalOptions:GetHeight())
    leftColumn:SetPoint("TOPLEFT", generalOptions, "TOPLEFT", 0, 0)

    local rightColumn = CreateFrame("Frame", nil, generalOptions)
    rightColumn:SetSize(generalOptions:GetWidth() / 2 - 10, generalOptions:GetHeight())
    rightColumn:SetPoint("TOPRIGHT", generalOptions, "TOPRIGHT", 0, 0)

    local leftYOffset = -10
    local rightYOffset = -10

    -- General Options (Left Column)
    CreateOptionElement(leftColumn, "Checkbox", "Show Border", "Display border around unit frames", function(self)
        MinimalUnitFramesDB.showBorder = self:GetChecked()
        addon.UpdateBorderVisibility()
    end, leftYOffset, MinimalUnitFramesDB.showBorder)
    leftYOffset = leftYOffset - 30

    CreateOptionElement(leftColumn, "Checkbox", "Enable Class Resources", "Display class-specific resource bars", function(self)
        MinimalUnitFramesDB.enableClassResources = self:GetChecked()
        addon.UpdateClassResources()
    end, leftYOffset, MinimalUnitFramesDB.enableClassResources)
    leftYOffset = leftYOffset - 30

    CreateOptionElement(leftColumn, "Checkbox", "Show Frame Backdrop", "Display backdrop behind unit frames", function(self)
        MinimalUnitFramesDB.showFrameBackdrop = self:GetChecked()
        addon.UpdateFrameBackdropVisibility()
    end, leftYOffset, MinimalUnitFramesDB.showFrameBackdrop)

    -- General Options (Right Column)
    CreateOptionElement(rightColumn, "Dropdown", "Bar Texture", "Select the texture for health and power bars", function(value)
        MinimalUnitFramesDB.barTexture = value
        addon.UpdateBarTexture()
    end, rightYOffset, MinimalUnitFramesDB.barTexture, {
        items = addon.Util.GetMediaList("textures")
    })
    rightYOffset = rightYOffset - 50

    CreateOptionElement(rightColumn, "Dropdown", "Font", "Select the font for unit frames", function(value)
        MinimalUnitFramesDB.font = value
        addon.UpdateFont()
        addon.UpdateAllFrames()
    end, rightYOffset, MinimalUnitFramesDB.font, {
        items = addon.Util.GetMediaList("fonts")
    })
    rightYOffset = rightYOffset - 50

    CreateOptionElement(rightColumn, "Dropdown", "Font Style", "Select the font style for unit frames", function(value)
        MinimalUnitFramesDB.fontStyle = value
        addon.UpdateFont()
    end, rightYOffset, MinimalUnitFramesDB.fontStyle or "NONE", {
        items = addon.Util.GetMediaList("fontStyles")
    })
    rightYOffset = rightYOffset - 50

    CreateOptionElement(rightColumn, "Slider", "Font Size", "Adjust the font size for unit frames", function(self, value)
        MinimalUnitFramesDB.fontSize = value
        addon.UpdateFont()
    end, rightYOffset, MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize, {
        min = 8,
        max = 24,
        step = 1
    })
    rightYOffset = rightYOffset - 50

    CreateOptionElement(rightColumn, "Button", "Reset Options", "Reset all options to default values", function()
        StaticPopup_Show("MINIMAL_UNIT_FRAMES_RESET_CONFIRM")
    end, rightYOffset)

    -- *********************
    -- Player Frame Options
    -- *********************
    local playerOptions = content.tabContents[2]
    local playerLeftColumn = CreateFrame("Frame", nil, playerOptions)
    playerLeftColumn:SetSize(playerOptions:GetWidth() / 2 - 10, playerOptions:GetHeight())
    playerLeftColumn:SetPoint("TOPLEFT", playerOptions, "TOPLEFT", 0, -10)

    local playerRightColumn = CreateFrame("Frame", nil, playerOptions)
    playerRightColumn:SetSize(playerOptions:GetWidth() / 2 - 10, playerOptions:GetHeight())
    playerRightColumn:SetPoint("TOPRIGHT", playerOptions, "TOPRIGHT", 0, -10)

    local playerLeftY = 0
    local playerRightY = 0

    -- Player Frame Options (Left Column)
    CreateOptionElement(playerLeftColumn, "Checkbox", "Use Player Class Colors", "Use class colors for player health bar", function(self)
        MinimalUnitFramesDB.useClassColorsPlayer = self:GetChecked()
        addon.UpdateFrame(addon.playerFrame, "player")
    end, playerLeftY, MinimalUnitFramesDB.useClassColorsPlayer)
    playerLeftY = playerLeftY - 30

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Frame", "Display Player frame", function(self)
        MinimalUnitFramesDB.showPlayerFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, playerLeftY, MinimalUnitFramesDB.showPlayerFrame)
    playerLeftY = playerLeftY - 30

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Power Bar", "Display power bar on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("player")
    end, playerLeftY, MinimalUnitFramesDB.showPlayerPowerBar)
    playerLeftY = playerLeftY - 30

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Frame Text", "Display text on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("player")
    end, playerLeftY, MinimalUnitFramesDB.showPlayerFrameText)
    playerLeftY = playerLeftY - 30

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Level Text", "Display level text on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("player")
    end, playerLeftY, MinimalUnitFramesDB.showPlayerLevelText)
    playerLeftY = playerLeftY - 30

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Buffs", "Display buffs on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerBuffs = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, playerLeftY, MinimalUnitFramesDB.showPlayerBuffs)
    playerLeftY = playerLeftY - 30

    CreateOptionElement(playerLeftColumn, "Checkbox", "Show Player Debuffs", "Display debuffs on Player frame", function(self)
        MinimalUnitFramesDB.showPlayerDebuffs = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, playerLeftY, MinimalUnitFramesDB.showPlayerDebuffs)
    playerLeftY = playerLeftY - 50

    CreateOptionElement(playerLeftColumn, "Slider", "Aura Button Size", "Adjust the size of the aura buttons", function(self, value)
        MinimalUnitFramesDB.playerAuraButtonSize = value
        addon.UpdateAllFrames()
    end, playerLeftY, MinimalUnitFramesDB.playerAuraButtonSize or addon.Config.auraConfig.buffs.size, {
        min = 10,
        max = 50,
        step = 1
    })
    playerLeftY = playerLeftY - 50

    CreateOptionElement(playerLeftColumn, "Slider", "Aura Buttons Per Row", "Adjust the number of aura buttons per row", function(self, value)
        MinimalUnitFramesDB.playerAuraButtonsPerRow = value
        addon.UpdateAllFrames()
    end, playerLeftY, MinimalUnitFramesDB.playerAuraButtonsPerRow or addon.Config.auraConfig.buffs.perRow, {
        min = 1,
        max = 20,
        step = 1
    })
    playerLeftY = playerLeftY - 50

    CreateOptionElement(playerLeftColumn, "ColorPicker", "Aura Swipe Color", "Select the swipe color for aura buttons", function(r, g, b, a)
        MinimalUnitFramesDB.playerAuraSwipeColor = {r, g, b, a}
        addon.UpdateAllFrames()
    end, playerLeftY, unpack(MinimalUnitFramesDB.playerAuraSwipeColor or {0, 0, 0, 0.8}))
    playerLeftY = playerLeftY - 50

    CreateOptionElement(playerLeftColumn, "Dropdown", "Player Frame Strata", "Set the strata of the Player frame", function(value)
        MinimalUnitFramesDB.playerStrata = value
        addon.UpdateFrameStrata(addon.playerFrame, "player")
    end, playerLeftY, MinimalUnitFramesDB.playerStrata, {
        items = addon.Util.GetMediaList("stratas")
    })
    playerLeftY = playerLeftY - 50

    CreateOptionElement(playerLeftColumn, "Dropdown", "Player Anchor Point", "Set the anchor point of the Player frame", function(value)
        MinimalUnitFramesDB.playerAnchor = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end, playerLeftY, MinimalUnitFramesDB.playerAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Player Frame Options (Right Column)
    CreateOptionElement(playerRightColumn, "Slider", "Player Width", "Adjust the width of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerWidth = value
        addon.UpdateFrameSize(addon.playerFrame, "player")
    end, playerRightY, MinimalUnitFramesDB.playerWidth, {
        min = 50,
        max = 400,
        step = 1
    })
    playerRightY = playerRightY - 50

    CreateOptionElement(playerRightColumn, "Slider", "Player Height", "Adjust the height of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerHeight = value
        addon.UpdateFrameSize(addon.playerFrame, "player")
    end, playerRightY, MinimalUnitFramesDB.playerHeight, {
        min = 20,
        max = 200,
        step = 1
    })
    playerRightY = playerRightY - 50

    CreateOptionElement(playerRightColumn, "Slider", "Player X Position", "Adjust the horizontal position of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerXPos = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end, playerRightY, MinimalUnitFramesDB.playerXPos, {
        min = -800,
        max = 800,
        step = 1
    })
    playerRightY = playerRightY - 50

    CreateOptionElement(playerRightColumn, "Slider", "Player Y Position", "Adjust the vertical position of the Player frame", function(self, value)
        MinimalUnitFramesDB.playerYPos = value
        addon.UpdateFramePosition(addon.playerFrame, "player")
    end, playerRightY, MinimalUnitFramesDB.playerYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    -- *********************
    -- Target Frame Options
    -- *********************
    local targetOptions = content.tabContents[3]
    local targetLeftColumn = CreateFrame("Frame", nil, targetOptions)
    targetLeftColumn:SetSize(targetOptions:GetWidth() / 2 - 10, targetOptions:GetHeight())
    targetLeftColumn:SetPoint("TOPLEFT", targetOptions, "TOPLEFT", 0, -10)

    local targetRightColumn = CreateFrame("Frame", nil, targetOptions)
    targetRightColumn:SetSize(targetOptions:GetWidth() / 2 - 10, targetOptions:GetHeight())
    targetRightColumn:SetPoint("TOPRIGHT", targetOptions, "TOPRIGHT", 0, -10)

    local targetLeftY = 0
    local targetRightY = 0

    -- Target Frame Options (Left Column)
    CreateOptionElement(targetLeftColumn, "Checkbox", "Use Target Class Colors", "Use class colors for target health bar", function(self)
        MinimalUnitFramesDB.useClassColorsTarget = self:GetChecked()
        addon.UpdateFrame(addon.targetFrame, "target")
    end, targetLeftY, MinimalUnitFramesDB.useClassColorsTarget)
    targetLeftY = targetLeftY - 30

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Frame", "Display Target frame", function(self)
        MinimalUnitFramesDB.showTargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, targetLeftY, MinimalUnitFramesDB.showTargetFrame)
    targetLeftY = targetLeftY - 30

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Power Bar", "Display power bar on Target frame", function(self)
        MinimalUnitFramesDB.showTargetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("target")
    end, targetLeftY, MinimalUnitFramesDB.showTargetPowerBar)
    targetLeftY = targetLeftY - 30

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Text", "Display text on Target frame", function(self)
        MinimalUnitFramesDB.showTargetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("target")
    end, targetLeftY, MinimalUnitFramesDB.showTargetFrameText)
    targetLeftY = targetLeftY - 30

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Level Text", "Display level text on Target frame", function(self)
        MinimalUnitFramesDB.showTargetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("target")
    end, targetLeftY, MinimalUnitFramesDB.showTargetLevelText)
    targetLeftY = targetLeftY - 30

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Buffs", "Display buffs on Target frame", function(self)
        MinimalUnitFramesDB.showTargetBuffs = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, targetLeftY, MinimalUnitFramesDB.showTargetBuffs)
    targetLeftY = targetLeftY - 30

    CreateOptionElement(targetLeftColumn, "Checkbox", "Show Target Debuffs", "Display debuffs on Target frame", function(self)
        MinimalUnitFramesDB.showPlayerDebuffs = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, targetLeftY, MinimalUnitFramesDB.showTargetDebuffs)
    targetLeftY = targetLeftY - 50

    CreateOptionElement(targetLeftColumn, "Slider", "Aura Button Size", "Adjust the size of the aura buttons", function(self, value)
        MinimalUnitFramesDB.targetAuraButtonSize = value
        addon.UpdateAllFrames()
    end, targetLeftY, MinimalUnitFramesDB.targetAuraButtonSize or addon.Config.auraConfig.buffs.size, {
        min = 10,
        max = 50,
        step = 1
    })
    targetLeftY = targetLeftY - 50

    CreateOptionElement(targetLeftColumn, "Slider", "Aura Buttons Per Row", "Adjust the number of aura buttons per row", function(self, value)
        MinimalUnitFramesDB.targetAuraButtonsPerRow = value
        addon.UpdateAllFrames()
    end, targetLeftY, MinimalUnitFramesDB.targetAuraButtonsPerRow or addon.Config.auraConfig.buffs.perRow, {
        min = 1,
        max = 20,
        step = 1
    })
    targetLeftY = targetLeftY - 50

    CreateOptionElement(targetLeftColumn, "Dropdown", "Target Frame Strata", "Set the strata of the Target frame", function(value)
        MinimalUnitFramesDB.targetStrata = value
        addon.UpdateFrameStrata(addon.targetFrame, "target")
    end, targetLeftY, MinimalUnitFramesDB.targetStrata, {
        items = addon.Util.GetMediaList("stratas")
    })
    targetLeftY = targetLeftY - 50

    CreateOptionElement(targetLeftColumn, "Dropdown", "Target Anchor Point", "Set the anchor point of the Target frame", function(value)
        MinimalUnitFramesDB.targetAnchor = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, targetLeftY, MinimalUnitFramesDB.targetAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Target Frame Options (Right Column)
    CreateOptionElement(targetRightColumn, "Slider", "Target Width", "Adjust the width of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetWidth = value
        addon.UpdateFrameSize(addon.targetFrame, "target")
    end, targetRightY, MinimalUnitFramesDB.targetWidth, {
        min = 50,
        max = 400,
        step = 1
    })
    targetRightY = targetRightY - 50

    CreateOptionElement(targetRightColumn, "Slider", "Target Height", "Adjust the height of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetHeight = value
        addon.UpdateFrameSize(addon.targetFrame, "target")
    end, targetRightY, MinimalUnitFramesDB.targetHeight, {
        min = 20,
        max = 200,
        step = 1
    })
    targetRightY = targetRightY - 50

    CreateOptionElement(targetRightColumn, "Slider", "Target X Position", "Adjust the horizontal position of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetXPos = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, targetRightY, MinimalUnitFramesDB.targetXPos, {
        min = -800,
        max = 800,
        step = 1
    })
    targetRightY = targetRightY - 50

    CreateOptionElement(targetRightColumn, "Slider", "Target Y Position", "Adjust the vertical position of the Target frame", function(self, value)
        MinimalUnitFramesDB.targetYPos = value
        addon.UpdateFramePosition(addon.targetFrame, "target")
    end, targetRightY, MinimalUnitFramesDB.targetYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    -- *********************
    -- Target of Target Frame Options
    -- *********************
    local totOptions = content.tabContents[4]
    local totLeftColumn = CreateFrame("Frame", nil, totOptions)
    totLeftColumn:SetSize(totOptions:GetWidth() / 2 - 10, totOptions:GetHeight())
    totLeftColumn:SetPoint("TOPLEFT", totOptions, "TOPLEFT", 0, -10)

    local totRightColumn = CreateFrame("Frame", nil, totOptions)
    totRightColumn:SetSize(totOptions:GetWidth() / 2 - 10, totOptions:GetHeight())
    totRightColumn:SetPoint("TOPRIGHT", totOptions, "TOPRIGHT", 0, -10)

    local totLeftY = 0
    local totRightY = 0

    -- Target of Target Frame Options (Left Column)
    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Frame", "Display Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, totLeftY, MinimalUnitFramesDB.showTargetoftargetFrame)
    totLeftY = totLeftY - 30

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Power Bar", "Display power bar on Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("targetoftarget")
    end, totLeftY, MinimalUnitFramesDB.showTargetoftargetPowerBar)
    totLeftY = totLeftY - 30

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Text", "Display text on Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("targetoftarget")
    end, totLeftY, MinimalUnitFramesDB.showTargetoftargetFrameText)
    totLeftY = totLeftY - 30

    CreateOptionElement(totLeftColumn, "Checkbox", "Show Target of Target Level Text", "Display level text on Target of Target frame", function(self)
        MinimalUnitFramesDB.showTargetoftargetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("targetoftarget")
    end, totLeftY, MinimalUnitFramesDB.showTargetoftargetLevelText)
    totLeftY = totLeftY - 50

    CreateOptionElement(totLeftColumn, "Dropdown", "Target of Target Frame Strata", "Set the strata of the Target of Target frame", function(value)
        MinimalUnitFramesDB.targetoftargetStrata = value
        addon.UpdateFrameStrata(addon.targetoftargetFrame, "targetoftarget")
    end, totLeftY, MinimalUnitFramesDB.targetoftargetStrata, {
        items = addon.Util.GetMediaList("stratas")
    })
    totLeftY = totLeftY - 50

    CreateOptionElement(totLeftColumn, "Dropdown", "Target of Target Anchor Point", "Set the anchor point of the Target of Target frame", function(value)
        MinimalUnitFramesDB.targetoftargetAnchor = value
        addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    end, totLeftY, MinimalUnitFramesDB.targetoftargetAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Target of Target Frame Options (Right Column)
    CreateOptionElement(totRightColumn, "Slider", "Target of Target Width", "Adjust the width of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetWidth = value
        addon.UpdateFrameSize(addon.targetoftargetFrame, "targetoftarget")
    end, totRightY, MinimalUnitFramesDB.targetoftargetWidth, {
        min = 50,
        max = 400,
        step = 1
    })
    totRightY = totRightY - 50

    CreateOptionElement(totRightColumn, "Slider", "Target of Target Height", "Adjust the height of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetHeight = value
        addon.UpdateFrameSize(addon.targetoftargetFrame, "targetoftarget")
    end, totRightY, MinimalUnitFramesDB.targetoftargetHeight, {
        min = 20,
        max = 200,
        step = 1
    })
    totRightY = totRightY - 50

    CreateOptionElement(totRightColumn, "Slider", "Target of Target X Position", "Adjust the horizontal position of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetXPos = value
        addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    end, totRightY, MinimalUnitFramesDB.targetoftargetXPos, {
        min = -800,
        max = 800,
        step = 1
    })
    totRightY = totRightY - 50

    CreateOptionElement(totRightColumn, "Slider", "Target of Target Y Position", "Adjust the vertical position of the Target of Target frame", function(self, value)
        MinimalUnitFramesDB.targetoftargetYPos = value
        addon.UpdateFramePosition(addon.targetoftargetFrame, "targetoftarget")
    end, totRightY, MinimalUnitFramesDB.targetoftargetYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    -- *********************
    -- Pet Frame Options
    -- *********************
    local petOptions = content.tabContents[5]
    local petLeftColumn = CreateFrame("Frame", nil, petOptions)
    petLeftColumn:SetSize(petOptions:GetWidth() / 2 - 10, petOptions:GetHeight())
    petLeftColumn:SetPoint("TOPLEFT", petOptions, "TOPLEFT", 0, -10)

    local petRightColumn = CreateFrame("Frame", nil, petOptions)
    petRightColumn:SetSize(petOptions:GetWidth() / 2 - 10, petOptions:GetHeight())
    petRightColumn:SetPoint("TOPRIGHT", petOptions, "TOPRIGHT", 0, -10)

    local petLeftY = 0
    local petRightY = 0

    -- Pet Frame Options (Left Column)
    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Frame", "Display Pet frame", function(self)
        MinimalUnitFramesDB.showPetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, petLeftY, MinimalUnitFramesDB.showPetFrame)
    petLeftY = petLeftY - 30

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Power Bar", "Display power bar on Pet frame", function(self)
        MinimalUnitFramesDB.showPetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("pet")
    end, petLeftY, MinimalUnitFramesDB.showPetPowerBar)
    petLeftY = petLeftY - 30

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Frame Text", "Display text on Pet frame", function(self)
        MinimalUnitFramesDB.showPetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("pet")
    end, petLeftY, MinimalUnitFramesDB.showPetFrameText)
    petLeftY = petLeftY - 30

    CreateOptionElement(petLeftColumn, "Checkbox", "Show Pet Level Text", "Display level text on Pet frame", function(self)
        MinimalUnitFramesDB.showPetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("pet")
    end, petLeftY, MinimalUnitFramesDB.showPetLevelText)
    petLeftY = petLeftY - 50

    CreateOptionElement(petLeftColumn, "Dropdown", "Pet Frame Strata", "Set the strata of the Pet frame", function(value)
        MinimalUnitFramesDB.petStrata = value
        addon.UpdateFrameStrata(addon.petFrame, "pet")
    end, petLeftY, MinimalUnitFramesDB.petStrata, {
        items = addon.Util.GetMediaList("stratas")
    })
    petLeftY = petLeftY - 50

    CreateOptionElement(petLeftColumn, "Dropdown", "Pet Anchor Point", "Set the anchor point of the Pet frame", function(value)
        MinimalUnitFramesDB.petAnchor = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end, petLeftY, MinimalUnitFramesDB.petAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Pet Frame Options (Right Column)
    CreateOptionElement(petRightColumn, "Slider", "Pet Width", "Adjust the width of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petWidth = value
        addon.UpdateFrameSize(addon.petFrame, "pet")
    end, petRightY, MinimalUnitFramesDB.petWidth, {
        min = 50,
        max = 400,
        step = 1
    })
    petRightY = petRightY - 50

    CreateOptionElement(petRightColumn, "Slider", "Pet Height", "Adjust the height of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petHeight = value
        addon.UpdateFrameSize(addon.petFrame, "pet")
    end, petRightY, MinimalUnitFramesDB.petHeight, {
        min = 20,
        max = 200,
        step = 1
    })
    petRightY = petRightY - 50

    CreateOptionElement(petRightColumn, "Slider", "Pet X Position", "Adjust the horizontal position of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petXPos = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end, petRightY, MinimalUnitFramesDB.petXPos, {
        min = -800,
        max = 800,
        step = 1
    })
    petRightY = petRightY - 50

    CreateOptionElement(petRightColumn, "Slider", "Pet Y Position", "Adjust the vertical position of the Pet frame", function(self, value)
        MinimalUnitFramesDB.petYPos = value
        addon.UpdateFramePosition(addon.petFrame, "pet")
    end, petRightY, MinimalUnitFramesDB.petYPos, {
        min = -600,
        max = 600,
        step = 1
    })

    -- *********************
    -- Pet Target Frame Options
    -- *********************
    local petTargetOptions = content.tabContents[6]
    local petTargetLeftColumn = CreateFrame("Frame", nil, petTargetOptions)
    petTargetLeftColumn:SetSize(petTargetOptions:GetWidth() / 2 - 10, petTargetOptions:GetHeight())
    petTargetLeftColumn:SetPoint("TOPLEFT", petTargetOptions, "TOPLEFT", 0, -10)

    local petTargetRightColumn = CreateFrame("Frame", nil, petTargetOptions)
    petTargetRightColumn:SetSize(petTargetOptions:GetWidth() / 2 - 10, petTargetOptions:GetHeight())
    petTargetRightColumn:SetPoint("TOPRIGHT", petTargetOptions, "TOPRIGHT", 0, -10)

    local petTargetLeftY = 0
    local petTargetRightY = 0

    -- Pet Target Frame Options (Left Column)
    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Frame", "Display Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetFrame = self:GetChecked()
        addon.UpdateFramesVisibility()
    end, petTargetLeftY, MinimalUnitFramesDB.showPetTargetFrame)
    petTargetLeftY = petTargetLeftY - 30

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Power Bar", "Display power bar on Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetPowerBar = self:GetChecked()
        addon.UpdateFramePowerBarVisibility("pettarget")
    end, petTargetLeftY, MinimalUnitFramesDB.showPetTargetPowerBar)
    petTargetLeftY = petTargetLeftY - 30

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Frame Text", "Display text on Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetFrameText = self:GetChecked()
        addon.UpdateFrameTextVisibility("pettarget")
    end, petTargetLeftY, MinimalUnitFramesDB.showPetTargetFrameText)
    petTargetLeftY = petTargetLeftY - 30

    CreateOptionElement(petTargetLeftColumn, "Checkbox", "Show Pet Target Level Text", "Display level text on Pet Target frame", function(self)
        MinimalUnitFramesDB.showPetTargetLevelText = self:GetChecked()
        addon.UpdateLevelTextVisibility("pettarget")
    end, petTargetLeftY, MinimalUnitFramesDB.showPetTargetLevelText)
    petTargetLeftY = petTargetLeftY - 50

    CreateOptionElement(petTargetLeftColumn, "Dropdown", "Pet Target Frame Strata", "Set the strata of the Pet Target frame", function(value)
        MinimalUnitFramesDB.petTargetStrata = value
        addon.UpdateFrameStrata(addon.petTargetFrame, "pettarget")
    end, petTargetLeftY, MinimalUnitFramesDB.petTargetStrata, {
        items = addon.Util.GetMediaList("stratas")
    })
    petTargetLeftY = petTargetLeftY - 50

    CreateOptionElement(petTargetLeftColumn, "Dropdown", "Pet Target Anchor Point", "Set the anchor point of the Pet Target frame", function(value)
        MinimalUnitFramesDB.petTargetAnchor = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end, petTargetLeftY, MinimalUnitFramesDB.petTargetAnchor, {
        items = addon.Util.GetMediaList("anchorPoints")
    })

    -- Pet Target Frame Options (Right Column)
    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target Width", "Adjust the width of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetWidth = value
        addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")
    end, petTargetRightY, MinimalUnitFramesDB.petTargetWidth, {
        min = 50,
        max = 400,
        step = 1
    })
    petTargetRightY = petTargetRightY - 50

    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target Height", "Adjust the height of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetHeight = value
        addon.UpdateFrameSize(addon.petTargetFrame, "pettarget")
    end, petTargetRightY, MinimalUnitFramesDB.petTargetHeight, {
        min = 20,
        max = 200,
        step = 1
    })
    petTargetRightY = petTargetRightY - 50

    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target X Position", "Adjust the horizontal position of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetXPos = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end, petTargetRightY, MinimalUnitFramesDB.petTargetXPos, {
        min = -800,
        max = 800,
        step = 1
    })
    petTargetRightY = petTargetRightY - 50

    CreateOptionElement(petTargetRightColumn, "Slider", "Pet Target Y Position", "Adjust the vertical position of the Pet Target frame", function(self, value)
        MinimalUnitFramesDB.petTargetYPos = value
        addon.UpdateFramePosition(addon.petTargetFrame, "pettarget")
    end, petTargetRightY, MinimalUnitFramesDB.petTargetYPos, {
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
