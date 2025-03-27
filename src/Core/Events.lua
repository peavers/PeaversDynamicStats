local addonName, ST = ...
local Core = ST.Core

-- Frame to handle events
local frame = CreateFrame("Frame")

-- Initialize local variables for events
local updateTimer = 0
local inCombat = false

-- Event handling
function Core:OnEvent(event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        ST.Config:Load()
        self:Initialize()
        frame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGOUT" then
        ST.Config:Save()
    elseif event == "UNIT_STATS" or event == "UNIT_AURA" or event == "PLAYER_EQUIPMENT_CHANGED" then
        self:UpdateAllBars()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    end
end

-- OnUpdate handler for periodic updates
function Core:OnUpdate(elapsed)
    updateTimer = updateTimer + elapsed

    -- Use a much longer interval when not in combat
    local interval = inCombat and ST.Config.combatUpdateInterval or 2.0 -- 2 seconds when out of combat

    if updateTimer >= interval then
        -- Only update when necessary
        self:UpdateAllBars()
        updateTimer = 0
    end
end

-- Register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("UNIT_STATS")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Set event and update handlers
frame:SetScript("OnEvent", function(self, event, ...) Core:OnEvent(event, ...) end)
frame:SetScript("OnUpdate", function(self, elapsed) Core:OnUpdate(elapsed) end)