local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local mouse = LocalPlayer:GetMouse()

local CmdSignal = ReplicatedStorage:FindFirstChild("HDAdminHDClient") and ReplicatedStorage.HDAdminHDClient:FindFirstChild("Signals") and ReplicatedStorage.HDAdminHDClient.Signals:FindFirstChild("RequestCommandModification")
local ChatRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DataService")

-- ===========================================
-- 📋 جداول الإشعارات والحماية
-- ===========================================
local Notifications = {}
local ProtectedUsers = {["Eslam9O"] = true, ["MADARA11111222"] = true}
local BannedUsers = {}

-- ===========================================
-- 📢 دالة الإشعارات
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

            for i, v in ipairs(Notifications) do
                if v == Notification then
                    table.remove(Notifications, i)
                    break
                end
            end
        end
    end)
end

-- ===========================================
-- 🔒 دالة فحص الحماية
-- ===========================================
local function CheckTargetProtection(playerName)
    if BannedUsers[playerName] then
        createNotification("GBORE SYSTEM", "هذا اللاعب محظور!", "rbxassetid://7992557358", 5)
        return true
    end
    
    if ProtectedUsers[playerName] then
        createNotification("GBORE SYSTEM", "هذا اللاعب محمي!", "rbxassetid://7992557358", 5)
        return true
    end
    return false
end

-- ===========================================
-- 🎨 دوال إنشاء الأزرار والتوهج
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

-- ===========================================
-- 🎯 الواجهة الرئيسية
-- ===========================================
if PlayerGui:FindFirstChild("MHNDSPAMGui") then PlayerGui.MHNDSPAMGui:Destroy() end
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "MHNDSPAMGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- العنوان
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "RK KLAN"
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
RunService.Heartbeat:Connect(function() Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- زر الإغلاق والتصغير
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.new(1, 1, 1)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Minimized = false
local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.new(1, 1, 1)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    MainFrame.Size = Minimized and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 350)
    Container.Visible = not Minimized
    MinBtn.Text = Minimized and "+" or "-"
end)

-- تصفية المحتوى
local ScrollFrame = Instance.new("ScrollingFrame", Container)
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
ScrollFrame.ScrollBarThickness = 8

-- تخطيط قائمة
local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Enum.FillDirection.Vertical

-- ============================
-- 📝 قسم الأوامر
-- ============================
local CmdLabel = Instance.new("TextLabel", ScrollFrame)
CmdLabel.Size = UDim2.new(1, -10, 0, 25)
CmdLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CmdLabel.Text = "📝 الأوامر والحماية"
CmdLabel.Font = Enum.Font.GothamBold
CmdLabel.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CmdLabel).CornerRadius = UDim.new(0, 8)

local CmdBox = Instance.new("TextBox", ScrollFrame)
CmdBox.Size = UDim2.new(1, -10, 0, 35)
CmdBox.PlaceholderText = "أدخل الأمر"
CmdBox.Text = "/nv"
CmdBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CmdBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CmdBox).CornerRadius = UDim.new(0, 8)

local SpeedBox = Instance.new("TextBox", ScrollFrame)
SpeedBox.Size = UDim2.new(1, -10, 0, 35)
SpeedBox.PlaceholderText = "سرعة السبام (مثال: 0.2)"
SpeedBox.Text = "0.2"
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 8)

local SendBtn = Instance.new("TextButton", ScrollFrame)
SendBtn.Size = UDim2.new(1, -10, 0, 35)
SendBtn.Text = "📤 ارسال مره واحده"
SendBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SendBtn.TextColor3 = Color3.new(1, 1, 1)
SendBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 8)

local SpamBtn = Instance.new("TextButton", ScrollFrame)
SpamBtn.Size = UDim2.new(1, -10, 0, 35)
SpamBtn.Text = "🔁 سبام"
SpamBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpamBtn.TextColor3 = Color3.new(1, 1, 1)
SpamBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SpamBtn).CornerRadius = UDim.new(0, 8)

local BatchBtn = Instance.new("TextButton", ScrollFrame)
BatchBtn.Size = UDim2.new(1, -10, 0, 35)
BatchBtn.Text = "💥 تخريب جماعي"
BatchBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BatchBtn.TextColor3 = Color3.new(1, 1, 1)
BatchBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", BatchBtn).CornerRadius = UDim.new(0, 8)

