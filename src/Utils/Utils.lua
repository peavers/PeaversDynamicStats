local addonName, PDS = ...

-- Initialize Utils namespace
PDS.Utils = {}
local Utils = PDS.Utils

-- Returns the current value of the specified secondary stat
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
