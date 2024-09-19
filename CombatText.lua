---@class CombatText
local addonName, addon = ...
local CombatText = {}
addon.CombatText = CombatText

--- Updates the visibility of the combat text
function CombatText:UpdateVisibility()
    if addon.playerFrame and addon.playerFrame.feedbackFrame then
        if MinimalUnitFramesDB.showCombatFeedback then
            addon.playerFrame.feedbackFrame:Show()
        else
            addon.playerFrame.feedbackFrame:Hide()
        end
    end
end

--- Creates the combat text
---@param frame any UnitFrame
function CombatText:CreateCombatFeedback(frame)
    local feedbackText = frame:CreateFontString(nil, "OVERLAY")
    feedbackText:SetPoint("CENTER", frame, "CENTER")
    local fontSize = MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize
    feedbackText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), fontSize * 2, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
    feedbackText:SetShadowOffset(1, -1)
    frame.feedbackText = feedbackText

    local feedbackFrame = CreateFrame("Frame", nil, frame)
    feedbackFrame:SetAllPoints(frame)
    feedbackFrame:SetFrameLevel(frame:GetFrameLevel() + 100)
    feedbackText:SetParent(feedbackFrame)
    frame.feedbackFrame = feedbackFrame -- Attach feedbackFrame to the main frame

    local feedbackStartTime = 0
    local feedbackDuration = 0

    feedbackFrame:SetScript("OnUpdate", function(self, elapsed)
        if feedbackStartTime + feedbackDuration > GetTime() then
            local alpha = 1.0 - (GetTime() - feedbackStartTime) / feedbackDuration
            feedbackText:SetAlpha(alpha)
        else
            feedbackText:SetText(nil)
        end
    end)

    --- Handles the combat event
    ---@param self any UnitFrame
    ---@param event string
    ---@param flags string
    ---@param amount number
    ---@param type string
    frame.CombatFeedback_OnCombatEvent = function(self, event, flags, amount, type)
        local text, color
        if type == "ENTERING_COMBAT" then
            text = "COMBAT"
            color = addon.Config.combatFeedbackColors.STANDARD
        elseif type == "LEAVING_COMBAT" then
            text = "LEAVING COMBAT"
            color = addon.Config.combatFeedbackColors.STANDARD
        else
            if not amount or amount == 0 then
                return
            end
            text = tostring(amount)
            color = addon.Config.combatFeedbackColors[type] or addon.Config.combatFeedbackColors.STANDARD
        end

        local fontHeight = (MinimalUnitFramesDB.fontSize or addon.Config.defaultConfig.fontSize) * 2
        feedbackText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), fontHeight, MinimalUnitFramesDB.fontStyle or addon.Config.defaultConfig.fontStyle)
        feedbackStartTime = GetTime()
        feedbackDuration = 2.0

        feedbackText:SetText(text)
        feedbackText:SetTextColor(color.r, color.g, color.b)
        feedbackText:SetAlpha(1)
    end
end

--- Handles the combat event
---@param frame any UnitFrame
---@param event string
---@param flags string
---@param amount number
---@param type string
function CombatText:OnEvent(frame, event, ...)
    if event == "UNIT_COMBAT" then
        local unit, action, descriptor, damage, damageType = ...
        if unit == frame.unit then
            frame.CombatFeedback_OnCombatEvent(frame, event, nil, damage, action)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        frame.CombatFeedback_OnCombatEvent(frame, event, nil, nil, "ENTERING_COMBAT")
    elseif event == "PLAYER_REGEN_ENABLED" then
        frame.CombatFeedback_OnCombatEvent(frame, event, nil, nil, "LEAVING_COMBAT")
    end
end
