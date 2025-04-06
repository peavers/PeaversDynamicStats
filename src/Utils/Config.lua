local addonName, PDS = ...

-- Initialize Config namespace with default values
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
	fontOutline = "OUTLINE",
	fontShadow = false,

	-- Other settings
	barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
	bgAlpha = 0.8,
	bgColor = { r = 0, g = 0, b = 0 },
	updateInterval = 0.5,
	combatUpdateInterval = 0.2,
	showOnLogin = true,
	showTitleBar = true,
	showStats = {},
	customColors = {},
	showOverflowBars = true, -- Show overflow bars for stats exceeding 100%
	showStatChanges = true, -- Show stat value changes
	showRatings = true, -- Show rating values
	showTooltips = true, -- Show enhanced tooltips on hover
	enableStatHistory = true, -- Enable stat history tracking
	hideOutOfCombat = false, -- Hide the addon when out of combat

	-- Profile settings
	currentProfile = "Default",
	profiles = {}
}

-- Initialize showStats with values from Stats.STAT_TYPES
for _, statType in ipairs(PDS.Stats.STAT_ORDER) do
	PDS.Config.showStats[statType] = true
end

local Config = PDS.Config

-- Saves all configuration values to the SavedVariables database
function Config:Save()
	if not PeaversDynamicStatsDB then
		PeaversDynamicStatsDB = {}
	end

	-- Initialize profiles table if it doesn't exist
	if not PeaversDynamicStatsDB.profiles then
		PeaversDynamicStatsDB.profiles = {}
	end

	-- Get current character name and realm
	local character = UnitName("player")
	local realm = GetRealmName()
	local characterKey = character .. "-" .. realm

	-- Initialize character data if it doesn't exist
	if not PeaversDynamicStatsDB.characters then
		PeaversDynamicStatsDB.characters = {}
	end

	-- Store current profile for this character
	PeaversDynamicStatsDB.characters[characterKey] = {
		currentProfile = self.currentProfile
	}

	-- Create profile data
	local profileData = {
		fontFace = self.fontFace,
		fontSize = self.fontSize,
		fontOutline = self.fontOutline,
		fontShadow = self.fontShadow,
		framePoint = self.framePoint,
		frameX = self.frameX,
		frameY = self.frameY,
		frameWidth = self.frameWidth,
		barWidth = self.barWidth,
		barHeight = self.barHeight,
		barTexture = self.barTexture,
		barBgAlpha = self.barBgAlpha,
		bgAlpha = self.bgAlpha,
		bgColor = self.bgColor,
		showStats = self.showStats,
		barSpacing = self.barSpacing,
		showTitleBar = self.showTitleBar,
		lockPosition = self.lockPosition,
		customColors = self.customColors,
		showOverflowBars = self.showOverflowBars,
		showStatChanges = self.showStatChanges,
		showRatings = self.showRatings,
		showTooltips = self.showTooltips,
		enableStatHistory = self.enableStatHistory,
		hideOutOfCombat = self.hideOutOfCombat
	}

	-- Save profile data
	PeaversDynamicStatsDB.profiles[self.currentProfile] = profileData

	-- Also save current profile name
	PeaversDynamicStatsDB.currentProfile = self.currentProfile

	-- For backward compatibility, also save to the root level
	for key, value in pairs(profileData) do
		PeaversDynamicStatsDB[key] = value
	end
end

