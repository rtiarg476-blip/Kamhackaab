-- TpAllToMe.lua с GUI + Noclip
-- GUI теперь по центру экрана

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().TpAllActive = false
getgenv().NoclipActive = false

-- === Телепортация всех к тебе ===
local function startTpAll()
    if getgenv().TpAllActive then return end
    getgenv().TpAllActive = true
    
    task.spawn(function()
        local duration = 88888
        local startTime = tick()
        
        while tick() - startTime < duration and getgenv().TpAllActive do
            pcall(function()
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local myCFrame = myChar.HumanoidRootPart.CFrame
                    
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            local pChar = plr.Character
                            if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                                local hrp = pChar.HumanoidRootPart
                                
                                pcall(function()
                                    hrp:SetNetworkOwner(LocalPlayer)
                                end)
                                
                                hrp.CFrame = myCFrame * CFrame.new(0, 3 + math.random(-2, 2), 0)
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
        
        getgenv().TpAllActive = false
        warn("TpAll завершён по таймеру!")
    end)
end

local function stopTpAll()
    getgenv().TpAllActive = false
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

-- === GUI (теперь по центру экрана) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TpAllGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 170)
-- Центрирование по экрану
Frame.Position = UDim2.new(0.5, -110, 0.5, -85)  -- -половина ширины и высоты
Frame.AnchorPoint = Vector2.new(0.5, 0.5)        -- точка привязки — центр фрейма
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

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.9, 0, 0, 35)
StartBtn.Position = UDim2.new(0.05, 0, 0, 45)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.Text = "START TpAll"
StartBtn.TextColor3 = Color3.new(1,1,1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 16
StartBtn.Parent = Frame
StartBtn.MouseButton1Click:Connect(startTpAll)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.9, 0, 0, 35)
StopBtn.Position = UDim2.new(0.05, 0, 0, 85)
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.Text = "STOP TpAll"
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 16
StopBtn.Parent = Frame
StopBtn.MouseButton1Click:Connect(stopTpAll)

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 35)
NoclipBtn.Position = UDim2.new(0.05, 0, 0, 125)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.TextColor3 = Color3.new(1,1,1)
NoclipBtn.Font = Enum.Font.GothamBold
NoclipBtn.TextSize = 16
NoclipBtn.Parent = Frame
NoclipBtn.MouseButton1Click:Connect(toggleNoclip)

-- Уголки
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

for _, obj in pairs({Title, StartBtn, StopBtn, NoclipBtn}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = obj
end

-- Авто-подключение ноуклипа при респавне
LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().NoclipActive then
        disableNoclip()
        enableNoclip()
    end
end)

print("🟢 TpAllToMe + Noclip GUI загружен!")
print("Меню теперь по центру экрана. Перетаскивать можно как раньше.")
