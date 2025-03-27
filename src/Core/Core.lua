local addonName, ST = ...
local Core = {}
ST.Core = Core

-- Initialize local variables
Core.bars = {}

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
    local titleBar = ST.TitleBar:Create(self.frame)
    self.titleBar = titleBar

    -- Create content frame
    self.contentFrame = CreateFrame("Frame", nil, self.frame)
    self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -20)
    self.contentFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)

    -- Apply title bar visibility AFTER content frame is created
    self:UpdateTitleBarVisibility()

    -- Create the stat bars
    self:CreateBars()

    self:UpdateFrameLock()

    -- Show if needed
    if ST.Config.showOnLogin then
        self.frame:Show()
    else
        self.frame:Hide()
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

function Core:UpdateFrameLock()
    if ST.Config.lockPosition then
        -- Disable dragging
        self.frame:SetMovable(false)
        self.frame:EnableMouse(false)
        -- Don't pass nil to RegisterForDrag, pass an empty string instead
        self.frame:RegisterForDrag("")
        self.frame:SetScript("OnDragStart", nil)
        self.frame:SetScript("OnDragStop", nil)
    else
        -- Enable dragging
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

-- Export the Core module
return Core