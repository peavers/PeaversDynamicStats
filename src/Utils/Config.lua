-- At the beginning of Config.lua, add this check:
local addonName, PDS = ...

-- Create Config namespace with default values
PDS.Config = {
	-- Frame settings
	frameWidth = 250,
	frameHeight = 300,
	framePoint = "RIGHT",
	frameX = -20,
	frameY = 0,
	lockPosition = false,

	-- Bar settings
	barWidth = 230,
	barHeight = 20,
	barSpacing = 2,
	barBgAlpha = 0.7,

	-- Visual settings
	fontFace = "Fonts\\FRIZQT__.TTF",
	fontSize = 9,

	-- Other settings
	barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
	bgAlpha = 0.8,
	bgColor = { r = 0, g = 0, b = 0 },
	updateInterval = 0.5,
	combatUpdateInterval = 0.2,
	showOnLogin = true,
	showTitleBar = true,
	showStats = {
		HASTE = true,
		CRIT = true,
		MASTERY = true,
		VERSATILITY = true
	}
}

-- Local variables
local Config = PDS.Config
local UI

-- Initialize options panel
function Config:InitializeOptions()
	-- Ensure UI is loaded
	UI = PDS.UI
	if not UI then
		print("ERROR: UI module not loaded. Cannot initialize options.")
		return
	end

	local panel = CreateFrame("Frame")
	panel.name = "PeaversDynamicStats"

	-- Create scrolling content frame
	local scrollFrame, content = UI:CreateScrollFrame(panel)

	-- Start position
	local yPos = 0

	-- Title
	local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 25, yPos)
	title:SetText("Peavers Dynamic Stats")
	yPos = yPos - 30

	-- Subtitle
	local subtitle = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	subtitle:SetPoint("TOPLEFT", 25, yPos)
	subtitle:SetText("Configuration options for the dynamic stats display")
	yPos = yPos - 40

	local function CreateStatCheckbox(statKey, statName, y)
		local onClick = function(self)
			Config.showStats[statKey] = self:GetChecked()
			Config:Save()
			if PDS.Core and PDS.Core.CreateBars then
				PDS.Core:CreateBars()
			end
		end

		return UI:CreateCheckbox(
			content,
			"PeaversStat" .. statKey .. "Checkbox",
			statName,
			25,
			y,
			Config.showStats[statKey],
			{ 1, 1, 1 },
			onClick
		)
	end

	-- General section
	local _, newY = UI:CreateSectionHeader(content, "General", 25, yPos)
	yPos = newY

	-- Stat checkboxes
	local _, newY = CreateStatCheckbox("HASTE", "Haste", yPos)
	yPos = newY
	local _, newY = CreateStatCheckbox("CRIT", "Critical Strike", yPos)
	yPos = newY
	local _, newY = CreateStatCheckbox("MASTERY", "Mastery", yPos)
	yPos = newY
	local _, newY = CreateStatCheckbox("VERSATILITY", "Versatility", yPos)
	yPos = newY - 25 -- Extra spacing between sections

	-- Bar Settings section
	local _, newY = UI:CreateSectionHeader(content, "Bar Settings", 25, yPos)
	yPos = newY

	-- Bar spacing slider
	local spacingLabel, newY = UI:CreateLabel(content, "Bar Spacing: " .. Config.barSpacing, 25, yPos)
	yPos = newY

	local spacingSlider, newY = UI:CreateSlider(
		content, "PeaversSpacingSlider", -5, 10, 1, 25, yPos, Config.barSpacing
	)
	yPos = newY

	spacingSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value + 0.5)
		spacingLabel:SetText("Bar Spacing: " .. roundedValue)
		Config.barSpacing = roundedValue
		Config:Save()
		if PDS.Core and PDS.Core.CreateBars then
			PDS.Core:CreateBars()
		end
	end)

	-- Bar height slider
	local heightLabel, newY = UI:CreateLabel(content, "Bar Height: " .. Config.barHeight, 25, yPos)
	yPos = newY

	local heightSlider, newY = UI:CreateSlider(
		content, "PeaversHeightSlider", 10, 40, 1, 25, yPos, Config.barHeight
	)
	yPos = newY

	heightSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value + 0.5)
		heightLabel:SetText("Bar Height: " .. roundedValue)
		Config.barHeight = roundedValue
		Config:Save()
		if PDS.Core and PDS.Core.CreateBars then
			PDS.Core:CreateBars()
		end
	end)

	-- Frame width slider
	local widthLabel, newY = UI:CreateLabel(content, "Frame Width: " .. Config.frameWidth, 25, yPos)
	yPos = newY

	local widthSlider, newY = UI:CreateSlider(
		content, "PeaversWidthSlider", 150, 400, 10, 25, yPos, Config.frameWidth
	)
	yPos = newY

	widthSlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value / 10 + 0.5) * 10
		widthLabel:SetText("Frame Width: " .. roundedValue)
		Config.frameWidth = roundedValue
		Config.barWidth = roundedValue - 20
		Config:Save()
		if PDS.Core and PDS.Core.frame then
			PDS.Core.frame:SetWidth(roundedValue)
			if PDS.Core.bars then
				for _, bar in ipairs(PDS.Core.bars) do
					bar:UpdateWidth()
				end
			end
		end
	end)

	yPos = yPos - 10 -- Extra spacing between sections

	-- Bar background opacity slider
	local barBgOpacityLabel, newY = UI:CreateLabel(
			content,
			"Bar Background Opacity: " .. math.floor(Config.barBgAlpha * 100) .. "%",
			25,
			yPos
	)
	yPos = newY

	local barBgOpacitySlider, newY = UI:CreateSlider(
			content, "PeaversBarBgOpacitySlider", 0, 1, 0.05, 25, yPos, Config.barBgAlpha
	)
	yPos = newY

	barBgOpacitySlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value * 20 + 0.5) / 20
		barBgOpacityLabel:SetText("Bar Background Opacity: " .. math.floor(roundedValue * 100) .. "%")
		Config.barBgAlpha = roundedValue
		Config:Save()
		if PDS.Core and PDS.Core.bars then
			for _, bar in ipairs(PDS.Core.bars) do
				bar:UpdateBackgroundOpacity()
			end
		end
	end)
	

	-- Visual Settings section
	local _, newY = UI:CreateSectionHeader(content, "Visual Settings", 25, yPos)
	yPos = newY

	-- Group 1: Layout controls
	local _, newY = UI:CreateLabel(content, "Layout Options:", 30, yPos, "GameFontNormalSmall")
	yPos = newY

	-- Show title bar checkbox
	local titleBarCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversTitleBarCheckbox",
		"Show Title Bar",
		40,
		yPos,
		Config.showTitleBar,
		{ 1, 1, 1 },
		function(self)
			Config.showTitleBar = self:GetChecked()
			Config:Save()
			if PDS.Core then
				PDS.Core:UpdateTitleBarVisibility()
			end
		end
	)
	yPos = newY

	-- Lock position checkbox
	local lockPositionCheckbox, newY = UI:CreateCheckbox(
		content,
		"PeaversLockPositionCheckbox",
		"Lock Frame Position",
		40,
		yPos,
		Config.lockPosition,
		{ 1, 1, 1 },
		function(self)
			Config.lockPosition = self:GetChecked()
			Config:Save()
			if PDS.Core then
				PDS.Core:UpdateFrameLock()
			end
		end
	)
	yPos = newY - 10 -- Extra spacing between control groups

	-- Group 2: Background settings
	local _, newY = UI:CreateLabel(content, "Background:", 30, yPos, "GameFontNormalSmall")
	yPos = newY

	-- Background opacity slider
	local opacityLabel, newY = UI:CreateLabel(
		content,
		"Opacity: " .. math.floor(Config.bgAlpha * 100) .. "%",
		40,
		yPos
	)
	yPos = newY

	local opacitySlider, newY = UI:CreateSlider(
		content, "PeaversOpacitySlider", 0, 1, 0.05, 40, yPos, Config.bgAlpha
	)
	yPos = newY

	opacitySlider:SetScript("OnValueChanged", function(self, value)
		local roundedValue = math.floor(value * 20 + 0.5) / 20
		opacityLabel:SetText("Opacity: " .. math.floor(roundedValue * 100) .. "%")
		Config.bgAlpha = roundedValue
		Config:Save()
		if PDS.Core and PDS.Core.frame then
			PDS.Core.frame:SetBackdropColor(
				Config.bgColor.r,
				Config.bgColor.g,
				Config.bgColor.b,
				Config.bgAlpha
			)
			if PDS.Core.titleBar then
				PDS.Core.titleBar:SetBackdropColor(
					Config.bgColor.r,
					Config.bgColor.g,
					Config.bgColor.b,
					Config.bgAlpha
				)
			end
		end
	end)
	yPos = newY - 10 -- Extra spacing between control groups

	-- Group 3: Font selection
	local _, newY = UI:CreateLabel(content, "Text Style:", 30, yPos, "GameFontNormalSmall")
	yPos = newY

	local fontLabel, newY = UI:CreateLabel(content, "Font", 40, yPos)
	yPos = newY

	local fonts = self:GetFonts()
	local currentFont = fonts[self.fontFace] or "Default"

	local fontDropdown, newY = UI:CreateDropdown(
		content, "PeaversFontDropdown", 40, yPos, 345, currentFont
	)
	yPos = newY

	UIDropDownMenu_Initialize(fontDropdown, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for path, name in pairs(fonts) do
			info.text = name
			info.checked = (path == Config.fontFace)
			info.func = function()
				Config.fontFace = path
				UIDropDownMenu_SetText(fontDropdown, name)
				Config:Save()
				if PDS.Core and PDS.Core.CreateBars then
					PDS.Core:CreateBars()
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	yPos = newY - 10 -- Extra spacing between control groups

	-- Group 4: Bar texture
	local _, newY = UI:CreateLabel(content, "Bar Appearance:", 30, yPos, "GameFontNormalSmall")
	yPos = newY

	local textureLabel, newY = UI:CreateLabel(content, "Bar Texture", 40, yPos)
	yPos = newY

	local textures = self:GetBarTextures()
	local currentTexture = textures[self.barTexture] or "Default"

	local textureDropdown, newY = UI:CreateDropdown(
		content, "PeaversTextureDropdown", 40, yPos, 345, currentTexture
	)
	yPos = newY

	UIDropDownMenu_Initialize(textureDropdown, function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for path, name in pairs(textures) do
			info.text = name
			info.checked = (path == Config.barTexture)
			info.func = function()
				Config.barTexture = path
				UIDropDownMenu_SetText(textureDropdown, name)
				Config:Save()
				if PDS.Core and PDS.Core.bars then
					for _, bar in ipairs(PDS.Core.bars) do
						bar:UpdateTexture()
					end
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)

	-- Update content height based on the last element position
	content:SetHeight(math.abs(yPos) + 50)

	-- Register with the Interface Options
	if Settings and Settings.RegisterCanvasLayoutCategory then
		PDS.Config.categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(PDS.Config.categoryID)
	else
		InterfaceOptions_AddCategory(panel)
	end

	return panel
end

-- Save configuration
function Config:Save()
	if not PeaversDynamicStatsDB then
		PeaversDynamicStatsDB = {}
	end

	PeaversDynamicStatsDB.fontFace = self.fontFace
	PeaversDynamicStatsDB.framePoint = self.framePoint
	PeaversDynamicStatsDB.frameX = self.frameX
	PeaversDynamicStatsDB.frameY = self.frameY
	PeaversDynamicStatsDB.frameWidth = self.frameWidth
	PeaversDynamicStatsDB.barWidth = self.barWidth
	PeaversDynamicStatsDB.barHeight = self.barHeight
	PeaversDynamicStatsDB.barTexture = self.barTexture
	PeaversDynamicStatsDB.barBgAlpha = self.barBgAlpha
	PeaversDynamicStatsDB.bgAlpha = self.bgAlpha
	PeaversDynamicStatsDB.bgColor = self.bgColor
	PeaversDynamicStatsDB.showStats = self.showStats
	PeaversDynamicStatsDB.barSpacing = self.barSpacing
	PeaversDynamicStatsDB.showTitleBar = self.showTitleBar
	PeaversDynamicStatsDB.lockPosition = self.lockPosition
end

-- Load configuration
function Config:Load()
	if not PeaversDynamicStatsDB then
		return
	end

	if PeaversDynamicStatsDB.fontFace then
		self.fontFace = PeaversDynamicStatsDB.fontFace
	end
	if PeaversDynamicStatsDB.framePoint then
		self.framePoint = PeaversDynamicStatsDB.framePoint
	end
	if PeaversDynamicStatsDB.frameX then
		self.frameX = PeaversDynamicStatsDB.frameX
	end
	if PeaversDynamicStatsDB.frameY then
		self.frameY = PeaversDynamicStatsDB.frameY
	end
	if PeaversDynamicStatsDB.frameWidth then
		self.frameWidth = PeaversDynamicStatsDB.frameWidth
	end
	if PeaversDynamicStatsDB.barWidth then
		self.barWidth = PeaversDynamicStatsDB.barWidth
	end
	if PeaversDynamicStatsDB.barHeight then
		self.barHeight = PeaversDynamicStatsDB.barHeight
	end
	if PeaversDynamicStatsDB.barTexture then
		self.barTexture = PeaversDynamicStatsDB.barTexture
	end
	if PeaversDynamicStatsDB.barBgAlpha then
		self.barBgAlpha = PeaversDynamicStatsDB.barBgAlpha
	end
	if PeaversDynamicStatsDB.bgAlpha then
		self.bgAlpha = PeaversDynamicStatsDB.bgAlpha
	end
	if PeaversDynamicStatsDB.bgColor then
		self.bgColor = PeaversDynamicStatsDB.bgColor
	end
	if PeaversDynamicStatsDB.showStats then
		self.showStats = PeaversDynamicStatsDB.showStats
	end
	if PeaversDynamicStatsDB.barSpacing then
		self.barSpacing = PeaversDynamicStatsDB.barSpacing
	end
	if PeaversDynamicStatsDB.showTitleBar ~= nil then
		self.showTitleBar = PeaversDynamicStatsDB.showTitleBar
	end
	if PeaversDynamicStatsDB.lockPosition ~= nil then
		self.lockPosition = PeaversDynamicStatsDB.lockPosition
	end
end

-- Function to get available fonts in alphabetical order
function Config:GetFonts()
	local fonts = {
		["Fonts\\ARIALN.TTF"] = "Arial Narrow",
		["Fonts\\FRIZQT__.TTF"] = "Default",
		["Fonts\\MORPHEUS.TTF"] = "Morpheus",
		["Fonts\\SKURRI.TTF"] = "Skurri"
	}

	-- Check for SharedMedia
	if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
		local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
		if LSM then
			for name, path in pairs(LSM:HashTable("font")) do
				fonts[path] = name
			end
		end
	end

	-- Sort the fonts table by display name
	local sortedFonts = {}
	for path, name in pairs(fonts) do
		table.insert(sortedFonts, { path = path, name = name })
	end

	table.sort(sortedFonts, function(a, b)
		return a.name < b.name
	end)

	-- Rebuild the fonts table
	local result = {}
	for _, font in ipairs(sortedFonts) do
		result[font.path] = font.name
	end

	return result
end

-- Function to get available bar textures in alphabetical order
function Config:GetBarTextures()
	local textures = {
		["Interface\\TargetingFrame\\UI-StatusBar"] = "Default",
		["Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"] = "Skill Bar",
		["Interface\\PVPFrame\\UI-PVP-Progress-Bar"] = "PVP Bar",
		["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid"
	}

	-- Check for SharedMedia which is the standard library for shared textures
	if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
		local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
		if LSM then
			-- Properly iterate through all statusbar textures
			for name, path in pairs(LSM:HashTable("statusbar")) do
				textures[path] = name
			end
		end
	end

	-- Check if Details! is loaded and add its textures
	if _G.Details and _G.Details.statusbar_info then
		for i, textureTable in ipairs(_G.Details.statusbar_info) do
			if textureTable.file and textureTable.name then
				textures[textureTable.file] = textureTable.name
			end
		end
	end

	-- Sort the textures table by display name
	local sortedTextures = {}
	for path, name in pairs(textures) do
		table.insert(sortedTextures, { path = path, name = name })
	end

	table.sort(sortedTextures, function(a, b)
		return a.name < b.name
	end)

	-- Rebuild the textures table
	local result = {}
	for _, texture in ipairs(sortedTextures) do
		result[texture.path] = texture.name
	end

	return result
end

-- Function to open settings
function Config:OpenOptions()
	if not self.optionsPanel then
		self.optionsPanel = self:InitializeOptions()
	end
end

-- Slash command handler
PDS.Config.OpenOptionsCommand = function()
	Config:OpenOptions()
end
