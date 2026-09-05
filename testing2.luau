local cloneref = cloneref or function(...) return ... end

local sbPlaceIds = {
    [6403373529] = true,
    [11520107397] = true,
    [124596094333302] = true,
    [9015014224] = true,
    [78262906459073] = true,
}

if not sbPlaceIds[game.PlaceId] then
    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name or "another game"
    print("This script is for Slap Battles, but you are in " .. gameName)
    return
end

if getgenv().KsHelper_Loaded then
    return
end

pcall(function() getgenv().KsHelper_Loaded = true end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = cloneref(game:GetService("CoreGui"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = cloneref(Players.LocalPlayer)

local guiParent = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui

local function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

-- Variables
local autoResetEnabled = true
local autoResetLimit = 1
local waitRagdollEnabled = true
local ragdollCount = 0
local resetCount = 0
local savedCFrame = nil
local targetMode = "Player" -- "Player" oppure "Position"
local helperRunning = false
local targetPlayer = nil
local alreadyReset = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

-- Dimensioni adeguate a 300x410 per il nuovo pulsante
local Frame = Instance.new("Frame")
Frame.Name = randomString()
Frame.Size = UDim2.new(0, 300, 0, 410)
Frame.Position = UDim2.new(0.5, -150, 0.5, -205)
Frame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Name = randomString()
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Name = randomString()
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = randomString()
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Name = randomString()
Minimize.Size = UDim2.new(0, 25, 0, 25)
Minimize.Position = UDim2.new(1, -60, 0, 2)
Minimize.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Minimize.Text = "_"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.Parent = Frame

local MinimizeUICorner = Instance.new("UICorner")
MinimizeUICorner.CornerRadius = UDim.new(0, 6)
MinimizeUICorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Name = randomString()
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Frame

local CloseUICorner = Instance.new("UICorner")
CloseUICorner.CornerRadius = UDim.new(0, 6)
CloseUICorner.Parent = Close

-- Status Report Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = randomString()
StatusLabel.Position = UDim2.new(0.5, -135, 0, 35)
StatusLabel.Size = UDim2.new(0, 270, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.Text = "Ragdolls: 0 | Resets: 0\nTarget: None | Mode: Player"
StatusLabel.Parent = Frame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- TextBox Target (Nome o UserId)
local TextBox = Instance.new("TextBox")
TextBox.Name = randomString()
TextBox.Position = UDim2.new(0.5, -135, 0, 80)
TextBox.Size = UDim2.new(0, 270, 0, 30)
TextBox.Text = ""
TextBox.PlaceholderText = "Player Name or UserId"
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 13
TextBox.Parent = Frame

local TextBoxCorner = Instance.new("UICorner")
TextBoxCorner.CornerRadius = UDim.new(0, 6)
TextBoxCorner.Parent = TextBox

-- Save Pos & Target Mode Buttons
local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Name = randomString()
SavePosBtn.Position = UDim2.new(0.5, -135, 0, 120)
SavePosBtn.Size = UDim2.new(0, 130, 0, 30)
SavePosBtn.Text = "Save Pos"
SavePosBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.Font = Enum.Font.GothamBold
SavePosBtn.TextSize = 12
SavePosBtn.Parent = Frame

local SavePosCorner = Instance.new("UICorner")
SavePosCorner.CornerRadius = UDim.new(0, 6)
SavePosCorner.Parent = SavePosBtn

local ModeBtn = Instance.new("TextButton")
ModeBtn.Name = randomString()
ModeBtn.Position = UDim2.new(0.5, 5, 0, 120)
ModeBtn.Size = UDim2.new(0, 130, 0, 30)
ModeBtn.Text = "Mode: Player"
ModeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 12
ModeBtn.Parent = Frame

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 6)
ModeCorner.Parent = ModeBtn

-- Start & Stop
local Start = Instance.new("TextButton")
Start.Name = randomString()
Start.Position = UDim2.new(0.5, -135, 0, 160)
Start.Size = UDim2.new(0, 130, 0, 30)
Start.Text = "Start"
Start.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
Start.TextColor3 = Color3.fromRGB(255, 255, 255)
Start.Font = Enum.Font.GothamBold
Start.TextSize = 14
Start.Parent = Frame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 6)
StartCorner.Parent = Start

local Stop = Instance.new("TextButton")
Stop.Name = randomString()
Stop.Position = UDim2.new(0.5, 5, 0, 160)
Stop.Size = UDim2.new(0, 130, 0, 30)
Stop.Text = "Stop"
Stop.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
Stop.TextColor3 = Color3.fromRGB(255, 255, 255)
Stop.Font = Enum.Font.GothamBold
Stop.TextSize = 14
Stop.Parent = Frame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 6)
StopCorner.Parent = Stop

-- Auto-Reset Toggle & Max Ragdolls Box
local ToggleReset = Instance.new("TextButton")
ToggleReset.Name = randomString()
ToggleReset.Position = UDim2.new(0.5, -135, 0, 200)
ToggleReset.Size = UDim2.new(0, 180, 0, 30)
ToggleReset.Text = "Auto-Reset: ON"
ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ToggleReset.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleReset.Font = Enum.Font.GothamBold
ToggleReset.TextSize = 13
ToggleReset.Parent = Frame

local ToggleResetCorner = Instance.new("UICorner")
ToggleResetCorner.CornerRadius = UDim.new(0, 6)
ToggleResetCorner.Parent = ToggleReset

local MaxRagdollInput = Instance.new("TextBox")
MaxRagdollInput.Name = randomString()
MaxRagdollInput.Position = UDim2.new(0.5, 55, 0, 200)
MaxRagdollInput.Size = UDim2.new(0, 80, 0, 30)
MaxRagdollInput.Text = "1"
MaxRagdollInput.PlaceholderText = "Max"
MaxRagdollInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MaxRagdollInput.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxRagdollInput.Font = Enum.Font.GothamBold
MaxRagdollInput.TextSize = 13
MaxRagdollInput.Parent = Frame

local MaxRagdollCorner = Instance.new("UICorner")
MaxRagdollCorner.CornerRadius = UDim.new(0, 6)
MaxRagdollCorner.Parent = MaxRagdollInput

-- Wait Ragdoll Toggle Button
local ToggleWaitRagdoll = Instance.new("TextButton")
ToggleWaitRagdoll.Name = randomString()
ToggleWaitRagdoll.Position = UDim2.new(0.5, -135, 0, 240)
ToggleWaitRagdoll.Size = UDim2.new(0, 270, 0, 30)
ToggleWaitRagdoll.Text = "Wait Until Unragdolled: ON"
ToggleWaitRagdoll.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ToggleWaitRagdoll.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleWaitRagdoll.Font = Enum.Font.GothamBold
ToggleWaitRagdoll.TextSize = 13
ToggleWaitRagdoll.Parent = Frame

local ToggleWaitRagdollCorner = Instance.new("UICorner")
ToggleWaitRagdollCorner.CornerRadius = UDim.new(0, 6)
ToggleWaitRagdollCorner.Parent = ToggleWaitRagdoll

-- Infinite Yield Button
local IY = Instance.new("TextButton")
IY.Name = randomString()
IY.Position = UDim2.new(0.5, -135, 0, 280)
IY.Size = UDim2.new(0, 270, 0, 25)
IY.Text = "Execute Infinite Yield"
IY.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
IY.TextColor3 = Color3.fromRGB(255, 255, 255)
IY.Font = Enum.Font.GothamBold
IY.TextSize = 13
IY.Parent = Frame

local IY_UICorner = Instance.new("UICorner")
IY_UICorner.CornerRadius = UDim.new(0, 6)
IY_UICorner.Parent = IY

local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "Killstreak Helper",
        Text = message,
        Duration = 3
    })
