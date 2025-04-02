local addonName, PDS = ...
local Core = PDS.Core

local frame = CreateFrame("Frame")
local updateTimer = 0
local inCombat = false

-- Handles WoW events to update the addon state
function Core:OnEvent(event, ...)
	if event == "ADDON_LOADED" and ... == addonName then
		PDS.Config:Load()
		self:Initialize()
		frame:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGOUT" then
		PDS.Config:Save()
	elseif event == "UNIT_STATS" or event == "UNIT_AURA" or event == "PLAYER_EQUIPMENT_CHANGED" then
		self:UpdateAllBars()
	elseif event == "PLAYER_REGEN_DISABLED" then
		inCombat = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false
	end
end

-- Handles periodic updates with different intervals for combat/non-combat
function Core:OnUpdate(elapsed)
	updateTimer = updateTimer + elapsed

	local interval = inCombat and PDS.Config.combatUpdateInterval or 2.0 -- 2 seconds when out of combat

	if updateTimer >= interval then
		self:UpdateAllBars()
		updateTimer = 0
	end
end

-- Register all required events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("UNIT_STATS")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Set up event and update handlers
frame:SetScript("OnEvent", function(self, event, ...)
	Core:OnEvent(event, ...)
end)
frame:SetScript("OnUpdate", function(self, elapsed)
	Core:OnUpdate(elapsed)
end)
