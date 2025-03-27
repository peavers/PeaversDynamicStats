local addonName, PDS = ...
local Core = {}
PDS.Core = Core

-- Initialize local variables
Core.bars = {}

-- Initialize the addon
function Core:Initialize()
	self.previousValues = {}

	-- Load config first
	PDS.Config:Load()

	-- Initialize the options panel
	PDS.Config:InitializeOptions()

	-- Create main frame
	self.frame = CreateFrame("Frame", "PeaversDynamicStatsFrame", UIParent, "BackdropTemplate")
	self.frame:SetSize(PDS.Config.frameWidth, PDS.Config.frameHeight)
	self.frame:SetPoint(PDS.Config.framePoint, PDS.Config.frameX, PDS.Config.frameY)
	self.frame:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		tile = true, tileSize = 16, edgeSize = 1,
	})
	self.frame:SetBackdropColor(PDS.Config.bgColor.r, PDS.Config.bgColor.g, PDS.Config.bgColor.b, PDS.Config.bgAlpha)
	self.frame:SetBackdropBorderColor(0, 0, 0, 1)

	-- Create title bar
	local titleBar = PDS.TitleBar:Create(self.frame)
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
	if PDS.Config.showOnLogin then
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

-- Add this function to recalculate frame height
function Core:AdjustFrameHeight()
	-- Calculate height based on number of bars
	local barCount = #self.bars
	local contentHeight = barCount * (PDS.Config.barHeight + PDS.Config.barSpacing) - PDS.Config.barSpacing

	if contentHeight == 0 then
		-- No bars shown
		if PDS.Config.showTitleBar then
			self.frame:SetHeight(20) -- Just title bar
		else
			self.frame:SetHeight(10) -- Minimal height
		end
	else
		if PDS.Config.showTitleBar then
			self.frame:SetHeight(contentHeight + 20) -- Add title bar height
		else
			self.frame:SetHeight(contentHeight) -- Just content
		end
	end
end

function Core:UpdateFrameLock()
	if PDS.Config.lockPosition then
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
			PDS.Config.framePoint = point
			PDS.Config.frameX = x
			PDS.Config.frameY = y
			PDS.Config:Save()
		end)
	end
end

function Core:UpdateTitleBarVisibility()
	if self.titleBar then
		if PDS.Config.showTitleBar then
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
