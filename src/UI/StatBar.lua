local addonName, PDS = ...

-- Initialize StatBar namespace
PDS.StatBar = {}
local StatBar = PDS.StatBar

-- Creates a new stat bar instance
function StatBar:New(parent, name, statType)
	local obj = {}
	setmetatable(obj, { __index = StatBar })

	obj.name = name
	obj.statType = statType
	obj.value = 0
	obj.maxValue = 100
	obj.targetValue = 0
	obj.smoothing = true
	obj.yOffset = 0
	obj.frame = obj:CreateFrame(parent)

	-- Set the initial color after frame is created
	obj:UpdateColor()

	obj:InitAnimationSystem()
	obj:InitChangeTextFadeAnimation()

	return obj
end

-- Sets up the animation system for smooth value transitions
function StatBar:InitAnimationSystem()
	self.smoothing = true
	self.animationGroup = self.frame.bar:CreateAnimationGroup()
	self.valueAnimation = self.animationGroup:CreateAnimation("Progress")
	self.valueAnimation:SetDuration(0.3)
	self.valueAnimation:SetSmoothing("OUT")

	self.valueAnimation:SetScript("OnUpdate", function(anim)
		local progress = anim:GetProgress()
		local startValue = anim.startValue or 0
		local changeValue = anim.changeValue or 0
		local currentValue = startValue + (changeValue * progress)

		self.frame.bar:SetValue(currentValue)
	end)
end

-- Sets up the fade animation for the change indicator text
function StatBar:InitChangeTextFadeAnimation()
	-- Create animation group for the change text
	self.changeTextAnimGroup = self.frame.changeText:CreateAnimationGroup()

	-- Create alpha animation to fade out the text
	-- This animation will gradually reduce the opacity of the text from 100% to 0%
	self.changeTextFadeAnim = self.changeTextAnimGroup:CreateAnimation("Alpha")
	self.changeTextFadeAnim:SetFromAlpha(1.0)  -- Start fully visible
	self.changeTextFadeAnim:SetToAlpha(0.0)    -- End completely transparent
	self.changeTextFadeAnim:SetDuration(3.0)   -- Fade out over 3 seconds
	self.changeTextFadeAnim:SetStartDelay(1.0) -- Start fading after 1 second display
	self.changeTextFadeAnim:SetSmoothing("OUT") -- Ease out for smoother appearance

	-- Hide the text when the animation completes to ensure it's not taking up space
	-- and reset the alpha for the next time it needs to be displayed
	self.changeTextAnimGroup:SetScript("OnFinished", function()
		self.frame.changeText:SetText("")      -- Clear the text
		self.frame.changeText:SetAlpha(1.0)    -- Reset alpha for next display
	end)
end

-- Creates the visual elements of the stat bar
function StatBar:CreateFrame(parent)
	local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	frame:SetSize(PDS.Config.barWidth, PDS.Config.barHeight)

	local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	bg:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		tile = true, edgeSize = 1,
	})
	bg:SetBackdropColor(0, 0, 0, PDS.Config.barBgAlpha)
	bg:SetBackdropBorderColor(0, 0, 0, PDS.Config.barBgAlpha)
	frame.bg = bg

	-- Create the status bar with explicit name to help with debugging
	local bar = CreateFrame("StatusBar", "PDS_StatBar_"..self.statType, bg)
	bar:SetPoint("TOPLEFT", bg, "TOPLEFT", 1, -1)
	bar:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)
	bar:SetMinMaxValues(0, 100)
	bar:SetValue(0)

	-- Set the status bar texture using the configured texture if available
	if PDS.Config.barTexture then
		bar:SetStatusBarTexture(PDS.Config.barTexture)
	else
		-- Fallback to a plain white texture if no texture path is configured
		local texture = bar:CreateTexture(nil, "ARTWORK")
		texture:SetAllPoints()
		texture:SetColorTexture(1, 1, 1, 1) -- White texture that will take color
		bar:SetStatusBarTexture(texture)
	end

	-- Set initial color
	bar:SetStatusBarColor(0.8, 0.8, 0.8, 1)

	frame.bar = bar

	local valueText = bar:CreateFontString(nil, "OVERLAY")
	valueText:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
	valueText:SetFont(PDS.Config.fontFace, PDS.Config.fontSize, PDS.Config.fontOutline)
	valueText:SetJustifyH("RIGHT")
	valueText:SetText("0")
	valueText:SetTextColor(1, 1, 1)
	if PDS.Config.fontShadow then
		valueText:SetShadowOffset(1, -1)
	else
		valueText:SetShadowOffset(0, 0)
	end
	frame.valueText = valueText

	local nameText = bar:CreateFontString(nil, "OVERLAY")
	nameText:SetPoint("LEFT", bar, "LEFT", 4, 0)
	nameText:SetFont(PDS.Config.fontFace, PDS.Config.fontSize, PDS.Config.fontOutline)
	nameText:SetJustifyH("LEFT")
	nameText:SetText(self.name)
	nameText:SetTextColor(1, 1, 1)
	if PDS.Config.fontShadow then
		nameText:SetShadowOffset(1, -1)
	else
		nameText:SetShadowOffset(0, 0)
	end
	frame.nameText = nameText

	-- Create change indicator text
	local changeText = bar:CreateFontString(nil, "OVERLAY")
	changeText:SetPoint("CENTER", bar, "CENTER", 0, 0)
	changeText:SetFont(PDS.Config.fontFace, PDS.Config.fontSize, PDS.Config.fontOutline)
	changeText:SetJustifyH("CENTER")
	changeText:SetText("")
	changeText:SetTextColor(1, 1, 1)
	if PDS.Config.fontShadow then
		changeText:SetShadowOffset(1, -1)
	else
		changeText:SetShadowOffset(0, 0)
	end
	frame.changeText = changeText

	return frame
