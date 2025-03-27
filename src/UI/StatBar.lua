local addonName, ST = ...

ST.StatBar = {}
local StatBar = ST.StatBar

-- Constructor
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

    -- Initialize the animation system
    obj:InitAnimationSystem()

    return obj
end

-- Initialize animation system for smooth updates
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

-- Create the bar frame
function StatBar:CreateFrame(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(ST.Config.barWidth, ST.Config.barHeight)

    -- Background for the bar
    local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bg:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = true, edgeSize = 1,
    })
    bg:SetBackdropColor(0, 0, 0, 0.7)
    bg:SetBackdropBorderColor(0, 0, 0, 1)
    frame.bg = bg

    -- The actual status bar
    local bar = CreateFrame("StatusBar", nil, bg)
    bar:SetPoint("TOPLEFT", bg, "TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(0)
    bar:SetStatusBarTexture(ST.Config.barTexture)

    -- Set color based on stat type
    local r, g, b = self:GetColorForStat(self.statType)
    bar:SetStatusBarColor(r, g, b, 1)
    frame.bar = bar

    -- Value text (right side)
    local valueText = bar:CreateFontString(nil, "OVERLAY")
    valueText:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
    valueText:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    valueText:SetJustifyH("RIGHT")
    valueText:SetText("0")
    valueText:SetTextColor(1, 1, 1)
    frame.valueText = valueText

    -- Name text (left side)
    local nameText = bar:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("LEFT", bar, "LEFT", 4, 0)
    nameText:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    nameText:SetJustifyH("LEFT")
    nameText:SetText(self.name)
    nameText:SetTextColor(1, 1, 1)
    frame.nameText = nameText

    return frame
end

-- Update the bar with smooth animation
function StatBar:Update(value, maxValue)
    -- Only update if the value has actually changed
    if value ~= self.value then
        self.value = value or 0

        local displayValue
        local percentValue

        -- We're dealing only with percentage stats now
        displayValue = string.format("%.2f%%", self.value)
        percentValue = math.min(self.value, 100)

        -- Only update text if it's changed
        local currentText = self.frame.valueText:GetText()
        if currentText ~= displayValue then
            self.frame.valueText:SetText(displayValue)
        end

        -- Use animation for smooth transition
        if self.smoothing then
            self:AnimateToValue(percentValue)
        else
            self.frame.bar:SetValue(percentValue)
        end
    end
end

-- Animate bar value change
function StatBar:AnimateToValue(newValue)
    -- Stop any current animation
    self.animationGroup:Stop()

    -- Get current value
    local currentValue = self.frame.bar:GetValue()

    -- Only animate if there's a significant difference (0.5% or more)
    if math.abs(newValue - currentValue) >= 0.5 then
        -- Set up animation properties
        self.valueAnimation.startValue = currentValue
        self.valueAnimation.changeValue = newValue - currentValue
        self.animationGroup:Play()
    else
        -- Just set the value directly for small changes
        self.frame.bar:SetValue(newValue)
    end
end

-- Get color for stat type
function StatBar:GetColorForStat(statType)
    local colors = {
        HASTE = { 0.0, 0.9, 0.9 },        -- Cyan
        CRIT = { 0.9, 0.9, 0.0 },         -- Yellow
        MASTERY = { 0.9, 0.4, 0.0 },      -- Orange
        VERSATILITY = { 0.2, 0.6, 0.2 }   -- Green
    }

    if colors[statType] then
        return unpack(colors[statType])
    else
        return 0.8, 0.8, 0.8 -- Default to white/grey
    end
end

-- Set position relative to parent
function StatBar:SetPosition(x, y)
    self.yOffset = y
    self.frame:ClearAllPoints()
    self.frame:SetPoint("TOPLEFT", self.frame:GetParent(), "TOPLEFT", x, y)
    self.frame:SetPoint("TOPRIGHT", self.frame:GetParent(), "TOPRIGHT", 0, y)
end

-- Set highlight/select state
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

-- Method to update the font
function StatBar:UpdateFont()
    -- Update the font for both text elements
    self.frame.valueText:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    self.frame.nameText:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
end

-- Method to update bar texture
function StatBar:UpdateTexture()
    -- Update the texture for the status bar
    self.frame.bar:SetStatusBarTexture(ST.Config.barTexture)
end

-- Method to update bar height
function StatBar:UpdateHeight()
    -- Update the height of the bar frame
    self.frame:SetHeight(ST.Config.barHeight)
end

-- Method to update bar width
function StatBar:UpdateWidth()
    -- Update bar width by reconfiguring the anchors
    self.frame:ClearAllPoints()
    self.frame:SetPoint("TOPLEFT", self.frame:GetParent(), "TOPLEFT", 0, self.yOffset)
    self.frame:SetPoint("TOPRIGHT", self.frame:GetParent(), "TOPRIGHT", 0, self.yOffset)
end