-- Loads settings from a specific profile or database
function Config:LoadSettings(source)
	if not source then
		return
	end

	if source.fontFace then
		self.fontFace = source.fontFace
	end
	if source.fontSize then
		self.fontSize = source.fontSize
	end
	if source.fontOutline then
		self.fontOutline = source.fontOutline
	end
	if source.fontShadow ~= nil then
		self.fontShadow = source.fontShadow
	end
	if source.framePoint then
		self.framePoint = source.framePoint
	end
	if source.frameX then
		self.frameX = source.frameX
	end
	if source.frameY then
		self.frameY = source.frameY
	end
	if source.frameWidth then
		self.frameWidth = source.frameWidth
	end
	if source.barWidth then
		self.barWidth = source.barWidth
	end
	if source.barHeight then
		self.barHeight = source.barHeight
	end
	if source.barTexture then
		self.barTexture = source.barTexture
	end
	if source.barBgAlpha then
		self.barBgAlpha = source.barBgAlpha
	end
	if source.bgAlpha then
		self.bgAlpha = source.bgAlpha
	end
	if source.bgColor then
		self.bgColor = source.bgColor
	end
	if source.showStats then
		self.showStats = source.showStats
	end
	if source.barSpacing then
		self.barSpacing = source.barSpacing
	end
	if source.showTitleBar ~= nil then
		self.showTitleBar = source.showTitleBar
	end
	if source.lockPosition ~= nil then
		self.lockPosition = source.lockPosition
	end
	if source.customColors then
		self.customColors = source.customColors
	end
	if source.showOverflowBars ~= nil then
		self.showOverflowBars = source.showOverflowBars
	end
	if source.showStatChanges ~= nil then
		self.showStatChanges = source.showStatChanges
	end
	if source.showRatings ~= nil then
		self.showRatings = source.showRatings
	end
	if source.showTooltips ~= nil then
		self.showTooltips = source.showTooltips
	end
	if source.enableStatHistory ~= nil then
		self.enableStatHistory = source.enableStatHistory
	end
	if source.hideOutOfCombat ~= nil then
		self.hideOutOfCombat = source.hideOutOfCombat
	end
end

-- Loads configuration values from the SavedVariables database
function Config:Load()
	if not PeaversDynamicStatsDB then
		return
	end

	-- Initialize profiles table if it doesn't exist
	if not PeaversDynamicStatsDB.profiles then
		PeaversDynamicStatsDB.profiles = {}

		-- Migrate existing settings to Default profile
		PeaversDynamicStatsDB.profiles["Default"] = {
			fontFace = PeaversDynamicStatsDB.fontFace,
			fontSize = PeaversDynamicStatsDB.fontSize,
			fontOutline = PeaversDynamicStatsDB.fontOutline,
			fontShadow = PeaversDynamicStatsDB.fontShadow,
			framePoint = PeaversDynamicStatsDB.framePoint,
			frameX = PeaversDynamicStatsDB.frameX,
			frameY = PeaversDynamicStatsDB.frameY,
			frameWidth = PeaversDynamicStatsDB.frameWidth,
			barWidth = PeaversDynamicStatsDB.barWidth,
			barHeight = PeaversDynamicStatsDB.barHeight,
			barTexture = PeaversDynamicStatsDB.barTexture,
			barBgAlpha = PeaversDynamicStatsDB.barBgAlpha,
			bgAlpha = PeaversDynamicStatsDB.bgAlpha,
			bgColor = PeaversDynamicStatsDB.bgColor,
			showStats = PeaversDynamicStatsDB.showStats,
			barSpacing = PeaversDynamicStatsDB.barSpacing,
			showTitleBar = PeaversDynamicStatsDB.showTitleBar,
			lockPosition = PeaversDynamicStatsDB.lockPosition,
			customColors = PeaversDynamicStatsDB.customColors,
			showOverflowBars = PeaversDynamicStatsDB.showOverflowBars,
			showStatChanges = PeaversDynamicStatsDB.showStatChanges,
			showRatings = PeaversDynamicStatsDB.showRatings,
			showTooltips = PeaversDynamicStatsDB.showTooltips,
			enableStatHistory = PeaversDynamicStatsDB.enableStatHistory,
			hideOutOfCombat = PeaversDynamicStatsDB.hideOutOfCombat
		}
	end

	-- Get current character name and realm
	local characterKey = self:GetCurrentCharacterKey()

	-- Initialize character data if it doesn't exist
	if not PeaversDynamicStatsDB.characters then
		PeaversDynamicStatsDB.characters = {}
	end

	-- Get current profile for this character
	if PeaversDynamicStatsDB.characters[characterKey] and PeaversDynamicStatsDB.characters[characterKey].currentProfile then
		self.currentProfile = PeaversDynamicStatsDB.characters[characterKey].currentProfile
	else
		-- If no profile exists for this character, use Default or create it
		self.currentProfile = "Default"
		PeaversDynamicStatsDB.characters[characterKey] = {
			currentProfile = self.currentProfile
		}

		-- Create Default profile if it doesn't exist
		if not PeaversDynamicStatsDB.profiles["Default"] then
			PeaversDynamicStatsDB.profiles["Default"] = {}
		end
	end

	-- Load settings from the current profile
	local profile = PeaversDynamicStatsDB.profiles[self.currentProfile]

	if profile then
		-- Load settings from the profile
		self:LoadSettings(profile)
	else
		-- Fallback to root level settings for backward compatibility
		self:LoadSettings(PeaversDynamicStatsDB)
	end
