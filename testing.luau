local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Creazione del contenitore della UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArceusNeoFullbright"
screenGui.ResetOnSpawn = false

-- Tentativo di inserire la UI in CoreGui (utile se eseguito da exploit), altrimenti in PlayerGui (per Roblox Studio)
local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ================================
-- CREAZIONE ELEMENTI VISIVI
-- ================================

-- Finestra Principale
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 120)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Grigio molto scuro, stile Neo
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Titolo
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "ARCEUS X NEO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- Testo del Toggle
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(0.5, 0, 0, 40)
toggleLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Fullbright"
toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleLabel.Font = Enum.Font.GothamSemibold
toggleLabel.TextSize = 15
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = mainFrame

-- Sfondo del Toggle (Il pulsante in sé)
local toggleBg = Instance.new("TextButton")
toggleBg.Size = UDim2.new(0, 50, 0, 24)
toggleBg.Position = UDim2.new(0.75, 0, 0.5, 8)
toggleBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleBg.Text = ""
toggleBg.AutoButtonColor = false
toggleBg.Parent = mainFrame

local toggleBgCorner = Instance.new("UICorner")
toggleBgCorner.CornerRadius = UDim.new(1, 0)
toggleBgCorner.Parent = toggleBg

-- Cerchio del Toggle
local toggleCircle = Instance.new("Frame")
toggleCircle.Size = UDim2.new(0, 18, 0, 18)
toggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleCircle.Parent = toggleBg

local toggleCircleCorner = Instance.new("UICorner")
toggleCircleCorner.CornerRadius = UDim.new(1, 0)
toggleCircleCorner.Parent = toggleCircle

-- ================================
-- LOGICA DEL FULLBRIGHT E ANIMAZIONI
-- ================================

local isFullbrightEnabled = false
local originalLighting = {} -- Qui salveremo i valori originali della mappa

toggleBg.MouseButton1Click:Connect(function()
    isFullbrightEnabled = not isFullbrightEnabled
    
    local circleGoal = {}
    local bgGoal = {}
    
    if isFullbrightEnabled then
        -- Animazione Accensione
        circleGoal.Position = UDim2.new(1, -21, 0.5, -9)
        bgGoal.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- Colore Blu Neon in stile Arceus
        toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Salva l'illuminazione originale prima di cambiarla
        originalLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows
        }
        
        -- Applica il Fullbright
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        -- Animazione Spegnimento
        circleGoal.Position = UDim2.new(0, 3, 0.5, -9)
        bgGoal.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        -- Ripristina l'illuminazione originale
        if originalLighting.Ambient then
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
    end
    
    -- Esegui la transizione fluida (Tween)
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(toggleCircle, tweenInfo, circleGoal):Play()
    TweenService:Create(toggleBg, tweenInfo, bgGoal):Play()
end)

-- ================================
-- SISTEMA DI TRASCINAMENTO (DRAG)
-- ================================

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
