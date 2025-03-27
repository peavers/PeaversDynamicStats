--[[
    Utils.lua - Utility functions for StatTracker
]]

local addonName, ST = ...

-- Create Utils namespace
ST.Utils = {}
local Utils = ST.Utils

-- Get primary stat for a class
function Utils:GetPrimaryStatForClass(class)
    local strengthClasses = { "WARRIOR", "PALADIN", "DEATHKNIGHT" }
    local agilityClasses = { "HUNTER", "ROGUE", "MONK", "DEMONHUNTER", "EVOKER" }
    local intellectClasses = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }

    for _, c in ipairs(strengthClasses) do
        if class == c then return "STRENGTH" end
    end

    for _, c in ipairs(agilityClasses) do
        if class == c then return "AGILITY" end
    end

    for _, c in ipairs(intellectClasses) do
        if class == c then return "INTELLECT" end
    end

    return "STAMINA" -- Default if somehow no match
end

-- Get stat value
function Utils:GetStatValue(statType, primaryStat)
    local value = 0
    local maxValue = 100

    if statType == "STRENGTH" then
        value = UnitStat("player", 1)
        maxValue = self:EstimateMaxStat(value, primaryStat == "STRENGTH")

    elseif statType == "AGILITY" then
        value = UnitStat("player", 2)
        maxValue = self:EstimateMaxStat(value, primaryStat == "AGILITY")

    elseif statType == "STAMINA" then
        value = UnitStat("player", 3)
        maxValue = self:EstimateMaxStat(value, false) -- Stamina is never a primary stat

    elseif statType == "INTELLECT" then
        value = UnitStat("player", 4)
        maxValue = self:EstimateMaxStat(value, primaryStat == "INTELLECT")

    elseif statType == "HASTE" then
        value = GetHaste()
        maxValue = 30 -- Reasonable cap for percentage stats

    elseif statType == "CRIT" then
        value = GetCritChance()
        maxValue = 30

    elseif statType == "MASTERY" then
        value = GetMasteryEffect()
        maxValue = 30

    elseif statType == "VERSATILITY" then
        value = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
        maxValue = 20 -- Versatility tends to be lower than other stats
    end

    return value, maxValue
end

-- Estimate a reasonable max stat value based on current value
function Utils:EstimateMaxStat(currentValue, isPrimary)
    -- For primary stats, estimate what a well-geared player might have
    -- For secondary stats, use a lower value
    local buffer = isPrimary and 1.5 or 1.2
    return math.max(100, math.floor(currentValue * buffer))
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