end

-- Returns a sorted table of available fonts, including those from LibSharedMedia
function Config:GetFonts()
	local fonts = {
		["Fonts\\ARIALN.TTF"] = "Arial Narrow",
		["Fonts\\FRIZQT__.TTF"] = "Default",
		["Fonts\\MORPHEUS.TTF"] = "Morpheus",
		["Fonts\\SKURRI.TTF"] = "Skurri"
	}

	if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
		local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
		if LSM then
			for name, path in pairs(LSM:HashTable("font")) do
				fonts[path] = name
			end
		end
	end

	local sortedFonts = {}
	for path, name in pairs(fonts) do
		table.insert(sortedFonts, { path = path, name = name })
	end

	table.sort(sortedFonts, function(a, b)
		return a.name < b.name
	end)

	local result = {}
	for _, font in ipairs(sortedFonts) do
		result[font.path] = font.name
	end

	return result
end

-- Returns a sorted table of available statusbar textures from various sources
function Config:GetBarTextures()
	local textures = {
		["Interface\\TargetingFrame\\UI-StatusBar"] = "Default",
		["Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"] = "Skill Bar",
		["Interface\\PVPFrame\\UI-PVP-Progress-Bar"] = "PVP Bar",
		["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid"
	}

	if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
		local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
		if LSM then
			for name, path in pairs(LSM:HashTable("statusbar")) do
				textures[path] = name
			end
		end
	end

	if _G.Details and _G.Details.statusbar_info then
		for i, textureTable in ipairs(_G.Details.statusbar_info) do
			if textureTable.file and textureTable.name then
				textures[textureTable.file] = textureTable.name
			end
		end
	end

	local sortedTextures = {}
	for path, name in pairs(textures) do
		table.insert(sortedTextures, { path = path, name = name })
	end

	table.sort(sortedTextures, function(a, b)
		return a.name < b.name
	end)

	local result = {}
	for _, texture in ipairs(sortedTextures) do
		result[texture.path] = texture.name
	end

	return result
end

-- Initialize the configuration when the addon loads
function Config:Initialize()
    -- Load saved configuration
    self:Load()

    -- Ensure all required stats are in the showStats table
    for _, statType in ipairs(PDS.Stats.STAT_ORDER) do
        if self.showStats[statType] == nil then
            -- Enable all stats by default, including primary stats
            self.showStats[statType] = true
        end

    end

    -- Ensure showStatChanges is enabled by default
    if self.showStatChanges == nil then
        self.showStatChanges = true
    end

    -- Ensure showRatings is enabled by default
    if self.showRatings == nil then
        self.showRatings = true
    end

    -- Ensure showOverflowBars is enabled by default
    if self.showOverflowBars == nil then
        self.showOverflowBars = true
    end

    -- Ensure showTooltips is enabled by default
    if self.showTooltips == nil then
        self.showTooltips = true
    end

    -- Ensure enableStatHistory is enabled by default
    if self.enableStatHistory == nil then
        self.enableStatHistory = true
    end

    -- Ensure hideOutOfCombat is disabled by default
    if self.hideOutOfCombat == nil then
        self.hideOutOfCombat = false
    end
end

-- Gets the current character key (name-realm)
function Config:GetCurrentCharacterKey()
    local character = UnitName("player")
    local realm = GetRealmName()
    return character .. "-" .. realm
end

-- Gets a list of all available profiles
function Config:GetProfiles()
    if not PeaversDynamicStatsDB or not PeaversDynamicStatsDB.profiles then
        return {}
    end

    local profiles = {}
    for profileName, _ in pairs(PeaversDynamicStatsDB.profiles) do
        table.insert(profiles, profileName)
    end

    table.sort(profiles)
    return profiles
end

-- Creates a new profile with the given name
function Config:CreateProfile(profileName)
    if not profileName or profileName == "" then
        return false, "Profile name cannot be empty"
    end

    if not PeaversDynamicStatsDB then
        PeaversDynamicStatsDB = {}
    end

    if not PeaversDynamicStatsDB.profiles then
        PeaversDynamicStatsDB.profiles = {}
    end

    -- Check if profile already exists
    if PeaversDynamicStatsDB.profiles[profileName] then
        return false, "Profile already exists"
    end

    -- Create a new profile with current settings
    PeaversDynamicStatsDB.profiles[profileName] = {
        fontFace = self.fontFace,
        fontSize = self.fontSize,
        fontOutline = self.fontOutline,
        fontShadow = self.fontShadow,
        framePoint = self.framePoint,
        frameX = self.frameX,
        frameY = self.frameY,
        frameWidth = self.frameWidth,
        barWidth = self.barWidth,
        barHeight = self.barHeight,
        barTexture = self.barTexture,
        barBgAlpha = self.barBgAlpha,
        bgAlpha = self.bgAlpha,
        bgColor = self.bgColor,
        showStats = self.showStats,
        barSpacing = self.barSpacing,
        showTitleBar = self.showTitleBar,
        lockPosition = self.lockPosition,
        customColors = self.customColors,
        showOverflowBars = self.showOverflowBars,
        showStatChanges = self.showStatChanges,
        showRatings = self.showRatings,
        showTooltips = self.showTooltips,
        enableStatHistory = self.enableStatHistory,
        hideOutOfCombat = self.hideOutOfCombat
    }

    return true
end

-- Selects a profile for the current character
function Config:SelectProfile(profileName)
    if not PeaversDynamicStatsDB or not PeaversDynamicStatsDB.profiles or not PeaversDynamicStatsDB.profiles[profileName] then
        return false, "Profile does not exist"
    end

    -- Update current profile
    self.currentProfile = profileName

    -- Save current profile for this character
    local characterKey = self:GetCurrentCharacterKey()

    if not PeaversDynamicStatsDB.characters then
        PeaversDynamicStatsDB.characters = {}
    end

    PeaversDynamicStatsDB.characters[characterKey] = {
        currentProfile = profileName
    }

    -- Load settings from the selected profile
    self:Load()

    return true
end

-- Deletes a profile
function Config:DeleteProfile(profileName)
    if not PeaversDynamicStatsDB or not PeaversDynamicStatsDB.profiles or not PeaversDynamicStatsDB.profiles[profileName] then
        return false, "Profile does not exist"
    end

    -- Don't delete the Default profile
    if profileName == "Default" then
        return false, "Cannot delete the Default profile"
    end

    -- Check if any character is using this profile
    if PeaversDynamicStatsDB.characters then
        for characterKey, characterData in pairs(PeaversDynamicStatsDB.characters) do
            if characterData.currentProfile == profileName then
                -- Switch this character to Default profile
                PeaversDynamicStatsDB.characters[characterKey].currentProfile = "Default"
            end
        end
    end

    -- Delete the profile
    PeaversDynamicStatsDB.profiles[profileName] = nil

    -- If current profile was deleted, switch to Default
    if self.currentProfile == profileName then
        self.currentProfile = "Default"
        self:Load()
    end

    return true
end

-- Copies settings from one profile to another
function Config:CopyProfile(sourceProfileName, targetProfileName)
    if not PeaversDynamicStatsDB or not PeaversDynamicStatsDB.profiles then
        return false, "No profiles exist"
    end

    if not PeaversDynamicStatsDB.profiles[sourceProfileName] then
        return false, "Source profile does not exist"
    end

    if not targetProfileName or targetProfileName == "" then
        return false, "Target profile name cannot be empty"
    end

    -- Create a deep copy of the source profile
    local sourceProfile = PeaversDynamicStatsDB.profiles[sourceProfileName]
    local targetProfile = {}

    for key, value in pairs(sourceProfile) do
        if type(value) == "table" then
            targetProfile[key] = {}
            for k, v in pairs(value) do
                targetProfile[key][k] = v
            end
        else
            targetProfile[key] = value
        end
    end

    -- Save the copied profile
    PeaversDynamicStatsDB.profiles[targetProfileName] = targetProfile

    return true
end
