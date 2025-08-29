-- Professional GUI Builder (LocalScript)
-- Put this LocalScript in StarterPlayerScripts or StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Settings (in-memory). To persist across sessions use a server DataStore.
local settings = {
    theme = "Dark", -- "Dark" or "Light"
    scale = 1,
    visible = true,
    bind = Enum.KeyCode.RightShift,
    accent = Color3.fromRGB(0, 162, 255)
}

-- Helper: create UI instances quickly
local function new(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k == "Parent" then
            obj.Parent = v
        else
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

-- Root ScreenGui
local screenGui = new("ScreenGui", {Parent = player:WaitForChild("PlayerGui"), Name = "ProGUI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
screenGui.ResetOnSpawn = false

-- Main window
local window = new("Frame", {
    Parent = screenGui,
    Name = "Window",
    Size = UDim2.fromOffset(820 * settings.scale, 480 * settings.scale),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundTransparency = 0,
    Active = true
})
local corner = new("UICorner", {Parent = window, CornerRadius = UDim.new(0, 10)})
local stroke = new("UIStroke", {Parent = window, Thickness = 1})

-- Shadow (simple)
local shadow = new("ImageLabel", {
    Parent = window,
    Size = UDim2.new(1,20,1,20),
    Position = UDim2.new(0,-10,0,-10),
    BackgroundTransparency = 1,
    Image = "rbxassetid://3526301355", -- subtle shadow image
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(20,20,280,280),
    ZIndex = 0,
})
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.92

-- Header
local header = new("Frame", {Parent = window, Name = "Header", Size = UDim2.new(1,0,0,48), BackgroundTransparency = 0})
new("UICorner", {Parent = header, CornerRadius = UDim.new(0, 10)})
local headerTitle = new("TextLabel", {
    Parent = header,
    Text = "Pro GUI",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.new(0,16,0,8),
    Size = UDim2.new(0.6,0,1, -8),
    BackgroundTransparency = 1
})
local btnMin = new("TextButton", {
    Parent = header,
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    Size = UDim2.new(0,40,0,28),
    Position = UDim2.new(1,-96,0,10),
    BackgroundTransparency = 0,
})
local btnClose = new("TextButton", {
    Parent = header,
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    Size = UDim2.new(0,40,0,28),
    Position = UDim2.new(1,-48,0,10),
    BackgroundTransparency = 0,
})

-- Left sidebar (tabs)
local sidebar = new("Frame", {Parent = window, Name = "Sidebar", Size = UDim2.new(0,160,1,-48), Position = UDim2.new(0,0,0,48)})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 8)})
local tabList = new("UIListLayout", {Parent = sidebar, Padding = UDim.new(0,6), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder})
tabList.Padding = UDim.new(0,10)

-- Content area
local content = new("Frame", {Parent = window, Name = "Content", Size = UDim2.new(1, -160, 1, -48), Position = UDim2.new(0,160,0,48), BackgroundTransparency = 0})
new("UICorner", {Parent = content, CornerRadius = UDim.new(0, 8)})

-- Tab creation helper
local tabs = {}
local function createTab(name)
    local btn = new("TextButton", {
        Parent = sidebar,
        Text = name,
        Size = UDim2.new(1,-16,0,44),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BackgroundTransparency = 0
    })
    local page = new("Frame", {Parent = content, Name = name.."Page", Size = UDim2.new(1,0,1,0), Visible = false})
    new("UICorner", {Parent = page, CornerRadius = UDim.new(0,6)})
    tabs[name] = page
    return btn, page
end

-- Make some example tabs
local btnHome, pageHome = createTab("Home")
local btnSettings, pageSettings = createTab("Settings")
local btnTools, pageTools = createTab("Tools")

-- Activate default tab
local function activateTab(name)
    for k,v in pairs(tabs) do
        v.Visible = (k == name)
    end
    -- visually mark sidebar buttons
    for _,child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundTransparency = 0.9
        end
    end
end

-- wire buttons
btnHome.MouseButton1Click:Connect(function() activateTab("Home") end)
btnSettings.MouseButton1Click:Connect(function() activateTab("Settings") end)
btnTools.MouseButton1Click:Connect(function() activateTab("Tools") end)
activateTab("Home")

-- Build Home page contents
do
    local label = new("TextLabel", {Parent = pageHome, Text = "Welcome to Pro GUI", Font = Enum.Font.GothamBold, TextSize = 24, Size = UDim2.new(1, -24, 0, 40), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1})
    local subtitle = new("TextLabel", {Parent = pageHome, Text = "Professional interface with tabs, sliders, dropdowns and notifications.", Font = Enum.Font.Gotham, TextSize = 14, Position = UDim2.new(0,12,0,50), Size = UDim2.new(1,-24,0,36), BackgroundTransparency = 1})
end

