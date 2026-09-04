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
	local length = math.random(10, 20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

-- === STILE & COLORI ===
local THEME = {
    Background = Color3.fromRGB(24, 24, 28),
    Header = Color3.fromRGB(32, 32, 38),
    Card = Color3.fromRGB(36, 36, 44),
    InputBg = Color3.fromRGB(44, 44, 54),
    Border = Color3.fromRGB(55, 55, 68),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 175),
    AccentGreen = Color3.fromRGB(46, 160, 67),
    AccentRed = Color3.fromRGB(218, 54, 51),
    AccentBlue = Color3.fromRGB(45, 110, 210),
    ButtonHover = Color3.fromRGB(50, 50, 62)
}

-- === INTERFACCIA GRAFICA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = randomString()
MainFrame.Size = UDim2.new(0, 300, 0, 310)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -155)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Top Bar / Header
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = randomString()
HeaderBar.Size = UDim2.new(1, 0, 0, 36)
HeaderBar.BackgroundColor3 = THEME.Header
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderBar

-- Fix per coprire i bordi arrotondati inferiori dell'header
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = THEME.Header
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = HeaderBar

local Title = Instance.new("TextLabel")
Title.Name = randomString()
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Killstreak Helper"
Title.TextColor3 = THEME.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -56, 0.5, -12)
MinimizeBtn.BackgroundColor3 = THEME.InputBg
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = THEME.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
MinimizeBtn.Parent = HeaderBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
CloseBtn.BackgroundColor3 = THEME.AccentRed
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Container Contenuti
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = randomString()
ContentContainer.Size = UDim2.new(1, -24, 1, -48)
ContentContainer.Position = UDim2.new(0, 12, 0, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- 1. Selettore Modalità Target
local ModeSelector = Instance.new("TextButton")
ModeSelector.Size = UDim2.new(1, 0, 0, 32)
ModeSelector.Position = UDim2.new(0, 0, 0, 0)
ModeSelector.BackgroundColor3 = THEME.AccentBlue
ModeSelector.Text = "🎯 Mode: Follow Player"
ModeSelector.TextColor3 = THEME.Text
ModeSelector.Font = Enum.Font.GothamBold
ModeSelector.TextSize = 13
ModeSelector.Parent = ContentContainer

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 7)
ModeCorner.Parent = ModeSelector

-- 2. Input per Player
local PlayerInput = Instance.new("TextBox")
PlayerInput.Size = UDim2.new(1, 0, 0, 32)
PlayerInput.Position = UDim2.new(0, 0, 0, 38)
PlayerInput.PlaceholderText = "Enter target player name..."
PlayerInput.Text = ""
PlayerInput.BackgroundColor3 = THEME.InputBg
PlayerInput.TextColor3 = THEME.Text
PlayerInput.PlaceholderColor3 = THEME.TextDim
PlayerInput.Font = Enum.Font.Gotham
PlayerInput.TextSize = 13
PlayerInput.Parent = ContentContainer

local PlayerInputCorner = Instance.new("UICorner")
PlayerInputCorner.CornerRadius = UDim.new(0, 7)
PlayerInputCorner.Parent = PlayerInput

-- 2b. Bottone Posizione (Visibile solo in modalità Position)
local PosButton = Instance.new("TextButton")
PosButton.Size = UDim2.new(1, 0, 0, 32)
PosButton.Position = UDim2.new(0, 0, 0, 38)
PosButton.Text = "📍 Save Current Position"
PosButton.BackgroundColor3 = THEME.Card
PosButton.TextColor3 = THEME.Text
PosButton.Font = Enum.Font.GothamBold
PosButton.TextSize = 13
PosButton.Visible = false
PosButton.Parent = ContentContainer

local PosCorner = Instance.new("UICorner")
PosCorner.CornerRadius = UDim.new(0, 7)
PosCorner.Parent = PosButton

local PosStroke = Instance.new("UIStroke")
PosStroke.Color = THEME.Border
PosStroke.Parent = PosButton

-- 3. Sezione Auto-Reset & Ragdoll Limit
local ResetFrame = Instance.new("Frame")
ResetFrame.Size = UDim2.new(1, 0, 0, 34)
ResetFrame.Position = UDim2.new(0, 0, 0, 76)
ResetFrame.BackgroundTransparency = 1
ResetFrame.Parent = ContentContainer

local ToggleResetBtn = Instance.new("TextButton")
ToggleResetBtn.Size = UDim2.new(0, 160, 1, 0)
ToggleResetBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleResetBtn.Text = "Auto-Reset: ON"
ToggleResetBtn.BackgroundColor3 = THEME.AccentGreen
ToggleResetBtn.TextColor3 = THEME.Text
ToggleResetBtn.Font = Enum.Font.GothamBold
ToggleResetBtn.TextSize = 12
ToggleResetBtn.Parent = ResetFrame

