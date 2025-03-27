--[[
    StatTracker.lua - Main addon file
]]

local addonName, ST = ...
local Core = {}
ST.Core = Core

-- Initialize local variables
local updateTimer = 0
local inCombat = false
Core.bars = {}

-- Frame to handle events
local frame = CreateFrame("Frame")

-- Creates the titlebar
function Core:CreateTitleBar()
    -- Add title bar
    local titleBar = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    titleBar:SetHeight(20)
    titleBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })

    -- Use the same background color as the main frame
    titleBar:SetBackdropColor(ST.Config.bgColor.r, ST.Config.bgColor.g, ST.Config.bgColor.b, ST.Config.bgAlpha)
    titleBar:SetBackdropBorderColor(0, 0, 0, 1)

    -- Store reference to title bar for later updates
    self.titleBar = titleBar

    -- Add title text
    local title = titleBar:CreateFontString(nil, "OVERLAY")
    title:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    title:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    title:SetText("Secondary Stats")

    -- Set the title text to white
    title:SetTextColor(1, 1, 1)

    -- Add vertical line separator after title text
    local verticalLine = titleBar:CreateTexture(nil, "ARTWORK")
    verticalLine:SetSize(1, 16)
    verticalLine:SetPoint("LEFT", title, "RIGHT", 5, 0)
    verticalLine:SetColorTexture(0.3, 0.3, 0.3, 0.5)

    -- Add a subtitle or version
    local subtitle = titleBar:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    subtitle:SetPoint("LEFT", verticalLine, "RIGHT", 5, 0)
    subtitle:SetText("v1.0")
    subtitle:SetTextColor(0.8, 0.8, 0.8)

    -- Make frame movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", self.frame.StartMoving)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        -- Save position
        local point, _, _, x, y = frame:GetPoint()
        ST.Config.framePoint = point
        ST.Config.frameX = x
        ST.Config.frameY = y
        ST.Config:Save()
    end)

    return titleBar
end

-- Initialize the addon
function Core:Initialize()
    self.previousValues = {}

    -- Load config first
    ST.Config:Load()

    -- Initialize the options panel
    ST.Config:InitializeOptions()

    -- Create main frame
    self.frame = CreateFrame("Frame", "PeaversDynamicStatsFrame", UIParent, "BackdropTemplate")
    self.frame:SetSize(ST.Config.frameWidth, ST.Config.frameHeight)
    self.frame:SetPoint(ST.Config.framePoint, ST.Config.frameX, ST.Config.frameY)
    self.frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })
    self.frame:SetBackdropColor(ST.Config.bgColor.r, ST.Config.bgColor.g, ST.Config.bgColor.b, ST.Config.bgAlpha)
    self.frame:SetBackdropBorderColor(0, 0, 0, 1)

    -- Create title bar
    local titleBar = self:CreateTitleBar()

    -- Create content frame
    self.contentFrame = CreateFrame("Frame", nil, self.frame)
    self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -20)
    self.contentFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)

    -- Apply title bar visibility AFTER content frame is created
    self:UpdateTitleBarVisibility()

    -- Create the stat bars
    self:CreateBars()

    -- Show if needed
    if ST.Config.showOnLogin then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

-- Create or recreate stat bars
function Core:CreateBars()
    -- Clear existing bars
    for _, bar in ipairs(self.bars) do
        bar.frame:Hide()
    end
    self.bars = {}

    -- Stats to display in order
    local statOrder = {
        "HASTE", "CRIT", "MASTERY", "VERSATILITY"
    }

    -- Stat display names
    local statNames = {
        HASTE = "Haste",
        CRIT = "Critical Strike",
        MASTERY = "Mastery",
        VERSATILITY = "Versatility"
    }

    -- Create bars for enabled stats
    local yOffset = 0
    for _, statType in ipairs(statOrder) do
        if ST.Config.showStats[statType] then
            local bar = ST.StatBar:New(self.contentFrame, statNames[statType], statType)
            bar:SetPosition(0, yOffset)

            -- Update stat values
            local value = ST.Utils:GetStatValue(statType)
            bar:Update(value)

            -- Add to bar collection
            table.insert(self.bars, bar)

            -- Adjust offset for next bar using the configured height and spacing
            yOffset = yOffset - (ST.Config.barHeight + ST.Config.barSpacing)
        end
    end

    -- Adjust frame height based on number of bars
    local contentHeight = math.abs(yOffset)
    if contentHeight == 0 then
        -- Default height if no bars are shown
        self.frame:SetHeight(20) -- Just title bar
    else
        self.frame:SetHeight(contentHeight + 20) -- Add title bar height
    end


    -- After all bars are created, adjust frame height
    self:AdjustFrameHeight()

    -- Set frame width based on configuration
    self.frame:SetWidth(ST.Config.frameWidth)
end

-- Update all bars with latest stat values
function Core:UpdateAllBars()
    -- Initialize previousValues table if it doesn't exist
    if not self.previousValues then
        self.previousValues = {}
    end

    -- Update each bar only if value has changed
    for _, bar in ipairs(self.bars) do
        local value = ST.Utils:GetStatValue(bar.statType)

        -- Create key for this stat if it doesn't exist
        local statKey = bar.statType
        if not self.previousValues[statKey] then
            self.previousValues[statKey] = 0
        end

        -- Only update the bar if the value has changed
        if value ~= self.previousValues[statKey] then
            bar:Update(value)
            self.previousValues[statKey] = value
        end
    end
end

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

function Core:UpdateTitleBarVisibility()
    if self.titleBar then
        if ST.Config.showTitleBar then
            self.titleBar:Show()
            -- Adjust the content frame to start below title bar
            self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -20)
        else
            self.titleBar:Hide()
            -- Adjust the content frame to use full frame space
            self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
        end

        -- Recalculate frame height
        self:AdjustFrameHeight()
    end
end

-- Add this function to recalculate frame height
function Core:AdjustFrameHeight()
    -- Calculate height based on number of bars
    local barCount = #self.bars
    local contentHeight = barCount * (ST.Config.barHeight + ST.Config.barSpacing) - ST.Config.barSpacing

    if contentHeight == 0 then
        -- No bars shown
        if ST.Config.showTitleBar then
            self.frame:SetHeight(20) -- Just title bar
        else
            self.frame:SetHeight(10) -- Minimal height
        end
    else
        if ST.Config.showTitleBar then
            self.frame:SetHeight(contentHeight + 20) -- Add title bar height
        else
            self.frame:SetHeight(contentHeight) -- Just content
        end
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