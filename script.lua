local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService('VirtualUser')
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- ===========================================
-- 🔒 نظام حماية اللاعبين المؤقتة
-- ===========================================

local ProtectedUsers = {
    ["Eslam9O"] = true,
    ["Eslam9O0"] = true,
    ["MADARA11111222"] = true,
    ["MADARA1111122221"] = true
}

-- ===========================================
-- 🔔 جدول الإشعارات
-- ===========================================

local Notifications = {}
local function updateNotificationsPositions()
    for i, notif in ipairs(Notifications) do
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, -260, 1, -80 - (i-1) * 80)}):Play()
        end
    end
end

-- ===========================================
-- 🔔 دالة إنشاء إشعار
-- ===========================================

local function createNotification(titleText, mainText, playerImageId, duration)
    duration = duration or 5
    
    local notificationScreen = CoreGui:FindFirstChild("GBORE_Notifications")
    if not notificationScreen then
        notificationScreen = Instance.new("ScreenGui")
        notificationScreen.Name = "GBORE_Notifications"
        notificationScreen.ResetOnSpawn = false
        notificationScreen.Parent = CoreGui
    end
    
    local baseWidth = 300
    local textWidth = #mainText * 6
    local notifWidth = math.max(baseWidth, math.min(textWidth + 40, 400))

    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, notifWidth, 0, 70)
    Notification.Position = UDim2.new(1, 10, 1, -80)
    Notification.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Notification.BackgroundTransparency = 0.4
    Notification.BorderSizePixel = 0
    Notification.Parent = notificationScreen
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = Notification

    local PlayerImage = Instance.new("ImageLabel")
    PlayerImage.Size = UDim2.new(0, 50, 0, 50)
    PlayerImage.Position = UDim2.new(0, 10, 0.5, -25)
    PlayerImage.BackgroundTransparency = 1
    PlayerImage.Image = playerImageId or "rbxassetid://7992557358"
    PlayerImage.Parent = Notification
    
    local PlayerImageCorner = Instance.new("UICorner")
    PlayerImageCorner.CornerRadius = UDim.new(1, 0)
    PlayerImageCorner.Parent = PlayerImage

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70, 0, 25)
    TitleLabel.Position = UDim2.new(0, 60, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText or "GBORE SYSTEM"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    TitleLabel.Parent = Notification

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -50, 1, -25)
    TextLabel.Position = UDim2.new(0, 65, 0, 15)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = mainText or "إشعار"
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel.TextWrapped = true
    TextLabel.Parent = Notification

    table.insert(Notifications, 1, Notification)
    updateNotificationsPositions()

    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -(notifWidth + 10), 1, -80)}):Play()

    delay(duration, function()
        if Notification and Notification.Parent then
            TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, 10, 1, -80), BackgroundTransparency = 1}):Play()
            
            delay(0.5, function()
                if Notification and Notification.Parent then
                    Notification:Destroy()
                end
            end)

            -- سجّل الواجهة الصغيرة كمرجع عام وافعِل إخفاء الواجهة الكبيرة
            _G.GBORE_SmallGUI = (rawget(_G, "GBORE_SmallGUI") or nil)
            pcall(function()
                if _G.GBORE_SmallGUI == nil then
                    -- حاول الحصول على الواجهة التي أنشأناها باسمها داخل الـ CoreGui
                    local maybe = game:GetService("CoreGui"):FindFirstChild("GBORE_SmallGUI")
                    if maybe then _G.GBORE_SmallGUI = maybe end
                end
            end)

            -- إخفاء الواجهة الكبيرة لتكون الواجهة الصغيرة هي الرئيسية
            pcall(function()
                if ScreenGui and ScreenGui:IsA("ScreenGui") then
                    ScreenGui.Enabled = false
                end
                if Frame and typeof(Frame) == "Instance" then
                    Frame.Visible = false
                end
            end)

            local function antiScriptDetection()
        for i, v in ipairs(Notifications) do
            if v == Notification then
                table.remove(Notifications, i)
                break
            end
        end
        updateNotificationsPositions()
    end)
end

-- ===========================================
-- 🔒 دالة فحص الحماية المؤقتة
-- ===========================================

local function CheckTargetProtection(playerName)
    if BannedUsers[playerName] then
        createNotification("GBORE SYSTEM", "هذا اللاعب محظور!", "rbxassetid://7992557358", 5)
        return true
    end
    
    if ProtectedUsers[playerName] then
        createNotification("GBORE SYSTEM", 
            "هذا اللاعب محمي!", 
            "rbxassetid://7992557358", 
            5)
        return true
    end
    return false
end

-- ===========================================
-- 🔒 فحص المحظورين
-- ===========================================

if BannedUsers[LocalPlayer.Name] then
    createNotification("GBORE SYSTEM", "أنت محظور من استخدام السكربت!", "rbxassetid://7992557358", 10)
    task.wait(3)
    
    local gui = Instance.new("ScreenGui")
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false

    local bg = Instance.new("ImageLabel", gui)
    bg.Size = UDim2.new(2, 1, 1, 0)
    bg.BackgroundTransparency = 1
    bg.Image = "rbxassetid://139378337018608"

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 32
    txt.TextColor3 = Color3.fromRGB(240, 0, 0)
    txt.TextWrapped = true
    txt.Text = "عذراً ، لايمكنك تشغيل السكربت لانك من قائمة المحظورين\n\nرسالة من المطور :\n( بنعالي يبن القحبة محروم من سكربتي كسمك يلا برا يبن الزنا انيك امك )"

    while true do
        task.wait(1e9)
    end
    return
end

-- ===========================================
-- 📊 عرض معلومات الحماية المؤقتة للاعب المحلي
-- ===========================================

task.spawn(function()
    task.wait(8)
    
    if ProtectedUsers[LocalPlayer.Name] then
        local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        createNotification("GBORE SYSTEM", 
            "أنت محمي!", 
            thumb, 
            10)
    end
end)

-- ===========================================
-- 🔧 نظام منع الموت والتجميد
-- ===========================================

local Fixing = false
local Connections = {}

local function DisconnectAll()
    for _, c in pairs(Connections) do
        if c.Connected then
            c:Disconnect()
        end
    end
    table.clear(Connections)
end

local function fixMovement()
    if Fixing then
        return
    end
    Fixing = true

    DisconnectAll()

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        Fixing = false
        return
    end

    hum.AutoRotate = true
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)

    local function antiForcedSit()
        if hum and hum.Parent then
            if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.Swimming then
                hum.Sit = true
            end
        end
    end

    Connections["HB"] = RunService.Heartbeat:Connect(antiForcedSit)
    Connections["Sit"] = hum:GetPropertyChangedSignal("Sit"):Connect(antiForcedSit)

    task.spawn(function()
        while hum and hum.Parent do
            antiForcedSit()
            task.wait(0.05)
        end
    end)

    Fixing = false
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    fixMovement()
end)

if LocalPlayer.Character then
    task.wait(0.3)
    fixMovement()
end

-- ===========================================
-- 🎬 شاشة البداية
-- ===========================================

task.spawn(function()
    local screenGui = Instance.new("ScreenGui")
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local bg = Instance.new("Frame", screenGui)
    bg.Size = UDim2.new(2, 1, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 1

    local img = Instance.new("ImageLabel", bg)
    img.Size = UDim2.new(2, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = ""
    img.ImageTransparency = 1

    local label = Instance.new("TextLabel", bg)
    label.Size = UDim2.new(0.9, 0, 0.2, 0)
    label.Position = UDim2.new(0.1, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 48
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "GBORE ON TOP"
    label.TextTransparency = 1
    label.TextStrokeTransparency = 0.7
    label.TextScaled = true

    local gradient = Instance.new("UIGradient", label)
    gradient.Rotation = 0
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Offset = Vector2.new(-1, 0)

    local tweenGlow = TweenService:Create(
        gradient,
        TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
        {Offset = Vector2.new(1, 0)}
    )
    tweenGlow:Play()

    local fadeInTween = TweenService:Create(bg, TweenInfo.new(1.5), {BackgroundTransparency = 0})
    local imgTween = TweenService:Create(img, TweenInfo.new(1.5), {ImageTransparency = 0})
    local labelTween = TweenService:Create(label, TweenInfo.new(1.5), {TextTransparency = 0})

    fadeInTween:Play()
    imgTween:Play()
    labelTween:Play()

    task.delay(5, function()
        local fadeOutTween = TweenService:Create(bg, TweenInfo.new(1.5), {BackgroundTransparency = 1})
        local imgOutTween = TweenService:Create(img, TweenInfo.new(1.5), {ImageTransparency = 1})
        local labelOutTween = TweenService:Create(label, TweenInfo.new(1.5), {TextTransparency = 1})

        fadeOutTween:Play()
        imgOutTween:Play()
        labelOutTween:Play()

        task.delay(1.5, function()
            screenGui:Destroy()
        end)
    end)
end)

-- ===========================================
-- 📢 رسائل الترحيب
-- ===========================================

task.spawn(function()
    task.wait(3)
    local args = {"GBORE ON TOP"}
    pcall(function()
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args))
    end)
end)

task.delay(15, function()
    local args = {"GBORE TOP1👆🏿"}
    pcall(function()
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args))
    end)
end)

-- ===========================================
-- 🎮 الواجهة الرئيسية
-- ===========================================

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "GBORE_GUI_" .. math.random(1, 999999)

