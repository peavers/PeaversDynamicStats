local _, ST = ...
local TitleBar = {}
ST.TitleBar = TitleBar

-- Creates the titlebar
function TitleBar:Create(parentFrame)
    -- Add title bar
    local titleBar = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    titleBar:SetHeight(20)
    titleBar:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        tile = true, tileSize = 16, edgeSize = 1,
    })

    -- Use the same background color as the main frame
    titleBar:SetBackdropColor(ST.Config.bgColor.r, ST.Config.bgColor.g, ST.Config.bgColor.b, ST.Config.bgAlpha)
    titleBar:SetBackdropBorderColor(0, 0, 0, 1)

    -- Add title text
    local title = titleBar:CreateFontString(nil, "OVERLAY")
    title:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    title:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    title:SetText("Secondary Stats")

    -- Set the title text to white
    title:SetTextColor(1, 1, 1)

    -- Add vertical line separator after title text
    local verticalLine = titleBar:CreateTexture(nil, "ARTWORK")
    verticalLine:SetSize(1, 16)
    verticalLine:SetPoint("LEFT", title, "RIGHT", 5, 0)
    verticalLine:SetColorTexture(0.3, 0.3, 0.3, 0.5)

    -- Add a subtitle or version
    local subtitle = titleBar:CreateFontString(nil, "OVERLAY")
    subtitle:SetFont(ST.Config.fontFace, ST.Config.fontSize, "OUTLINE")
    subtitle:SetPoint("LEFT", verticalLine, "RIGHT", 5, 0)
    subtitle:SetText("v1.0")
    subtitle:SetTextColor(0.8, 0.8, 0.8)

    return titleBar
end

-- Export the TitleBar module
return TitleBar