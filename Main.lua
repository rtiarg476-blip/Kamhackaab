-- TpAllToMe.lua с GUI + Noclip + Постоянный TP по нику
-- Игроки спереди, постоянная телепортация (не возвращаются)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().TpAllActive = false
getgenv().NoclipActive = false
getgenv().SingleTpActive = false  -- для одного игрока
getgenv().TargetPlayer = nil      -- текущая цель

-- === Телепортация всех ===
local function startTpAll()
    if getgenv().TpAllActive then return end
    getgenv().TpAllActive = true
    
    task.spawn(function()
        while getgenv().TpAllActive do
            pcall(function()
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local myHRP = myChar.HumanoidRootPart
                    local spawnCFrame = myHRP.CFrame * CFrame.new(0, 3, -5)
                    
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            local pChar = plr.Character
                            if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                                local hrp = pChar.HumanoidRootPart
                                pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
                                hrp.CFrame = spawnCFrame * CFrame.new(math.random(-3,3), 0, math.random(-2,2))
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function stopTpAll()
    getgenv().TpAllActive = false
end

-- === Постоянная телепортация ОДНОГО игрока ===
local SingleTpConnection

local function startSingleTp(partialName)
    if partialName == "" then
        warn("Введите часть никнейма!")
        return
    end
    
    local lowerName = string.lower(partialName)
    local targetPlayer = nil
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and string.find(string.lower(plr.Name), lowerName) then
            targetPlayer = plr
            break
        end
    end
    
    if not targetPlayer then
        warn("Игрок с ником '" .. partialName .. "' не найден!")
        return
    end
    
    -- Если уже телепортируем кого-то — останавливаем старого
    if getgenv().SingleTpActive and getgenv().TargetPlayer then
        stopSingleTp()
    end
    
    getgenv().TargetPlayer = targetPlayer
    getgenv().SingleTpActive = true
    
    SingleTpConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().SingleTpActive or not getgenv().TargetPlayer then return end
        
        local myChar = LocalPlayer.Character
        local pChar = getgenv().TargetPlayer.Character
        
        if myChar and myChar:FindFirstChild("HumanoidRootPart") and pChar and pChar:FindFirstChild("HumanoidRootPart") then
            local myHRP = myChar.HumanoidRootPart
            local hrp = pChar.HumanoidRootPart
            
            local targetCFrame = myHRP.CFrame * CFrame.new(0, 3, -5)
            
            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
            hrp.CFrame = targetCFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
        end
    end)
    
    print("Постоянная телепортация " .. targetPlayer.Name .. " запущена (спереди от тебя)!")
    TpPlayerBtn.Text = "TP Active: " .. targetPlayer.Name
    TpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
end

local function stopSingleTp()
    getgenv().SingleTpActive = false
    getgenv().TargetPlayer = nil
    
    if SingleTpConnection then
        SingleTpConnection:Disconnect()
        SingleTpConnection = nil
    end
    
    TpPlayerBtn.Text = "TP Player"
    TpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    print("Постоянная телепортация одного игрока остановлена.")
end

-- === Noclip ===
local NoclipConnection

local function enableNoclip()
    if getgenv().NoclipActive then return end
    getgenv().NoclipActive = true
    
    NoclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().NoclipActive then return end
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    getgenv().NoclipActive = false
    
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function toggleNoclip()
    if getgenv().NoclipActive then
        disableNoclip()
        NoclipBtn.Text = "Noclip: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    else
        enableNoclip()
        NoclipBtn.Text = "Noclip: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TpAllGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 280)
Frame.Position = UDim2.new(0.5, -140, 0.5, -140)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(70, 70, 70)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "TpAllToMe + Noclip"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

-- Кнопки TpAll
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.9, 0, 0, 35)
StartBtn.Position = UDim2.new(0.05, 0, 0, 40)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.Text = "START TpAll"
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 16
StartBtn.Parent = Frame
StartBtn.MouseButton1Click:Connect(startTpAll)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.9, 0, 0, 35)
StopBtn.Position = UDim2.new(0.05, 0, 0, 80)
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.Text = "STOP TpAll"
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 16
StopBtn.Parent = Frame
StopBtn.MouseButton1Click:Connect(stopTpAll)

-- Поле ввода
local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(0.9, 0, 0, 30)
NameBox.Position = UDim2.new(0.05, 0, 0, 120)
NameBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NameBox.PlaceholderText = "Часть никнейма..."
NameBox.TextColor3 = Color3.new(1,1,1)
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 14
NameBox.Parent = Frame

-- Кнопка запуска TP одного
local TpPlayerBtn = Instance.new("TextButton")
TpPlayerBtn.Size = UDim2.new(0.9, 0, 0, 35)
TpPlayerBtn.Position = UDim2.new(0.05, 0, 0, 155)
TpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TpPlayerBtn.Text = "TP Player"
TpPlayerBtn.Font = Enum.Font.GothamBold
TpPlayerBtn.TextSize = 16
TpPlayerBtn.Parent = Frame
TpPlayerBtn.MouseButton1Click:Connect(function()
    if getgenv().SingleTpActive then
        stopSingleTp()
    else
        startSingleTp(NameBox.Text)
    end
end)

-- Кнопка остановки TP одного
local StopTpPlayerBtn = Instance.new("TextButton")
StopTpPlayerBtn.Size = UDim2.new(0.9, 0, 0, 35)
StopTpPlayerBtn.Position = UDim2.new(0.05, 0, 0, 195)
StopTpPlayerBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopTpPlayerBtn.Text = "STOP TP Player"
StopTpPlayerBtn.Font = Enum.Font.GothamBold
StopTpPlayerBtn.TextSize = 16
StopTpPlayerBtn.Parent = Frame
StopTpPlayerBtn.MouseButton1Click:Connect(stopSingleTp)

-- Noclip
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 35)
NoclipBtn.Position = UDim2.new(0.05, 0, 0, 235)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.TextSize = 16
NoclipBtn.Parent = Frame
NoclipBtn.MouseButton1Click:Connect(toggleNoclip)

-- Уголки
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

for _, obj in pairs({Title, StartBtn, StopBtn, TpPlayerBtn, StopTpPlayerBtn, NoclipBtn, NameBox}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = obj
end

-- Авто-ноуклип при респавне
LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().NoclipActive then
        disableNoclip()
        enableNoclip()
    end
end)

print("🟢 TpAllToMe + Постоянный TP по нику загружен!")
print("Теперь игроки НЕ возвращаются назад — постоянная телепортация.")
print("TP Player = запуск, STOP TP Player = остановка.")
