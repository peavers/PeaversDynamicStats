local _, ST = ...
local Core = ST.Core

-- Slash command to toggle visibility
SLASH_PEAVERSDYNAMICSTATS1 = "/pds"
SLASH_PEAVERSDYNAMICSTATS2 = "/dynstats"
SLASH_PEAVERSDYNAMICSTATS3 = "/st"
SlashCmdList["PEAVERSDYNAMICSTATS"] = function(msg)
    if msg == "config" or msg == "options" then
        ST.Config:OpenOptions()
    else
        if Core.frame:IsShown() then
            Core.frame:Hide()
        else
            Core.frame:Show()
        end
    end
end