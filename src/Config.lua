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
    lockPosition = false, -- New option

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
    showTitleBar = true,
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

-- Safe text setting function
local function SetText(fontString, text)
    if fontString and type(text) == "string" then
        fontString:SetText(text)
        return true
    end
    return false
end

-- Safe global access function
local function GetGlobal(name)
    if name and type(name) == "string" then
        return _G[name]
    end
    return nil
end

-- Add to the Config:Save() function:
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
    PeaversDynamicStatsDB.bgAlpha = self.bgAlpha
    PeaversDynamicStatsDB.bgColor = self.bgColor
    PeaversDynamicStatsDB.showStats = self.showStats
    PeaversDynamicStatsDB.barSpacing = self.barSpacing
    PeaversDynamicStatsDB.showTitleBar = self.showTitleBar
    PeaversDynamicStatsDB.lockPosition = self.lockPosition -- New line
end

-- Add to the Config:Load() function:
function Config:Load()
    if not PeaversDynamicStatsDB then return end

    if PeaversDynamicStatsDB.fontFace then self.fontFace = PeaversDynamicStatsDB.fontFace end
    if PeaversDynamicStatsDB.framePoint then self.framePoint = PeaversDynamicStatsDB.framePoint end
    if PeaversDynamicStatsDB.frameX then self.frameX = PeaversDynamicStatsDB.frameX end
    if PeaversDynamicStatsDB.frameY then self.frameY = PeaversDynamicStatsDB.frameY end
    if PeaversDynamicStatsDB.frameWidth then self.frameWidth = PeaversDynamicStatsDB.frameWidth end
    if PeaversDynamicStatsDB.barWidth then self.barWidth = PeaversDynamicStatsDB.barWidth end
    if PeaversDynamicStatsDB.barHeight then self.barHeight = PeaversDynamicStatsDB.barHeight end
    if PeaversDynamicStatsDB.barTexture then self.barTexture = PeaversDynamicStatsDB.barTexture end
    if PeaversDynamicStatsDB.bgAlpha then self.bgAlpha = PeaversDynamicStatsDB.bgAlpha end
    if PeaversDynamicStatsDB.bgColor then self.bgColor = PeaversDynamicStatsDB.bgColor end
    if PeaversDynamicStatsDB.showStats then self.showStats = PeaversDynamicStatsDB.showStats end
    if PeaversDynamicStatsDB.barSpacing then self.barSpacing = PeaversDynamicStatsDB.barSpacing end
    if PeaversDynamicStatsDB.showTitleBar ~= nil then self.showTitleBar = PeaversDynamicStatsDB.showTitleBar end
    if PeaversDynamicStatsDB.lockPosition ~= nil then self.lockPosition = PeaversDynamicStatsDB.lockPosition end -- New line
end


local function CreateScrollFrame(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -16)  -- Move up to capture the whole area
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)
    content:SetWidth(scrollFrame:GetWidth() - 16)
    content:SetHeight(1) -- Will be adjusted dynamically

    return scrollFrame, content
end

