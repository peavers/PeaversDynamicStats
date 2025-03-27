local _, PDS = ...
local Core = PDS.Core

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
		if PDS.Config.showStats[statType] then
			local bar = PDS.StatBar:New(self.contentFrame, statNames[statType], statType)
			bar:SetPosition(0, yOffset)

			-- Update stat values
			local value = PDS.Utils:GetStatValue(statType)
			bar:Update(value)

			-- Add to bar collection
			table.insert(self.bars, bar)

			-- Adjust offset for next bar using the configured height and spacing
			yOffset = yOffset - (PDS.Config.barHeight + PDS.Config.barSpacing)
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
	self.frame:SetWidth(PDS.Config.frameWidth)
end

-- Update all bars with latest stat values
function Core:UpdateAllBars()
	-- Initialize previousValues table if it doesn't exist
	if not self.previousValues then
		self.previousValues = {}
	end

	-- Update each bar only if value has changed
	for _, bar in ipairs(self.bars) do
		local value = PDS.Utils:GetStatValue(bar.statType)

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
