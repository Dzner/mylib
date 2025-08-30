-- =========================================================
-- تحميل مكتبة Ash-Libs من GitHub
-- هذا السطر يجيب الملف (source.lua) ويشغله
-- الكائن الراجِع هو GUI ومن خلاله نستخدم كل الدوال
-- =========================================================
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"))()

-- =========================================================
-- إنشاء النافذة الرئيسية للواجهة
-- =========================================================
GUI:CreateMain({
    Name = "Ashlabs",             -- اسم داخلي للواجهة (ما يظهر للمستخدم)
    title = "Ashlabs GUI",        -- عنوان النافذة (يظهر بالواجهة)
    ToggleUI = "K",               -- الزر اللي يخفي/يظهر الواجهة (هنا: حرف K)
    WindowIcon = "home",          -- أيقونة النافذة (ممكن تستخدم lucid icons)

    -- WindowHeight = 600,        -- تقدر تعدل طول النافذة (اختياري)
    -- WindowWidth = 800,         -- تقدر تعدل عرض النافذة (اختياري)

    alwaysIconOnly = false,       -- لو true رح يخلي شريط التبويبات أيقونات فقط

    -- إعدادات الألوان (Theme)
    Theme = {
        Background = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(138, 43, 226),
        AccentSecondary = Color3.fromRGB(118, 23, 206),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(45, 45, 55),
        NavBackground = Color3.fromRGB(20, 20, 30),
        Surface = Color3.fromRGB(30, 30, 40),
        SurfaceVariant = Color3.fromRGB(35, 35, 45),
        Success = Color3.fromRGB(40, 201, 64),
        Warning = Color3.fromRGB(255, 189, 46),
        Error = Color3.fromRGB(255, 95, 87),
        Shadow = Color3.fromRGB(0, 0, 0)
    },

    -- تأثير الضبابية بالخلفية (Buggy حسب المكتبة)
    Blur = {
        Enable = false,  -- لو true يشتغل الضباب
        value = 0.2      -- درجة الضباب
    },

    -- إعدادات حفظ الملفات (Configs)
    Config = {
        Enabled = false,          -- لو true يشتغل الحفظ التلقائي
        FileName = "AshLabs",     -- اسم ملف الإعدادات
        FolerName = "AshDir",     -- مجلد حفظ الملفات (مكتوب Foler مو Folder بالمكتبة)
    }
})

-- =========================================================
-- إنشاء تبويب رئيسي (Main)
-- =========================================================
local main = GUI:CreateTab("Main", "home") -- "Main" اسم التبويب / "home" أيقونة

-- =========================================================
-- إضافة قسم داخل تبويب Main
-- =========================================================
GUI:CreateSection({
    parent = main, 
    text = "Section" -- عنوان القسم
})

-- =========================================================
-- زر عادي
-- =========================================================
GUI:CreateButton({
    parent = main, 
    text = "Click Me",             -- النص على الزر
    flag = "ClickMeBtn",           -- اسم خاص بالزر (لتخزين حالته مثلاً)
    callback = function()          -- الدالة اللي تتنفذ عند الضغط
        GUI:CreateNotify({title = "Button Clicked", description = "You clicked the button!"})
    end
})

-- زر ثاني يعرض إشعار طويل
GUI:CreateButton({
    parent = main, 
    text = "Notify", 
    flag = "NotifyBtn",
    callback = function()
        GUI:CreateNotify({
            title = "Welcome", 
            description = "Welcome to the Ashlabs GUI! هذا مثال إشعار طويل..."
        })
    end
})

-- =========================================================
-- Toggle (تشغيل/إيقاف)
-- =========================================================
GUI:CreateToggle({
    parent = main, 
    text = "Toggle Me",        -- اسم التوغل
    default = false,           -- الحالة الافتراضية (مغلق)
    flag = "ToggleMe",
    callback = function(state) -- يرجع true/false حسب الحالة
        print("Toggle state:", state)
    end
})

-- =========================================================
-- Slider (شريط تمرير)
-- =========================================================
GUI:CreateSlider({
    parent = main, 
    text = "Slider",           -- عنوان السلايدر
    min = 0,                   -- أقل قيمة
    max = 100,                 -- أكبر قيمة
    default = 50,              -- القيمة الابتدائية
    flag = "SliderValue",
    callback = function(value) -- يرجع الرقم المختار
        print("Slider value changed:", value)
    end
})

-- =========================================================
-- Dropdown (قائمة منسدلة)
-- =========================================================
GUI:CreateDropdown({
    parent = main, 
    text = "Select Option", 
    options = {"Option 1", "Option 2", "Option 3"}, -- قائمة الخيارات
    default = "Option 1", 
    flag = "DropdownOption",
    callback = function(selected) -- يرجع الخيار اللي اختاره المستخدم
        print("Selected option:", selected)
    end
})

-- =========================================================
-- KeyBind (اختصار من الكيبورد)
-- =========================================================
GUI:CreateKeyBind({
    parent = main, 
    text = "Press a Key", 
    default = "K", 
    flag = "KeyBind",
    callback = function(key, input, isPressed)
        if isPressed then
            print("Key pressed:", key)
        else
            print("Key released:", key)
        end
    end
})

-- =========================================================
-- Input (إدخال نص)
-- =========================================================
GUI:CreateInput({
    parent = main, 
    text = "Enter Text", 
    placeholder = "Placeholder", 
    flag = "InputText", -- ملاحظة: بالكود الأصلي كان خطأ مطبعي "flaag"
    callback = function(text)
        print("Input text:", text)
    end
})

-- =========================================================
-- Paragraph (فقرة نصية طويلة)
-- =========================================================
GUI:CreateParagraph({
    parent = main,
    title = "title", -- عنوان الفقرة
    text = "هذا نص طويل يشرح شيء مهم..."
})

-- =========================================================
-- Color Picker (اختيار لون)
-- =========================================================
GUI:CreateColorPicker({
    parent = main, 
    text = "Pick a Color", 
    default = Color3.fromRGB(255, 0, 0), -- اللون الافتراضي (أحمر)
    flag = "ColorPicker",
    callback = function(color)
        print("Selected color:", color)
    end
})

-- =========================================================
-- إنشاء تبويب جديد (Settings)
-- =========================================================
local settings = GUI:CreateTab("Settings", "settings")

-- قسم داخل تبويب Settings
GUI:CreateSection({
    parent = settings, 
    text = "Settings Section"
})

-- زر لإعادة ضبط الإعدادات
GUI:CreateButton({
    parent = settings, 
    text = "Reset Settings", 
    flag = "ResetSettingsBtn",
    callback = function()
        GUI:CreateNotify({ title = "Settings Reset", text = "All settings have been reset to default."})
    end
})

-- Divider (فاصل خطي)
GUI:CreateDivider({
    parent = settings
})

-- زر ثاني
GUI:CreateButton({
    parent = settings, 
    text = "Reset 2", 
    flag = "ResetSettingsBtn2",
    callback = function()
        GUI:CreateNotify({ title = "Settings Reset", text = "All settings have been reset to default."})
    end
})

-- =========================================================
-- تبويب إضافي بدون أيقونة (مثال)
-- =========================================================
local move = GUI:CreateTab("Settings")
