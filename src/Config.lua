--[[
    Config.lua - Configuration settings for StatTracker
]]

local addonName, ST = ...

-- Create Config namespace with default values
ST.Config = {
    -- Frame settings
    frameWidth = 250,
    frameHeight = 300,
    framePoint = "RIGHT",
    frameX = -20,
    frameY = 0,

    -- Bar settings
    barWidth = 230,
    barHeight = 20,
    barSpacing = 2,

    -- Visual settings
    fontFace = "Fonts\\FRIZQT__.TTF",
    fontSize = 9,

    -- Other settings
    barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
    bgAlpha = 0.8,
    bgColor = {r = 0, g = 0, b = 0},
    updateInterval = 0.5,
    combatUpdateInterval = 0.2,
    showOnLogin = true,
    showStats = {
        STRENGTH = true,
        AGILITY = true,
        INTELLECT = true,
        STAMINA = true,
        HASTE = true,
        CRIT = true,
        MASTERY = true,
        VERSATILITY = true
    }
}

-- Local variables
local Config = ST.Config
local categoryID

-- Function to save configuration
function Config:Save()
    if not PeaversDynamicStatsDB then
        PeaversDynamicStatsDB = {}
    end

    PeaversDynamicStatsDB.fontFace = self.fontFace
    PeaversDynamicStatsDB.framePoint = self.framePoint
    PeaversDynamicStatsDB.frameX = self.frameX
    PeaversDynamicStatsDB.frameY = self.frameY
    PeaversDynamicStatsDB.barTexture = self.barTexture
    PeaversDynamicStatsDB.bgAlpha = self.bgAlpha
    PeaversDynamicStatsDB.bgColor = self.bgColor
    PeaversDynamicStatsDB.showStats = self.showStats
    PeaversDynamicStatsDB.barSpacing = self.barSpacing
end

-- Function to load configuration
function Config:Load()
    if not PeaversDynamicStatsDB then return end

    if PeaversDynamicStatsDB.fontFace then self.fontFace = PeaversDynamicStatsDB.fontFace end
    if PeaversDynamicStatsDB.framePoint then self.framePoint = PeaversDynamicStatsDB.framePoint end
    if PeaversDynamicStatsDB.frameX then self.frameX = PeaversDynamicStatsDB.frameX end
    if PeaversDynamicStatsDB.frameY then self.frameY = PeaversDynamicStatsDB.frameY end
    if PeaversDynamicStatsDB.barTexture then self.barTexture = PeaversDynamicStatsDB.barTexture end
    if PeaversDynamicStatsDB.bgAlpha then self.bgAlpha = PeaversDynamicStatsDB.bgAlpha end
    if PeaversDynamicStatsDB.bgColor then self.bgColor = PeaversDynamicStatsDB.bgColor end
    if PeaversDynamicStatsDB.showStats then self.showStats = PeaversDynamicStatsDB.showStats end
    if PeaversDynamicStatsDB.barSpacing then self.barSpacing = PeaversDynamicStatsDB.barSpacing end
end

