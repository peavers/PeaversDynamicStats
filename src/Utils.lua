--[[
    Utils.lua - Utility functions for StatTracker
]]

local addonName, ST = ...

-- Create Utils namespace
ST.Utils = {}
local Utils = ST.Utils

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

-- Format large numbers
function Utils:FormatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(math.floor(number))
    end
end

-- Get player class color
function Utils:GetClassColor(class)
    local colors = {
        WARRIOR     = {0.78, 0.61, 0.43},
        PALADIN     = {0.96, 0.55, 0.73},
        HUNTER      = {0.67, 0.83, 0.45},
        ROGUE       = {1.00, 0.96, 0.41},
        PRIEST      = {1.00, 1.00, 1.00},
        DEATHKNIGHT = {0.77, 0.12, 0.23},
        SHAMAN      = {0.00, 0.44, 0.87},
        MAGE        = {0.25, 0.78, 0.92},
        WARLOCK     = {0.53, 0.53, 0.93},
        MONK        = {0.00, 1.00, 0.59},
        DRUID       = {1.00, 0.49, 0.04},
        DEMONHUNTER = {0.64, 0.19, 0.79},
        EVOKER      = {0.20, 0.58, 0.50}
    }

    if colors[class] then
        return unpack(colors[class])
    else
        return 0.8, 0.8, 0.8 -- Default to white/grey
    end
end