--// ScriptHub Pro GUI - LocalScript by ChatGPT (Arabic)
--// المكان المناسب: StarterPlayerScripts أو StarterGui
--// يعتمد على ModuleScripts داخل ReplicatedStorage.ScriptHubModules
--// جميع الإعدادات هنا تحفظ "لجلسة اللعب" فقط (وليس عبر الداتا ستور)

--== الخدمات ==--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--== ثابت المجلدات ==--
local MODULES_FOLDER_NAME = "ScriptHubModules"
local SNIPPETS_FOLDER_NAME = "ScriptHubSnippets"

--== ثيمات ==--
local Themes = {
    Dark = {
        Bg = Color3.fromRGB(22,22,24),
        Panel = Color3.fromRGB(33,34,38),
        Accent = Color3.fromRGB(0,162,255),
        Text = Color3.fromRGB(235,235,240),
        Subtle = Color3.fromRGB(140,140,150)
    },
    Light = {
        Bg = Color3.fromRGB(245,246,250),
        Panel = Color3.fromRGB(230,232,238),
        Accent = Color3.fromRGB(0,120,215),
        Text = Color3.fromRGB(25,27,33),
        Subtle = Color3.fromRGB(95,98,110)
    }
}

--== تفضيلات الجلسة ==--
local SessionState = {
    Theme = "Dark",
    Pos = UDim2.new(0.2,0,0.2,0),
    Size = UDim2.new(0, 560, 0, 360),
    Visible = true,
    LastTab = "Modules",
    EnabledModules = {} -- [moduleId] = true/false
}

-- محاولة استرجاع من قيمة مخزّنة في PlayerGui (لجلسة واحدة)
local function tryLoadSession()
    local pgui = LocalPlayer:WaitForChild("PlayerGui", 5)
    if not pgui then return end
    local holder = pgui:FindFirstChild("ScriptHubSession")
    if holder and holder:IsA("StringValue") then
        local ok, data = pcall(function() return HttpService:JSONDecode(holder.Value) end)
        if ok and typeof(data) == "table" then
            for k,v in pairs(data) do SessionState[k] = v end
        end
    end
end

local function saveSession()
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pgui then return end
    local holder = pgui:FindFirstChild("ScriptHubSession")
    if not holder then
        holder = Instance.new("StringValue")
        holder.Name = "ScriptHubSession"
        holder.Parent = pgui
    end
    holder.Value = HttpService:JSONEncode(SessionState)
end

tryLoadSession()

--== أدوات واجهة ==--
local function mk(instance, props, children)
    local obj = Instance.new(instance)
    for k,v in pairs(props or {}) do obj[k] = v end
    for _,c in ipairs(children or {}) do c.Parent = obj end
    return obj
end

local function corner(parent, radius)
    mk("UICorner",{CornerRadius = UDim.new(0, radius or 8)},{}).Parent = parent
end

local function stroke(parent, t)
    mk("UIStroke",{
        Thickness = t or 1,
        Transparency = 0.5,
        Color = Color3.fromRGB(0,0,0),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    },{}).Parent = parent
end

local function padding(parent, p)
    mk("UIPadding",{
        PaddingTop = UDim.new(0,p), PaddingBottom = UDim.new(0,p),
        PaddingLeft = UDim.new(0,p), PaddingRight = UDim.new(0,p)
    },{}).Parent = parent
end

