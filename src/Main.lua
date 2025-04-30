local addonName, PDS = ...

-- Access the PeaversCommons library
local PeaversCommons = _G.PeaversCommons

-- Initialize addon namespace and modules
PDS = PDS or {}

-- Module namespaces
PDS.Core = {}
PDS.UI = {}
PDS.Utils = {}
PDS.Config = {}
PDS.Stats = {}

-- Version information
local function getAddOnMetadata(name, key)
    return C_AddOns.GetAddOnMetadata(name, key)
end

PDS.version = getAddOnMetadata(addonName, "Version") or "1.0.5"
PDS.addonName = addonName
PDS.name = addonName

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "pds", {
    default = function()
        if PDS.Core.frame:IsShown() then
            PDS.Core.frame:Hide()
        else
            PDS.Core.frame:Show()
        end
    end,
})

-- Initialize addon using the PeaversCommons Events module
PeaversCommons.Events:Init(addonName, function()
    -- Initialize configuration
    PDS.Config:Initialize()

    -- Initialize configuration UI
    if PDS.Config.UI and PDS.Config.UI.InitializeOptions then
        PDS.Config.UI:InitializeOptions()
    end

    -- Initialize support UI
    if PDS.SupportUI and PDS.SupportUI.Initialize then
        PDS.SupportUI:Initialize()
    end

    -- Initialize core components
    PDS.Core:Initialize()

    -- Register event handlers
    PeaversCommons.Events:RegisterEvent("UNIT_STATS", function()
        PDS.BarManager:UpdateAllBars()
    end)

    PeaversCommons.Events:RegisterEvent("UNIT_AURA", function()
        PDS.BarManager:UpdateAllBars()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function()
        PDS.BarManager:UpdateAllBars()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function()
        PDS.BarManager:UpdateAllBars()
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        PDS.Core.inCombat = true
        -- Always show the frame when entering combat if hideOutOfCombat is enabled
        if PDS.Config.hideOutOfCombat then
            PDS.Core.frame:Show()
        end
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        PDS.Core.inCombat = false
        -- Hide the frame when leaving combat if hideOutOfCombat is enabled
        if PDS.Config.hideOutOfCombat then
            PDS.Core.frame:Hide()
        end
    end)

    PeaversCommons.Events:RegisterEvent("PLAYER_LOGOUT", function()
        PDS.Config:Save()
    end)

    -- Set up OnUpdate handler for stats
    PeaversCommons.Events:RegisterOnUpdate(0.5, function(elapsed)
        local interval = PDS.Core.inCombat and PDS.Config.combatUpdateInterval or 2.0
        PDS.BarManager:UpdateAllBars()

        -- Record stat history if the module is available
        if PDS.StatHistory then
            PDS.StatHistory:RecordStats()
        end
    end, "PDS_Update")
end)
