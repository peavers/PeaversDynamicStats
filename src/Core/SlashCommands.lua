local _, PDS = ...
local Core = PDS.Core

-- Slash command to toggle visibility
SLASH_PEAVERSDYNAMICSTATS1 = "/pds"
SlashCmdList["PEAVERSDYNAMICSTATS"] = function(msg)
	if msg == "config" or msg == "options" then
		if Settings and Settings.OpenToCategory then
			Settings.OpenToCategory("PeaversDynamicStats")
		else
			InterfaceOptionsFrame_OpenToCategory("PeaversDynamicStats")
			InterfaceOptionsFrame_OpenToCategory("PeaversDynamicStats")
		end
	else
		if Core.frame:IsShown() then
			Core.frame:Hide()
		else
			Core.frame:Show()
		end
	end
end