local ShieldBtn = Instance.new("TextButton", ScrollFrame)
ShieldBtn.Size = UDim2.new(1, -10, 0, 35)
ShieldBtn.Text = "🛡️ حماية / تنظيف"
ShieldBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ShieldBtn.TextColor3 = Color3.new(1, 1, 1)
ShieldBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ShieldBtn).CornerRadius = UDim.new(0, 8)

-- ============================
-- 👤 قسم الاستهداف
-- ============================
local TargetLabel = Instance.new("TextLabel", ScrollFrame)
TargetLabel.Size = UDim2.new(1, -10, 0, 25)
TargetLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetLabel.Text = "👤 نظام الاستهداف"
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", TargetLabel).CornerRadius = UDim.new(0, 8)

local NickTextBox = Instance.new("TextBox", ScrollFrame)
NickTextBox.Size = UDim2.new(1, -10, 0, 35)
NickTextBox.PlaceholderText = "ابحث عن اللاعب..."
NickTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NickTextBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", NickTextBox).CornerRadius = UDim.new(0, 8)

local UserLabel = Instance.new("TextLabel", ScrollFrame)
UserLabel.Size = UDim2.new(1, -10, 0, 25)
UserLabel.Text = "الحساب: غير محدد"
UserLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
UserLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
UserLabel.Font = Enum.Font.GothamBold
Instance.new("UICorner", UserLabel).CornerRadius = UDim.new(0, 8)

-- ============================
-- 💪 قسم الحركات
-- ============================
local ActionsLabel = Instance.new("TextLabel", ScrollFrame)
ActionsLabel.Size = UDim2.new(1, -10, 0, 25)
ActionsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ActionsLabel.Text = "💪 حركات الاستهداف"
ActionsLabel.Font = Enum.Font.GothamBold
ActionsLabel.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ActionsLabel).CornerRadius = UDim.new(0, 8)

-- متغيرات الحركات
local targetPlayer = nil
local bangActive = false
local faceBangActive = false
local headSitActive = false
local backpackActive = false
local suckActive = false
local benxActive = false

-- دالة مساعدة للحصول على HRP
local function GetRoot(plr)
    if plr and plr.Character then
        return plr.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- دالة الاستهداف
local function setTargetFromText()
    local search = NickTextBox.Text:lower()
    if #search < 2 then
        targetPlayer = nil
        UserLabel.Text = "الحساب: غير محدد"
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
            UserLabel.Text = "الحساب: " .. plr.DisplayName
            
            local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            createNotification("استهداف", "تم استهداف اللاعب " .. plr.DisplayName, thumb, 3)
            break
        end
    end
end

NickTextBox:GetPropertyChangedSignal("Text"):Connect(setTargetFromText)

-- ============================
-- 🎮 أزرار الحركات
-- ============================
local WatchButton = Instance.new("TextButton", ScrollFrame)
WatchButton.Size = UDim2.new(1, -10, 0, 35)
WatchButton.Text = "👁️ مشاهدة"
WatchButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
WatchButton.TextColor3 = Color3.new(1, 1, 1)
WatchButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", WatchButton).CornerRadius = UDim.new(0, 8)

local BangButton = Instance.new("TextButton", ScrollFrame)
BangButton.Size = UDim2.new(1, -10, 0, 35)
BangButton.Text = "💥 بانق خلفي"
BangButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BangButton.TextColor3 = Color3.new(1, 1, 1)
BangButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", BangButton).CornerRadius = UDim.new(0, 8)

local FaceBangButton = Instance.new("TextButton", ScrollFrame)
FaceBangButton.Size = UDim2.new(1, -10, 0, 35)
FaceBangButton.Text = "😛 بانق وجهي"
FaceBangButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FaceBangButton.TextColor3 = Color3.new(1, 1, 1)
FaceBangButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", FaceBangButton).CornerRadius = UDim.new(0, 8)

local HeadSitButton = Instance.new("TextButton", ScrollFrame)
HeadSitButton.Size = UDim2.new(1, -10, 0, 35)
HeadSitButton.Text = "🪑 جلوس فوق الرأس"
HeadSitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
HeadSitButton.TextColor3 = Color3.new(1, 1, 1)
HeadSitButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", HeadSitButton).CornerRadius = UDim.new(0, 8)

local BackpackButton = Instance.new("TextButton", ScrollFrame)
BackpackButton.Size = UDim2.new(1, -10, 0, 35)
BackpackButton.Text = "🎒 حقيبة ظهر"
BackpackButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BackpackButton.TextColor3 = Color3.new(1, 1, 1)
BackpackButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", BackpackButton).CornerRadius = UDim.new(0, 8)