-- Settings page: theme toggle and scale slider and accent
do
    local themeLabel = new("TextLabel", {Parent = pageSettings, Text = "Theme:", Font = Enum.Font.GothamBold, TextSize = 16, Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1})
    local themeBtn = new("TextButton", {Parent = pageSettings, Text = settings.theme, Position = UDim2.new(0,90,0,12), Size = UDim2.new(0,120,0,28), Font = Enum.Font.Gotham, TextSize = 14})
    themeBtn.MouseButton1Click:Connect(function()
        settings.theme = (settings.theme == "Dark") and "Light" or "Dark"
        themeBtn.Text = settings.theme
        applyTheme()
        showNotification("Theme switched to "..settings.theme)
    end)

    local scaleLabel = new("TextLabel", {Parent = pageSettings, Text = "Scale:", Font = Enum.Font.GothamBold, TextSize = 16, Position = UDim2.new(0,12,0,56), BackgroundTransparency = 1})
    local scaleSliderBg = new("Frame", {Parent = pageSettings, Position = UDim2.new(0,90,0,56), Size = UDim2.new(0,160,0,18), BackgroundTransparency = 0.6})
    new("UICorner", {Parent = scaleSliderBg, CornerRadius = UDim.new(0,8)})
    local scaleHandle = new("Frame", {Parent = scaleSliderBg, Size = UDim2.new(0.5,0,1,0)})
    new("UICorner", {Parent = scaleHandle, CornerRadius = UDim.new(0,8)})

    local draggingScale = false
    scaleHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingScale = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingScale = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingScale and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((mouse.X - scaleSliderBg.AbsolutePosition.X) / scaleSliderBg.AbsoluteSize.X, 0, 1)
            scaleHandle.Size = UDim2.new(rel,0,1,0)
            settings.scale = 0.7 + rel * 0.8 -- scale between 0.7 and 1.5
            applyScale()
        end
    end)

    -- Accent color picker (very simple: few buttons)
    local accentLabel = new("TextLabel", {Parent = pageSettings, Text = "Accent:", Font = Enum.Font.GothamBold, TextSize = 16, Position = UDim2.new(0,12,0,96), BackgroundTransparency = 1})
    local choices = {
        Color3.fromRGB(0,162,255),
        Color3.fromRGB(255,99,71),
        Color3.fromRGB(102,204,0),
        Color3.fromRGB(255,200,0)
    }
    for i,col in ipairs(choices) do
        local b = new("TextButton", {Parent = pageSettings, Size = UDim2.new(0,28,0,28), Position = UDim2.new(0,90 + (i-1)*36,0,92), Text = "", BackgroundColor3 = col})
        new("UICorner", {Parent = b, CornerRadius = UDim.new(0,6)})
        b.MouseButton1Click:Connect(function()
            settings.accent = col
            applyTheme()
            showNotification("Accent color changed")
        end)
    end
end

-- Tools page: dropdown & search example
do
    local ddLabel = new("TextLabel", {Parent = pageTools, Text = "Example Dropdown:", Font = Enum.Font.GothamBold, TextSize = 16, Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1})
    local dropdown = new("TextButton", {Parent = pageTools, Text = "Select Option ▼", Size = UDim2.new(0,220,0,36), Position = UDim2.new(0,12,0,44), Font = Enum.Font.Gotham})
    new("UICorner", {Parent = dropdown, CornerRadius = UDim.new(0,6)})
    local ddList = new("Frame", {Parent = pageTools, Position = UDim2.new(0,12,0,84), Size = UDim2.new(0,220,0,0), ClipsDescendants = true, BackgroundTransparency = 1})
    new("UICorner", {Parent = ddList, CornerRadius = UDim.new(0,6)})
    local ddLayout = new("UIListLayout", {Parent = ddList})

    local options = {"One", "Two", "Three", "Four"}
    local expanded = false
    local function setDropdownText(t)
        dropdown.Text = t.." ▼"
    end
    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        local target = expanded and #options*36 or 0
        TweenService:Create(ddList, TweenInfo.new(0.2), {Size = UDim2.new(0,220,0,target)}):Play()
    end)
    for _,opt in ipairs(options) do
        local b = new("TextButton", {Parent = ddList, Text = opt, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 0})
        b.MouseButton1Click:Connect(function()
            setDropdownText(opt)
            expanded = false
            TweenService:Create(ddList, TweenInfo.new(0.2), {Size = UDim2.new(0,220,0,0)}):Play()
            showNotification("Selected: "..opt)
        end)
    end

    -- Search box
    local searchBox = new("TextBox", {Parent = pageTools, PlaceholderText = "Search tools...", Position = UDim2.new(0,260,0,44), Size = UDim2.new(0,320,0,36), ClearTextOnFocus = false})
    new("UICorner", {Parent = searchBox, CornerRadius = UDim.new(0,6)})
    local searchResults = new("ScrollingFrame", {Parent = pageTools, Position = UDim2.new(0,260,0,84), Size = UDim2.new(0,320,0,240), CanvasSize = UDim2.new(0,0,0,0)})
    new("UIListLayout", {Parent = searchResults})
    local sampleTools = {"Fly", "Speed", "ESP", "Teleport", "AutoFarm","Music Player","Cleaner"}
    local function updateSearch(q)
        for i,v in ipairs(searchResults:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local count = 0
        for _,t in ipairs(sampleTools) do
            if q == "" or string.find(string.lower(t), string.lower(q)) then
                local b = new("TextButton", {Parent = searchResults, Text = t, Size = UDim2.new(1,0,0,36)})
                count = count + 1
                b.MouseButton1Click:Connect(function()
                    showNotification("Activated tool: "..t)
                end)
            end
        end
        searchResults.CanvasSize = UDim2.new(0,0,0, 36*count)
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() updateSearch(searchBox.Text) end)
    updateSearch("")
