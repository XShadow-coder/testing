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

-- === INTERFACCIA GRAFICA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local Frame = Instance.new("Frame")
Frame.Name = randomString()
Frame.Size = UDim2.new(0, 280, 0, 280)
Frame.Position = UDim2.new(0.5, -140, 0.5, -140)
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
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Position = UDim2.new(0, 25, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper V2"
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

-- RIGA 1: Selezione Modalità
local ModeBtn = Instance.new("TextButton")
ModeBtn.Name = randomString()
ModeBtn.Position = UDim2.new(0.5, -130, 0, 40)
ModeBtn.Size = UDim2.new(0, 260, 0, 30)
ModeBtn.Text = "Target: Player"
ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 14
ModeBtn.Parent = Frame

-- RIGA 2: Nome Player
local TextBox = Instance.new("TextBox")
TextBox.Name = randomString()
TextBox.Position = UDim2.new(0.5, -130, 0, 80)
TextBox.Size = UDim2.new(0, 260, 0, 30)
TextBox.Text = ""
TextBox.PlaceholderText = "Player's name"
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Parent = Frame

-- RIGA 3: Salva Posizione
local SetPosBtn = Instance.new("TextButton")
SetPosBtn.Name = randomString()
SetPosBtn.Position = UDim2.new(0.5, -130, 0, 120)
SetPosBtn.Size = UDim2.new(0, 260, 0, 30)
SetPosBtn.Text = "Save Current Position"
SetPosBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SetPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetPosBtn.Font = Enum.Font.GothamBold
SetPosBtn.TextSize = 14
SetPosBtn.Parent = Frame

-- RIGA 4: Reset & Ragdoll Limit
local ToggleReset = Instance.new("TextButton")
ToggleReset.Name = randomString()
ToggleReset.Position = UDim2.new(0.5, -130, 0, 160)
ToggleReset.Size = UDim2.new(0, 150, 0, 30)
ToggleReset.Text = "Auto-Reset: ON"
ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ToggleReset.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleReset.Font = Enum.Font.GothamBold
ToggleReset.TextSize = 14
ToggleReset.Parent = Frame

local RagdollInput = Instance.new("TextBox")
RagdollInput.Name = randomString()
RagdollInput.Position = UDim2.new(0.5, 30, 0, 160)
RagdollInput.Size = UDim2.new(0, 100, 0, 30)
RagdollInput.Text = "1"
RagdollInput.PlaceholderText = "Limit"
RagdollInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RagdollInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RagdollInput.Font = Enum.Font.GothamBold
RagdollInput.TextSize = 14
RagdollInput.Parent = Frame

-- RIGA 5: Start & Stop
local Start = Instance.new("TextButton")
Start.Name = randomString()
Start.Position = UDim2.new(0.5, -130, 0, 200)
Start.Size = UDim2.new(0, 125, 0, 30)
Start.Text = "Start"
Start.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
Start.TextColor3 = Color3.fromRGB(255, 255, 255)
Start.Font = Enum.Font.GothamBold
Start.TextSize = 14
Start.Parent = Frame

local Stop = Instance.new("TextButton")
Stop.Name = randomString()
Stop.Position = UDim2.new(0.5, 5, 0, 200)
Stop.Size = UDim2.new(0, 125, 0, 30)
Stop.Text = "Stop"
Stop.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
Stop.TextColor3 = Color3.fromRGB(255, 255, 255)
Stop.Font = Enum.Font.GothamBold
Stop.TextSize = 14
Stop.Parent = Frame

-- RIGA 6: Extra
local IY = Instance.new("TextButton")
IY.Name = randomString()
IY.Position = UDim2.new(0.5, -130, 0, 240)
IY.Size = UDim2.new(0, 260, 0, 25)
IY.Text = "Execute Infinite Yield"
IY.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
IY.TextColor3 = Color3.fromRGB(255, 255, 255)
IY.Font = Enum.Font.GothamBold
IY.TextSize = 14
IY.Parent = Frame
local IY_UICorner = Instance.new("UICorner")
IY_UICorner.CornerRadius = UDim.new(0, 6)
IY_UICorner.Parent = IY

local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "KS Helper",
        Text = message,
        Duration = 3
    })
end

-- === VARIABILI LOGICA ===
local helperRunning = false
local autoResetEnabled = true
local targetPlayer = nil

local targetMode = "Player" -- o "Position"
local savedCFrame = nil

local ragdollLimit = 1
local currentRagdolls = 0
local wasRagdolled = false
local alreadyReset = false

-- === EVENTI BOTTONI ===
ModeBtn.MouseButton1Click:Connect(function()
    if targetMode == "Player" then
        targetMode = "Position"
        ModeBtn.Text = "Target: Saved Position"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 150)
        TextBox.PlaceholderText = "Mode: Position (Name ignored)"
    else
        targetMode = "Player"
        ModeBtn.Text = "Target: Player"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
        TextBox.PlaceholderText = "Player's name"
    end
end)

SetPosBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedCFrame = char.HumanoidRootPart.CFrame
        notify("Position Saved successfully!")
    else
        notify("Character not found!")
    end
end)

