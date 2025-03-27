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
    PeaversDynamicStatsDB.barHeight = self.barHeight
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
    if PeaversDynamicStatsDB.barHeight then self.barHeight = PeaversDynamicStatsDB.barHeight end
end

-- Initialize settings with a simplified approach
function Config:InitializeOptions()
    -- Create simple panel
    local panel = CreateFrame("Frame", "PeaversDynamicStatsPanel", UIParent)
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

    -- Add bar height slider
    yPos = yPos - 40
    local heightText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    heightText:SetPoint("TOPLEFT", 16, yPos)
    heightText:SetText("Bar Height:")

    yPos = yPos - 20
    local heightSlider = CreateFrame("Slider", "PeaversDynamicStatsHeightSlider", panel, "OptionsSliderTemplate")
    heightSlider:SetPoint("TOPLEFT", 25, yPos)
    heightSlider:SetWidth(200)
    heightSlider:SetMinMaxValues(10, 30)
    heightSlider:SetValueStep(1)
    heightSlider:SetValue(Config.barHeight)

    -- Set slider text
    _G[heightSlider:GetName() .. "Low"]:SetText("10")
    _G[heightSlider:GetName() .. "High"]:SetText("30")
    _G[heightSlider:GetName() .. "Text"]:SetText(Config.barHeight)

    heightSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText(value)

        Config.barHeight = value
        Config:Save()

        -- Update the UI if Core is available
        if ST.Core and ST.Core.CreateBars then
            ST.Core:CreateBars()
        end
    end)

    -- Add background opacity slider
    yPos = yPos - 40
    local bgAlphaText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    bgAlphaText:SetPoint("TOPLEFT", 16, yPos)
    bgAlphaText:SetText("Background Opacity:")

    yPos = yPos - 20
    local bgAlphaSlider = CreateFrame("Slider", "PeaversDynamicStatsBGAlphaSlider", panel, "OptionsSliderTemplate")
    bgAlphaSlider:SetPoint("TOPLEFT", 25, yPos)
    bgAlphaSlider:SetWidth(200)
    bgAlphaSlider:SetMinMaxValues(0, 1)
    bgAlphaSlider:SetValueStep(0.05)
    bgAlphaSlider:SetValue(Config.bgAlpha)

    -- Set slider text
    _G[bgAlphaSlider:GetName() .. "Low"]:SetText("0%")
    _G[bgAlphaSlider:GetName() .. "High"]:SetText("100%")
    _G[bgAlphaSlider:GetName() .. "Text"]:SetText(math.floor(Config.bgAlpha * 100) .. "%")

    bgAlphaSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest 0.05
        value = math.floor(value * 20 + 0.5) / 20
        _G[self:GetName() .. "Text"]:SetText(math.floor(value * 100) .. "%")

        Config.bgAlpha = value
        Config:Save()

        -- Update the background alpha if Core is available
        if ST.Core and ST.Core.frame then
            ST.Core.frame:SetBackdropColor(
                Config.bgColor.r,
                Config.bgColor.g,
                Config.bgColor.b,
                Config.bgAlpha
            )

            -- Also update title bar if it exists
            if ST.Core.titleBar then
                ST.Core.titleBar:SetBackdropColor(
                    Config.bgColor.r,
                    Config.bgColor.g,
                    Config.bgColor.b,
                    Config.bgAlpha
                )
            end
        end
    end)

    -- Add frame width slider
    yPos = yPos - 40
    local frameWidthText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frameWidthText:SetPoint("TOPLEFT", 16, yPos)
    frameWidthText:SetText("Frame Width:")

    yPos = yPos - 20
    local frameWidthSlider = CreateFrame("Slider", "PeaversDynamicStatsWidthSlider", panel, "OptionsSliderTemplate")
    frameWidthSlider:SetPoint("TOPLEFT", 25, yPos)
    frameWidthSlider:SetWidth(200)
    frameWidthSlider:SetMinMaxValues(150, 400)
    frameWidthSlider:SetValueStep(10)
    frameWidthSlider:SetValue(Config.frameWidth)

    -- Set slider text
    _G[frameWidthSlider:GetName() .. "Low"]:SetText("150")
    _G[frameWidthSlider:GetName() .. "High"]:SetText("400")
    _G[frameWidthSlider:GetName() .. "Text"]:SetText(Config.frameWidth)

    frameWidthSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest 10
        value = math.floor(value / 10 + 0.5) * 10
        _G[self:GetName() .. "Text"]:SetText(value)

        Config.frameWidth = value
        Config.barWidth = value - 20  -- Adjust bar width to account for padding
        Config:Save()

        -- Update the frame width if Core is available
        if ST.Core and ST.Core.frame then
            ST.Core.frame:SetWidth(value)

            -- Update all bar widths
            if ST.Core.bars then
                for _, bar in ipairs(ST.Core.bars) do
                    bar.frame:SetWidth(value - 20)  -- Account for frame padding
                end
            end
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

    -- Check for Dragonflight+ Settings API
    if Settings and Settings.RegisterCanvasLayoutCategory then
        categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(categoryID)
    end

    -- For compatibility with pre-Dragonflight UI
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end

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
    if not self.optionsPanel then
        self.optionsPanel = self:InitializeOptions()
    end

    -- Try to use modern Settings API first
    if categoryID and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(categoryID)
    -- Fall back to pre-Dragonflight method
    elseif InterfaceAddOns and InterfaceAddOns.PeaversDynamicStats then
        InterfaceOptionsFrame_OpenToCategory("PeaversDynamicStats")
    end
end

-- Slash command handler
ST.Config.OpenOptionsCommand = function()
    Config:OpenOptions()
end