-- Initialize settings with a simplified approach
function Config:InitializeOptions()
    -- Create simple panel
    local panel = CreateFrame("Frame", nil, UIParent)
    panel.name = "PeaversDynamicStats"

    -- Create title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("PeaversDynamicStats Options")

    -- Stats section
    local statText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    statText:SetPoint("TOPLEFT", 16, -50)
    statText:SetText("Stats to Display:")

    -- Create checkboxes for stats
    local yPos = -70
    local stats = {
        {key = "STRENGTH", name = "Strength"},
        {key = "AGILITY", name = "Agility"},
        {key = "INTELLECT", name = "Intellect"},
        {key = "STAMINA", name = "Stamina"},
        {key = "HASTE", name = "Haste"},
        {key = "CRIT", name = "Critical Strike"},
        {key = "MASTERY", name = "Mastery"},
        {key = "VERSATILITY", name = "Versatility"}
    }

    for _, stat in ipairs(stats) do
        local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 25, yPos)
        checkbox:SetChecked(Config.showStats[stat.key])

        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        label:SetText(stat.name)

        checkbox:SetScript("OnClick", function(self)
            Config.showStats[stat.key] = self:GetChecked()
            Config:Save()
            if ST.Core and ST.Core.CreateBars then
                ST.Core:CreateBars()
            end
        end)

        yPos = yPos - 25
    end

    -- Add bar spacing slider
    yPos = yPos - 30
    local spacingText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    spacingText:SetPoint("TOPLEFT", 16, yPos)
    spacingText:SetText("Bar Spacing:")

    yPos = yPos - 20
    local spacingSlider = CreateFrame("Slider", "PeaversDynamicStatsSpacingSlider", panel, "OptionsSliderTemplate")
    spacingSlider:SetPoint("TOPLEFT", 25, yPos)
    spacingSlider:SetWidth(200)
    spacingSlider:SetMinMaxValues(-5, 10)
    spacingSlider:SetValueStep(1)
    spacingSlider:SetValue(Config.barSpacing)

    -- Set slider text
    _G[spacingSlider:GetName() .. "Low"]:SetText("0")
    _G[spacingSlider:GetName() .. "High"]:SetText("10")
    _G[spacingSlider:GetName() .. "Text"]:SetText(Config.barSpacing)

    spacingSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText(value)

        Config.barSpacing = value
        Config:Save()

        -- Update the UI if Core is available
        if ST.Core and ST.Core.CreateBars then
            ST.Core:CreateBars()
        end
    end)

    -- Add font dropdown section
    yPos = yPos - 40
    local fontText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontText:SetPoint("TOPLEFT", 16, yPos)
    fontText:SetText("Font:")

    yPos = yPos - 25
    local fontDropdown = CreateFrame("Frame", "PeaversDynamicStatsFontDropdown", panel, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", 25, yPos)
    UIDropDownMenu_SetWidth(fontDropdown, 200)

    local fonts = Config:GetFonts()
    local currentFontName = fonts[Config.fontFace] or "Default"
    UIDropDownMenu_SetText(fontDropdown, currentFontName)

    UIDropDownMenu_Initialize(fontDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for path, name in pairs(fonts) do
            info.text = name
            info.value = path
            info.func = function()
                Config.fontFace = path
                UIDropDownMenu_SetText(fontDropdown, name)
                Config:Save()
                if ST.Core and ST.Core.bars then
                    for _, bar in ipairs(ST.Core.bars) do
                        bar:UpdateFont()
                    end
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Add bar texture section
    yPos = yPos - 40
    local textureText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    textureText:SetPoint("TOPLEFT", 16, yPos)
    textureText:SetText("Bar Texture:")

    yPos = yPos - 25
    local textureDropdown = CreateFrame("Frame", "PeaversDynamicStatsTextureDropdown", panel, "UIDropDownMenuTemplate")
    textureDropdown:SetPoint("TOPLEFT", 25, yPos)
    UIDropDownMenu_SetWidth(textureDropdown, 200)

    local textures = Config:GetBarTextures()
    local currentTextureName = textures[Config.barTexture] or "Default"
    UIDropDownMenu_SetText(textureDropdown, currentTextureName)

    UIDropDownMenu_Initialize(textureDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for path, name in pairs(textures) do
            info.text = name
            info.value = path
            info.func = function()
                Config.barTexture = path
                UIDropDownMenu_SetText(textureDropdown, name)
                Config:Save()
                if ST.Core and ST.Core.bars then
                    for _, bar in ipairs(ST.Core.bars) do
                        bar:UpdateTexture()
                    end
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Register with Settings
    categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(categoryID)

    return panel
end

function Config:GetFonts()
    local fonts = {
        ["Fonts\\FRIZQT__.TTF"] = "Default",
        ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
        ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
        ["Fonts\\SKURRI.TTF"] = "Skurri"
    }

    -- Check for SharedMedia
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        if LSM then
            for name, path in pairs(LSM:HashTable("font")) do
                fonts[path] = "LSM: " .. name
            end
        end
    end

    return fonts
end

-- Enhanced function to get available bar textures
function Config:GetBarTextures()
    local textures = {
        ["Interface\\TargetingFrame\\UI-StatusBar"] = "Default",
        ["Interface\\RaidFrame\\Raid-Bar-Hp-Fill"] = "Raid",
        ["Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"] = "Skill Bar",
        ["Interface\\PVPFrame\\UI-PVP-Progress-Bar"] = "PVP Bar"
    }

    -- Check for SharedMedia which is the standard library for shared textures
    if LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true) then
        local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
        if LSM then
            -- Properly iterate through all statusbar textures
            for name, path in pairs(LSM:HashTable("statusbar")) do
                textures[path] = "LSM: " .. name
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

    return textures
end

-- Function to open settings
function Config:OpenOptions()
    if not categoryID then
        self:InitializeOptions()
    end

    if categoryID then
        Settings.OpenToCategory(categoryID)
    end
end

-- Slash command handler
ST.Config.OpenOptionsCommand = function()
    Config:OpenOptions()
end