end

local function updateStatusUI()
    local name = targetPlayer and targetPlayer.Name or "None"
    StatusLabel.Text = string.format("Ragdolls: %d | Resets: %d\nTarget: %s | Mode: %s", ragdollCount, resetCount, name, targetMode)
end

-- Ricerca Player per Nome o UserId
local function findPlayer(input)
    local num = tonumber(input)
    for _, player in ipairs(Players:GetPlayers()) do
        if num and player.UserId == num then
            return player
        end
        if player.Name:lower():find(input:lower()) or player.DisplayName:lower():find(input:lower()) then
            return player
        end
    end
    return nil
end

-- Tasti Interfaccia
SavePosBtn.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local inArena = workspace:FindFirstChild(LocalPlayer.Name) and workspace[LocalPlayer.Name]:FindFirstChild("isInArena")
        if inArena and inArena.Value then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                savedCFrame = root.CFrame
                notify("Position Saved!")
            end
        else
            notify("You must be IN ARENA to save position!")
        end
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    if targetMode == "Player" then
        targetMode = "Position"
    else
        targetMode = "Player"
    end
    ModeBtn.Text = "Mode: " .. targetMode
    updateStatusUI()
end)

ToggleReset.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled
    if autoResetEnabled then
        ToggleReset.Text = "Auto-Reset: ON"
        ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    else
        ToggleReset.Text = "Auto-Reset: OFF"
        ToggleReset.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    end
end)

ToggleWaitRagdoll.MouseButton1Click:Connect(function()
    waitRagdollEnabled = not waitRagdollEnabled
    if waitRagdollEnabled then
        ToggleWaitRagdoll.Text = "Wait Until Unragdolled: ON"
        ToggleWaitRagdoll.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    else
        ToggleWaitRagdoll.Text = "Wait Until Unragdolled: OFF"
        ToggleWaitRagdoll.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    end
end)