function Config:InitializeOptions()
    local panel = CreateFrame("Frame")
    panel.name = "PeaversDynamicStats"

    -- Create scrolling content frame
    local scrollFrame, content = CreateScrollFrame(panel)

    -- Move title and subtitle inside the content frame
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
    yPos = yPos - 40  -- Extra space after subtitle

    -- Helper function to create a stat checkbox
    local function CreateStatCheckbox(statKey, statName, yPos)
        local checkbox = CreateFrame("CheckButton", "PeaversStat"..statKey.."Checkbox", content, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 25, yPos)

        -- Get and set the text
        local textObj = checkbox.Text
        if not textObj and checkbox:GetName() then
            textObj = GetGlobal(checkbox:GetName().."Text")
        end

        if textObj then
            textObj:SetText(statName)
            textObj:SetTextColor(1, 0.82, 0)  -- Gold color
        end

        -- Set the initial state
        if Config.showStats[statKey] ~= nil then
            checkbox:SetChecked(Config.showStats[statKey])
        end

        -- OnClick handler
        checkbox:SetScript("OnClick", function(self)
            Config.showStats[statKey] = self:GetChecked()
            Config:Save()
            if ST.Core and ST.Core.CreateBars then
                ST.Core:CreateBars()
            end
        end)

        return checkbox
    end

    -- General section
    local generalText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    generalText:SetPoint("TOPLEFT", 25, yPos)  -- Aligned with content
    generalText:SetText("General")
    generalText:SetTextColor(1, 0.82, 0)
    generalText:SetWidth(400)  -- Gold color

    -- Stat checkboxes
    yPos = yPos - 25
    CreateStatCheckbox("HASTE", "Haste", yPos)
    yPos = yPos - 25
    CreateStatCheckbox("CRIT", "Critical Strike", yPos)
    yPos = yPos - 25
    CreateStatCheckbox("MASTERY", "Mastery", yPos)
    yPos = yPos - 25
    CreateStatCheckbox("VERSATILITY", "Versatility", yPos)
    yPos = yPos - 50  -- Extra spacing between sections

    -- Bar Settings section
    local barSettingsText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    barSettingsText:SetPoint("TOPLEFT", 25, yPos)  -- Aligned with content
    barSettingsText:SetText("Bar Settings")
    barSettingsText:SetTextColor(1, 0.82, 0)
    barSettingsText:SetWidth(400)  -- Gold color
    yPos = yPos - 25

    -- Bar spacing slider
    local spacingLabel = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    spacingLabel:SetPoint("TOPLEFT", 25, yPos)
    spacingLabel:SetText("Bar Spacing: " .. Config.barSpacing)
    yPos = yPos - 20

    local spacingSlider = CreateFrame("Slider", "PeaversSpacingSlider", content, "OptionsSliderTemplate")
    spacingSlider:SetPoint("TOPLEFT", 25, yPos)
    spacingSlider:SetWidth(400)
    spacingSlider:SetMinMaxValues(-5, 10)
    spacingSlider:SetValueStep(1)
    spacingSlider:SetValue(Config.barSpacing)

    -- Get slider text elements
    local     sliderName = spacingSlider:GetName()
    if sliderName then
        local lowText = GetGlobal(sliderName.."Low")
        local highText = GetGlobal(sliderName.."High")
        local valueText = GetGlobal(sliderName.."Text")

        if lowText then lowText:SetText("") end
        if highText then highText:SetText("") end
        if valueText then valueText:SetText("") end
    end

    spacingSlider:SetScript("OnValueChanged", function(self, value)
        local roundedValue = math.floor(value + 0.5)
        spacingLabel:SetText("Bar Spacing: " .. roundedValue)
        Config.barSpacing = roundedValue
        Config:Save()
        if ST.Core and ST.Core.CreateBars then
            ST.Core:CreateBars()
        end
    end)

    yPos = yPos - 40

    -- Bar height slider
    local heightLabel = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    heightLabel:SetPoint("TOPLEFT", 25, yPos)
    heightLabel:SetText("Bar Height: " .. Config.barHeight)
    yPos = yPos - 20

    local heightSlider = CreateFrame("Slider", "PeaversHeightSlider", content, "OptionsSliderTemplate")
    heightSlider:SetPoint("TOPLEFT", 25, yPos)
    heightSlider:SetWidth(400)
    heightSlider:SetMinMaxValues(10, 40)
    heightSlider:SetValueStep(1)
    heightSlider:SetValue(Config.barHeight)

    sliderName = heightSlider:GetName()
    if sliderName then
        local lowText = GetGlobal(sliderName.."Low")
        local highText = GetGlobal(sliderName.."High")
        local valueText = GetGlobal(sliderName.."Text")

        if lowText then lowText:SetText("") end
        if highText then highText:SetText("") end
        if valueText then valueText:SetText("") end
    end

    heightSlider:SetScript("OnValueChanged", function(self, value)
        local roundedValue = math.floor(value + 0.5)
        heightLabel:SetText("Bar Height: " .. roundedValue)
        Config.barHeight = roundedValue
        Config:Save()
        if ST.Core and ST.Core.CreateBars then
            ST.Core:CreateBars()
        end
    end)

    yPos = yPos - 40

    -- Frame width slider
    local widthLabel = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    widthLabel:SetPoint("TOPLEFT", 25, yPos)
    widthLabel:SetText("Frame Width: " .. Config.frameWidth)
    yPos = yPos - 20

    local widthSlider = CreateFrame("Slider", "PeaversWidthSlider", content, "OptionsSliderTemplate")
    widthSlider:SetPoint("TOPLEFT", 25, yPos)
    widthSlider:SetWidth(400)
    widthSlider:SetMinMaxValues(150, 400)
    widthSlider:SetValueStep(10)
    widthSlider:SetValue(Config.frameWidth)

    sliderName = widthSlider:GetName()
    if sliderName then
        local lowText = GetGlobal(sliderName.."Low")
        local highText = GetGlobal(sliderName.."High")
        local valueText = GetGlobal(sliderName.."Text")

        if lowText then lowText:SetText("") end
        if highText then highText:SetText("") end
        if valueText then valueText:SetText("") end
    end

    widthSlider:SetScript("OnValueChanged", function(self, value)
        local roundedValue = math.floor(value / 10 + 0.5) * 10
        widthLabel:SetText("Frame Width: " .. roundedValue)
        Config.frameWidth = roundedValue
        Config.barWidth = roundedValue - 20
        Config:Save()
        if ST.Core and ST.Core.frame then
            ST.Core.frame:SetWidth(roundedValue)
            if ST.Core.bars then
                for _, bar in ipairs(ST.Core.bars) do
                    bar:UpdateWidth()
                end
            end
        end
    end)

    yPos = yPos - 50  -- Extra spacing between sections

    -- Visual Settings section
    local visualText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    visualText:SetPoint("TOPLEFT", 25, yPos)  -- Aligned with content
    visualText:SetText("Visual Settings")
    visualText:SetTextColor(1, 0.82, 0)
    visualText:SetWidth(400)  -- Gold color
    yPos = yPos - 25

    -- Add title bar checkbox
    local titleBarCheckbox = CreateFrame("CheckButton", "PeaversTitleBarCheckbox", content, "InterfaceOptionsCheckButtonTemplate")
    titleBarCheckbox:SetPoint("TOPLEFT", 25, yPos)

    -- Get and set the text
    local textObj = titleBarCheckbox.Text
    if not textObj and titleBarCheckbox:GetName() then
        textObj = GetGlobal(titleBarCheckbox:GetName().."Text")
    end

    if textObj then
        textObj:SetText("Show Title Bar")
        textObj:SetTextColor(1, 1, 1)  -- White color
    end

    -- Set the initial state
    titleBarCheckbox:SetChecked(Config.showTitleBar)

    -- OnClick handler
    titleBarCheckbox:SetScript("OnClick", function(self)
        Config.showTitleBar = self:GetChecked()
        Config:Save()
        if ST.Core then
            ST.Core:UpdateTitleBarVisibility()
        end
    end)

    yPos = yPos - 30  -- Move down for next element

    -- Lock position checkbox
    local lockPositionCheckbox = CreateFrame("CheckButton", "PeaversLockPositionCheckbox", content, "InterfaceOptionsCheckButtonTemplate")
    lockPositionCheckbox:SetPoint("TOPLEFT", 25, yPos)

    -- Get and set the text
    local textObj = lockPositionCheckbox.Text
    if not textObj and lockPositionCheckbox:GetName() then
        textObj = GetGlobal(lockPositionCheckbox:GetName().."Text")
    end

    if textObj then
        textObj:SetText("Lock Frame Position")
        textObj:SetTextColor(1, 1, 1)  -- White color
    end

    -- Set the initial state
    lockPositionCheckbox:SetChecked(Config.lockPosition)

    -- OnClick handler
    lockPositionCheckbox:SetScript("OnClick", function(self)
        Config.lockPosition = self:GetChecked()
        Config:Save()
        if ST.Core then
            ST.Core:UpdateFrameLock()
        end
    end)

    yPos = yPos - 30  -- Move down for next element

    -- Background opacity slider
    local opacityLabel = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    opacityLabel:SetPoint("TOPLEFT", 25, yPos)
    opacityLabel:SetText("Background Opacity: " .. math.floor(Config.bgAlpha * 100) .. "%")
    yPos = yPos - 20

    local opacitySlider = CreateFrame("Slider", "PeaversOpacitySlider", content, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", 25, yPos)
    opacitySlider:SetWidth(400)
    opacitySlider:SetMinMaxValues(0, 1)
    opacitySlider:SetValueStep(0.05)
    opacitySlider:SetValue(Config.bgAlpha)

    sliderName = opacitySlider:GetName()
    if sliderName then
        local lowText = GetGlobal(sliderName.."Low")
        local highText = GetGlobal(sliderName.."High")
        local valueText = GetGlobal(sliderName.."Text")

        if lowText then lowText:SetText("") end
        if highText then highText:SetText("") end
        if valueText then valueText:SetText("") end
    end

    opacitySlider:SetScript("OnValueChanged", function(self, value)
        local roundedValue = math.floor(value * 20 + 0.5) / 20
        opacityLabel:SetText("Background Opacity: " .. math.floor(roundedValue * 100) .. "%")
        Config.bgAlpha = roundedValue
        Config:Save()
        if ST.Core and ST.Core.frame then
            ST.Core.frame:SetBackdropColor(
                Config.bgColor.r,
                Config.bgColor.g,
                Config.bgColor.b,
                Config.bgAlpha
            )
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

    yPos = yPos - 40

    -- Bar texture dropdown
    local textureText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    textureText:SetPoint("TOPLEFT", 25, yPos)
    textureText:SetText("Bar Texture:")
    textureText:SetTextColor(1, 0.82, 0)  -- Gold color
    yPos = yPos - 25

    local textureDropdown = CreateFrame("Frame", "PeaversTextureDropdown", content, "UIDropDownMenuTemplate")
    textureDropdown:SetPoint("TOPLEFT", 25, yPos)
    UIDropDownMenu_SetWidth(textureDropdown, 360)

    local textures = self:GetBarTextures()
    local currentTexture = textures[self.barTexture] or "Default"
    UIDropDownMenu_SetText(textureDropdown, currentTexture)

    UIDropDownMenu_Initialize(textureDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for path, name in pairs(textures) do
            info.text = name
            info.checked = (path == Config.barTexture)
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

    yPos = yPos - 40

    -- Font dropdown
    local fontText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontText:SetPoint("TOPLEFT", 25, yPos)
    fontText:SetText("Font:")
    fontText:SetTextColor(1, 0.82, 0)  -- Gold color
    yPos = yPos - 25

    local fontDropdown = CreateFrame("Frame", "PeaversFontDropdown", content, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", 25, yPos)
    UIDropDownMenu_SetWidth(fontDropdown, 360)

    local fonts = self:GetFonts()
    local currentFont = fonts[self.fontFace] or "Default"
    UIDropDownMenu_SetText(fontDropdown, currentFont)

    UIDropDownMenu_Initialize(fontDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for path, name in pairs(fonts) do
            info.text = name
            info.checked = (path == Config.fontFace)
            info.func = function()
                Config.fontFace = path
                UIDropDownMenu_SetText(fontDropdown, name)
                Config:Save()
                if ST.Core and ST.Core.CreateBars then
                    ST.Core:CreateBars()
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Update content height based on the last element position
    content:SetHeight(math.abs(yPos) + 50)

    -- Register with the Interface Options
    if Settings and Settings.RegisterCanvasLayoutCategory then
        categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(categoryID)
    else
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
    elseif InterfaceOptions_AddCategory then
        -- Workaround for Blizzard bug where first call may not properly focus category
        InterfaceOptionsFrame_OpenToCategory("PeaversDynamicStats")
        InterfaceOptionsFrame_OpenToCategory("PeaversDynamicStats")
    end
end

-- Slash command handler
ST.Config.OpenOptionsCommand = function()
    Config:OpenOptions()
end