local ToggleResetCorner = Instance.new("UICorner")
ToggleResetCorner.CornerRadius = UDim.new(0, 7)
ToggleResetCorner.Parent = ToggleResetBtn

local RagdollBox = Instance.new("TextBox")
RagdollBox.Size = UDim2.new(0, 110, 1, 0)
RagdollBox.Position = UDim2.new(1, -110, 0, 0)
RagdollBox.Text = "1"
RagdollBox.PlaceholderText = "Limit"
RagdollBox.BackgroundColor3 = THEME.InputBg
RagdollBox.TextColor3 = THEME.Text
RagdollBox.Font = Enum.Font.GothamBold
RagdollBox.TextSize = 13
RagdollBox.Parent = ResetFrame

local RagdollCorner = Instance.new("UICorner")
RagdollCorner.CornerRadius = UDim.new(0, 7)
RagdollCorner.Parent = RagdollBox

local RagdollLabel = Instance.new("TextLabel")
RagdollLabel.Size = UDim2.new(1, 0, 0, 12)
RagdollLabel.Position = UDim2.new(0, 0, -0.4, 0)
RagdollLabel.BackgroundTransparency = 1
RagdollLabel.Text = "Max Ragdolls:"
RagdollLabel.TextColor3 = THEME.TextDim
RagdollLabel.Font = Enum.Font.Gotham
RagdollLabel.TextSize = 10
RagdollLabel.TextXAlignment = Enum.TextXAlignment.Right
RagdollLabel.Parent = RagdollBox

-- 4. Bottoni Start / Stop
local ActionFrame = Instance.new("Frame")
ActionFrame.Size = UDim2.new(1, 0, 0, 36)
ActionFrame.Position = UDim2.new(0, 0, 0, 120)
ActionFrame.BackgroundTransparency = 1
ActionFrame.Parent = ContentContainer

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.48, 0, 1, 0)
StartBtn.Position = UDim2.new(0, 0, 0, 0)
StartBtn.Text = "▶ Start"
StartBtn.BackgroundColor3 = THEME.AccentGreen
StartBtn.TextColor3 = THEME.Text
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = ActionFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 7)
StartCorner.Parent = StartBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.48, 0, 1, 0)
StopBtn.Position = UDim2.new(0.52, 0, 0, 0)
StopBtn.Text = "⏹ Stop"
StopBtn.BackgroundColor3 = THEME.AccentRed
StopBtn.TextColor3 = THEME.Text
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = ActionFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 7)
StopCorner.Parent = StopBtn

-- 5. Utility
local IYBtn = Instance.new("TextButton")
IYBtn.Size = UDim2.new(1, 0, 0, 30)
IYBtn.Position = UDim2.new(0, 0, 0, 166)
IYBtn.Text = "🌐 Load Infinite Yield"
IYBtn.BackgroundColor3 = THEME.Card
IYBtn.TextColor3 = THEME.Text
IYBtn.Font = Enum.Font.GothamMedium
IYBtn.TextSize = 12
IYBtn.Parent = ContentContainer

local IYCorner = Instance.new("UICorner")
IYCorner.CornerRadius = UDim.new(0, 7)
IYCorner.Parent = IYBtn

local IYStroke = Instance.new("UIStroke")
IYStroke.Color = THEME.Border
IYStroke.Parent = IYBtn

-- Label di Stato
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 202)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = THEME.TextDim
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.Parent = ContentContainer

-- === FUNZIONE NOTIFICHE ===
local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "KS Helper",
        Text = message,
        Duration = 2.5
    })
end

-- === LOGICA E STATO ===
local helperRunning = false
local autoResetEnabled = true
local targetPlayer = nil
local targetMode = "Player" -- "Player" o "Position"
local savedCFrame = nil

local ragdollLimit = 1
local currentRagdolls = 0
local wasRagdolled = false
local alreadyReset = false

-- === LOGICA DELLA UI ===
ModeSelector.MouseButton1Click:Connect(function()
    if targetMode == "Player" then
        targetMode = "Position"
        ModeSelector.Text = "📍 Mode: Fixed Position"
        ModeSelector.BackgroundColor3 = Color3.fromRGB(120, 70, 190)
        PlayerInput.Visible = false
        PosButton.Visible = true
    else
        targetMode = "Player"
        ModeSelector.Text = "🎯 Mode: Follow Player"
        ModeSelector.BackgroundColor3 = THEME.AccentBlue
        PlayerInput.Visible = true
        PosButton.Visible = false
    end
end)