-- الإطار الرئيسي
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 700, 0, 500)
Frame.Position = UDim2.new(0.5, -250, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(4, 10, 6)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 12)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Thickness = 2
FrameStroke.Color = Color3.fromRGB(60, 60, 60)

-- العنوان
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "سكربت GBORE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(240, 240, 255)

local glowGradientTitle = Instance.new("UIGradient", Title)
glowGradientTitle.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
glowGradientTitle.Rotation = 45
local glowTweenTitle = TweenService:Create(
    glowGradientTitle,
    TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
    {Offset = Vector2.new(1, 0)}
)
glowGradientTitle.Offset = Vector2.new(-1, 0)
glowTweenTitle:Play()

-- زر إغلاق النافذة
local CloseWindowButton = Instance.new("TextButton", Frame)
CloseWindowButton.Size = UDim2.new(0, 30, 0, 30)
CloseWindowButton.Position = UDim2.new(1, -35, 0, 5)
CloseWindowButton.Text = "❌"
CloseWindowButton.Font = Enum.Font.GothamBold
CloseWindowButton.TextSize = 16
CloseWindowButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseWindowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseWindowButton.AutoButtonColor = false
Instance.new("UICorner", CloseWindowButton).CornerRadius = UDim.new(0, 8)

-- أزرار التنقل
local ButtonsFrame = Instance.new("Frame", Frame)
ButtonsFrame.Size = UDim2.new(0, 160, 0, 310)
ButtonsFrame.Position = UDim2.new(0, 5, 0, 50)
ButtonsFrame.BackgroundTransparency = 1

local MainPageButton = Instance.new("TextButton", ButtonsFrame)
MainPageButton.Size = UDim2.new(1, 0, 0, 40)
MainPageButton.Position = UDim2.new(0, 0, 0, 0)
MainPageButton.Text = "اسـتـهـداف"
MainPageButton.Font = Enum.Font.GothamBold
MainPageButton.TextSize = 15
MainPageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainPageButton.BackgroundTransparency = 0.3
MainPageButton.TextColor3 = Color3.fromRGB(0, 0, 0)
MainPageButton.AutoButtonColor = false
Instance.new("UICorner", MainPageButton).CornerRadius = UDim.new(0, 8)

local OtherPageButton = Instance.new("TextButton", ButtonsFrame)
OtherPageButton.Size = UDim2.new(1, 0, 0, 40)
OtherPageButton.Position = UDim2.new(0, 0, 0, 50)
OtherPageButton.Text = "مـيـزات"
OtherPageButton.Font = Enum.Font.GothamBold
OtherPageButton.TextSize = 14
OtherPageButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OtherPageButton.BackgroundTransparency = 0.4
OtherPageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OtherPageButton.AutoButtonColor = false
Instance.new("UICorner", OtherPageButton).CornerRadius = UDim.new(0, 8)

-- إطارات الصفحات
local PagesFrame = Instance.new("Frame", Frame)
PagesFrame.Size = UDim2.new(0, 390, 0, 310)
PagesFrame.Position = UDim2.new(0, 120, 0, 50)
PagesFrame.BackgroundTransparency = 1

local MainScrollFrame = Instance.new("ScrollingFrame", PagesFrame)
MainScrollFrame.Size = UDim2.new(1, 0, 1, 0)
MainScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
MainScrollFrame.ScrollBarThickness = 6
MainScrollFrame.BackgroundTransparency = 1
MainScrollFrame.Active = true
MainScrollFrame.Selectable = true
MainScrollFrame.Visible = true

local OtherScrollFrame = Instance.new("ScrollingFrame", PagesFrame)
OtherScrollFrame.Size = UDim2.new(1, 0, 1, 0)
OtherScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
OtherScrollFrame.ScrollBarThickness = 6
OtherScrollFrame.BackgroundTransparency = 1
OtherScrollFrame.Active = true
OtherScrollFrame.Selectable = true
OtherScrollFrame.Visible = false

-- ===========================================
-- 🎯 صفحة الاستهداف
-- ===========================================

local PlayerSelector = Instance.new("Frame", MainScrollFrame)
PlayerSelector.Size = UDim2.new(1, -10, 0, 150)
PlayerSelector.Position = UDim2.new(0, 5, 0, 0)
PlayerSelector.BackgroundTransparency = 1

local MidImage = Instance.new("ImageLabel", PlayerSelector)
MidImage.Size = UDim2.new(0, 70, 0, 70)
MidImage.Position = UDim2.new(0.5, -35, 0, 10)
MidImage.BackgroundTransparency = 1
MidImage.Image = ""
Instance.new("UICorner", MidImage).CornerRadius = UDim.new(1, 0)

local PlayerInfo = Instance.new("Frame", PlayerSelector)
PlayerInfo.Size = UDim2.new(1, 0, 0, 70)
PlayerInfo.Position = UDim2.new(0, 0, 0, 85)
PlayerInfo.BackgroundTransparency = 1

