--[ SETUP AMBIENTE EXECUTOR ]--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--[ VARIABILI DI STATO ]--
local State = {
    IsRunning = false,
    Target = nil,
    TargetMode = "Player", -- "Player" o "Position"
    SavedPosition = nil,
    RagdollCount = 0,
    ResetCount = 0,
    AutoReset = false,
    AutoResetLimit = 3,
    IsResetting = false
}

-- Elimina vecchia GUI se esiste
if CoreGui:FindFirstChild("AdvancedProHub") then
    CoreGui.AdvancedProHub:Destroy()
end

--[ CREAZIONE INTERFACCIA (Design Moderno) ]--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedProHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 520)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Titolo
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Advanced Control Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Container per layout ordinato
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Content

-- Funzione helper per creare pannelli
local function createPanel(height)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, 0, 0, height)
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
    panel.Parent = Content
    return panel
end

-- Funzione helper per creare bottoni moderni
local function createButton(parent, text, size, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = parent
    return btn
end

-- [1] STATUS REPORT
local StatusPanel = createPanel(60)
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Ragdolls: 0  |  Resets: 0\nTarget: Nessuno  |  Mode: Player"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusPanel

local function updateUI()
    local tName = State.Target and State.Target.Name or "Nessuno"
    StatusText.Text = string.format("Ragdolls: %d  |  Resets: %d\nTarget: %s  |  Mode: %s", 
        State.RagdollCount, State.ResetCount, tName, State.TargetMode)
end

-- [2] TARGETING
local TargetPanel = createPanel(50)
local TargetInput = Instance.new("TextBox")
TargetInput.Size = UDim2.new(1, -20, 1, -10)
TargetInput.Position = UDim2.new(0, 10, 0, 5)
TargetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TargetInput.PlaceholderText = "Inserisci Username o UserId..."
TargetInput.Text = ""
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.Font = Enum.Font.Gotham
TargetInput.TextSize = 14
Instance.new("UICorner", TargetInput).CornerRadius = UDim.new(0, 6)
TargetInput.Parent = TargetPanel

TargetInput.FocusLost:Connect(function()
    local input = TargetInput.Text
    State.Target = nil
    if tonumber(input) then
        for _, p in pairs(Players:GetPlayers()) do
            if p.UserId == tonumber(input) then State.Target = p break end
        end
    end
    if not State.Target then
        for _, p in pairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, #input) == string.lower(input) then
                State.Target = p break
            end
        end
    end
    updateUI()
end)

-- [3] MODE & SAVE POS
local ModePanel = createPanel(50)
local ModeBtn = createButton(ModePanel, "Mode: Player", UDim2.new(0.48, 0, 1, -10), UDim2.new(0, 10, 0, 5), Color3.fromRGB(41, 128, 185))
local SaveBtn = createButton(ModePanel, "Save Position", UDim2.new(0.48, 0, 1, -10), UDim2.new(0.52, -10, 0, 5), Color3.fromRGB(39, 174, 96))

ModeBtn.MouseButton1Click:Connect(function()
    State.TargetMode = State.TargetMode == "Player" and "Position" or "Player"
    ModeBtn.Text = "Mode: " .. State.TargetMode
    updateUI()
end)

SaveBtn.MouseButton1Click:Connect(function()
    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if char and char:FindFirstChild("HumanoidRootPart") then
        if char:FindFirstChild("IsInArena") then -- Check in workspace
            State.SavedPosition = char.HumanoidRootPart.CFrame
            SaveBtn.Text = "Saved!"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        else
            SaveBtn.Text = "Not in Arena!"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
        end
        task.wait(1.5)
        SaveBtn.Text = "Save Position"
        SaveBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    end
end)

-- [4] AUTO RESET
local ResetPanel = createPanel(50)
local AutoResetBtn = createButton(ResetPanel, "Auto Reset: OFF", UDim2.new(0.7, 0, 1, -10), UDim2.new(0, 10, 0, 5), Color3.fromRGB(192, 57, 43))
local LimitInput = Instance.new("TextBox")
LimitInput.Size = UDim2.new(0.3, -20, 1, -10)
LimitInput.Position = UDim2.new(0.7, 10, 0, 5)
LimitInput.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
LimitInput.Text = tostring(State.AutoResetLimit)
LimitInput.PlaceholderText = "Max"
LimitInput.TextColor3 = Color3.fromRGB(255, 255, 255)
LimitInput.Font = Enum.Font.Gotham
LimitInput.TextSize = 14
Instance.new("UICorner", LimitInput).CornerRadius = UDim.new(0, 6)
LimitInput.Parent = ResetPanel

AutoResetBtn.MouseButton1Click:Connect(function()
    State.AutoReset = not State.AutoReset
    AutoResetBtn.Text = State.AutoReset and "Auto Reset: ON" or "Auto Reset: OFF"
    AutoResetBtn.BackgroundColor3 = State.AutoReset and Color3.fromRGB(39, 174, 96) or Color3.fromRGB(192, 57, 43)
end)

LimitInput.FocusLost:Connect(function()
    local num = tonumber(LimitInput.Text)
    if num then State.AutoResetLimit = num else LimitInput.Text = tostring(State.AutoResetLimit) end
end)

-- [5] START & STOP
local ActionPanel = createPanel(60)
ActionPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Trasparente al bg
local StartBtn = createButton(ActionPanel, "▶ START", UDim2.new(0.48, 0, 1, -10), UDim2.new(0, 10, 0, 5), Color3.fromRGB(46, 204, 113))
local StopBtn = createButton(ActionPanel, "⏹ STOP", UDim2.new(0.48, 0, 1, -10), UDim2.new(0.52, -10, 0, 5), Color3.fromRGB(231, 76, 60))

-- Dragging Logic Fluida
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- [ LOGICA DI FUNZIONAMENTO (Stabile) ]--

local function isPlayerInArena(targetPlayer)
    if not targetPlayer then return false end
    local char = workspace:FindFirstChild(targetPlayer.Name)
    return char and char:FindFirstChild("IsInArena") ~= nil
end

local function loopAction()
    task.spawn(function()
        while State.IsRunning do
            task.wait(0.05) -- Delay per non laggare il gioco
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then continue end

            local hrp = myChar.HumanoidRootPart

            if State.TargetMode == "Player" and State.Target then
                if isPlayerInArena(State.Target) then
                    local targetChar = workspace:FindFirstChild(State.Target.Name)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        -- Stabilizza il teleport azzerando la velocità (Anticheat bypass)
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.RotVelocity = Vector3.new(0,0,0)
                        hrp.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5) -- Dietro il player
                    end
                end
            elseif State.TargetMode == "Position" and State.SavedPosition then
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.RotVelocity = Vector3.new(0,0,0)
                hrp.CFrame = State.SavedPosition
            end
        end
    end)
end

StartBtn.MouseButton1Click:Connect(function()
    if not State.IsRunning then
        State.IsRunning = true
        StartBtn.Text = "▶ RUNNING..."
        StartBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        loopAction()
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    State.IsRunning = false
    StartBtn.Text = "▶ START"
    StartBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
end)

-- Rilevamento Ragdoll / Reset (Ottimizzato)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum and hum.Health > 0 then
        local st = hum:GetState()
        local isRagdolled = (st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown or hum.PlatformStand)
        
        if isRagdolled and not char:GetAttribute("IsRagdollActive") then
            char:SetAttribute("IsRagdollActive", true)
            State.RagdollCount = State.RagdollCount + 1
            updateUI()
            
            -- Auto Reset (Setta Health = 0 al posto di BreakJoints)
            if State.AutoReset and State.RagdollCount >= State.AutoResetLimit and not State.IsResetting then
                State.IsResetting = true
                hum.Health = 0
            end
        elseif not isRagdolled then
            char:SetAttribute("IsRagdollActive", false)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    State.RagdollCount = 0
    State.IsResetting = false
    if State.AutoReset then
        State.ResetCount = State.ResetCount + 1
    end
    updateUI()
end)