PosButton.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedCFrame = char.HumanoidRootPart.CFrame
        PosButton.Text = "✓ Position Saved!"
        PosButton.BackgroundColor3 = THEME.AccentGreen
        task.delay(1.5, function()
            PosButton.Text = "📍 Update Saved Position"
            PosButton.BackgroundColor3 = THEME.Card
        end)
    else
        notify("Character not found!")
    end
end)

RagdollBox.FocusLost:Connect(function()
    local num = tonumber(RagdollBox.Text)
    if num and num > 0 then
        ragdollLimit = math.floor(num)
        RagdollBox.Text = tostring(ragdollLimit)
    else
        RagdollBox.Text = tostring(ragdollLimit)
        notify("Enter a valid number!")
    end
end)

ToggleResetBtn.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled
    if autoResetEnabled then
        ToggleResetBtn.Text = "Auto-Reset: ON"
        ToggleResetBtn.BackgroundColor3 = THEME.AccentGreen
    else
        ToggleResetBtn.Text = "Auto-Reset: OFF"
        ToggleResetBtn.BackgroundColor3 = THEME.AccentRed
    end
end)

IYBtn.MouseButton1Click:Connect(function()
    if getgenv().IY_LOADED then
        notify("Infinite Yield is already running!")
        return
    end
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    if not success then notify("Infinite Yield failed to load") end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    local isMinimized = ContentContainer.Visible
    ContentContainer.Visible = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 300, 0, 36) or UDim2.new(0, 300, 0, 310)
    MinimizeBtn.Text = isMinimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function()
    helperRunning = false
    if ScreenGui then
        ScreenGui:Destroy()
    end
    getgenv().KsHelper_Loaded = nil
end)

-- === DISABILITA PORTALE BRAZIL ===
for _, part in ipairs(workspace:WaitForChild("Lobby"):WaitForChild("brazil"):GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanTouch = false
    end
end

-- === LOGICA CORE GAMEPLAY ===
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

        -- Contatore Ragdoll
        local ragdolled = character:FindFirstChild("Ragdolled")
        local isCurrentlyRagdolled = (ragdolled and ragdolled.Value)

        if isCurrentlyRagdolled and not wasRagdolled then
            wasRagdolled = true
            currentRagdolls = currentRagdolls + 1
            StatusLabel.Text = "Status: Ragdolled (" .. currentRagdolls .. "/" .. ragdollLimit .. ")"

            if autoResetEnabled and currentRagdolls >= ragdollLimit then
                local resetEvent = LocalPlayer:FindFirstChild("Reset")
                if not alreadyReset and resetEvent then
                    resetEvent:FireServer()
                    alreadyReset = true
                    currentRagdolls = 0
                    StatusLabel.Text = "Status: Auto-Resetting..."
                end
            end
        elseif not isCurrentlyRagdolled then
            wasRagdolled = false
            alreadyReset = false
        end

        if alreadyReset or (isCurrentlyRagdolled and autoResetEnabled and currentRagdolls >= ragdollLimit) then
            continue
        end

        -- Teletrasporto / Movimento
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
                StatusLabel.Text = "Status: Following " .. targetPlayer.DisplayName
            end

        elseif targetMode == "Position" then
            if savedCFrame and not isCurrentlyRagdolled then
                rootPart.CFrame = savedCFrame
                StatusLabel.Text = "Status: Holding Position"
            end
        end
    end
end

local function enterArena()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local isInArena = character:WaitForChild("isInArena")

    StatusLabel.Text = "Status: Waiting for Arena..."

    while helperRunning do
        if isInArena.Value then
            break 
        end

        if targetMode == "Player" and targetPlayer then
            local tChar = targetPlayer.Character
            if tChar then
                local tArena = tChar:FindFirstChild("isInArena")
                local tArena2 = tChar:FindFirstChild("KillstreakLevel")

                if (tArena and tArena.Value) or tArena2 then
                    local portal = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Teleport1")
                    if portal and portal:IsA("BasePart") then
                        rootPart.CFrame = portal.CFrame
                    end
                    break
                end
            end
        elseif targetMode == "Position" then
            local portal = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Teleport1")
            if portal and portal:IsA("BasePart") then
                rootPart.CFrame = portal.CFrame
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
        local nameInput = PlayerInput.Text
        if nameInput == "" then
            notify("Please enter a player's name!")
            return
        end

        local player = findPlayer(nameInput)
        if not player then
            notify("Player not found in server!")
            return
        end
        targetPlayer = player
    else
        if not savedCFrame then
            notify("Save a position first!")
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
    StatusLabel.Text = "Status: Stopped"
end

LocalPlayer.CharacterAdded:Connect(function()
    if helperRunning then
        alreadyReset = false
        enterArena()
    end
end)

StartBtn.MouseButton1Click:Connect(startHelper)
StopBtn.MouseButton1Click:Connect(stopHelper)