end

-- Notifications (toast)
function showNotification(text, duration)
    duration = duration or 3
    local n = new("Frame", {Parent = screenGui, Position = UDim2.new(1,-320,1,-120), Size = UDim2.new(0,300,0,48), BackgroundTransparency = 0})
    new("UICorner", {Parent = n, CornerRadius = UDim.new(0,8)})
    local t = new("TextLabel", {Parent = n, Text = text, Size = UDim2.new(1,-8,1,-8), Position = UDim2.new(0,8,0,4), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 14})
    n.Position = UDim2.new(1,20,1,-120)
    local tweenIn = TweenService:Create(n, TweenInfo.new(0.25), {Position = UDim2.new(1,-320,1,-120), BackgroundTransparency = 0})
    local tweenOut = TweenService:Create(n, TweenInfo.new(0.25), {Position = UDim2.new(1,20,1,-120), BackgroundTransparency = 1})
    tweenIn:Play()
    delay(duration, function()
        tweenOut:Play()
        tweenOut.Completed:Wait()
        n:Destroy()
    end)
end

-- Apply theme function
function applyTheme()
    local bg, text, translucent = nil, nil, nil
    if settings.theme == "Dark" then
        bg = Color3.fromRGB(20,20,22)
        text = Color3.fromRGB(230,230,230)
        translucent = 0.85
    else
        bg = Color3.fromRGB(245,245,245)
        text = Color3.fromRGB(20,20,20)
        translucent = 0.6
    end
    window.BackgroundColor3 = bg
    header.BackgroundColor3 = Color3.fromRGB(30,30,35)
    headerTitle.TextColor3 = settings.theme == "Dark" and Color3.fromRGB(230,230,230) or Color3.fromRGB(20,20,20)
    sidebar.BackgroundColor3 = Color3.fromRGB(40,40,44)
    content.BackgroundColor3 = Color3.fromRGB(26,26,28)
    for _,child in ipairs(window:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            child.TextColor3 = text
        end
        if child:IsA("Frame") and child.Name ~= "Window" and child.Parent ~= screenGui then
            -- lighten inner frames slightly for contrast
            child.BackgroundTransparency = 0.8
        end
    end
    -- Accent color applied to strokes
    stroke.Color = settings.accent
    headerTitle.TextColor3 = text
end

-- Apply scale
function applyScale()
    local targetSize = UDim2.fromOffset(820 * settings.scale, 480 * settings.scale)
    local targetPos = UDim2.new(0.5, -410 * settings.scale, 0.5, -240 * settings.scale)
    TweenService:Create(window, TweenInfo.new(0.18), {Size = targetSize, Position = targetPos}):Play()
end

-- Draggable header (smooth)
do
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = nil

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging and startPos then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                window.Position = newPos
            end
        end
    end)
end

-- Minimize & close
local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(content, TweenInfo.new(0.18), {Size = UDim2.new(content.Size.X.Scale, content.Size.X.Offset, 0,0)}):Play()
        TweenService:Create(window, TweenInfo.new(0.18), {Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0,48)}):Play()
    else
        applyScale()
        TweenService:Create(content, TweenInfo.new(0.18), {Size = UDim2.new(1, -160, 1, -48)}):Play()
    end
end)
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Keyboard toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == settings.bind then
        settings.visible = not settings.visible
        local target = settings.visible and 1 or 0
        TweenService:Create(window, TweenInfo.new(0.18), {Position = settings.visible and window.Position or UDim2.new(window.Position.X.Scale, window.Position.X.Offset, 1.2, 0)}):Play()
        window.Visible = true
        if not settings.visible then
            delay(0.2, function() window.Visible = false end)
        end
    end
end)

-- Simple apply at start
applyTheme()
applyScale()

-- Show startup notification
showNotification("Pro GUI loaded. Press RightShift to toggle.")

-- Example: expose a public API for other local scripts (optional)
local API = {}
function API.Show(msg) showNotification(msg) end
screenGui:SetAttribute("ProGUI_API", true)
screenGui:GetAttributeChangedSignal("ProGUI_API"):Connect(function() end) -- dummy

-- End of script