--== إشعارات ==--
local Notifications
do
    local queue = {}
    local holder
    local function ensure(parent)
        if holder and holder.Parent then return end
        holder = mk("Frame",{
            Name="NotifyHolder", BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1,1),
            Size = UDim2.new(0, 320, 1, -20),
            Position = UDim2.new(1,-10,1,-10)
        },{})
        holder.Parent = parent
    end
    local function push(parent, text, theme)
        ensure(parent)
        local f = mk("Frame",{
            BackgroundColor3 = theme.Panel, Size = UDim2.new(1,0,0,0),
            AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true
        },{
            mk("TextLabel",{
                BackgroundTransparency = 1, TextWrapped = true,
                RichText = true, Font = Enum.Font.GothamMedium, TextSize = 14,
                TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,10,0,8),
                Text = text
            },{})
        })
        corner(f,8); stroke(f,1)
        f.Parent = holder
        f.Position = UDim2.new(1,10,1,0)
        TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(1,0,1,0)}):Play()
        task.delay(3, function()
            if f and f.Parent then
                TweenService:Create(f, TweenInfo.new(0.25), {Position = UDim2.new(1,10,1,0)}):Play()
                task.wait(0.26); f:Destroy()
            end
        end)
    end
    Notifications = {Show = push}
end

--== الجذر ==--
local gui = mk("ScreenGui",{Name = "ScriptHubPro", ResetOnSpawn = false, IgnoreGuiInset = true},{})
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--== نافذة رئيسية ==--
local theme = Themes[SessionState.Theme] or Themes.Dark

local root = mk("Frame",{
    Name="Root",
    BackgroundColor3 = theme.Bg,
    Size = SessionState.Size,
    Position = SessionState.Pos,
    Active = true, Draggable = true -- سحب
},{}); corner(root,10); stroke(root,1); root.Parent = gui

--== شريط علوي ==--
local topbar = mk("Frame",{
    BackgroundColor3 = theme.Panel,
    Size = UDim2.new(1, -12, 0, 36),
    Position = UDim2.new(0,6,0,6)
},{}); corner(topbar,8); stroke(topbar,1); topbar.Parent = root
padding(topbar,8)

local title = mk("TextLabel",{
    BackgroundTransparency = 1, Text = "ScriptHub Pro",
    Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.Text, Size = UDim2.new(1,-180,1,0)
},{}); title.Parent = topbar

-- أزرار الشريط
local btnArea = mk("Frame",{
    BackgroundTransparency = 1, Size = UDim2.new(0,160,1,0), Position = UDim2.new(1,-160,0,0)
},{}); btnArea.Parent = topbar

local function makeBtn(txt, tip)
    local b = mk("TextButton",{
        BackgroundColor3 = theme.Accent, Text = txt, AutoButtonColor = true,
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(0,44,1,0)
    },{}); corner(b,6)
    b.MouseEnter:Connect(function() title.Text = "ScriptHub Pro — "..tip end)
    b.MouseLeave:Connect(function() title.Text = "ScriptHub Pro" end)
    return b
end

local btnMin = makeBtn("-", "تصغير/إظهار")
btnMin.Position = UDim2.new(1,-150,0,0); btnMin.Parent = btnArea
local btnTheme = makeBtn("☀", "تبديل الثيم")
btnTheme.Position = UDim2.new(1,-100,0,0); btnTheme.Parent = btnArea
local btnClose = makeBtn("×", "إخفاء اللوحة (RightCtrl لإظهار)")
btnClose.Position = UDim2.new(1,-50,0,0); btnClose.Parent = btnArea

--== منطقة المحتوى ==--
local content = mk("Frame",{
    BackgroundColor3 = theme.Panel,
    Size = UDim2.new(1, -12, 1, -54),
    Position = UDim2.new(0,6,0,48),
    ClipsDescendants = true
},{}); corner(content,10); stroke(content,1); content.Parent = root

--== تبويبات ==--
local tabsBar = mk("Frame",{
    BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 30),
    Position = UDim2.new(0,8,0,6)
},{}); tabsBar.Parent = content

local pages = mk("Frame",{
    BackgroundTransparency = 1, Size = UDim2.new(1,-16,1,-44),
    Position = UDim2.new(0,8,0,38)
},{}); pages.Parent = content

local function makeTabButton(name)
    local b = mk("TextButton",{
        BackgroundColor3 = theme.Bg, Text = name,
        Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text,
        Size = UDim2.new(0,110,1,0)
    },{}); corner(b,6); stroke(b,1)
    return b