RagdollInput.FocusLost:Connect(function()
    local num = tonumber(RagdollInput.Text)
    if num and num > 0 then
        ragdollLimit = math.floor(num)
        RagdollInput.Text = tostring(ragdollLimit)
    else
        RagdollInput.Text = tostring(ragdollLimit)
        notify("Invalid number for ragdoll limit")
    end
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

IY.MouseButton1Click:Connect(function()
    if getgenv().IY_LOADED then
        notify("Infinite Yield is already running!")
        return
    end
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    if not success then notify("Infinite Yield failed to load") end
end)

for _, part in ipairs(workspace:WaitForChild("Lobby"):WaitForChild("brazil"):GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanTouch = false
    end
end

local function findPlayer(nickname)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(nickname:lower()) or player.DisplayName:lower():find(nickname:lower()) then
            return player
        end
    end
    return nil
end

local function followLoop()
    while helperRunning do
        task.wait()
        local character = LocalPlayer.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not rootPart then continue end

        local isInArena = character:FindFirstChild("isInArena")
        if not isInArena or not isInArena.Value then continue end

        -- LOGICA RAGDOLL
        local ragdolled = character:FindFirstChild("Ragdolled")
        local isCurrentlyRagdolled = (ragdolled and ragdolled.Value)

        if isCurrentlyRagdolled and not wasRagdolled then
            wasRagdolled = true
            currentRagdolls = currentRagdolls + 1

            if autoResetEnabled and currentRagdolls >= ragdollLimit then
                local resetEvent = LocalPlayer:FindFirstChild("Reset")
                if not alreadyReset and resetEvent then
                    resetEvent:FireServer()
                    alreadyReset = true
                    currentRagdolls = 0 
                end
            end
        elseif not isCurrentlyRagdolled then
            wasRagdolled = false
            alreadyReset = false
        end

        if alreadyReset or (isCurrentlyRagdolled and autoResetEnabled and currentRagdolls >= ragdollLimit) then
            continue
        end

        -- LOGICA MOVIMENTO
        if targetMode == "Player" then
            if not targetPlayer then continue end
            local targetCharacter = targetPlayer.Character
            if not targetCharacter then continue end

            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
            local isTargetInArena = targetCharacter:FindFirstChild("isInArena")
            local isTargetInArenaV2 = targetCharacter:FindFirstChild("KillstreakLevel")

            if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then continue end
            if (not isTargetInArenaV2) and (not isTargetInArena or not isTargetInArena.Value) then continue end

            if not isCurrentlyRagdolled then
                rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
            end

        elseif targetMode == "Position" then
            if savedCFrame and not isCurrentlyRagdolled then
                rootPart.CFrame = savedCFrame
            end
        end
    end
end

-- LOGICA ENTRATA ARENA CON FIRETOUCHINTEREST
local function enterArena()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local isInArena = character:WaitForChild("isInArena")

    while helperRunning do
        if isInArena.Value then
            break 
        end

        local shouldTeleport = false

        if targetMode == "Player" and targetPlayer then
            local tChar = targetPlayer.Character
            if tChar then
                local tArena = tChar:FindFirstChild("isInArena")
                local tArena2 = tChar:FindFirstChild("KillstreakLevel")

                if (tArena and tArena.Value) or tArena2 then
                    shouldTeleport = true
                end
            end
        elseif targetMode == "Position" then
            shouldTeleport = true
        end
        
        if shouldTeleport then
            local portal = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Teleport1")
            if portal and portal:IsA("BasePart") then
                -- Uso di firetouchinterest invece del CFrame
                if firetouchinterest then
                    firetouchinterest(rootPart, portal, 0)
                    task.wait()
                    firetouchinterest(rootPart, portal, 1)
                else
                    -- Fallback nel caso in cui l'executor non supporti firetouchinterest
                    rootPart.CFrame = portal.CFrame
                end
            end
            break
        end
        task.wait(0.2)
    end

    if helperRunning then
        task.spawn(followLoop)
    end
end

local function startHelper()
    if targetMode == "Player" then
        local nameInput = TextBox.Text
        if nameInput == "" then
            notify("Enter a player's name!")
            return
        end

        local player = findPlayer(nameInput)
        if not player then
            notify("Player not found!")
            return
        end
        targetPlayer = player
    else
        if not savedCFrame then
            notify("You need to save a position first!")
            return
        end
    end

    helperRunning = true
    currentRagdolls = 0
    wasRagdolled = false
    alreadyReset = false
    task.spawn(enterArena)
end

local function stopHelper()
    helperRunning = false
end

Minimize.MouseButton1Click:Connect(function()
    local minimized = ModeBtn.Visible == false
    for _, child in ipairs(Frame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child ~= Title and child ~= Close and child ~= Minimize then
                child.Visible = minimized
            end
        end
    end
    Frame.Size = minimized and UDim2.new(0, 280, 0, 280) or UDim2.new(0, 280, 0, 30)
end)

Close.MouseButton1Click:Connect(function()
    stopHelper()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    getgenv().KsHelper_Loaded = nil
end)

LocalPlayer.CharacterAdded:Connect(function()
    if helperRunning then
        alreadyReset = false
        enterArena()
    end
end)

Start.MouseButton1Click:Connect(startHelper)
Stop.MouseButton1Click:Connect(stopHelper)