end

-- Updates the bar with a new value, using animation for smooth transitions
function StatBar:Update(value, maxValue, change)
	if value ~= self.value then
		self.value = value or 0

		local percentValue = math.min(self.value, 100)
		local displayValue = PDS.Utils:FormatPercent(self.value)

		-- If showRatings is enabled, get the rating and add it to the display value
		if PDS.Config.showRatings then
			local rating = PDS.Stats:GetRating(self.statType)
			if rating > 0 then
				displayValue = displayValue .. " | " .. math.floor(rating + 0.5)
			end
		end

		local currentText = self.frame.valueText:GetText()
		if currentText ~= displayValue then
			self.frame.valueText:SetText(displayValue)
		end

  -- Update change indicator if showStatChanges is enabled
		if PDS.Config.showStatChanges and change and change ~= 0 then
			-- If there's an existing animation playing, we need to stop it
			-- before starting a new one to prevent visual glitches
			if self.changeTextAnimGroup then
				self.changeTextAnimGroup:Stop()
			end

			-- Reset alpha to full visibility for the new change display
			self.frame.changeText:SetAlpha(1.0)

			-- Format and display the change value with appropriate sign
			local changeDisplay = PDS.Utils:FormatChange(change)
			self.frame.changeText:SetText(changeDisplay)

			-- Set color based on change direction for better visual feedback
			if change > 0 then
				self.frame.changeText:SetTextColor(0, 1, 0) -- Green for positive changes
			elseif change < 0 then
				self.frame.changeText:SetTextColor(1, 0, 0) -- Red for negative changes
			else
				self.frame.changeText:SetTextColor(1, 1, 1) -- White for no change (shouldn't happen)
			end

			-- Start the fade-out animation to gradually hide the change indicator
			-- This will make the text fade out over a few seconds instead of staying static
			if self.changeTextAnimGroup then
				self.changeTextAnimGroup:Play()
			end
		else
			-- If there's no change or changes are disabled, just clear the text
			self.frame.changeText:SetText("")
		end

		-- Use animation if enabled, otherwise set value directly
		if self.smoothing then
			self:AnimateToValue(percentValue)
		else
			self.frame.bar:SetValue(percentValue)
		end
	end
end

-- Animates the bar to a new value
function StatBar:AnimateToValue(newValue)
	self.animationGroup:Stop()

	local currentValue = self.frame.bar:GetValue()

	if math.abs(newValue - currentValue) >= 0.5 then
		self.valueAnimation.startValue = currentValue
		self.valueAnimation.changeValue = newValue - currentValue
		self.animationGroup:Play()
	else
		self.frame.bar:SetValue(newValue)
	end
end

-- Returns the color for a specific stat type
function StatBar:GetColorForStat(statType)
	-- Check if there's a custom color for this stat
	if PDS.Config.customColors and PDS.Config.customColors[statType] then
		local color = PDS.Config.customColors[statType]
		if color and color.r and color.g and color.b then
			return color.r, color.g, color.b
		end
	end

	-- Fall back to default colors from STAT_COLORS
	if PDS.Stats.STAT_COLORS and PDS.Stats.STAT_COLORS[statType] then
		return unpack(PDS.Stats.STAT_COLORS[statType])
	end

	-- Ultimate fallback to ensure visibility
	return 0.8, 0.8, 0.8
end

-- Updates the color of the bar
function StatBar:UpdateColor()
	local r, g, b = self:GetColorForStat(self.statType)

	-- Ensure we have valid color values
	r = r or 0.8
	g = g or 0.8
	b = b or 0.8

	-- Apply the color to the status bar - set color directly without recreating texture
	if self.frame and self.frame.bar then
		self.frame.bar:SetStatusBarColor(r, g, b, 1)
	end
end

-- Sets the position of the bar relative to its parent
function StatBar:SetPosition(x, y)
	self.yOffset = y
	self.frame:ClearAllPoints()
	self.frame:SetPoint("TOPLEFT", self.frame:GetParent(), "TOPLEFT", x, y)
	self.frame:SetPoint("TOPRIGHT", self.frame:GetParent(), "TOPRIGHT", 0, y)
end

-- Sets the highlight/select state of the bar
function StatBar:SetSelected(selected)
	if selected then
		if not self.frame.highlight then
			local highlight = self.frame.bar:CreateTexture(nil, "OVERLAY")
			highlight:SetAllPoints()
			highlight:SetColorTexture(1, 1, 1, 0.1)
			self.frame.highlight = highlight
		end
		self.frame.highlight:Show()
	elseif self.frame.highlight then
		self.frame.highlight:Hide()
	end
end

-- Updates the font used for text elements
function StatBar:UpdateFont()
	self.frame.valueText:SetFont(PDS.Config.fontFace, PDS.Config.fontSize, PDS.Config.fontOutline)
	self.frame.nameText:SetFont(PDS.Config.fontFace, PDS.Config.fontSize, PDS.Config.fontOutline)
	self.frame.changeText:SetFont(PDS.Config.fontFace, PDS.Config.fontSize, PDS.Config.fontOutline)

	-- Apply shadow if enabled
	if PDS.Config.fontShadow then
		self.frame.valueText:SetShadowOffset(1, -1)
		self.frame.nameText:SetShadowOffset(1, -1)
		self.frame.changeText:SetShadowOffset(1, -1)
	else
		self.frame.valueText:SetShadowOffset(0, 0)
		self.frame.nameText:SetShadowOffset(0, 0)
		self.frame.changeText:SetShadowOffset(0, 0)
	end
end

-- Updates the texture used for the status bar
function StatBar:UpdateTexture()
	-- Use the configured texture path if available
	if PDS.Config.barTexture then
		self.frame.bar:SetStatusBarTexture(PDS.Config.barTexture)
	else
		-- Fallback to a plain white texture if no texture path is configured
		local texture = self.frame.bar:CreateTexture(nil, "ARTWORK")
		texture:SetAllPoints()
		texture:SetColorTexture(1, 1, 1, 1)
		self.frame.bar:SetStatusBarTexture(texture)
	end

	-- Reapply color after updating texture
	self:UpdateColor()
end

-- Updates the height of the bar
function StatBar:UpdateHeight()
	self.frame:SetHeight(PDS.Config.barHeight)
end

-- Updates the width of the bar
function StatBar:UpdateWidth()
	self.frame:ClearAllPoints()
	self.frame:SetPoint("TOPLEFT", self.frame:GetParent(), "TOPLEFT", 0, self.yOffset)
	self.frame:SetPoint("TOPRIGHT", self.frame:GetParent(), "TOPRIGHT", 0, self.yOffset)
end

-- Updates the background opacity of the bar
function StatBar:UpdateBackgroundOpacity()
	self.frame.bg:SetBackdropColor(0, 0, 0, PDS.Config.barBgAlpha)
	self.frame.bg:SetBackdropBorderColor(0, 0, 0, PDS.Config.barBgAlpha)
end
