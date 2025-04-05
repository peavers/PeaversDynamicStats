local _, PDS = ...
local Support = {}
PDS.Support = Support

-- Constants for the support information
Support.GITHUB_URL = "https://github.com/Extends"
Support.ISSUE_TRACKER_URL = "https://github.com/Extends/issues"
Support.DISCORD_URL = "https://discord.gg/extends"
Support.PATREON_URL = "https://www.patreon.com/extends"
Support.INGAME_NAME = "Extends"
Support.BATTLE_TAG = "Extends#1234"

-- Creates and initializes the Support tab in the options panel
function Support:InitializeOptions()
    -- Create the panel
    local panel = CreateFrame("Frame")
    panel.name = "Support"
    panel.parent = "PeaversDynamicStats"

    -- Set a specific size for the panel to ensure content is visible
    panel:SetSize(600, 500)

    -- Create a background texture that covers the entire panel
    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(panel)
    background:SetTexture("Interface\\AddOns\\" .. PDS.addonName .. "\\src\\Media\\Icon.tga")
    background:SetAlpha(0.2) -- Slight opacity as requested

    -- Create a scroll frame for the content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    -- Create the content frame with a specific width to match the scroll frame
    local content = CreateFrame("Frame")
    content:SetWidth(scrollFrame:GetWidth())
    content:SetHeight(500) -- Initial height, will be adjusted later
    scrollFrame:SetScrollChild(content)

    -- Add a visible background to the content frame for debugging
    local contentBg = content:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints(content)
    contentBg:SetColorTexture(0, 0, 0, 0.1) -- Very light black background to verify visibility

    -- Title and description
    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Support " .. PDS.addonName)
    title:SetTextColor(1, 0.84, 0) -- Gold color for title

    local description = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", 20, -50)
    description:SetWidth(scrollFrame:GetWidth() - 40)
    description:SetJustifyH("LEFT")
    description:SetText("Thank you for using " .. PDS.addonName .. "! If you enjoy this addon and would like to support its development, here are some ways you can help:")

    -- Create support links
    local yPos = -90

    -- Helper function to create links
    local function CreateLink(text, url, yPosition)
        local linkButton = CreateFrame("Button", nil, content)
        linkButton:SetSize(scrollFrame:GetWidth() - 40, 30)
        linkButton:SetPoint("TOPLEFT", 20, yPosition)

        -- Add a highlight texture to make the button more visible
        local highlight = linkButton:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(linkButton)
        highlight:SetColorTexture(1, 1, 1, 0.1)

        local linkText = linkButton:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        linkText:SetPoint("LEFT", 0, 0)
        linkText:SetText(text)
        linkText:SetTextColor(0.2, 0.6, 1) -- Blue color for links

        -- Create highlight effect on hover
        linkButton:SetScript("OnEnter", function()
            linkText:SetTextColor(0.4, 0.8, 1) -- Lighter blue on hover
        end)

        linkButton:SetScript("OnLeave", function()
            linkText:SetTextColor(0.2, 0.6, 1) -- Back to normal blue
        end)

        -- Copy URL to clipboard on click
        linkButton:SetScript("OnClick", function()
            -- Create an editbox for copying
            local editBox = CreateFrame("EditBox", nil, UIParent)
            editBox:SetMultiLine(false)
            editBox:SetMaxLetters(0)
            editBox:SetAutoFocus(true)
            editBox:SetFontObject(ChatFontNormal)
            editBox:SetWidth(scrollFrame:GetWidth())
            editBox:SetHeight(30)
            editBox:SetText(url)
            editBox:HighlightText()

            -- Position the editbox centered on screen
            editBox:SetPoint("CENTER", UIParent, "CENTER")

            -- Add a background to make it visible
            local bg = editBox:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(editBox)
            bg:SetColorTexture(0, 0, 0, 0.8)

            -- Add a border
            local border = CreateFrame("Frame", nil, editBox)
            border:SetPoint("TOPLEFT", editBox, "TOPLEFT", -2, 2)
            border:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 2, -2)
            border:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 },
            })

            editBox:SetScript("OnEscapePressed", function() editBox:Hide() end)
            editBox:SetScript("OnEnterPressed", function() editBox:Hide() end)
            editBox:SetScript("OnEditFocusLost", function() editBox:Hide() end)
            editBox:Show()

            -- Print a message to chat
            print("URL copied to clipboard: " .. url)
        end)

        return linkButton, yPosition - 30
    end

    -- GitHub link
    local _, newY = CreateLink("GitHub: " .. Support.GITHUB_URL, Support.GITHUB_URL, yPos)
    yPos = newY

    -- Issue Tracker link
    local _, newY = CreateLink("Issue Tracker: " .. Support.ISSUE_TRACKER_URL, Support.ISSUE_TRACKER_URL, yPos)
    yPos = newY

    -- Discord link
    local _, newY = CreateLink("Discord: " .. Support.DISCORD_URL, Support.DISCORD_URL, yPos)
    yPos = newY

    -- Patreon link
    local _, newY = CreateLink("Patreon: " .. Support.PATREON_URL, Support.PATREON_URL, yPos)
    yPos = newY - 20

    -- In-game information
    local ingameTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ingameTitle:SetPoint("TOPLEFT", 20, yPos)
    ingameTitle:SetText("In-Game Support:")
    ingameTitle:SetTextColor(1, 0.84, 0) -- Gold color
    yPos = yPos - 30

    local ingameInfo = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    ingameInfo:SetPoint("TOPLEFT", 20, yPos)
    ingameInfo:SetWidth(scrollFrame:GetWidth() - 40)
    ingameInfo:SetJustifyH("LEFT")
    ingameInfo:SetText("You can also support me in-game by sending gold or items to:")
    yPos = yPos - 30

    local ingameName = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ingameName:SetPoint("TOPLEFT", 40, yPos)
    ingameName:SetText("Character Name: " .. Support.INGAME_NAME)
    yPos = yPos - 20

    local battleTag = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    battleTag:SetPoint("TOPLEFT", 40, yPos)
    battleTag:SetText("Battle Tag: " .. Support.BATTLE_TAG)
    yPos = yPos - 40

    -- Thank you message
    local thankYou = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    thankYou:SetPoint("TOPLEFT", 20, yPos)
    thankYou:SetWidth(scrollFrame:GetWidth() - 40)
    thankYou:SetJustifyH("CENTER")
    thankYou:SetText("Thank you for your support!")
    thankYou:SetTextColor(0, 1, 0) -- Green color

    -- Adjust content height based on the last element position
    content:SetHeight(math.abs(yPos) + 60)

    -- Event handler for when the panel becomes visible
    panel:SetScript("OnShow", function()
        -- Force scrollframe to update
        scrollFrame:UpdateScrollChildRect()

        -- Log to chat that the panel is shown (for debugging)
        print(PDS.addonName .. ": Support panel is now visible")
    end)

    -- This is the part that needs to change - use the modern Settings API consistently
    if Settings and Settings.RegisterCanvasLayoutSubcategory then
        -- Make sure the main category ID exists
        if PDS.Config and PDS.Config.categoryID then
            -- The key change is here - we need to register directly to the main category
            local subcategoryID = Settings.RegisterCanvasLayoutSubcategory(PDS.Config.categoryID, panel, panel.name)
            -- Store the subcategoryID for future reference
            PDS.Support.subcategoryID = subcategoryID

            -- Register the panel for display - this is crucial for the content to show
            Settings.RegisterAddOnCategory(subcategoryID)
        else
            -- Log an error to help with debugging
            print(PDS.addonName .. ": Error - Main category ID not found when registering Support tab")
            -- Fallback if needed
            local categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
            Settings.RegisterAddOnCategory(categoryID)
        end
    else
        -- Fallback for older versions
        InterfaceOptions_AddCategory(panel)
    end

    return panel
end

-- Initialize the Support tab when the addon loads
function Support:Initialize()
    self:InitializeOptions()

    -- Print a message when initialization is complete
    print(PDS.addonName .. ": Support module initialized")
end

return Support
