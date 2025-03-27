local addonName, PDS = ...

-- Create Utils namespace
PDS.Utils = {}
local Utils = PDS.Utils

-- Get stat value
function Utils:GetStatValue(statType)
    local value = 0

    if statType == "HASTE" then
        value = GetHaste()
    elseif statType == "CRIT" then
        value = GetCritChance()
    elseif statType == "MASTERY" then
        value = GetMasteryEffect()
    elseif statType == "VERSATILITY" then
        value = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    end

    return value
end