local UserLabel = Instance.new("TextLabel", PlayerInfo)
UserLabel.Size = UDim2.new(1, 0, 0.4, 0)
UserLabel.Position = UDim2.new(0, 0, 0, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "User"
UserLabel.Font = Enum.Font.GothamBold
UserLabel.TextSize = 20
UserLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UserLabel.TextXAlignment = Enum.TextXAlignment.Center

local NickLabel = Instance.new("TextLabel", PlayerInfo)
NickLabel.Size = UDim2.new(1, 0, 0.3, 0)
NickLabel.Position = UDim2.new(0, 0, 0.4, 0)
NickLabel.BackgroundTransparency = 1
NickLabel.Text = "NickName"
NickLabel.Font = Enum.Font.Gotham
NickLabel.TextSize = 15
NickLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
NickLabel.TextXAlignment = Enum.TextXAlignment.Center

local NickTextBox = Instance.new("TextBox", PlayerInfo)
NickTextBox.Size = UDim2.new(0.8, 0, 0.5, 0)
NickTextBox.Position = UDim2.new(0.1, 0, 0.7, 0)
NickTextBox.Text = ""
NickTextBox.PlaceholderText = "اكتب اسم اللاعب..."
NickTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
NickTextBox.ClearTextOnFocus = true
NickTextBox.Font = Enum.Font.Gotham
NickTextBox.TextSize = 14
NickTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NickTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NickTextBox.BorderSizePixel = 0
NickTextBox.TextXAlignment = Enum.TextXAlignment.Center
NickTextBox.TextYAlignment = Enum.TextYAlignment.Center
Instance.new("UICorner", NickTextBox).CornerRadius = UDim.new(0, 8)

-- ===========================================
-- 🎮 دالة إنشاء أزرار عامة
-- ===========================================

local function createButton(name, position, width, height, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(width, 0, 0, height)
    btn.Position = position
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.4
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- ===========================================
-- 🎭 نظام التوهج
-- ===========================================

local function createGlow(button)
    local gradient = Instance.new("UIGradient", button)
    gradient.Rotation = 0
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Offset = Vector2.new(-1, 0)
    local tween = TweenService:Create(gradient, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Offset = Vector2.new(1, 0)})
    tween:Play()
    return gradient, tween
end

local function removeGlow(button)
    local gradient = button:FindFirstChildOfClass("UIGradient")
    if gradient then
        gradient:Destroy()
    end
end

local function flashGlow(button, duration)
    local gradient = Instance.new("UIGradient", button)
    gradient.Rotation = 0
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Offset = Vector2.new(-1, 0)
    local tween = TweenService:Create(gradient, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        gradient:Destroy()
    end)
end

-- ===========================================
-- 🎯 نظام استهداف اللاعب
-- ===========================================

local targetPlayer = nil
local watchingEnabled = false
local bangActive = false
local faceBangActive = false
local headSitActive = false
local backpackActive = false
local suckActive = false
local benxActive = false

local function GetRoot(plr)
    if plr and plr.Character then
        return plr.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function setTargetFromText()
    local search = NickTextBox.Text:lower()
    if #search < 2 then
        targetPlayer = nil
        UserLabel.Text = "اليوزر"
        NickLabel.Text = "الاسم"
        MidImage.Image = "rbxassetid://7992557358"
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        local name = plr.Name:lower()
        local nick = plr.DisplayName:lower()
        if string.find(name, search, 1, true) or string.find(nick, search, 1, true) then
            if CheckTargetProtection(plr.Name) then
                return
            end
            
            targetPlayer = plr
            UserLabel.Text = plr.Name
            NickLabel.Text = plr.DisplayName
            MidImage.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            
            local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            createNotification("GBORE SYSTEM","تم استهداف اللاعب "..plr.DisplayName,thumb,5)
            break
        end
    end
end

NickTextBox:GetPropertyChangedSignal("Text"):Connect(setTargetFromText)

-- ===========================================
-- 🎮 أزرار صفحة الاستهداف
-- ===========================================

local startY = 160
local buttonWidth = 0.48
local buttonHeight = 32
local buttonSpacing = 36

-- الصف الأول
local WatchButton = createButton("مـشـاهـده", UDim2.new(0.02, 0, 0, startY), buttonWidth, buttonHeight, MainScrollFrame)
local TeleportButton = createButton("انـتـقـال", UDim2.new(0.51, 0, 0, startY), buttonWidth, buttonHeight, MainScrollFrame)

-- الصف الثاني
local BangButton = createButton("نيك خلفي", UDim2.new(0.02, 0, 0, startY + buttonSpacing), buttonWidth, buttonHeight, MainScrollFrame)
local FaceBangButton = createButton("بـانـق وجـه", UDim2.new(0.51, 0, 0, startY + buttonSpacing), buttonWidth, buttonHeight, MainScrollFrame)

-- الصف الثالث
local HeadSitButton = createButton("جـلـوس فـوق راسـه", UDim2.new(0.02, 0, 0, startY + buttonSpacing * 2), buttonWidth, buttonHeight, MainScrollFrame)
local BackpackButton = createButton("حـقـيـبـة ظـهـر", UDim2.new(0.51, 0, 0, startY + buttonSpacing * 2), buttonWidth, buttonHeight, MainScrollFrame)

-- الصف الرابع
local SuckButton = createButton("مـص قـضـيـبـه", UDim2.new(0.02, 0, 0, startY + buttonSpacing * 3), buttonWidth, buttonHeight, MainScrollFrame)
local BenxButton = createButton("يـغـتـصـبـك", UDim2.new(0.51, 0, 0, startY + buttonSpacing * 3), buttonWidth, buttonHeight, MainScrollFrame)

-- الصف الخامس
local CopyFatButton = createButton("نـسـخ تـسـمـيـن", UDim2.new(0.02, 0, 0, startY + buttonSpacing * 4), buttonWidth, buttonHeight, MainScrollFrame)
local CopyAntiHackButton = createButton("نـسـخ رهـيـب", UDim2.new(0.51, 0, 0, startY + buttonSpacing * 4), buttonWidth, buttonHeight, MainScrollFrame)

-- ===========================================
-- 🎮 نظام المشاهدة
-- ===========================================

WatchButton.MouseButton1Click:Connect(function()
    local plr = Players:FindFirstChild(UserLabel.Text)
    if not plr then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(plr.Name) then return end

    if watchingEnabled then
        watchingEnabled = false
        WatchButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if WatchButton:FindFirstChildOfClass("UIGradient") then
            WatchButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
        createNotification("GBORE", "تم إيقاف المشاهدة", "rbxassetid://7992557358", 3)
        return
    end

    watchingEnabled = true
    WatchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    createGlow(WatchButton)
    if plr.Character then
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
        end
    end
    createNotification("GBORE", "تم تشغيل المشاهدة على "..plr.Name, "rbxassetid://7992557358", 3)
    
    plr.CharacterAdded:Connect(function(char)
        if watchingEnabled then
            repeat task.wait() until char:FindFirstChild("Humanoid")
            workspace.CurrentCamera.CameraSubject = char:FindFirstChild("Humanoid")
        end
    end)
end)

-- ===========================================
-- ⚡ نظام الانتقال
-- ===========================================

TeleportButton.MouseButton1Click:Connect(function()
    local plr = Players:FindFirstChild(UserLabel.Text)
    if not plr then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if not GetRoot(plr) then 
        createNotification("Gbore", "اللاعب غير موجود في الماب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(plr.Name) then return end

    local targetPos = GetRoot(plr).Position
    local playerRoot = GetRoot(LocalPlayer)
    if playerRoot then
        playerRoot.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        flashGlow(TeleportButton, 1)
        createNotification("GBORE", "تم الانتقال إلى "..plr.Name, "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 👥 نظام البانق الخلفي
-- ===========================================

local bangHeartbeat = nil
local bangAnimationId = "10714068222"

local function playBangAnimation()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://"..bangAnimationId
    local animTrack = humanoid:LoadAnimation(animation)
    animTrack.Looped = true
    animTrack:Play()
    animTrack:AdjustSpeed(70)
end

local function startBang()
    if not targetPlayer or not targetPlayer.Character then return end
    if CheckTargetProtection(targetPlayer.Name) then return end

    playBangAnimation()
    if bangHeartbeat then bangHeartbeat:Disconnect() end
    
    bangHeartbeat = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and LocalPlayer.Character then
            local targetTorso = targetPlayer.Character:FindFirstChild("UpperTorso") or targetPlayer.Character:FindFirstChild("Torso")
            local playerHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetTorso and playerHRP then
                playerHRP.CFrame = targetTorso.CFrame * CFrame.new(0, 0, 0.70)
            end
        end
    end)
end

local function stopBang()
    if bangHeartbeat then bangHeartbeat:Disconnect() bangHeartbeat = nil end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop() end
    end
end

BangButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    bangActive = not bangActive
    if bangActive then
        BangButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        createGlow(BangButton)
        startBang()
        createNotification("GBORE", "تم تشغيل البانق الخلفي على "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        BangButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
        if BangButton:FindFirstChildOfClass("UIGradient") then
            BangButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopBang()
        createNotification("GBORE", "تم إيقاف البانق الخلفي", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 😁 نظام البانق الوجهي
-- ===========================================

local faceBangHeartbeat = nil
local suckAnimTrack = nil
local currentDistance = 1.5
local movingIn = true
local movementSpeed = 0.3
local minDistance = 0.5
local maxDistance = 2.5

local function updateFaceBang()
    while faceBangActive do
        local localChar = LocalPlayer.Character
        if not localChar then RunService.Heartbeat:Wait() continue end
        
        local humanoid = localChar:FindFirstChildOfClass("Humanoid")
        if humanoid and faceBangActive then
            humanoid.Sit = true
            humanoid.PlatformStand = false
            if not suckAnimTrack then
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://2506281703"
                suckAnimTrack = humanoid:LoadAnimation(animation)
                suckAnimTrack:Play()
                suckAnimTrack:AdjustSpeed(1.5)
            end
        end

        if targetPlayer and targetPlayer.Character then
            if CheckTargetProtection(targetPlayer.Name) then
                faceBangActive = false
                break
            end
            
            local humanoidRootPart = localChar:FindFirstChild("HumanoidRootPart")
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            if humanoidRootPart and targetHead then
                if movingIn then
                    currentDistance = currentDistance - movementSpeed
                    if currentDistance <= minDistance then movingIn = false end
                else
                    currentDistance = currentDistance + movementSpeed
                    if currentDistance >= maxDistance then movingIn = true end
                end
                local faceDirection = targetHead.CFrame.LookVector
                local targetPosition = targetHead.Position + (faceDirection * currentDistance)
                targetPosition = Vector3.new(targetPosition.X, targetHead.Position.Y, targetPosition.Z)
                humanoidRootPart.CFrame = CFrame.new(targetPosition, targetHead.Position)
                humanoidRootPart.Velocity = Vector3.new(0,2,0)
            end
        end

        RunService.Heartbeat:Wait()
    end

    local localChar = LocalPlayer.Character
    if localChar then
        local humanoid = localChar:FindFirstChildOfClass("Humanoid")
        if humanoid then 
            humanoid.Sit = false 
            humanoid.PlatformStand = false
        end
    end
    if suckAnimTrack then suckAnimTrack:Stop() suckAnimTrack = nil end
end

FaceBangButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    faceBangActive = not faceBangActive
    if faceBangActive then
        FaceBangButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        createGlow(FaceBangButton)
        spawn(updateFaceBang)
        createNotification("GBORE", "تم تشغيل البانق الوجهي على "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        FaceBangButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
        if FaceBangButton:FindFirstChildOfClass("UIGradient") then
            FaceBangButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        faceBangActive = false
        createNotification("GBORE", "تم إيقاف البانق الوجهي", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🧑‍🦽 نظام الجلوس فوق الرأس - معدل
-- ===========================================

local headSitHeartbeat = nil

local function startHeadSit()
    if not targetPlayer or not targetPlayer.Character then return end
    if CheckTargetProtection(targetPlayer.Name) then return end
    
    if headSitHeartbeat then headSitHeartbeat:Disconnect() end
    
    headSitHeartbeat = RunService.Heartbeat:Connect(function()
        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local plrRoot = character:FindFirstChild("HumanoidRootPart")
            if not plrRoot then return end
            
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            if not targetHead then return end
            
            -- تأكد من أن اللاعب يجلس
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = true
                humanoid.PlatformStand = false
                if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                    humanoid:ChangeState(Enum.HumanoidStateType.Seated)
                end
            end
            
            -- وضع فوق الرأس
            plrRoot.CFrame = targetHead.CFrame * CFrame.new(0, 2, 0)
            plrRoot.Velocity = Vector3.new(0, 0, 0)
        end)
    end)
end

local function stopHeadSit()
    if headSitHeartbeat then
        headSitHeartbeat:Disconnect()
        headSitHeartbeat = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = false
        end
    end
end

HeadSitButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    headSitActive = not headSitActive
    if headSitActive then
        HeadSitButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(HeadSitButton)
        startHeadSit()
        createNotification("GBORE", "تم تشغيل الجلوس فوق الرأس على "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        HeadSitButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if HeadSitButton:FindFirstChildOfClass("UIGradient") then
            HeadSitButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopHeadSit()
        createNotification("GBORE", "تم إيقاف الجلوس فوق الرأس", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🎒 نظام الحقيبة الظهر - معدل
-- ===========================================

local backpackHeartbeat = nil

local function startBackpack()
    if not targetPlayer or not targetPlayer.Character then return end
    if CheckTargetProtection(targetPlayer.Name) then return end
    
    if backpackHeartbeat then backpackHeartbeat:Disconnect() end
    
    backpackHeartbeat = RunService.Heartbeat:Connect(function()
        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            local target = targetPlayer.Character
            if not target then return end
            
            local targetTorso = target:FindFirstChild("Torso") or target:FindFirstChild("UpperTorso")
            if not targetTorso then return end
            
            -- تأكد من أن اللاعب يجلس
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = true
                humanoid.PlatformStand = false
                if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                    humanoid:ChangeState(Enum.HumanoidStateType.Seated)
                end
            end
            
            -- وضع في الخلف (حقيبة ظهر)
            root.CFrame = targetTorso.CFrame * CFrame.new(0, 0.5, 1.2) * CFrame.Angles(0, math.rad(180), 0)
            root.Velocity = Vector3.new(0, 0, 0)
        end)
    end)
end

local function stopBackpack()
    if backpackHeartbeat then
        backpackHeartbeat:Disconnect()
        backpackHeartbeat = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = false
        end
    end
end

BackpackButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    backpackActive = not backpackActive
    if backpackActive then
        BackpackButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(BackpackButton)
        startBackpack()
        createNotification("GBORE", "تم تشغيل حقيبة الظهر على "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        BackpackButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if BackpackButton:FindFirstChildOfClass("UIGradient") then
            BackpackButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopBackpack()
        createNotification("GBORE", "تم إيقاف حقيبة الظهر", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 💦 نظام المص
-- ===========================================

local suckHeartbeat = nil
local currentDistance2 = 1.5
local movingIn2 = true

local function updateSuck()
    while suckActive do
        if targetPlayer and targetPlayer.Character then
            if CheckTargetProtection(targetPlayer.Name) then
                suckActive = false
                break
            end
            
            local humanoidRootPart = GetRoot(LocalPlayer)
            local targetHRP = GetRoot(targetPlayer)
            
            if humanoidRootPart and targetHRP then
                if movingIn2 then currentDistance2 = currentDistance2 - movementSpeed
                else currentDistance2 = currentDistance2 + movementSpeed end
                if currentDistance2 <= 0.5 then movingIn2 = false end
                if currentDistance2 >= 2.5 then movingIn2 = true end
                
                local targetPosition = targetHRP.Position - Vector3.new(0, 2, 0) + (targetHRP.CFrame.LookVector * currentDistance2)
                humanoidRootPart.CFrame = CFrame.new(targetPosition, targetHRP.Position - Vector3.new(0, 2, 0))
                humanoidRootPart.Velocity = Vector3.new(0, 2, 0)
            end
        end
        RunService.Heartbeat:Wait()
    end
end

SuckButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    suckActive = not suckActive
    if suckActive then
        SuckButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(SuckButton)
        task.spawn(updateSuck)
        createNotification("GBORE", "تم تشغيل المص على "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        SuckButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if SuckButton:FindFirstChildOfClass("UIGradient") then
            SuckButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        suckActive = false
        createNotification("GBORE", "تم إيقاف المص", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🔥 نظام الاغتصاب - معدل (جلوس بتحرك)
-- ===========================================

local benxHeartbeat = nil
getgenv().Benx = false
local benxSitOffset = 0
local benxDirection = 1

local function startBenx()
    if not targetPlayer or not targetPlayer.Character then return end
    if CheckTargetProtection(targetPlayer.Name) then return end

    getgenv().Benx = true

    coroutine.wrap(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        -- تأكد من الجلوس أولاً
        if humanoid then
            humanoid.Sit = true
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
        end

        repeat
            task.wait(0.1)
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                local targetChar = targetPlayer.Character
                
                if not hrp or not hum or not targetChar then return end
                
                local targetLowerTorso = targetChar:FindFirstChild("LowerTorso")
                if not targetLowerTorso then return end
                
                -- تحريك متدرج مع جلوس
                benxSitOffset = benxSitOffset + (0.3 * benxDirection)
                
                if benxSitOffset > 2.5 then
                    benxDirection = -1
                elseif benxSitOffset < 1 then
                    benxDirection = 1
                end
                
                -- إجبار الجلوس المستمر
                hum.Sit = true
                hum.PlatformStand = false
                
                -- وضعية الجلوس للإغتصاب
                local targetCFrame = targetLowerTorso.CFrame
                local sitCFrame = targetCFrame * CFrame.new(0, -0.8, -benxSitOffset) * CFrame.Angles(-1.5, 0, 0)
                
                hrp.CFrame = sitCFrame
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                -- تأكيد حالة الجلوس
                if hum:GetState() ~= Enum.HumanoidStateType.Seated then
                    hum:ChangeState(Enum.HumanoidStateType.Seated)
                end
            end)
        until not getgenv().Benx or not benxActive

        -- التوقف عن الجلوس عند الإيقاف
        pcall(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Sit = false
                    hum.PlatformStand = false
                    task.wait(0.1)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        -- إعادة تعيين المتغيرات
        benxSitOffset = 0
        benxDirection = 1
    end)()
end

local function stopBenx()
    getgenv().Benx = false
end

BenxButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    benxActive = not benxActive
    if benxActive then
        BenxButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(BenxButton)
        startBenx()
        createNotification("GBORE", "تم تشغيل الاغتصاب (جلوس) على "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        BenxButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if BenxButton:FindFirstChildOfClass("UIGradient") then
            BenxButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopBenx()
        createNotification("GBORE", "تم إيقاف الاغتصاب", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 📝 أنظمة النسخ الكاملة
-- ===========================================

local copyFatActive = false
local copyAntiHackActive = false

local function getPlayerPrefix()
    if not targetPlayer then return "" end
    local name = targetPlayer.Name
    if #name >= 3 then return string.sub(name, 1, 3) else return name end
end

-- نسخ تسمين
CopyFatButton.MouseButton1Click:Connect(function()

    if not targetPlayer then 
        createNotification("GBORE", "لم يتم تحديد لاعب", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    copyAntiHackActive = not copyAntiHackActive
    if copyAntiHackActive then
        CopyAntiHackButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(CopyAntiHackButton)
        local prefix = getPlayerPrefix()
        local args = {".size " .. prefix .. " 3 .height " .. prefix .. " 1 .fat " .. prefix .. " .thin " .. prefix .. " .sit " .. prefix .. " .neon " .. prefix .. " .paint " .. prefix .. " pk"}
        task.spawn(function()
            while copyAntiHackActive do
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("HDAdminHDClient"):WaitForChild("Signals"):WaitForChild("RequestCommandSilent"):InvokeServer(unpack(args))
                end)
                task.wait(7)
            end
        end)
        createNotification("GBORE", "تم تشغيل النسخ القوي "..targetPlayer.Name, "rbxassetid://7992557358", 3)
    else
        CopyAntiHackButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if CopyAntiHackButton:FindFirstChildOfClass("UIGradient") then
            CopyAntiHackButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        createNotification("GBORE", "تم إيقاف النسخ القوي", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🎨 صفحة الميزات
-- ===========================================

local otherStartY = 10

-- سبام الرسائل
local SpamTextBox = Instance.new("TextBox", OtherScrollFrame)
SpamTextBox.Size = UDim2.new(1, -10, 0, 35)
SpamTextBox.Position = UDim2.new(0, 5, 0, otherStartY)
SpamTextBox.Text = "اكـتـب هـنـا"
SpamTextBox.ClearTextOnFocus = true
SpamTextBox.Font = Enum.Font.Gotham
SpamTextBox.TextSize = 14
SpamTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpamTextBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
SpamTextBox.TextXAlignment = Enum.TextXAlignment.Center
SpamTextBox.TextYAlignment = Enum.TextYAlignment.Center
Instance.new("UICorner", SpamTextBox).CornerRadius = UDim.new(0, 6)

local SpamButton = createButton("سـبـام رسـايـل", UDim2.new(0.02, 0, 0, otherStartY + 45), 0.96, 35, OtherScrollFrame)

-- الصف الأول
local AntiKlbButton = createButton("مـضـاد كـلـبـش", UDim2.new(0.02, 0, 0, otherStartY + 90), 0.48, 32, OtherScrollFrame)
local AntiBanqButton = createButton("مـضـاد بـانـق", UDim2.new(0.51, 0, 0, otherStartY + 90), 0.48, 32, OtherScrollFrame)

-- الصف الثاني
local AntiCopyButton = createButton("مـضـاد نـسـخ", UDim2.new(0.02, 0, 0, otherStartY + 132), 0.48, 32, OtherScrollFrame)
local AntiCopyMButton = createButton("مـضـاد نـسـخ (M)", UDim2.new(0.51, 0, 0, otherStartY + 132), 0.48, 32, OtherScrollFrame)

-- الصف الثالث
local RandomSizeButton = createButton("حـجـم عـشـوائـي", UDim2.new(0.02, 0, 0, otherStartY + 174), 0.48, 32, OtherScrollFrame)
local RandomSkinButton = createButton("سـكـن عـشـوائـي", UDim2.new(0.51, 0, 0, otherStartY + 174), 0.48, 32, OtherScrollFrame)

-- الصف الرابع
local AntiAfkButton = createButton("مـضـاد افـك", UDim2.new(0.02, 0, 0, otherStartY + 216), 0.48, 32, OtherScrollFrame)
local CmdNearButton = createButton("اوامـر لـلـقـريـبـيـن", UDim2.new(0.51, 0, 0, otherStartY + 216), 0.48, 32, OtherScrollFrame)

-- الصف الخامس
local PrepButton = createButton("تـجـهـيـز صـمـلـه", UDim2.new(0.02, 0, 0, otherStartY + 258), 0.48, 32, OtherScrollFrame)
local AutoPrepButton = createButton("تـجـهـيـز تـلـقـائـي", UDim2.new(0.51, 0, 0, otherStartY + 258), 0.48, 32, OtherScrollFrame)

-- الصف السادس
local FlyButton = createButton("طـيـران", UDim2.new(0.02, 0, 0, otherStartY + 300), 0.48, 32, OtherScrollFrame)
local NoclipButton = createButton("نـوكـلـيـب", UDim2.new(0.51, 0, 0, otherStartY + 300), 0.48, 32, OtherScrollFrame)

-- الصف السابع
local TeleportToolButton = createButton("اداة تنقل", UDim2.new(0.02, 0, 0, otherStartY + 342), 0.48, 32, OtherScrollFrame)
local SpinButton = createButton("دوران", UDim2.new(0.51, 0, 0, otherStartY + 342), 0.48, 32, OtherScrollFrame)

-- الصف الثامن
local JumpTextBox = Instance.new("TextBox", OtherScrollFrame)
JumpTextBox.Size = UDim2.new(0.48, 0, 0, 32)
JumpTextBox.Position = UDim2.new(0.02, 0, 0, otherStartY + 384)
JumpTextBox.Text = "قوة القفز"
JumpTextBox.Font = Enum.Font.Gotham
JumpTextBox.TextSize = 13
JumpTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
JumpTextBox.BorderColor3 = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", JumpTextBox).CornerRadius = UDim.new(0, 6)
JumpTextBox.ClearTextOnFocus = true

local SpeedTextBox = Instance.new("TextBox", OtherScrollFrame)
SpeedTextBox.Size = UDim2.new(0.48, 0, 0, 32)
SpeedTextBox.Position = UDim2.new(0.51, 0, 0, otherStartY + 384)
SpeedTextBox.Text = "عدد السرعة"
SpeedTextBox.Font = Enum.Font.Gotham
SpeedTextBox.TextSize = 13
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedTextBox.BorderColor3 = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", SpeedTextBox).CornerRadius = UDim.new(0, 6)
SpeedTextBox.ClearTextOnFocus = true

-- الصف التاسع
local JumpButton = createButton("قـفـز لـلاعـب", UDim2.new(0.02, 0, 0, otherStartY + 426), 0.48, 32, OtherScrollFrame)
local SpeedButton = createButton("سـرعـه لـلاعـب", UDim2.new(0.51, 0, 0, otherStartY + 426), 0.48, 32, OtherScrollFrame)

-- الصف العاشر
local RejoinButton = createButton("اعـادة دخـول لـسـيـرفـر", UDim2.new(0.02, 0, 0, otherStartY + 468), 0.48, 32, OtherScrollFrame)
local ChangeServerButton = createButton("تـغـيـر الـسـيـرفـر", UDim2.new(0.51, 0, 0, otherStartY + 468), 0.48, 32, OtherScrollFrame)

-- الصف الحادي عشر
local DeleteHatButton = createButton("حذف القبعة", UDim2.new(0.02, 0, 0, otherStartY + 510), 0.48, 32, OtherScrollFrame)
local DeleteToolButton = createButton("حذف الأدوات", UDim2.new(0.51, 0, 0, otherStartY + 510), 0.48, 32, OtherScrollFrame)

-- الصف الثاني عشر
local InvisibleButton = createButton("اختفاء", UDim2.new(0.02, 0, 0, otherStartY + 552), 0.48, 32, OtherScrollFrame)

-- أداة اختيار اللاعبين
local SelectToolButton = createButton("أداة اختيار", UDim2.new(0.51, 0, 0, otherStartY + 552), 0.48, 32, OtherScrollFrame)

-- ===========================================
-- 🔧 أنظمة الميزات
-- ===========================================

-- سبام الرسائل
local spamActive = false
local spamLoop = nil

SpamButton.MouseButton1Click:Connect(function()
    spamActive = not spamActive
    
    if spamActive then
        SpamButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(SpamButton)
        
        spamLoop = task.spawn(function()
            while spamActive do
                local text = SpamTextBox.Text
                if #text >= 1 then
                    local args = { text }
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args))
                    end)
                end
                task.wait(0.3)
            end
        end)
        createNotification("GBORE", "تم تشغيل سبام الرسائل", "rbxassetid://7992557358", 3)
    else
        SpamButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if SpamButton:FindFirstChildOfClass("UIGradient") then
            SpamButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        spamActive = false
        if spamLoop then spamLoop = nil end
        createNotification("GBORE", "تم إيقاف سبام الرسائل", "rbxassetid://7992557358", 3)
    end
end)

-- مضاد كلبش
local antibotActive = false
local antibotLoop = nil

AntiKlbButton.MouseButton1Click:Connect(function()
    antibotActive = not antibotActive
    
    if antibotActive then
        AntiKlbButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(AntiKlbButton)
        
        antibotLoop = task.spawn(function()
            local lp = Players.LocalPlayer
            local function fixMovement()
                local char = lp.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                hum.AutoRotate = true
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                while hum.Parent and antibotActive do
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hum.Sit = true
                    task.wait(0.1)
                end
            end
            lp.CharacterAdded:Connect(function()
                task.wait(0.5)
                fixMovement()
            end)
            if lp.Character then
                task.wait(0.5)
                fixMovement()
            end
        end)
        createNotification("GBORE", "تم تشغيل مضاد الكلبش", "rbxassetid://7992557358", 3)
    else
        AntiKlbButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if AntiKlbButton:FindFirstChildOfClass("UIGradient") then
            AntiKlbButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        antibotActive = false
        if antibotLoop then antibotLoop = nil end
        createNotification("GBORE", "تم إيقاف مضاد الكلبش", "rbxassetid://7992557358", 3)
    end
end)

-- مضاد بانق
local antibanActive = false
local antibanLoop = nil

AntiBanqButton.MouseButton1Click:Connect(function()
    antibanActive = not antibanActive
    
    if antibanActive then
        AntiBanqButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(AntiBanqButton)
        
        antibanLoop = task.spawn(function()
            while antibanActive do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local lastCFrame = hrp.CFrame
                    workspace.FallenPartsDestroyHeight = -1000
                    hrp.CFrame = CFrame.new(Vector3.new(0,-500,0))
                    task.wait(0.7)
                    hrp.CFrame = lastCFrame
                    workspace.FallenPartsDestroyHeight = -500
                end
                task.wait(1)
            end
        end)
        createNotification("GBORE", "تم تشغيل مضاد البانق", "rbxassetid://7992557358", 3)
    else
        AntiBanqButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if AntiBanqButton:FindFirstChildOfClass("UIGradient") then
            AntiBanqButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        antibanActive = false
        if antibanLoop then antibanLoop = nil end
        createNotification("GBORE", "تم إيقاف مضاد البانق", "rbxassetid://7992557358", 3)
    end
end)

-- مضاد نسخ
local antiCopyActive = false
local antiCopyLoop = nil

AntiCopyButton.MouseButton1Click:Connect(function()
    antiCopyActive = not antiCopyActive
    
    if antiCopyActive then
        AntiCopyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(AntiCopyButton)
        
        antiCopyLoop = task.spawn(function()
            while antiCopyActive do
                pcall(function()
                    local args1 = {"0.9"}
                    game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Size"):FireServer(unpack(args1))
                    local args2 = {" \226\128\152", Color3.new(0, 0, 0), "n"}
                    game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Title"):FireServer(unpack(args2))
                end)
                task.wait(1)
            end
        end)
        createNotification("GBORE", "تم تشغيل مضاد النسخ", "rbxassetid://7992557358", 3)
    else
        AntiCopyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if AntiCopyButton:FindFirstChildOfClass("UIGradient") then
            AntiCopyButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        antiCopyActive = false
        if antiCopyLoop then antiCopyLoop = nil end
        createNotification("GBORE", "تم إيقاف مضاد النسخ", "rbxassetid://7992557358", 3)
    end
end)

-- مضاد نسخ (M)
local antiCopyMActive = false
local antiCopyMLoop = nil

AntiCopyMButton.MouseButton1Click:Connect(function()
    antiCopyMActive = not antiCopyMActive
    
    if antiCopyMActive then
        AntiCopyMButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(AntiCopyMButton)
        
        antiCopyMLoop = task.spawn(function()
            while antiCopyMActive do
                local args = {
                    ".unneon me .unsize me .unaura me .unbox me .untitle me .unpaint .unheight me"
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("HDAdminHDClient"):WaitForChild("Signals"):WaitForChild("RequestCommandSilent"):InvokeServer(unpack(args))
                end)
                task.wait(5)
            end
        end)
        createNotification("GBORE", "تم تشغيل مضاد النسخ (M)", "rbxassetid://7992557358", 3)
    else
        AntiCopyMButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if AntiCopyMButton:FindFirstChildOfClass("UIGradient") then
            AntiCopyMButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        antiCopyMActive = false
        if antiCopyMLoop then antiCopyMLoop = nil end
        createNotification("GBORE", "تم إيقاف مضاد النسخ (M)", "rbxassetid://7992557358", 3)
    end
end)

-- حجم عشوائي
local randomSizeActive = false
local randomSizeLoop = nil

RandomSizeButton.MouseButton1Click:Connect(function()
    randomSizeActive = not randomSizeActive
    
    if randomSizeActive then
        RandomSizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(RandomSizeButton)
        
        randomSizeLoop = task.spawn(function()
            while randomSizeActive do
                local sizes = {"1", "1.3", "1.7", "1.8", "0.9"}
                for _, s in pairs(sizes) do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Size"):FireServer(s)
                    end)
                    task.wait(0.5)
                end
            end
        end)
        createNotification("GBORE", "تم تشغيل الحجم العشوائي", "rbxassetid://7992557358", 3)
    else
        RandomSizeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if RandomSizeButton:FindFirstChildOfClass("UIGradient") then
            RandomSizeButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        randomSizeActive = false
        if randomSizeLoop then randomSizeLoop = nil end
        createNotification("GBORE", "تم إيقاف الحجم العشوائي", "rbxassetid://7992557358", 3)
    end
end)

-- سكن عشوائي
local randomSkinActive = false
local randomSkinLoop = nil

RandomSkinButton.MouseButton1Click:Connect(function()
    randomSkinActive = not randomSkinActive
    
    if randomSkinActive then
        RandomSkinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(RandomSkinButton)
        
        randomSkinLoop = task.spawn(function()
            while randomSkinActive do
                local skins = {
                    {2291954878, "n"},
                    {7201145808, "n"},
                    {1306261556, "n"},
                    {5134648287, "n"},
                    {2578699902, "n"},
                    {4294786270, "n"}
                }
                for _, skin in pairs(skins) do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Char"):FireServer(skin[1], skin[2])
                    end)
                    task.wait(0.5)
                end
            end
        end)
        createNotification("GBORE", "تم تشغيل السكن العشوائي", "rbxassetid://7992557358", 3)
    else
        RandomSkinButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if RandomSkinButton:FindFirstChildOfClass("UIGradient") then
            RandomSkinButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        randomSkinActive = false
        if randomSkinLoop then randomSkinLoop = nil end
        createNotification("GBORE", "تم إيقاف السكن العشوائي", "rbxassetid://7992557358", 3)
    end
end)

-- مضاد افك
local antiAfkActive = false
local antiAfkLoop = nil

AntiAfkButton.MouseButton1Click:Connect(function()
    antiAfkActive = not antiAfkActive
    
    if antiAfkActive then
        AntiAfkButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(AntiAfkButton)
        
        antiAfkLoop = game:GetService('Players').LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        createNotification("GBORE", "تم تشغيل مضاد الافك", "rbxassetid://7992557358", 3)
    else
        AntiAfkButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if AntiAfkButton:FindFirstChildOfClass("UIGradient") then
            AntiAfkButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        if antiAfkLoop then
            antiAfkLoop:Disconnect()
            antiAfkLoop = nil
        end
        createNotification("GBORE", "تم إيقاف مضاد الافك", "rbxassetid://7992557358", 3)
    end
end)

local cmdNearGui = nil

local function createCmdNearGui()
    if cmdNearGui and cmdNearGui.Parent then return end
    if cmdNearGui then
        cmdNearGui:Destroy()
        cmdNearGui = nil
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "GBORE_CmdNearGui"
    sg.Parent = CoreGui
    sg.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 260)
    frame.Position = UDim2.new(0.5, -150, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Size = UDim2.new(1, -90, 0, 40)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "اوامر على القريبين | GBORE"
    title.TextColor3 = Color3.fromRGB(255, 0, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 19
    title.TextXAlignment = Enum.TextXAlignment.Left

    local xb = Instance.new("TextButton")
    xb.Parent = frame
    xb.Size = UDim2.new(0, 34, 0, 34)
    xb.Position = UDim2.new(1, -42, 0, 3)
    xb.BackgroundColor3 = Color3.fromRGB(255, 40, 80)
    xb.Text = "X"
    xb.TextSize = 24
    xb.Font = Enum.Font.GothamBold
    xb.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", xb).CornerRadius = UDim.new(0, 12)
    xb.MouseButton1Click:Connect(function()
        if sg then
            sg:Destroy()
            cmdNearGui = nil
        end
    end)

    local mb = Instance.new("TextButton")
    mb.Parent = frame
    mb.Size = UDim2.new(0, 34, 0, 34)
    mb.Position = UDim2.new(1, -82, 0, 3)
    mb.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    mb.Text = "_"
    mb.TextSize = 30
    mb.Font = Enum.Font.GothamBold
    mb.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 12)

    local skinTextBox = Instance.new("TextBox")
    skinTextBox.Parent = frame
    skinTextBox.Size = UDim2.new(0, 268, 0, 38)
    skinTextBox.Position = UDim2.new(0.5, -134, 0, 50)
    skinTextBox.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    skinTextBox.PlaceholderText = "كود السكن (فاضي = miri)"
    skinTextBox.Text = ""
    skinTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    skinTextBox.Font = Enum.Font.Gotham
    skinTextBox.TextSize = 16
    Instance.new("UICorner", skinTextBox).CornerRadius = UDim.new(0, 12)

    local last5 = {}
    local buttons = {}

    local function nearest5()
        if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return {} end
        local me = LocalPlayer.Character.HumanoidRootPart.Position
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - me).Magnitude
                if d < 500 then table.insert(t, {n = p.Name, d = d}) end
            end
        end
        table.sort(t, function(a, b) return a.d < b.d end)
        local r = {}
        for i = 1, math.min(5, #t) do table.insert(r, t[i].n) end
        if table.concat(r) == table.concat(last5) then return {} end
        last5 = r
        return r
    end

    local function fire(cmd)
        local targets = nearest5()
        if #targets == 0 then return end
        for _, n in ipairs(targets) do
            pcall(function()
                if cmd == ".char" then
                    local code = skinTextBox.Text ~= "" and skinTextBox.Text or "miri"
                    game.ReplicatedStorage.HDAdminHDClient.Signals.RequestCommandSilent:InvokeServer(".char " .. n .. " " .. code)
                elseif cmd == ".titlepk" then
                    game.ReplicatedStorage.HDAdminHDClient.Signals.RequestCommandSilent:InvokeServer(".titlepk " .. n .. " جبوري عمك")
                else
                    game.ReplicatedStorage.HDAdminHDClient.Signals.RequestCommandSilent:InvokeServer(cmd .. " " .. n)
                end
            end)
        end
    end

    local function fireSpecial(cmd)
        local targets = nearest5()
        if #targets == 0 then return end
        for _, n in ipairs(targets) do
            pcall(function()
                local args = {cmd:gsub("user", n)}
                game.ReplicatedStorage.HDAdminHDClient.Signals.RequestCommandSilent:InvokeServer(unpack(args))
            end)
        end
    end

    local function addBtn(txt, func, x, y)
        local b = Instance.new("TextButton")
        b.Parent = frame
        b.Size = UDim2.new(0, 128, 0, 46)
        b.Position = UDim2.new(0, x, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)

        local on = false
        b.MouseButton1Click:Connect(function()
            on = not on
            b.BackgroundColor3 = on and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(180, 0, 0)
            if on then
                task.spawn(function()
                    while on do
                        func()
                        task.wait(5)
                    end
                end)
            end
        end)
        table.insert(buttons, b)
    end

    addBtn("سكن للقريبين", function() fire(".char") end, 16, 100)
    addBtn("اسم للقريبين", function() fire(".titlepk") end, 156, 100)
    addBtn("تعليق للقريبين", function() fire(".aura") end, 16, 150)
    addBtn("كـلـب للقريبين", function() fire(".dog") end, 156, 150)
    addBtn("ري للقريبين", function() fireSpecial(".re user") end, 16, 200)
    addBtn("نيون للقريبين", function() fireSpecial(".neon user") end, 156, 200)

    local mini = false
    mb.MouseButton1Click:Connect(function()
        if mini then
            frame.Size = UDim2.new(0, 300, 0, 260)
            for _, b in ipairs(buttons) do b.Visible = true end
            skinTextBox.Visible = true
            mini = false
        else
            frame.Size = UDim2.new(0, 300, 0, 40)
            for _, b in ipairs(buttons) do b.Visible = false end
            skinTextBox.Visible = false
            mini = true
        end
    end)

    cmdNearGui = sg
end

-- أوامر للقريبين
CmdNearButton.MouseButton1Click:Connect(function()
    if cmdNearGui and cmdNearGui.Parent then
        cmdNearGui:Destroy()
        cmdNearGui = nil
    else
        createCmdNearGui()
    end
    flashGlow(CmdNearButton, 2)
    createNotification("GBORE", "تم فتح أوامر القريبين", "rbxassetid://7992557358", 3)
end)

-- تجهيز صمله
PrepButton.MouseButton1Click:Connect(function()
    local function runPrep()
        local args1 = {".char me ardaomeroglucooj"}
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args1))
        wait(0.5)

        local args2 = {"2"}
        game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Size"):FireServer(unpack(args2))
        wait(1)

        local args3 = {"3"}
        game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Size"):FireServer(unpack(args3))
        wait(0.5)

        local args4 = {".titlebk me 9MLH | \216\181\217\133\217\132\216\169"}
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args4))
        wait(1)
    end
    pcall(runPrep)
    flashGlow(PrepButton, 2)
    createNotification("GBORE", "تم تجهيز الصمله", "rbxassetid://7992557358", 3)
end)

-- تجهيز تلقائي
local autoPrepActive = false
local autoPrepLoop = nil

AutoPrepButton.MouseButton1Click:Connect(function()
    autoPrepActive = not autoPrepActive
    
    if autoPrepActive then
        AutoPrepButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(AutoPrepButton)
        
        autoPrepLoop = task.spawn(function()
            while autoPrepActive do
                local function runAutoPrep()
                    local args1 = {".char me ardaomeroglucooj"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args1))
                    wait(0.5)

                    local args2 = {"2"}
                    game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Size"):FireServer(unpack(args2))
                    wait(1)

                    local args3 = {"3"}
                    game:GetService("ReplicatedStorage"):WaitForChild("PrivateCommands"):WaitForChild("Size"):FireServer(unpack(args3))
                    wait(0.5)

                    local args4 = {".titlebk me 9MLH | \216\181\217\133\217\132\216\169"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SendMessage"):FireServer(unpack(args4))
                    wait(1)
                end
                pcall(runAutoPrep)
                task.wait(6)
            end
        end)
        createNotification("GBORE", "تم تشغيل التجهيز التلقائي", "rbxassetid://7992557358", 3)
    else
        AutoPrepButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if AutoPrepButton:FindFirstChildOfClass("UIGradient") then
            AutoPrepButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        autoPrepActive = false
        if autoPrepLoop then autoPrepLoop = nil end
        createNotification("GBORE", "تم إيقاف التجهيز التلقائي", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🚀 أنظمة الحركة
-- ===========================================

-- طيران
local flying = false
local lv, ao
local FlySpeed = 150

local function setupFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true
    lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge
    lv.Attachment0 = hrp:FindFirstChild("RootRigAttachment")
    lv.Parent = hrp
    ao = Instance.new("AlignOrientation")
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = math.huge
    ao.Attachment0 = hrp:FindFirstChild("RootRigAttachment")
    ao.Parent = hrp
end

local function stopFly()
    if lv then lv:Destroy() end
    if ao then ao:Destroy() end
    lv, ao = nil, nil
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if flying and lv and ao then
        local cam = Workspace.CurrentCamera
        local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        local mv = controlModule:GetMoveVector()
        ao.CFrame = cam.CFrame
        lv.VectorVelocity = cam.CFrame:VectorToWorldSpace(Vector3.new(mv.X, 0, mv.Z)) * FlySpeed
    end
end)

FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    
    if flying then
        FlyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(FlyButton)
        setupFly()
        createNotification("GBORE", "تم تشغيل الطيران", "rbxassetid://7992557358", 3)
    else
        FlyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if FlyButton:FindFirstChildOfClass("UIGradient") then
            FlyButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopFly()
        createNotification("GBORE", "تم إيقاف الطيران", "rbxassetid://7992557358", 3)
    end
end)

-- نوكليب
local noclipActive = false
local noclipConnection = nil

local function enableNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

NoclipButton.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    
    if noclipActive then
        NoclipButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(NoclipButton)
        enableNoclip()
        createNotification("GBORE", "تم تشغيل النوكليب", "rbxassetid://7992557358", 3)
    else
        NoclipButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if NoclipButton:FindFirstChildOfClass("UIGradient") then
            NoclipButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        disableNoclip()
        createNotification("GBORE", "تم إيقاف النوكليب", "rbxassetid://7992557358", 3)
    end
end)

-- أداة تنقل
local tpToolGiven = false
local tpTool = nil
local tpActive = false

local function giveTeleportTool()
    if tpToolGiven then return end
    tpToolGiven = true
    tpTool = Instance.new("Tool")
    tpTool.RequiresHandle = false
    tpTool.CanBeDropped = false
    tpTool.Name = "GBORE | اداة تنقل"
    tpTool.Parent = LocalPlayer.Backpack
    tpTool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local pos = mouse.Hit.p
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end)
    end)
end

TeleportToolButton.MouseButton1Click:Connect(function()
    tpActive = not tpActive
    
    if tpActive then
        TeleportToolButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(TeleportToolButton)
        giveTeleportTool()
        createNotification("GBORE", "تم إنشاء أداة التنقل في الحقيبة", "rbxassetid://7992557358", 3)
    else
        TeleportToolButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if TeleportToolButton:FindFirstChildOfClass("UIGradient") then
            TeleportToolButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        if tpTool and tpTool.Parent then
            tpTool:Destroy()
            tpToolGiven = false
            tpTool = nil
        end
        createNotification("GBORE", "تم إزالة أداة التنقل", "rbxassetid://7992557358", 3)
    end
end)

-- دوران
local spinActive = false
local spinThread = nil

local function startSpin()
    while spinActive do
        task.wait()
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(55), 0)
        end)
    end
end

SpinButton.MouseButton1Click:Connect(function()
    spinActive = not spinActive
    
    if spinActive then
        SpinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(SpinButton)
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(1)
            if spinActive then spinThread = task.spawn(startSpin) end
        end)
        spinThread = task.spawn(startSpin)
        createNotification("GBORE", "تم تشغيل الدوران", "rbxassetid://7992557358", 3)
    else
        SpinButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if SpinButton:FindFirstChildOfClass("UIGradient") then
            SpinButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        spinActive = false
        spinThread = nil
        createNotification("GBORE", "تم إيقاف الدوران", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 📊 أنظمة الإحصائيات
-- ===========================================

JumpButton.MouseButton1Click:Connect(function()
    local jumpVal = tonumber(JumpTextBox.Text)
    if not jumpVal then
        JumpTextBox.Text = "قوة القفز"
        jumpVal = 50
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = math.clamp(jumpVal, 1, 5000)
            flashGlow(JumpButton, 1.5)
            createNotification("GBORE", "تم ضبط قوة القفز إلى "..jumpVal, "rbxassetid://7992557358", 3)
        end
    end
end)

SpeedButton.MouseButton1Click:Connect(function()
    local speedVal = tonumber(SpeedTextBox.Text)
    if not speedVal then
        SpeedTextBox.Text = "عدد السرعة"
        speedVal = 16
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = math.clamp(speedVal, 1, 5000)
            flashGlow(SpeedButton, 1.5)
            createNotification("GBORE", "تم ضبط السرعة إلى "..speedVal, "rbxassetid://7992557358", 3)
        end
    end
end)

-- ===========================================
-- 🗑️ أنظمة الحذف
-- ===========================================

DeleteHatButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, accessory in pairs(char:GetChildren()) do
        if accessory:IsA("Accessory") then
            accessory:Destroy()
        end
    end
    
    flashGlow(DeleteHatButton, 1)
    createNotification("GBORE", "تم حذف جميع القبعات", "rbxassetid://7992557358", 3)
end)

DeleteToolButton.MouseButton1Click:Connect(function()
    local backpack = LocalPlayer.Backpack
    if not backpack then return end
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool:Destroy()
        end
    end
    
    flashGlow(DeleteToolButton, 1)
    createNotification("GBORE", "تم حذف جميع الأدوات", "rbxassetid://7992557358", 3)
end)

-- ===========================================
-- 🌌 أنظمة إضافية
-- ===========================================

local invisibleActive = false
local originalParts = {}

InvisibleButton.MouseButton1Click:Connect(function()
    invisibleActive = not invisibleActive
    local char = LocalPlayer.Character
    
    if invisibleActive then
        InvisibleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        createGlow(InvisibleButton)
        
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    originalParts[part] = part.Transparency
                    part.Transparency = 1
                elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                    originalParts[part.Handle] = part.Handle.Transparency
                    part.Handle.Transparency = 1
                end
            end
        end
        createNotification("GBORE", "تم تشغيل الاختفاء", "rbxassetid://7992557358", 3)
    else
        InvisibleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        if InvisibleButton:FindFirstChildOfClass("UIGradient") then
            InvisibleButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        
        if char then
            for part, transparency in pairs(originalParts) do
                if part and part.Parent then
                    part.Transparency = transparency
                end
            end
            table.clear(originalParts)
        end
        createNotification("GBORE", "تم إيقاف الاختفاء", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🔄 أنظمة السيرفرات
-- ===========================================

RejoinButton.MouseButton1Click:Connect(function()
    local placeId = game.PlaceId
    local jobId = game.JobId
    TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    flashGlow(RejoinButton, 1)
    createNotification("GBORE", "جاري إعادة الدخول إلى السيرفر", "rbxassetid://7992557358", 3)
end)

ChangeServerButton.MouseButton1Click:Connect(function()
    local placeId = game.PlaceId
    local servers = HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, server in ipairs(servers) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
            break
        end
    end
    flashGlow(ChangeServerButton, 1)
    createNotification("GBORE", "جاري البحث عن سيرفر جديد", "rbxassetid://7992557358", 3)
end)

-- ===========================================
-- 🎯 أداة الاختيار
-- ===========================================

local function Notify(message)
    createNotification("GBORE Tool", message, "rbxassetid://7992557358", 3)
end

local function createSelectTool()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    
    local oldTool = backpack:FindFirstChild("SELECT")
    if oldTool then
        oldTool:Destroy()
    end
    
    local selectTool = Instance.new("Tool")
    selectTool.Name = "SELECT"
    selectTool.Parent = backpack
    selectTool.CanBeDropped = false
    selectTool.ToolTip = "اختر لاعب"
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Parent = selectTool
    handle.Size = Vector3.new(0.7, 0.7, 0.7)
    handle.BrickColor = BrickColor.new("Bright blue")
    handle.Material = Enum.Material.Neon
    
    local mesh = Instance.new("SpecialMesh")
    mesh.Parent = handle
    mesh.MeshType = Enum.MeshType.Sphere
    
    local pointLight = Instance.new("PointLight")
    pointLight.Parent = handle
    pointLight.Color = Color3.fromRGB(0, 100, 255)
    pointLight.Brightness = 2
    pointLight.Range = 10
    
    selectTool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        
        if not target then 
            Notify("لم تضغط على شيء!")
            return 
        end
        
        local character = target.Parent
        local player = Players:GetPlayerFromCharacter(character)
        
        if not player then
            local model = character
            while model do
                player = Players:GetPlayerFromCharacter(model)
                if player then break end
                
                for _, child in pairs(model:GetChildren()) do
                    if child:IsA("BasePart") then
                        local ancestor = child:FindFirstAncestorWhichIsA("Model")
                        if ancestor then
                            player = Players:GetPlayerFromCharacter(ancestor)
                            if player then break end
                        end
                    end
                end
                
                if player then break end
                model = model.Parent
            end
        end
        
        if player and player ~= LocalPlayer then
            targetPlayer = player
            UserLabel.Text = player.Name
            NickLabel.Text = player.DisplayName
            MidImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            Notify("✅ تم اختيار: " .. player.Name)
        else
            Notify("❌ هذا ليس لاعب!")
        end
    end)
    
    return selectTool
end

SelectToolButton.MouseButton1Click:Connect(function()
    createSelectTool()
    flashGlow(SelectToolButton, 1)
    createNotification("GBORE", "تم إنشاء أداة الاختيار في الحقيبة", "rbxassetid://7992557358", 3)
end)

-- ===========================================
-- 🔄 نظام تبديل الصفحات
-- ===========================================

local currentPage = "main"

local function switchToPage(pageName)
    MainScrollFrame.Visible = false
    OtherScrollFrame.Visible = false
    
    MainPageButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    OtherPageButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainPageButton.BackgroundTransparency = 0.4
    OtherPageButton.BackgroundTransparency = 0.4
    MainPageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OtherPageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    if pageName == "main" then
        MainScrollFrame.Visible = true
        MainPageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MainPageButton.BackgroundTransparency = 0.3
        MainPageButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    elseif pageName == "other" then
        OtherScrollFrame.Visible = true
        OtherPageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OtherPageButton.BackgroundTransparency = 0.3
        OtherPageButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
    
    currentPage = pageName
end

MainPageButton.MouseButton1Click:Connect(function()
    switchToPage("main")
end)

OtherPageButton.MouseButton1Click:Connect(function()
    switchToPage("other")
end)

CloseWindowButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- زر إخفاء/إظهار النافذة
local ToggleWindowButton = Instance.new("ImageButton", ScreenGui)
ToggleWindowButton.Size = UDim2.new(0, 40, 0, 40)
ToggleWindowButton.Position = UDim2.new(1, -45, 0.5, -20)
ToggleWindowButton.AnchorPoint = Vector2.new(0, 0.5)
ToggleWindowButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleWindowButton.BackgroundTransparency = 0.6
ToggleWindowButton.BorderSizePixel = 2
ToggleWindowButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ToggleWindowButton.Image = "rbxassetid://11835491319"
ToggleWindowButton.AutoButtonColor = false
Instance.new("UICorner", ToggleWindowButton).CornerRadius = UDim.new(1, 0)

ToggleWindowButton.MouseButton1Click:Connect(function()
    local newState = not Frame.Visible
    Frame.Visible = newState
    if newState then
        createNotification("GBORE", "تم إظهار النافذة", "rbxassetid://7992557358", 2)
    else
        createNotification("GBORE", "تم إخفاء النافذة", "rbxassetid://7992557358", 2)
    end
end)

-- ===========================================
-- 🎪 نظام السحب والتحريك
-- ===========================================

local dragging = false
local dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    Frame.Position = newPos
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)

-- ===========================================
-- 🚀 تأثير دخول النافذة
-- ===========================================

Frame.Position = UDim2.new(0.5, -250, 1.2, 0)
TweenService:Create(Frame, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -250, 0.5, -200)}):Play()

