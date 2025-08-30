local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))() -- > تصديرالمكتبة 

-- ==============================================
-- N: مكان ال popup
-- ==============================================
local continue
WindUI:Popup({
    Title = "Popup Title",
    Icon = "info",
    Content = "Popup content",
    Buttons = {
        {
            Title = "Cancel",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "Continue",
            Icon = "arrow-right",
            
            Callback = function() continue = true end,
            Variant = "Primary",
        }
    }
})

repeat task.wait() until continue == true
--==>> N: وقف الكود حتى المتغير تصبح قيمته صحيحة

-- ==============================================
-- N: مكان صناعة الواجهة الرئيسية
-- ==============================================
local Window = WindUI:CreateWindow({ -- > انشاء الواجهة الرئيسة
    Title = "My Super Hub ",
    Icon = "door-open",
    Author = "by .ftgs and .ftgs",
    Folder = "MySuperHub", -- > اسم ملف التخزين
    -- > A : كل الس تحت قابل للحذف
    Size = UDim2.fromOffset(580, 460),
    Transparent = true, -- > شفافية؟
    Theme = "Dark", -- > الثيم
    Resizable = true, -- > قابل للتصغير والتكبير؟
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true, -- > بحث
    ScrollBarEnabled = false,
    --Background = "rbxassetid://", -- > خلفية صوره للقائمة
    --Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- > فيديو خلفية
    
    User = { -- > ملف اللاعب
        Enabled = true,
        Anonymous = true, -- > مجهول؟
        Callback = function()
            print("clicked")
        end,
    },
    
    KeySystem = { -- > نظام المفتاح
        Key = { "1234", "5678" },
        Note = "Example Key System.",
        Thumbnail = { -- > صوره عرض مع لوحة كلمه السر (احذفها اذا متريدها)
            Image = "rbxassetid://",
            Title = "Thumbnail",
        },
        
        URL = "YOUR LINK TO GET KEY (Discord, Linkvertise, Pastebin, etc.)",
        SaveKey = false, -- > حفظ المفتاح
        -- API = {} ← Services. Read about it below ↓
    },
})

-- ==============================================
-- N: تاك بشريط العنوان 
-- ==============================================

Window:Tag({
    Title = "v1.6.4",
    Color = Color3.fromHex("#30ff6a")
})
-- ==============================================
-- N: السكشنات والتبويبات 
-- ==============================================
local Tab = Window:Tab({ -- > زر بلا سكشن
    Title = "Tab Title",
    Icon = "bird",
    Locked = false,
})
-- > زر مع سكشن
local Section = Window:Section({Title = "Setting" , Icon = "app-window-mac", Opened = false}) 
local Tabtwo = Section:Tab({
    Title = "Tab Title",
    Icon = "bird",
    Locked = false,
})

Window:SelectTab(1) -- > تحديد القائمة المفترض فتحها اولاً

-- ==============================================
-- N: محتوى التبويب 
-- ==============================================

local Button = Tab:Button({ -- > زر
    Title = "Button",
    Desc = "Test Button",
    Locked = false,
    Callback = function()
        print("clicked")
    end
})

local Code = Tab:Code({ -- > كود قابل للنسخ
    Title = "Code",
    Code = [[print("Hello World!")]]
})

local Colorpicker = Tab:Colorpicker({ --> تخصيص لون
    Title = "Colorpicker",
    Desc = "Colorpicker Description",
    Default = Color3.fromRGB(0, 255, 0),
    Transparency = 0,
    Locked = false,
    Callback = function(color) 
        print("Background color: " .. tostring(color))
    end
})

local Dropdown = Tab:Dropdown({ -- > اختيارات متعددة
    Title = "Dropdown (Multi)",
    Values = { "Category A", "Category B", "Category C" },
    Value = { "Category A" },
    Multi = true,
    AllowNone = true,
    Callback = function(option) 
        print("Categories selected: " .. game:GetService("HttpService"):JSONEncode(option)) 
    end
})

local Dropdown = Tab:Dropdown({ -- > اختيارات مفرده
    Title = "Dropdown (Multi)",
    Values = { "Category A", "Category B", "Category C" },
    Value = "Category A",
    Callback = function(option) 
        print("Category selected: " .. option) 
    end
})

local Input = Tab:Input({ -- > ادخال
    Title = "Input",
    Desc = "Input Description",
    Value = "Default value",
    InputIcon = "bird",
    Type = "Input", -- or "Textarea"
    Placeholder = "Enter text...",
    Callback = function(input) 
        print("text entered: " .. input)
    end
})

local Paragraph = Tab:Paragraph({ -- > براكاف
    Title = "Paragraph with Image, Thumbnail, Buttons",
    Desc = "Test Paragraph",
    Color = "Red",
    Image = "",
    ImageSize = 30,
    Thumbnail = "",
    ThumbnailSize = 80,
    Locked = false,
    Buttons = {
        {
            Icon = "bird",
            Title = "Button",
            Callback = function() print("1 Button") end,
        }
    }
})

local Section = Tab:Section({ -- > موضوع جديد
    Title = "Section",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local Slider = Tab:Slider({ -- > سلايدر
    Title = "Slider",
    Step = 1, -- > رقم عدد الخطوات
    Value = {
        Min = 20,
        Max = 120,
        Default = 70,
    },
    Callback = function(value)
        print(value)
    end
})

local Toggle = Tab:Toggle({ -- > زر تفعيل/تعطيل
    Title = "Toggle",
    Desc = "Toggle Description",
    Icon = "bird",
    Type = "Checkbox",
    Default = false,
    Callback = function(state) 
        print("Toggle Activated" .. tostring(state))
    end
})












-- اضافات

-- Window:CreateTopbarButton("MyCustomButton3", "battery-plus", function() Window:ToggleFullscreen() end, 988
-- > اضافة ازارار اضافية الى شريط الادوات

-- Window:DisableTopbarButtons({
--     "Close", 
--     "Minimize", 
--     "Fullscreen",
-- })
-- > دالة التعديل على الايقونات الاساسية لشريط الاودات 

Window:EditOpenButton({ -- > دالة واجهة القائمة المنبثقة
    Title = "Open Example UI",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    --Enabled = false,
    Draggable = true,
})


-- > دالة تلوين مدرج
function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)

        local char = text:sub(i, i)
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"
    end

    return result
end
