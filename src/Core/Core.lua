local addonName, PDS = ...
local Core = {}
PDS.Core = Core

-- Initialize collection for stat bars
Core.bars = {}

-- Sets up the addon's main frame and components
function Core:Initialize()
	self.previousValues = {}

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

	local titleBar = PDS.TitleBar:Create(self.frame)
	self.titleBar = titleBar

	self.contentFrame = CreateFrame("Frame", nil, self.frame)
	self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -20)
	self.contentFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, 0)

	self:UpdateTitleBarVisibility()
	self:CreateBars()
	self:UpdateFrameLock()

	if PDS.Config.showOnLogin then
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

-- Registers all required events
function Core:RegisterEvents()
	local frame = CreateFrame("Frame")
	self.eventFrame = frame

	frame:RegisterEvent("UNIT_STATS")
	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")

	-- Set up event and update handlers
	frame:SetScript("OnEvent", function(self, event, ...)
		Core:OnEvent(event, ...)
	end)
	frame:SetScript("OnUpdate", function(self, elapsed)
		Core:OnUpdate(elapsed)
	end)
end

-- Recalculates frame height based on number of bars and title bar visibility
function Core:AdjustFrameHeight()
	local barCount = #self.bars
	local contentHeight = barCount * (PDS.Config.barHeight + PDS.Config.barSpacing) - PDS.Config.barSpacing

	if contentHeight == 0 then
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

-- Enables or disables frame dragging based on lock setting
function Core:UpdateFrameLock()
	if PDS.Config.lockPosition then
		self.frame:SetMovable(false)
		self.frame:EnableMouse(false)
		self.frame:RegisterForDrag("")
		self.frame:SetScript("OnDragStart", nil)
		self.frame:SetScript("OnDragStop", nil)
	else
		self.frame:SetMovable(true)
		self.frame:EnableMouse(true)
		self.frame:RegisterForDrag("LeftButton")
		self.frame:SetScript("OnDragStart", self.frame.StartMoving)
		self.frame:SetScript("OnDragStop", function(frame)
			frame:StopMovingOrSizing()

			local point, _, _, x, y = frame:GetPoint()
			PDS.Config.framePoint = point
			PDS.Config.frameX = x
			PDS.Config.frameY = y
			PDS.Config:Save()
		end)
	end
end

-- Shows or hides the title bar and adjusts content frame accordingly
function Core:UpdateTitleBarVisibility()
	if self.titleBar then
		if PDS.Config.showTitleBar then
			self.titleBar:Show()
			self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -20)
		else
			self.titleBar:Hide()
			self.contentFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
		end

		self:AdjustFrameHeight()
	end
end

return Core
