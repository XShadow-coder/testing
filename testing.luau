local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variabili di stato
local ragdollCount = 0
local resetCount = 0
local autoResetEnabled = false
local autoResetLimit = 3
local currentTarget = nil
local savedPosition = nil
local targetMode = "Player" -- o "Position"

-- Creazione GUI (Interfaccia più grande)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AdvancedHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Control Panel"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- Status Report
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 60)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 50)
StatusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Text = "Ragdolls: 0 | Resets: 0\nTarget: Nessuno"
Instance.new("UICorner", StatusLabel)

local function updateStatus()
    local targetName = currentTarget and currentTarget.Name or "Nessuno"
    StatusLabel.Text = string.format("Ragdolls: %d | Resets: %d\nTarget: %s | Mode: %s", ragdollCount, resetCount, targetName, targetMode)
end

-- Target Input (Nome o UserId)
local TargetInput = Instance.new("TextBox", MainFrame)
TargetInput.Size = UDim2.new(0.9, 0, 0, 40)
TargetInput.Position = UDim2.new(0.05, 0, 0, 120)
TargetInput.PlaceholderText = "Inserisci Nome o UserId"
TargetInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
TargetInput.TextColor3 = Color3.new(1, 1, 1)
TargetInput.Text = ""
Instance.new("UICorner", TargetInput)

TargetInput.FocusLost:Connect(function()
    local input = TargetInput.Text
    currentTarget = nil
    
    -- Ricerca per UserId
    if tonumber(input) then
        for _, p in pairs(Players:GetPlayers()) do
            if p.UserId == tonumber(input) then
                currentTarget = p
                break
            end
        end
    end
    
    -- Ricerca per Nome se UserId fallisce
    if not currentTarget then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #input) == input:lower() then
                currentTarget = p
                break
            end
        end
    end
    updateStatus()
end)

-- Toggle Mode (Player / Position)
local ModeBtn = Instance.new("TextButton", MainFrame)
ModeBtn.Size = UDim2.new(0.42, 0, 0, 40)
ModeBtn.Position = UDim2.new(0.05, 0, 0, 170)
ModeBtn.Text = "Mode: Player"
ModeBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ModeBtn)

ModeBtn.MouseButton1Click:Connect(function()
    if targetMode == "Player" then
        targetMode = "Position"
        ModeBtn.Text = "Mode: Position"
    else
        targetMode = "Player"
        ModeBtn.Text = "Mode: Player"
    end
    updateStatus()
end)

-- Save Position
local SavePosBtn = Instance.new("TextButton", MainFrame)
SavePosBtn.Size = UDim2.new(0.42, 0, 0, 40)
SavePosBtn.Position = UDim2.new(0.53, 0, 0, 170)
SavePosBtn.Text = "Save Position"
SavePosBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
SavePosBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SavePosBtn)

SavePosBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- Controllo IsInArena (Modifica il percorso se necessario per il tuo gioco)
        local isInArena = char:FindFirstChild("IsInArena")
        if isInArena and isInArena.Value == true then
            savedPosition = char.HumanoidRootPart.CFrame
            SavePosBtn.Text = "Saved!"
            task.wait(1)
            SavePosBtn.Text = "Save Position"
        else
            SavePosBtn.Text = "Not in Arena!"
            SavePosBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            task.wait(1)
            SavePosBtn.Text = "Save Position"
            SavePosBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
        end
    end
end)

-- Auto Reset Toggle
local AutoResetBtn = Instance.new("TextButton", MainFrame)
AutoResetBtn.Size = UDim2.new(0.6, 0, 0, 40)
AutoResetBtn.Position = UDim2.new(0.05, 0, 0, 230)
AutoResetBtn.Text = "Auto Reset: OFF"
AutoResetBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
AutoResetBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AutoResetBtn)

AutoResetBtn.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled
    AutoResetBtn.Text = autoResetEnabled and "Auto Reset: ON" or "Auto Reset: OFF"
    AutoResetBtn.BackgroundColor3 = autoResetEnabled and Color3.fromRGB(60, 200, 120) or Color3.fromRGB(200, 60, 60)
end)

-- Auto Reset Limit Input
local LimitInput = Instance.new("TextBox", MainFrame)
LimitInput.Size = UDim2.new(0.25, 0, 0, 40)
LimitInput.Position = UDim2.new(0.7, 0, 0, 230)
LimitInput.Text = tostring(autoResetLimit)
LimitInput.PlaceholderText = "Max"
LimitInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
LimitInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", LimitInput)

LimitInput.FocusLost:Connect(function()
    local num = tonumber(LimitInput.Text)
    if num then
        autoResetLimit = num
    else
        LimitInput.Text = tostring(autoResetLimit)
    end
end)

-- Logica Stabilità Portale (Esempio robusto)
local function teleportToPortal(portalCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- Teleport ripetuto per maggiore stabilità (Bypassa i problemi di caricamento)
        for i = 1, 3 do
            char.HumanoidRootPart.CFrame = portalCFrame
            task.wait(0.05)
        end
    end
end

-- Rilevamento Ragdoll e Logica Auto Reset
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local state = char.Humanoid:GetState()
        
        -- Rileva il ragdoll (PlatformStand o FallingDown/Ragdoll)
        if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or char.Humanoid.PlatformStand then
            if not char:GetAttribute("IsRagdolled") then
                char:SetAttribute("IsRagdolled", true)
                ragdollCount = ragdollCount + 1
                updateStatus()
                
                -- Esegui Auto Reset se attivato e il limite è raggiunto
                if autoResetEnabled and ragdollCount >= autoResetLimit then
                    char:BreakJoints()
                    resetCount = resetCount + 1
                    ragdollCount = 0
                    updateStatus()
                end
            end
        else
            char:SetAttribute("IsRagdolled", false)
        end
    end
end)

-- Reset contatore ragdoll al respawn
LocalPlayer.CharacterAdded:Connect(function()
    ragdollCount = 0
    updateStatus()
end)
