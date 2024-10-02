---@class CombatText
local addonName, addon = ...
local CombatText = {}
addon.CombatText = CombatText

--- Updates the visibility of the combat text
function CombatText:UpdateVisibility()
    if addon.playerFrame and addon.playerFrame.feedbackFrame then
        if MinimalUnitFramesDB.showCombatFeedback and UnitAffectingCombat("player") then
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
    feedbackText:SetPoint(addon.Config.combatFeedbackConfig.anchorPoint, frame, addon.Config.combatFeedbackConfig.anchorPoint, addon.Config.combatFeedbackConfig.xOffset, addon.Config.combatFeedbackConfig.yOffset)
    feedbackText:SetShadowOffset(1, -1)
    feedbackText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.combatFeedbackFontSize or addon.Config.combatFeedbackConfig.fontSize, addon.Config.combatFeedbackConfig.fontOutline)

    frame.feedbackText = feedbackText

    self:UpdateCombatFeedbackFontSize()

    local feedbackFrame = CreateFrame("Frame", nil, frame)
    feedbackFrame:SetAllPoints(frame)
    feedbackFrame:SetFrameLevel(frame:GetFrameLevel() + 100)
    feedbackText:SetParent(feedbackFrame)
    frame.feedbackFrame = feedbackFrame

    local feedbackStartTime = 0
    local feedbackDuration = 0

    --- OnUpdate function to fade out the feedback text
    ---@param self any Frame
    ---@param elapsed number
    feedbackFrame:SetScript("OnUpdate", function(self, elapsed)
        if feedbackStartTime + feedbackDuration > GetTime() then
            local alpha = math.max(0, 1.0 - (GetTime() - feedbackStartTime) / addon.Config.combatFeedbackConfig.fadeOutDuration)
            feedbackText:SetAlpha(alpha)
        else
            feedbackText:SetText(nil)
            feedbackText:SetAlpha(0)
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
            color = addon.Config.combatFeedbackConfig.colors.ENTERING_COMBAT
        elseif type == "LEAVING_COMBAT" then
            text = "LEAVING COMBAT"
            color = addon.Config.combatFeedbackConfig.colors.LEAVING_COMBAT
        else
            if not amount or amount == 0 then
                return
            end
            text = tostring(amount)
            color = addon.Config.combatFeedbackConfig.colors[type] or addon.Config.combatFeedbackConfig.colors.STANDARD
        end

        if not color then
            color = addon.Config.combatFeedbackConfig.colors.STANDARD or {
                r = 1,
                g = 1,
                b = 1
            }
        end

        feedbackStartTime = GetTime()
        feedbackDuration = addon.Config.combatFeedbackConfig.duration or 2.0

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

function CombatText:UpdateCombatFeedbackFontSize()
    if addon.playerFrame and addon.playerFrame.feedbackText then
        addon.playerFrame.feedbackText:SetFont(addon.Util.FetchMedia("fonts", MinimalUnitFramesDB.font or addon.Config.defaultConfig.font), MinimalUnitFramesDB.combatFeedbackFontSize or addon.Config.combatFeedbackConfig.fontSize, addon.Config.combatFeedbackConfig.fontOutline)
    end
end

return CombatText