end

local TabButtons = {}
local function addTab(name)
    local btn = makeTabButton(name); btn.Parent = tabsBar
    btn.Position = UDim2.new(#TabButtons * 0, (#TabButtons*116), 0, 0)
    local page = mk("Frame",{BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)},{})
    page.Visible = false; page.Parent = pages
    TabButtons[name] = {Button = btn, Page = page}
end

addTab("Modules")
addTab("Runner")
addTab("Console")
addTab("Settings")
addTab("About")

local function selectTab(name)
    for n, t in pairs(TabButtons) do
        t.Page.Visible = (n == name)
        t.Button.BackgroundColor3 = (n == name) and theme.Accent or theme.Bg
        t.Button.TextColor3 = (n == name) and Color3.fromRGB(255,255,255) or theme.Text
    end
    SessionState.LastTab = name; saveSession()
end

--== صفحة Modules ==--
local modulesUI = TabButtons.Modules.Page
local searchBox = mk("TextBox",{
    PlaceholderText="بحث عن وحدة...", Text="", ClearTextOnFocus=false,
    Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text,
    BackgroundColor3 = theme.Bg, Size = UDim2.new(1,0,0,32)
},{}); corner(searchBox,6); stroke(searchBox,1); searchBox.Parent = modulesUI

local list = mk("ScrollingFrame",{
    BackgroundTransparency=1, Size=UDim2.new(1,0,1,-40), Position=UDim2.new(0,0,0,36),
    CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=6
},{}); list.Parent = modulesUI