local SuckButton = Instance.new("TextButton", ScrollFrame)
SuckButton.Size = UDim2.new(1, -10, 0, 35)
SuckButton.Text = "💦 مص"
SuckButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SuckButton.TextColor3 = Color3.new(1, 1, 1)
SuckButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", SuckButton).CornerRadius = UDim.new(0, 8)

local BenxButton = Instance.new("TextButton", ScrollFrame)
BenxButton.Size = UDim2.new(1, -10, 0, 35)
BenxButton.Text = "🔥 اغتصاب"
BenxButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BenxButton.TextColor3 = Color3.new(1, 1, 1)
BenxButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", BenxButton).CornerRadius = UDim.new(0, 8)

-- ============================
-- 🎯 البانق الخلفي
-- ============================
local bangHeartbeat = nil
local bangAnimationId = "10714068222"

local function playBangAnimation()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. bangAnimationId
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
        createNotification("تنبيه", "اختر لاعب أولاً!", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    bangActive = not bangActive
    if bangActive then
        BangButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        createGlow(BangButton)
        startBang()
        createNotification("تنفيذ", "البانق الخلفي مفعل ✓", "rbxassetid://7992557358", 2)
    else
        BangButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if BangButton:FindFirstChildOfClass("UIGradient") then
            BangButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopBang()
        createNotification("إيقاف", "البانق الخلفي معطل", "rbxassetid://7992557358", 2)
    end
end)

-- ============================
-- 😁 البانق الوجهي
-- ============================
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
                humanoidRootPart.Velocity = Vector3.new(0, 2, 0)
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
        createNotification("تنبيه", "اختر لاعب أولاً!", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    faceBangActive = not faceBangActive
    if faceBangActive then
        FaceBangButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        createGlow(FaceBangButton)
        spawn(updateFaceBang)
        createNotification("تنفيذ", "البانق الوجهي مفعل ✓", "rbxassetid://7992557358", 2)
    else
        FaceBangButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if FaceBangButton:FindFirstChildOfClass("UIGradient") then
            FaceBangButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        faceBangActive = false
        createNotification("إيقاف", "البانق الوجهي معطل", "rbxassetid://7992557358", 2)
    end
end)

-- ============================
-- 🪑 الجلوس فوق الرأس
-- ============================
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
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = true
                humanoid.PlatformStand = false
            end
            
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
        end
    end
end

HeadSitButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("تنبيه", "اختر لاعب أولاً!", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    headSitActive = not headSitActive
    if headSitActive then
        HeadSitButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        createGlow(HeadSitButton)
        startHeadSit()
        createNotification("تنفيذ", "الجلوس مفعل ✓", "rbxassetid://7992557358", 2)
    else
        HeadSitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if HeadSitButton:FindFirstChildOfClass("UIGradient") then
            HeadSitButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopHeadSit()
        createNotification("إيقاف", "الجلوس معطل", "rbxassetid://7992557358", 2)
    end
end)

-- ============================
-- 🎒 حقيبة الظهر
-- ============================
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
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = true
            end
            
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
        end
    end
end

BackpackButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("تنبيه", "اختر لاعب أولاً!", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    backpackActive = not backpackActive
    if backpackActive then
        BackpackButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        createGlow(BackpackButton)
        startBackpack()
        createNotification("تنفيذ", "حقيبة الظهر مفعلة ✓", "rbxassetid://7992557358", 2)
    else
        BackpackButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if BackpackButton:FindFirstChildOfClass("UIGradient") then
            BackpackButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopBackpack()
        createNotification("إيقاف", "حقيبة الظهر معطلة", "rbxassetid://7992557358", 2)
    end
end)

-- ============================
-- 💦 المص
-- ============================
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
        createNotification("تنبيه", "اختر لاعب أولاً!", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    suckActive = not suckActive
    if suckActive then
        SuckButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        createGlow(SuckButton)
        task.spawn(updateSuck)
        createNotification("تنفيذ", "المص مفعل ✓", "rbxassetid://7992557358", 2)
    else
        SuckButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if SuckButton:FindFirstChildOfClass("UIGradient") then
            SuckButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        suckActive = false
        createNotification("إيقاف", "المص معطل", "rbxassetid://7992557358", 2)
    end
end)

