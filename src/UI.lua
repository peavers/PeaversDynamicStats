--[[
    UI.lua - UI utility class for StatTracker
]]

local addonName, ST = ...

-- Create UI namespace
ST.UI = {}

-- Initialize UI class
local UI = ST.UI
local UIMetatable = {}

-- Safe global access function
local function GetGlobal(name)
    if name and type(name) == "string" then
        return _G[name]
    end
    return nil
end

-- Create a section header
function UI:CreateSectionHeader(parent, text, x, y)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetPoint("TOPLEFT", x, y)
    header:SetText(text)
    header:SetWidth(400)
    return header, y - 25 -- Return new y position
end

-- Create a label
function UI:CreateLabel(parent, text, x, y, fontObject)
    local label = parent:CreateFontString(nil, "ARTWORK", fontObject or "GameFontHighlight")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(text)
    return label, y - 20 -- Return new y position
end

-- Create a checkbox
function UI:CreateCheckbox(parent, name, text, x, y, initialValue, textColor, onClick)
    local checkbox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)

    -- Get and set the text
    local textObj = checkbox.Text
    if not textObj and checkbox:GetName() then
        textObj = GetGlobal(checkbox:GetName().."Text")
    end

    if textObj then
        textObj:SetText(text)
        if textColor then
            textObj:SetTextColor(textColor[1], textColor[2], textColor[3])
        end
    end

    -- Set initial state
    if initialValue ~= nil then
        checkbox:SetChecked(initialValue)
    end

    -- Set onClick handler
    if onClick then
        checkbox:SetScript("OnClick", onClick)
    end

    return checkbox, y - 25 -- Return new y position
end

-- Create a slider
function UI:CreateSlider(parent, name, minVal, maxVal, step, x, y, initialValue, width)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetWidth(width or 400)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetValue(initialValue)

    -- Clear default text elements
    local sliderName = slider:GetName()
    if sliderName then
        local lowText = GetGlobal(sliderName.."Low")
        local highText = GetGlobal(sliderName.."High")
        local valueText = GetGlobal(sliderName.."Text")

        if lowText then lowText:SetText("") end
        if highText then highText:SetText("") end
        if valueText then valueText:SetText("") end
    end

    return slider, y - 40 -- Return new y position
end

-- Create a dropdown
function UI:CreateDropdown(parent, name, x, y, width, initialText)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    UIDropDownMenu_SetWidth(dropdown, width or 360)

    if initialText then
        UIDropDownMenu_SetText(dropdown, initialText)
    end

    return dropdown, y - 40 -- Return new y position
end

-- Create scrollable frame
function UI:CreateScrollFrame(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -16)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)
    content:SetWidth(scrollFrame:GetWidth() - 16)
    content:SetHeight(1) -- Will be adjusted dynamically

    return scrollFrame, content
end

-- Create a basic frame
function UI:CreateFrame(name, parent, width, height, backdrop)
    local frame = CreateFrame("Frame", name, parent, backdrop and "BackdropTemplate" or nil)

    if width and height then
        frame:SetSize(width, height)
    end

    if backdrop then
        frame:SetBackdrop(backdrop)
    end

    return frame
end

-- Create a button
function UI:CreateButton(parent, name, text, x, y, width, height, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width or 100, height or 22)
    button:SetText(text)

    if onClick then
        button:SetScript("OnClick", onClick)
    end

    return button, y - (height or 22) - 5
end

-- Create a color picker
function UI:CreateColorPicker(parent, name, label, x, y, initialColor, onChange)
    local colorFrame = CreateFrame("Button", name, parent, "BackdropTemplate")
    colorFrame:SetPoint("TOPLEFT", x, y)
    colorFrame:SetSize(16, 16)
    colorFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })

    -- Set initial color
    if initialColor then
        colorFrame:SetBackdropColor(initialColor.r, initialColor.g, initialColor.b)
    else
        colorFrame:SetBackdropColor(1, 1, 1)
    end

    -- Create label
    local colorLabel
    if label then
        colorLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        colorLabel:SetPoint("LEFT", colorFrame, "RIGHT", 5, 0)
        colorLabel:SetText(label)
    end

    -- Set onclick handler for color picker
    colorFrame:SetScript("OnClick", function()
        local function ColorCallback(restore)
            local newR, newG, newB
            if restore then
                -- User canceled, use previous values
                newR, newG, newB = unpack(restore)
            else
                -- Get the new values
                newR, newG, newB = ColorPickerFrame:GetColorRGB()
            end

            -- Update button color
            colorFrame:SetBackdropColor(newR, newG, newB)

            -- Call onChange handler if provided
            if onChange then
                onChange(newR, newG, newB)
            end
        end

        -- Get current color
        local r, g, b = colorFrame:GetBackdropColor()

        -- Open color picker
        ColorPickerFrame.func = ColorCallback
        ColorPickerFrame.cancelFunc = ColorCallback
        ColorPickerFrame.opacityFunc = nil
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = {r, g, b}
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame:Hide() -- Hide first to trigger OnShow handler
        ColorPickerFrame:Show()
    end)

    return colorFrame, colorLabel, y - 25
end

-- Set metatable to create OOP-like behavior
setmetatable(UI, UIMetatable)

-- Return the UI namespace
return UI