local uilist = mk("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder},{}); uilist.Parent = list
padding(list,2)

local RegisteredModules = {} -- { [id] = {module, running, frame, controls...} }

local function getModulesFolder()
    return ReplicatedStorage:FindFirstChild(MODULES_FOLDER_NAME)
end

local function makeModuleCard(info)
    local card = mk("Frame",{
        BackgroundColor3 = theme.Bg, Size=UDim2.new(1,-4,0,86)
    },{})
    corner(card,8); stroke(card,1); padding(card,10)

    local nameL = mk("TextLabel",{
        BackgroundTransparency=1, Text=info.Name or info.Id, TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.GothamBold, TextSize=16, TextColor3=theme.Text, Size=UDim2.new(1,-150,0,20)
    },{}); nameL.Parent = card

    local descL = mk("TextLabel",{
        BackgroundTransparency=1, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.Gotham, TextSize=13, TextColor3=theme.Subtle, Size=UDim2.new(1,-150,1,-24),
        Position=UDim2.new(0,0,0,24), Text=info.Description or "بدون وصف"
    },{}); descL.Parent = card

    local btnStart = mk("TextButton",{
        BackgroundColor3=theme.Accent, Text="تشغيل", Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=Color3.new(1,1,1), Size=UDim2.new(0,100,0,32), Position=UDim2.new(1,-110,0,6)
    },{}); corner(btnStart,6); btnStart.Parent = card

    local btnStop = mk("TextButton",{
        BackgroundColor3=Color3.fromRGB(200,60,60), Text="إيقاف", Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=Color3.new(1,1,1), Size=UDim2.new(0,100,0,32), Position=UDim2.new(1,-110,0,46)
    },{}); corner(btnStop,6); btnStop.Parent = card

    return {
        Card = card, StartButton = btnStart, StopButton = btnStop,
        SetRunning = function(running)
            btnStart.BackgroundColor3 = running and Color3.fromRGB(90,90,90) or theme.Accent
            btnStart.AutoButtonColor = not running
        end
    }
end

local function refreshModulesUI()
    list:ClearAllChildren(); uilist.Parent = list
    local query = string.lower(searchBox.Text or "")
    for id, entry in pairs(RegisteredModules) do
        local info = entry.Info
        if query == "" or string.find(string.lower(info.Name.." "..(info.Description or "")), query, 1, true) then
            entry.UI.Card.Parent = list
        end
    end
end

local function bindModuleButtons(entry)
    local ui = entry.UI
    ui.StartButton.MouseButton1Click:Connect(function()
        if entry.Running then
            Notifications.Show(gui, "<b>"..entry.Info.Name.."</b> تعمل بالفعل.", theme)
            return
        end
        local ok, err = pcall(function() entry.Module.Start(LocalPlayer) end)
        if ok then
            entry.Running = true; ui.SetRunning(true)
            SessionState.EnabledModules[entry.Info.Id] = true; saveSession()
            Notifications.Show(gui, "تم تشغيل <b>"..entry.Info.Name.."</b>.", theme)
        else
            Notifications.Show(gui, "فشل تشغيل <b>"..entry.Info.Name.."</b>: "..tostring(err), theme)
        end
    end)

    ui.StopButton.MouseButton1Click:Connect(function()
        if not entry.Running then
            Notifications.Show(gui, "<b>"..entry.Info.Name.."</b> ليست قيد التشغيل.", theme)
            return
        end
        local ok, err = pcall(function() if entry.Module.Stop then entry.Module.Stop(LocalPlayer) end end)
        entry.Running = false; ui.SetRunning(false)
        SessionState.EnabledModules[entry.Info.Id] = false; saveSession()
        if ok then
            Notifications.Show(gui, "تم إيقاف <b>"..entry.Info.Name.."</b>.", theme)
        else
            Notifications.Show(gui, "خطأ أثناء الإيقاف: "..tostring(err), theme)
        end
    end)
end

local function registerModule(mod)
    local info = mod.Info or {}
    assert(info.Id, "Module missing Info.Id")
    info.Name = info.Name or info.Id
    local ui = makeModuleCard(info)
    RegisteredModules[info.Id] = {
        Module = mod, Info = info, UI = ui, Running = false
    }
    bindModuleButtons(RegisteredModules[info.Id])
    uilist.Parent = list
    ui.Card.Parent = list
end

local function loadModules()
    for _,v in ipairs(list:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    table.clear(RegisteredModules)
    local folder = getModulesFolder()
    if not folder then
        Notifications.Show(gui, "لم يتم العثور على المجلد <b>"..MODULES_FOLDER_NAME.."</b> في ReplicatedStorage.", theme)
        return
    end
    for _,m in ipairs(folder:GetChildren()) do
        if m:IsA("ModuleScript") then
            local ok, modOrErr = pcall(require, m)
            if ok and type(modOrErr)=="table" and type(modOrErr.Start)=="function" then
                registerModule(modOrErr)
            else
                Notifications.Show(gui, "تجاهل Module: "..m.Name.." (صيغة غير صحيحة).", theme)
            end
        end
    end
    refreshModulesUI()
    -- تفعيل الافتراضي أو ما حُفظ في الجلسة
    for id, entry in pairs(RegisteredModules) do
        local shouldEnable = SessionState.EnabledModules[id]
            or (entry.Info.DefaultEnabled == true)
        if shouldEnable then
            local ok = pcall(function() entry.Module.Start(LocalPlayer) end)
            entry.Running = ok and true or false
            entry.UI.SetRunning(entry.Running)
        end
    end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshModulesUI)

--== صفحة Runner (مقاطع جاهزة فقط) ==--
local runnerPage = TabButtons.Runner.Page
local runnerHint = mk("TextLabel",{
    BackgroundTransparency=1, TextWrapped=true, Font=Enum.Font.Gotham, TextSize=13,
    TextColor3=theme.Subtle, Size=UDim2.new(1,0,0,32), TextXAlignment=Enum.TextXAlignment.Left,
    Text = "تشغيل مقاطع (Snippets) موثوقة من ReplicatedStorage/"..SNIPPETS_FOLDER_NAME..""
},{}); runnerHint.Parent = runnerPage

local runBtn = mk("TextButton",{
    BackgroundColor3=theme.Accent, Text="تشغيل المقطع المحدد", Font=Enum.Font.GothamBold, TextSize=14,
    TextColor3=Color3.new(1,1,1), Size=UDim2.new(0,180,0,30), Position=UDim2.new(1,-190,0,0)
},{}); corner(runBtn,6); runBtn.Parent = runnerPage

local snippetList = mk("ScrollingFrame",{
    BackgroundTransparency=1, Size=UDim2.new(1,0,1,-40), Position=UDim2.new(0,0,0,40),
    CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=6
},{}); snippetList.Parent = runnerPage
padding(snippetList,4)
local sLayout = mk("UIListLayout",{Padding=UDim.new(0,6)},{}); sLayout.Parent = snippetList

local selectedSnippet
local function refreshSnippets()
    snippetList:ClearAllChildren(); sLayout.Parent = snippetList
    local folder = ReplicatedStorage:FindFirstChild(SNIPPETS_FOLDER_NAME)
    if not folder then
        mk("TextLabel",{BackgroundTransparency=1, Text="(لا يوجد مجلد Snippets)", Size=UDim2.new(1,0,0,24),
            Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Subtle},{}).Parent = snippetList
        return
    end
    for _,m in ipairs(folder:GetChildren()) do
        if m:IsA("ModuleScript") then
            local b = mk("TextButton",{
                BackgroundColor3=theme.Bg, Text=m.Name, Font=Enum.Font.Gotham, TextSize=14,
                TextColor3=theme.Text, Size=UDim2.new(1,-6,0,30)
            },{}); corner(b,6); stroke(b,1); b.Parent = snippetList
            b.MouseButton1Click:Connect(function()
                selectedSnippet = m
                Notifications.Show(gui, "تم اختيار: <b>"..m.Name.."</b>", theme)
            end)
        end
    end
end

runBtn.MouseButton1Click:Connect(function()
    if not selectedSnippet then
        Notifications.Show(gui, "اختر مقطعاً أولاً.", theme); return
    end
    local ok, sn = pcall(require, selectedSnippet)
    if ok and type(sn)=="function" then
        local ok2, err = pcall(function() sn(LocalPlayer) end)
        if ok2 then
            Notifications.Show(gui, "تم تنفيذ المقطع: <b>"..selectedSnippet.Name.."</b>", theme)
        else
            Notifications.Show(gui, "خطأ أثناء التنفيذ: "..tostring(err), theme)
        end
    else
        Notifications.Show(gui, "المقطع غير صالح (يجب أن يُرجع دالة).", theme)
    end
end)

--== صفحة Console ==--
local consolePage = TabButtons.Console.Page
local consoleBox = mk("TextLabel",{
    BackgroundColor3=theme.Bg, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
    TextWrapped=true, Font=Enum.Font.Code, TextSize=14, TextColor3=theme.Text,
    Size=UDim2.new(1,0,1,0)
},{}); corner(consoleBox,8); stroke(consoleBox,1); padding(consoleBox,10); consoleBox.Parent = consolePage

local function consoleLog(...)
    local parts = {}
    for i,v in ipairs({...}) do parts[i] = tostring(v) end
    local line = table.concat(parts, " ")
    consoleBox.Text = (consoleBox.Text == "" and line) or (consoleBox.Text.."\n"..line)
end

--== صفحة Settings ==--
local settingsPage = TabButtons.Settings.Page

local themeBtn = mk("TextButton",{
    BackgroundColor3=theme.Bg, Text="تبديل الثيم (حالياً: "..SessionState.Theme..")",
    Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, Size=UDim2.new(1,0,0,34)
},{}); corner(themeBtn,6); stroke(themeBtn,1); themeBtn.Parent = settingsPage

local kbLabel = mk("TextLabel",{
    BackgroundTransparency=1, Text="مفتاح الاختصار: RightCtrl لإظهار/إخفاء",
    Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Subtle, Size=UDim2.new(1,0,0,28),
    Position=UDim2.new(0,0,0,40)
},{}); kbLabel.Parent = settingsPage

local reloadBtn = mk("TextButton",{
    BackgroundColor3=theme.Accent, Text="إعادة تحميل الوحدات",
    Font=Enum.Font.GothamBold, TextSize=14, TextColor3=Color3.new(1,1,1),
    Size=UDim2.new(0,180,0,32), Position=UDim2.new(0,0,0,74)
},{}); corner(reloadBtn,6); reloadBtn.Parent = settingsPage

reloadBtn.MouseButton1Click:Connect(function()
    loadModules()
    Notifications.Show(gui, "تم إعادة تحميل الوحدات.", theme)
end)

themeBtn.MouseButton1Click:Connect(function()
    SessionState.Theme = (SessionState.Theme=="Dark") and "Light" or "Dark"
    saveSession()
    Notifications.Show(gui, "ستتطبق الألوان بعد إعادة الفتح.", theme)
end)

--== صفحة About ==--
local about = TabButtons.About.Page
mk("TextLabel",{
    BackgroundTransparency=1, TextWrapped=true, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text,
    Size=UDim2.new(1,0,1,0), TextXAlignment=Enum.TextXAlignment.Left,
    Text = "ScriptHub Pro — واجهة احترافية لإدارة وحدات موثوقة داخل لعبتك.\n• السحب/التصغير/التبديل بالاختصار\n• تشغيل/إيقاف وحدات\n• بحث، إشعارات، كونسول\n• ثيم داكن/فاتح\n\nنصيحة: أبقِ الوحدات داخل ReplicatedStorage/"..MODULES_FOLDER_NAME.." وتأكد أنها آمنة."
},{}).Parent = about

--== منطق تبديل الرؤية/الثيم/الحجم ==--
local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(content, TweenInfo.new(0.25), {Size = minimized and UDim2.new(1,-12,0,0) or UDim2.new(1,-12,1,-54)}):Play()
end)