-- ===========================================
-- 📢 نظام الرسائل التلقائية
-- ===========================================

task.spawn(function()
    while true do
        task.wait(300)
        pcall(function()
            ReplicatedStorage.Events.SendMessage:FireServer("GBORE ON TOP")
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(1020)
        pcall(function()
            ReplicatedStorage.Events.SendMessage:FireServer(">UsE Gbore ScRiPt<")
        end)
    end
end)

-- ===========================================
-- 🔄 أنظمة إعادة التنشيط
-- ===========================================

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    
    -- إعادة تفعيل أنظمة الجلوس
    if headSitActive then 
        task.wait(0.3)
        startHeadSit() 
    end
    if backpackActive then 
        task.wait(0.3)
        startBackpack() 
    end
    if benxActive then 
        task.wait(0.3)
        startBenx() 
    end
    
    -- الأنظمة الأخرى
    if bangActive then startBang() end
    if faceBangActive then task.spawn(updateFaceBang) end
    if suckActive then task.spawn(updateSuck) end
    if spinActive then spinThread = task.spawn(startSpin) end
    if flying then setupFly() end
    if noclipActive then enableNoclip() end
    if invisibleActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                    part.Handle.Transparency = 1
                end
            end
        end
    end
end)

-- ===========================================
-- 🚫 نظام مراقبة خروج اللاعب (محدث)
-- ===========================================

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if targetPlayer and leavingPlayer == targetPlayer then
        -- إيقاف جميع الأنظمة
        bangActive = false
        faceBangActive = false
        headSitActive = false
        backpackActive = false
        suckActive = false
        benxActive = false
        
        -- إيقاف التوهج والأزرار
        if BangButton then
            BangButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
            if BangButton:FindFirstChildOfClass("UIGradient") then
                BangButton:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end
        
        if FaceBangButton then
            FaceBangButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
            if FaceBangButton:FindFirstChildOfClass("UIGradient") then
                FaceBangButton:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end
        
        if HeadSitButton then
            HeadSitButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
            if HeadSitButton:FindFirstChildOfClass("UIGradient") then
                HeadSitButton:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end
        
        if BackpackButton then
            BackpackButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
            if BackpackButton:FindFirstChildOfClass("UIGradient") then
                BackpackButton:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end
        
        if SuckButton then
            SuckButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
            if SuckButton:FindFirstChildOfClass("UIGradient") then
                SuckButton:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end
        
        if BenxButton then
            BenxButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
            if BenxButton:FindFirstChildOfClass("UIGradient") then
                BenxButton:FindFirstChildOfClass("UIGradient"):Destroy()
            end
        end
        
        -- إيقاف الأنظمة
        stopBang()
        stopHeadSit()
        stopBackpack()
        stopBenx()
        
        -- إعادة تعيين الهدف
        targetPlayer = nil
        UserLabel.Text = "User"
        NickLabel.Text = "NickName"
        MidImage.Image = "rbxassetid://7992557358"
        
        createNotification("GBORE", "خرج اللاعب المستهدف، تم إيقاف جميع الأنظمة", "rbxassetid://7992557358", 3)
    end