MaxRagdollInput.FocusLost:Connect(function()
    local val = tonumber(MaxRagdollInput.Text)
    if val and val > 0 then
        autoResetLimit = math.floor(val)
    else
        MaxRagdollInput.Text = tostring(autoResetLimit)
    end
end)

IY.MouseButton1Click:Connect(function()
    if getgenv().IY_LOADED then
        notify("Infinite Yield is already running!")
        return
    end

    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    if not success then
        notify("Infinite Yield failed to load")
    end
end)

-- Disabilita trappola Brazil nel lobby
pcall(function()
    for _, part in ipairs(workspace:WaitForChild("Lobby"):WaitForChild("brazil"):GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanTouch = false
        end
    end
end)

-- Rilevamento Ragdoll e Reset tramite Heartbeat
local lastRagdollState = false
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local ragdolled = character:FindFirstChild("Ragdolled")
    local isRag = ragdolled and ragdolled.Value or false

    if isRag and not lastRagdollState then
        ragdollCount = ragdollCount + 1
        updateStatusUI()

        -- Reset eseguito SOLO se lo script è attivo (helperRunning == true)
        if helperRunning and autoResetEnabled and ragdollCount >= autoResetLimit and not alreadyReset then
            local resetEvent = LocalPlayer:FindFirstChild("Reset")
            if resetEvent then
                resetEvent:FireServer()
                alreadyReset = true
                resetCount = resetCount + 1
                updateStatusUI()
            end
        end
    elseif not isRag then
        alreadyReset = false
    end
    lastRagdollState = isRag
end)

-- Logica Inseguimento
local function followTarget()
    while helperRunning do
        local character = LocalPlayer.Character
        if not character then task.wait(0.1) continue end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then task.wait(0.1) continue end

        local isInArena = character:FindFirstChild("isInArena")
        if not isInArena or not isInArena.Value then task.wait(0.1) continue end

        -- Se il toggle 'Wait Ragdoll' è ON, ferma il TP se il mio character è in ragdoll
        local ragdolled = character:FindFirstChild("Ragdolled")
        if waitRagdollEnabled and ragdolled and ragdolled.Value then
            task.wait(0.1)
            continue
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then task.wait(0.1) continue end

        if targetMode == "Player" then
            if not targetPlayer then task.wait(0.1) continue end
            
            local targetCharacter = workspace:FindFirstChild(targetPlayer.Name)
            if not targetCharacter then task.wait(0.1) continue end

            -- Controllo isInArena del target
            local isTargetInArena = targetCharacter:FindFirstChild("isInArena")
            local isTargetInArenaV2 = targetCharacter:FindFirstChild("KillstreakLevel")
            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

            if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
                task.wait(0.1)
                continue
            end

            -- Attende che il target sia effettivamente in arena
            local targetIsInArenaBool = (isTargetInArena and isTargetInArena.Value) or (isTargetInArenaV2 ~= nil)
            if not targetIsInArenaBool then
                task.wait(0.1)
                continue
            end

            rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)

        elseif targetMode == "Position" then
            if savedCFrame then
                rootPart.CFrame = savedCFrame
            end
        end

        task.wait()
    end
end

-- Ingresso Portale con Stabilizzazione
local function enterArena()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    while helperRunning do
        local isInArena = character:FindFirstChild("isInArena")
        if isInArena and isInArena.Value then
            break
        end

        local portal = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Teleport1")
        if portal and portal:IsA("BasePart") then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.CFrame = portal.CFrame
        end
        task.wait(0.1)
    end

    if helperRunning then
        followTarget()
    end
end

local function startHelper()
    if targetMode == "Player" then
        local nameInput = TextBox.Text
        if nameInput == "" then
            notify("Enter Name or UserId!")
            return
        end

        local player = findPlayer(nameInput)
        if not player then
            notify("Player not found!")
            return
        end

        targetPlayer = player
    elseif targetMode == "Position" and not savedCFrame then
        notify("No position saved!")
        return
    end

    helperRunning = true
    updateStatusUI()
    task.spawn(enterArena)
end

local function stopHelper()
    helperRunning = false
end

Minimize.MouseButton1Click:Connect(function()
    local minimized = TextBox.Visible == false
    for _, child in ipairs(Frame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child ~= Title and child ~= Close and child ~= Minimize then
                child.Visible = minimized
            end
        end
    end
    Frame.Size = minimized and UDim2.new(0, 300, 0, 410) or UDim2.new(0, 300, 0, 30)
end)

Close.MouseButton1Click:Connect(function()
    stopHelper()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    getgenv().KsHelper_Loaded = nil
end)

LocalPlayer.CharacterAdded:Connect(function()
    ragdollCount = 0
    alreadyReset = false
    updateStatusUI()
    if helperRunning then
        enterArena()
    end
end)

Start.MouseButton1Click:Connect(startHelper)
Stop.MouseButton1Click:Connect(stopHelper)