btnTheme.MouseButton1Click:Connect(function()
    themeBtn:Activate() -- استدعاء زر الإعدادات
end)

local function setVisible(v)
    SessionState.Visible = v; saveSession()
    gui.Enabled = v
end

btnClose.MouseButton1Click:Connect(function() setVisible(false) end)

-- مفتاح الاختصار RightCtrl
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        setVisible(not gui.Enabled)
    end
end)

-- تغيير الحجم من الزاوية اليمنى السفلى (بسيط)
local resizer = mk("Frame",{
    BackgroundTransparency=1, Size=UDim2.new(0,14,0,14), AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,0,1,0), Active=true
},{}); resizer.Parent = root
local draggingSize = false
resizer.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSize=true end end)
resizer.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSize=false end end)
UserInputService.InputChanged:Connect(function(i)
    if draggingSize and i.UserInputType==Enum.UserInputType.MouseMovement then
        local m = UserInputService:GetMouseLocation()
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local x = math.max(420, m.X - root.AbsolutePosition.X)
        local y = math.max(260, m.Y - root.AbsolutePosition.Y - guiInset.Y)
        root.Size = UDim2.new(0,x,0,y)
        SessionState.Size = root.Size; saveSession()
    end
end)

-- حفظ الموضع
root:GetPropertyChangedSignal("Position"):Connect(function()
    SessionState.Pos = root.Position; saveSession()
end)

-- اختيار التبويب الأول
selectTab(SessionState.LastTab or "Modules")

-- تحميل الوحدات والمقاطع
loadModules(); refreshSnippets()

-- مثال تسجيل في الكونسول
consoleLog("[ScriptHub] جاهز. عدد الوحدات: "..tostring(#RegisteredModules))