end)

-- ===========================================
-- 🧹 دالة التنظيف (محدثة)
-- ===========================================

local function cleanup()
    stopBang()
    stopHeadSit()
    stopBackpack()
    stopBenx()
    stopFly()
    disableNoclip()
    
    if bangHeartbeat then bangHeartbeat:Disconnect() end
    if faceBangHeartbeat then faceBangHeartbeat:Disconnect() end
    if headSitHeartbeat then headSitHeartbeat:Disconnect() end
    if backpackHeartbeat then backpackHeartbeat:Disconnect() end
    if suckAnimTrack then suckAnimTrack:Stop() suckAnimTrack = nil end
    
    if spamLoop then spamLoop = nil end
    if antibanLoop then antibanLoop = nil end
    if antiCopyLoop then antiCopyLoop = nil end
    if antiCopyMLoop then antiCopyMLoop = nil end
    if randomSizeLoop then randomSizeLoop = nil end
    if randomSkinLoop then randomSkinLoop = nil end
    if antiAfkLoop then antiAfkLoop:Disconnect() end
    
    targetPlayer = nil
end

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == ScreenGui or child == _G.GBORE_SmallGUI then
        cleanup()
    end
end)

game:BindToClose(function()
    cleanup()
end)

-- ===========================================
-- ✅ إشعار البدء
-- ===========================================

task.wait(1.5)
print("=====================================")
print("Z7F Script Loaded Successfully!")
print("Version: 10.0 ULTIMATE COMPLETE")
print("Developer: Z7F & Alaoui")
print("Features: All-in-One Ultimate")
print("=====================================")
createNotification("GBORE SYSTEM", "تم تحميل السكربت بنجاح!", thumb, 5)

-- ===========================================
-- 🎯 نظام الحماية من الأنتي سكربت
-- ===========================================

local function antiScriptDetection()
    local originalName = LocalPlayer.Name
    local fakeName = "Player" .. math.random(1000, 9999)
    
    pcall(function()
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end)
    
    task.spawn(function()
        while task.wait(math.random(5, 15)) do
            pcall(function()
                if LocalPlayer.Character then
                    LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10)))
                end
            end)
        end
    end)
end

task.spawn(antiScriptDetection)