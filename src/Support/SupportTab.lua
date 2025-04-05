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

    -- Create a background texture that covers the entire panel
    local background = panel:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(panel)
    background:SetTexture("Interface\\AddOns\\" .. PDS.addonName .. "\\src\\Media\\Icon.tga")
    background:SetAlpha(0.2) -- Slight opacity as requested

    -- Create a scroll frame for the content
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame")
    scrollFrame:SetScrollChild(content)
    content:SetSize(scrollFrame:GetWidth(), 500) -- Height will be adjusted based on content

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
            local editBox = CreateFrame("EditBox", nil, linkButton)
            editBox:SetMultiLine(false)
            editBox:SetMaxLetters(0)
            editBox:SetAutoFocus(true)
            editBox:SetFontObject(ChatFontNormal)
            editBox:SetWidth(1)
            editBox:SetHeight(1)
            editBox:SetText(url)
            editBox:HighlightText()
            editBox:SetScript("OnEscapePressed", function() editBox:Hide() end)
            editBox:SetScript("OnEnterPressed", function() editBox:Hide() end)
            editBox:SetScript("OnEditFocusLost", function() editBox:Hide() end)
            editBox:Show()
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

	-- Register with the Interface Options as a subcategory
	if Settings and Settings.RegisterCanvasLayoutSubcategory then
		-- Register as a subcategory of the main addon settings
		if PDS.Config.categoryID then
			local subcategoryID = Settings.RegisterCanvasLayoutSubcategory(PDS.Config.categoryID, panel)
			Settings.RegisterAddOnCategory(subcategoryID)
		else
			-- Fallback: register as a separate category if the main category ID is not available
			local categoryID = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
			Settings.RegisterAddOnCategory(categoryID)
		end
	else
		-- Fallback for older versions or if Settings API is not available
		InterfaceOptions_AddCategory(panel)
	end

	return panel
end

-- Initialize the Support tab when the addon loads
function Support:Initialize()
    self:InitializeOptions()
end

return Support