-- ============================
-- 🔥 الاغتصاب
-- ============================
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
        
        if humanoid then
            humanoid.Sit = true
            humanoid.PlatformStand = false
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
                
                benxSitOffset = benxSitOffset + (0.3 * benxDirection)
                
                if benxSitOffset > 2.5 then
                    benxDirection = -1
                elseif benxSitOffset < 1 then
                    benxDirection = 1
                end
                
                hum.Sit = true
                hum.PlatformStand = false
                
                local targetCFrame = targetLowerTorso.CFrame
                local sitCFrame = targetCFrame * CFrame.new(0, -0.8, -benxSitOffset) * CFrame.Angles(-1.5, 0, 0)
                
                hrp.CFrame = sitCFrame
                hrp.Velocity = Vector3.new(0, 0, 0)
            end)
        until not getgenv().Benx or not benxActive

        pcall(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Sit = false
                    task.wait(0.1)
                end
            end
        end)
        
        benxSitOffset = 0
        benxDirection = 1
    end)()
end

local function stopBenx()
    getgenv().Benx = false
end

BenxButton.MouseButton1Click:Connect(function()
    if not targetPlayer then 
        createNotification("تنبيه", "اختر لاعب أولاً!", "rbxassetid://7992557358", 3)
        return 
    end
    if CheckTargetProtection(targetPlayer.Name) then return end

    benxActive = not benxActive
    if benxActive then
        BenxButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        createGlow(BenxButton)
        startBenx()
        createNotification("تنفيذ", "الاغتصاب مفعل ✓", "rbxassetid://7992557358", 2)
    else
        BenxButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if BenxButton:FindFirstChildOfClass("UIGradient") then
            BenxButton:FindFirstChildOfClass("UIGradient"):Destroy()
        end
        stopBenx()
        createNotification("إيقاف", "الاغتصاب معطل", "rbxassetid://7992557358", 2)
    end
end)

-- ============================
-- 🔗 منطق الأوامر
-- ============================
local spamActive = false

SendBtn.MouseButton1Click:Connect(function() 
    if ChatRemote then ChatRemote:FireServer(CmdBox.Text) end
    if CmdSignal then CmdSignal:InvokeServer(CmdBox.Text) end
    createNotification("أمر", "تم إرسال: " .. CmdBox.Text, "rbxassetid://7992557358", 2)
end)

SpamBtn.MouseButton1Click:Connect(function()
    spamActive = not spamActive
    SpamBtn.Text = spamActive and "🛑 إيقاف السبام" or "🔁 سبام"
    SpamBtn.BackgroundColor3 = spamActive and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(80, 80, 80)
    
    if spamActive then
        task.spawn(function() 
            while spamActive do 
                if ChatRemote then ChatRemote:FireServer(CmdBox.Text) end
                if CmdSignal then CmdSignal:InvokeServer(CmdBox.Text) end
                task.wait(tonumber(SpeedBox.Text) or 0.2) 
            end 
        end)
        createNotification("سبام", "السبام مفعل ✓", "rbxassetid://7992557358", 2)
    else
        createNotification("سبام", "السبام معطل", "rbxassetid://7992557358", 2)
    end
end)

BatchBtn.MouseButton1Click:Connect(function()
    local cmd = CmdBox.Text
    local players = Players:GetPlayers()
    local batch = {}
    for i, p in pairs(players) do
        if p ~= LocalPlayer then
            table.insert(batch, p.Name)
            if #batch == 3 or i == #players then
                for _, name in pairs(batch) do 
                    if CmdSignal then CmdSignal:InvokeServer(cmd .. " " .. name) end 
                end
                task.wait(3)
                batch = {}
            end
        end
    end
    createNotification("تخريب", "تم تنفيذ التخريب الجماعي ✓", "rbxassetid://7992557358", 3)
end)

ShieldBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if ChatRemote then ChatRemote:FireServer("/clear") ChatRemote:FireServer("/stop") end
        if CmdSignal then CmdSignal:InvokeServer("clear") CmdSignal:InvokeServer("stop") end
        for _, v in pairs(Workspace.CurrentCamera:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
        end
        for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v:Destroy() end
        end
        local HD = PlayerGui:FindFirstChild("HDAdminInterface")
        if HD then HD:Destroy() end
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name == "NightVision" or obj.Name == "NV" or obj.Name == "Blur" then obj:Destroy() end
        end
    end)
    ShieldBtn.Text = "✅ تم التنظيف!"
    ShieldBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    createNotification("حماية", "تم تنظيف كل التأثيرات ✓", "rbxassetid://7992557358", 3)
    task.wait(2)
    ShieldBtn.Text = "🛡️ حماية / تنظيف"
    ShieldBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)
