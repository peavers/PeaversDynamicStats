local _, PDS = ...
local Core = PDS.Core

-- Creates or recreates all stat bars based on current configuration
function Core:CreateBars()
	-- Clear existing bars
	for _, bar in ipairs(self.bars) do
		bar.frame:Hide()
	end
	self.bars = {}

	local statOrder = {
		"HASTE", "CRIT", "MASTERY", "VERSATILITY"
	}

	local statNames = {
		HASTE = "Haste",
		CRIT = "Critical Strike",
		MASTERY = "Mastery",
		VERSATILITY = "Versatility"
	}

	local yOffset = 0
	for _, statType in ipairs(statOrder) do
		if PDS.Config.showStats[statType] then
			local bar = PDS.StatBar:New(self.contentFrame, statNames[statType], statType)
			bar:SetPosition(0, yOffset)

			local value = PDS.Utils:GetStatValue(statType)
			bar:Update(value)

			table.insert(self.bars, bar)

			yOffset = yOffset - (PDS.Config.barHeight + PDS.Config.barSpacing)
		end
	end

	local contentHeight = math.abs(yOffset)
	if contentHeight == 0 then
		self.frame:SetHeight(20) -- Just title bar
	else
		self.frame:SetHeight(contentHeight + 20) -- Add title bar height
	end

	self:AdjustFrameHeight()
	self.frame:SetWidth(PDS.Config.frameWidth)
end

-- Updates all stat bars with latest values, only if they've changed
function Core:UpdateAllBars()
	if not self.previousValues then
		self.previousValues = {}
	end

	for _, bar in ipairs(self.bars) do
		local value = PDS.Utils:GetStatValue(bar.statType)
		local statKey = bar.statType

		if not self.previousValues[statKey] then
			self.previousValues[statKey] = 0
		end

		if value ~= self.previousValues[statKey] then
			bar:Update(value)
			self.previousValues[statKey] = value
		end
	end
end
