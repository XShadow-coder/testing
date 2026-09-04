local cloneref = cloneref or function(...)
    return ...
end

--//====================================================
--// PLACE CHECK
--//====================================================

local sbPlaceIds = {
    [6403373529] = true,
    [11520107397] = true,
    [124596094333302] = true,
    [9015014224] = true,
    [78262906459073] = true,
}

if not sbPlaceIds[game.PlaceId] then
    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))

    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    local gameName = success and info and info.Name or "another game"

    print("This script is for Slap Battles, but you are in " .. gameName)
    return
end

--//====================================================
--// SINGLE INSTANCE
--//====================================================

if getgenv().KsHelper_Loaded then
    return
end

pcall(function()
    getgenv().KsHelper_Loaded = true
end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--//====================================================
--// SERVICES
--//====================================================

local CoreGui = cloneref(game:GetService("CoreGui"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = cloneref(Players.LocalPlayer)

local guiParent =
    (gethui and gethui())
    or CoreGui:FindFirstChild("RobloxGui")
    or CoreGui

--//====================================================
--// CONFIG
--//====================================================

local DEFAULT_RAGDOLLS = 1
local ARENA_TIMEOUT = 12
local ARENA_RETRY_DELAY = 0.35
local FOLLOW_DELAY = 0.03
local TARGET_DISTANCE = 4

--//====================================================
--// STATE
--//====================================================

local helperRunning = false
local targetPlayer = nil

local savedPosition = nil
local usingSavedPosition = false

local autoResetEnabled = true
local resetThreshold = DEFAULT_RAGDOLLS

local ragdollCount = 0
local totalRagdolls = 0
local resetCount = 0

local startTime = nil
local lastResetTime = 0

local characterConnection = nil
local ragdollConnection = nil

local alreadyReset = false
local previousRagdolled = false

--//====================================================
--// UTILITY
--//====================================================

local function randomString()
    local length = math.random(10, 20)
    local array = {}

    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end

    return table.concat(array)
end

local function notify(message, title)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Killstreak Helper",
            Text = tostring(message),
            Duration = 3
        })
    end)
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end

    return string.format("%02d:%02d", minutes, secs)
end

local function getRuntime()
    if not startTime then
        return "00:00"
    end

    return formatTime(os.clock() - startTime)
end

local function isCharacterInArena(character)
    if not character then
        return false
    end

    local arenaValue = character:FindFirstChild("isInArena")

    if arenaValue and arenaValue:IsA("BoolValue") then
        if arenaValue.Value then
            return true
        end
    end

    --// Preserve the compatibility behavior from the original script.
    if character:FindFirstChild("KillstreakLevel") then
        return true
    end

    return false
end

local function getLocalCharacter()
    local character = LocalPlayer.Character

    if not character then
        return nil
    end

    return character
end

--//====================================================
--// GUI
--//====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local Frame = Instance.new("Frame")
Frame.Name = randomString()
Frame.Size = UDim2.new(0, 360, 0, 430)
Frame.Position = UDim2.new(0.5, -180, 0.5, -215)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 26)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(65, 65, 67)
UIStroke.Thickness = 1
UIStroke.Parent = Frame

--//====================================================
--// TITLE
--//====================================================

local Title = Instance.new("TextLabel")
Title.Name = randomString()
Title.Size = UDim2.new(1, -100, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Name = randomString()
Minimize.Size = UDim2.new(0, 30, 0, 28)
Minimize.Position = UDim2.new(1, -68, 0, 4)
Minimize.BackgroundColor3 = Color3.fromRGB(55, 55, 57)
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
Close.Size = UDim2.new(0, 30, 0, 28)
Close.Position = UDim2.new(1, -34, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(70, 45, 45)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Frame

local CloseUICorner = Instance.new("UICorner")
CloseUICorner.CornerRadius = UDim.new(0, 6)
CloseUICorner.Parent = Close

--//====================================================
--// PLAYER INPUT
--//====================================================

local TextBox = Instance.new("TextBox")
TextBox.Name = randomString()
TextBox.Position = UDim2.new(0, 20, 0, 48)
TextBox.Size = UDim2.new(1, -40, 0, 34)
TextBox.Text = ""
TextBox.PlaceholderText = "Player's name"
TextBox.ClearTextOnFocus = false
TextBox.BackgroundColor3 = Color3.fromRGB(43, 43, 45)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Parent = Frame

local TextBoxCorner = Instance.new("UICorner")
TextBoxCorner.CornerRadius = UDim.new(0, 7)
TextBoxCorner.Parent = TextBox

--//====================================================
--// START / STOP
--//====================================================

local Start = Instance.new("TextButton")
Start.Name = randomString()
Start.Position = UDim2.new(0, 20, 0, 91)
Start.Size = UDim2.new(0.5, -25, 0, 34)
Start.Text = "START"
Start.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
Start.TextColor3 = Color3.fromRGB(255, 255, 255)
Start.Font = Enum.Font.GothamBold
Start.TextSize = 14
Start.Parent = Frame

local Stop = Instance.new("TextButton")
Stop.Name = randomString()
Stop.Position = UDim2.new(0.5, 5, 0, 91)
Stop.Size = UDim2.new(0.5, -25, 0, 34)
Stop.Text = "STOP"
Stop.BackgroundColor3 = Color3.fromRGB(125, 45, 45)
Stop.TextColor3 = Color3.fromRGB(255, 255, 255)
Stop.Font = Enum.Font.GothamBold
Stop.TextSize = 14
Stop.Parent = Frame

for _, button in ipairs({Start, Stop}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
end

--//====================================================
--// SAVE POSITION
--//====================================================

local SavePosition = Instance.new("TextButton")
SavePosition.Name = randomString()
SavePosition.Position = UDim2.new(0, 20, 0, 134)
SavePosition.Size = UDim2.new(0.5, -25, 0, 34)
SavePosition.Text = "SAVE POSITION"
SavePosition.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
SavePosition.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosition.Font = Enum.Font.GothamBold
SavePosition.TextSize = 13
SavePosition.Parent = Frame

local ClearPosition = Instance.new("TextButton")
ClearPosition.Name = randomString()
ClearPosition.Position = UDim2.new(0.5, 5, 0, 134)
ClearPosition.Size = UDim2.new(0.5, -25, 0, 34)
ClearPosition.Text = "CLEAR POSITION"
ClearPosition.BackgroundColor3 = Color3.fromRGB(65, 65, 67)
ClearPosition.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearPosition.Font = Enum.Font.GothamBold
ClearPosition.TextSize = 13
ClearPosition.Parent = Frame

for _, button in ipairs({SavePosition, ClearPosition}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
end

--//====================================================
--// AUTO RESET
--//====================================================

local ToggleReset = Instance.new("TextButton")
ToggleReset.Name = randomString()
ToggleReset.Position = UDim2.new(0, 20, 0, 177)
ToggleReset.Size = UDim2.new(0.58, -10, 0, 34)
ToggleReset.Text = "AUTO-RESET: ON"
ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
ToggleReset.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleReset.Font = Enum.Font.GothamBold
ToggleReset.TextSize = 13
ToggleReset.Parent = Frame

local RagdollInput = Instance.new("TextBox")
RagdollInput.Name = randomString()
RagdollInput.Position = UDim2.new(0.58, 10, 0, 177)
RagdollInput.Size = UDim2.new(0.42, -30, 0, 34)
RagdollInput.Text = tostring(DEFAULT_RAGDOLLS)
RagdollInput.PlaceholderText = "Ragdolls"
RagdollInput.ClearTextOnFocus = false
RagdollInput.BackgroundColor3 = Color3.fromRGB(43, 43, 45)
RagdollInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RagdollInput.Font = Enum.Font.GothamBold
RagdollInput.TextSize = 14
RagdollInput.Parent = Frame

for _, object in ipairs({ToggleReset, RagdollInput}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = object
end

--//====================================================
--// STATUS PANEL
--//====================================================

local StatusFrame = Instance.new("Frame")
StatusFrame.Name = randomString()
StatusFrame.Position = UDim2.new(0, 20, 0, 222)
StatusFrame.Size = UDim2.new(1, -40, 0, 125)
StatusFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 36)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = Frame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusFrame

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Name = randomString()
StatusTitle.Size = UDim2.new(1, -20, 0, 25)
StatusTitle.Position = UDim2.new(0, 10, 0, 5)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 13
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = randomString()
StatusLabel.Size = UDim2.new(1, -20, 1, -32)
StatusLabel.Position = UDim2.new(0, 10, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Stopped\nRuntime: 00:00\nRagdolls: 0\nResets: 0\nTarget: None"
StatusLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = StatusFrame

--//====================================================
--// REPORT
--//====================================================

local Report = Instance.new("TextButton")
Report.Name = randomString()
Report.Position = UDim2.new(0, 20, 0, 357)
Report.Size = UDim2.new(1, -40, 0, 32)
Report.Text = "REPORT"
Report.BackgroundColor3 = Color3.fromRGB(65, 65, 68)
Report.TextColor3 = Color3.fromRGB(255, 255, 255)
Report.Font = Enum.Font.GothamBold
Report.TextSize = 13
Report.Parent = Frame

local ReportCorner = Instance.new("UICorner")
ReportCorner.CornerRadius = UDim.new(0, 7)
ReportCorner.Parent = Report

--//====================================================
--// INFINITE YIELD
--//====================================================

local IY = Instance.new("TextButton")
IY.Name = randomString()
IY.Position = UDim2.new(0, 20, 0, 397)
IY.Size = UDim2.new(1, -40, 0, 25)
IY.Text = "Execute Infinite Yield"
IY.BackgroundColor3 = Color3.fromRGB(55, 55, 57)
IY.TextColor3 = Color3.fromRGB(255, 255, 255)
IY.Font = Enum.Font.GothamBold
IY.TextSize = 12
IY.Parent = Frame

local IY_UICorner = Instance.new("UICorner")
IY_UICorner.CornerRadius = UDim.new(0, 6)
IY_UICorner.Parent = IY

--//====================================================
--// PLAYER FINDER
--//====================================================

local function findPlayer(nickname)
    nickname = tostring(nickname or ""):lower()

    if nickname == "" then
        return nil
    end

    --// Exact username/display-name match gets priority.
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == nickname
            or player.DisplayName:lower() == nickname then
            return player
        end
    end

    --// Then partial matching.
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(nickname, 1, true)
            or player.DisplayName:lower():find(nickname, 1, true) then
            return player
        end
    end

    return nil
end

--//====================================================
--// STATUS
--//====================================================

local function updateStatus()
    local status

    if helperRunning then
        status = "RUNNING"
    else
        status = "STOPPED"
    end

    local targetText = "None"

    if usingSavedPosition and savedPosition then
        targetText = "Saved Position"
    elseif targetPlayer then
        targetText = targetPlayer.Name
    end

    StatusLabel.Text = string.format(
        "Status: %s\nRuntime: %s\nRagdolls: %d / %d\nTotal Ragdolls: %d\nResets: %d\nTarget: %s",
        status,
        getRuntime(),
        ragdollCount,
        resetThreshold,
        totalRagdolls,
        resetCount,
        targetText
    )
end

task.spawn(function()
    while ScreenGui.Parent do
        updateStatus()
        task.wait(0.25)
    end
end)

--//====================================================
--// RAGDOLL COUNTER
--//====================================================

local function resetRagdollState()
    ragdollCount = 0
    previousRagdolled = false
    alreadyReset = false
end

local function performReset()
    if not autoResetEnabled then
        return false
    end

    if alreadyReset then
        return false
    end

    local resetEvent = LocalPlayer:FindFirstChild("Reset")

    if not resetEvent then
        notify("Reset event was not found.", "Auto-Reset")
        return false
    end

    local success = false

    local fireSuccess = pcall(function()
        resetEvent:FireServer()
        success = true
    end)

    if not fireSuccess or not success then
        notify("Failed to fire Reset.", "Auto-Reset")
        return false
    end

    alreadyReset = true
    resetCount += 1
    lastResetTime = os.clock()

    ragdollCount = 0

    return true
end

local function disconnectRagdollConnection()
    if ragdollConnection then
        pcall(function()
            ragdollConnection:Disconnect()
        end)

        ragdollConnection = nil
    end
end

local function setupRagdollMonitor(character)
    disconnectRagdollConnection()

    previousRagdolled = false
    alreadyReset = false

    if not character then
        return
    end

    local ragdolled = character:FindFirstChild("Ragdolled")

    if not ragdolled then
        return
    end

    if not ragdolled:IsA("BoolValue") then
        return
    end

    previousRagdolled = ragdolled.Value

    ragdollConnection = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
        if not helperRunning then
            previousRagdolled = ragdolled.Value
            return
        end

        local current = ragdolled.Value

        --// Count only the rising edge, preventing one ragdoll
        --// from being counted every frame while Value == true.
        if current and not previousRagdolled then
            ragdollCount += 1
            totalRagdolls += 1

            if autoResetEnabled and ragdollCount >= resetThreshold then
                performReset()
            end
        end

        previousRagdolled = current
    end)
end

--//====================================================
--// ARENA HELPERS
--//====================================================

local function getArenaPortal()
    local lobby = workspace:FindFirstChild("Lobby")

    if not lobby then
        return nil
    end

    local portal = lobby:FindFirstChild("Teleport1")

    if portal and portal:IsA("BasePart") then
        return portal
    end

    return nil
end

local function touchPortal(portal, character)
    if not portal or not character then
        return false
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not rootPart then
        return false
    end

    --// First try the executor's firetouchinterest implementation.
    if typeof(firetouchinterest) == "function" then
        local success = pcall(function()
            firetouchinterest(rootPart, portal, 0)
            task.wait(0.08)
            firetouchinterest(rootPart, portal, 1)
        end)

        if success then
            return true
        end
    end

    --// Fallback: physically move onto the portal.
    local success = pcall(function()
        rootPart.CFrame = portal.CFrame + Vector3.new(0, 2, 0)
    end)

    return success
end

local function enterArena()
    local character = getLocalCharacter()

    if not character then
        return false
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not rootPart then
        return false
    end

    local started = os.clock()

    while helperRunning do
        character = getLocalCharacter()

        if not character then
            task.wait(0.2)
            continue
        end

        if isCharacterInArena(character) then
            return true
        end

        if os.clock() - started >= ARENA_TIMEOUT then
            return false
        end

        local portal = getArenaPortal()

        if portal then
            touchPortal(portal, character)
        end

        task.wait(ARENA_RETRY_DELAY)
    end

    return false
end

--//====================================================
--// TARGET VALIDATION
--//====================================================

local function getTargetCFrame()
    if usingSavedPosition and savedPosition then
        return savedPosition
    end

    if not targetPlayer then
        return nil
    end

    local targetCharacter = targetPlayer.Character

    if not targetCharacter then
        return nil
    end

    if not isCharacterInArena(targetCharacter) then
        return nil
    end

    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetRoot or not targetHumanoid then
        return nil
    end

    if targetHumanoid.Health <= 0 then
        return nil
    end

    return targetRoot.CFrame
end

--//====================================================
--// FOLLOW LOOP
--//====================================================

local function followTarget()
    while helperRunning do
        local character = getLocalCharacter()

        if not character then
            task.wait(0.1)
            continue
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local ragdolled = character:FindFirstChild("Ragdolled")

        if not humanoid or humanoid.Health <= 0 or not rootPart then
            task.wait(0.1)
            continue
        end

        if not isCharacterInArena(character) then
            task.wait(0.15)

            if helperRunning then
                enterArena()
            end

            continue
        end

        if ragdolled and ragdolled:IsA("BoolValue") and ragdolled.Value then
            task.wait(0.1)
            continue
        end

        local targetCFrame = getTargetCFrame()

        if targetCFrame then
            pcall(function()
                rootPart.CFrame = targetCFrame * CFrame.new(0, 0, -TARGET_DISTANCE)
            end)
        else
            --// A saved position doesn't require a live player.
            --// A player target, however, must exist and be valid.
            if not usingSavedPosition and not targetPlayer then
                break
            end

            task.wait(0.1)
            continue
        end

        task.wait(FOLLOW_DELAY)
    end
end

--//====================================================
--// START
--//====================================================

local function startHelper()
    if helperRunning then
        notify("Helper is already running.")
        return
    end

    --// Saved position has priority over player target.
    if usingSavedPosition and savedPosition then
        targetPlayer = nil
    else
        local nameInput = TextBox.Text

        if nameInput == "" then
            notify("Enter a player's name or save a position.")
            return
        end

        local player = findPlayer(nameInput)

        if not player then
            notify("Player not found!")
            return
        end

        targetPlayer = player
    end

    local number = tonumber(RagdollInput.Text)

    if not number then
        notify("Ragdoll value must be a number.")
        RagdollInput.Text = tostring(DEFAULT_RAGDOLLS)
        return
    end

    number = math.floor(number)

    if number < 1 then
        notify("Ragdoll value must be at least 1.")
        RagdollInput.Text = tostring(DEFAULT_RAGDOLLS)
        return
    end

    resetThreshold = number
    RagdollInput.Text = tostring(resetThreshold)

    helperRunning = true
    startTime = os.clock()

    ragdollCount = 0
    totalRagdolls = 0
    resetCount = 0

    alreadyReset = false

    local character = getLocalCharacter()

    if character then
        setupRagdollMonitor(character)
    end

    task.spawn(function()
        if not helperRunning then
            return
        end

        local entered = enterArena()

        if not helperRunning then
            return
        end

        if not entered then
            notify("Could not confirm Arena entry.", "Arena")
            return
        end

        task.spawn(followTarget)
    end)

    notify("Helper started.", "Killstreak Helper")
    updateStatus()
end

--//====================================================
--// STOP
--//====================================================

local function stopHelper()
    helperRunning = false
    targetPlayer = nil

    disconnectRagdollConnection()

    ragdollCount = 0
    alreadyReset = false
    previousRagdolled = false

    notify("Helper stopped.", "Killstreak Helper")
    updateStatus()
end

--//====================================================
--// SAVE POSITION
--//====================================================

SavePosition.MouseButton1Click:Connect(function()
    local character = getLocalCharacter()

    if not character then
        notify("Character not found.")
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not rootPart then
        notify("HumanoidRootPart not found.")
        return
    end

    local success, result = pcall(function()
        return rootPart.CFrame
    end)

    if not success or not result then
        notify("Failed to save position.")
        return
    end

    savedPosition = result
    usingSavedPosition = true
    targetPlayer = nil

    SavePosition.Text = "POSITION SAVED"
    SavePosition.BackgroundColor3 = Color3.fromRGB(50, 105, 135)

    notify("Current position saved as target.", "Position")
    updateStatus()
end)

ClearPosition.MouseButton1Click:Connect(function()
    savedPosition = nil
    usingSavedPosition = false

    SavePosition.Text = "SAVE POSITION"
    SavePosition.BackgroundColor3 = Color3.fromRGB(60, 70, 95)

    notify("Saved position cleared.", "Position")
    updateStatus()
end)

--//====================================================
--// AUTO RESET TOGGLE
--//====================================================

ToggleReset.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled

    if autoResetEnabled then
        ToggleReset.Text = "AUTO-RESET: ON"
        ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
    else
        ToggleReset.Text = "AUTO-RESET: OFF"
        ToggleReset.BackgroundColor3 = Color3.fromRGB(125, 45, 45)
    end

    updateStatus()
end)

RagdollInput.FocusLost:Connect(function()
    local number = tonumber(RagdollInput.Text)

    if not number then
        RagdollInput.Text = tostring(resetThreshold)
        return
    end

    number = math.floor(number)

    if number < 1 then
        RagdollInput.Text = tostring(resetThreshold)
        return
    end

    resetThreshold = number
    RagdollInput.Text = tostring(number)

    updateStatus()
end)

--//====================================================
--// INFINITE YIELD
--//====================================================

IY.MouseButton1Click:Connect(function()
    if getgenv().IY_LOADED then
        notify("Infinite Yield is already running!")
        return
    end

    local success = pcall(function()
        loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
            )
        )()
    end)

    if not success then
        notify("Infinite Yield failed to load.")
    end
end)

--//====================================================
--// REPORT
--//====================================================

Report.MouseButton1Click:Connect(function()
    local targetText

    if usingSavedPosition and savedPosition then
        targetText = "Saved Position"
    elseif targetPlayer then
        targetText = targetPlayer.Name
    else
        targetText = "None"
    end

    local report = string.format(
        "Killstreak Helper Report\n\n" ..
        "Status: %s\n" ..
        "Runtime: %s\n" ..
        "Target: %s\n" ..
        "Auto-Reset: %s\n" ..
        "Reset threshold: %d\n" ..
        "Current ragdolls: %d\n" ..
        "Total ragdolls: %d\n" ..
        "Total resets: %d",
        helperRunning and "Running" or "Stopped",
        getRuntime(),
        targetText,
        autoResetEnabled and "ON" or "OFF",
        resetThreshold,
        ragdollCount,
        totalRagdolls,
        resetCount
    )

    if typeof(setclipboard) == "function" then
        local success = pcall(function()
            setclipboard(report)
        end)

        if success then
            notify("Report copied to clipboard.", "Report")
        else
            notify(report, "Report")
        end
    else
        notify(report, "Report")
    end
end)

--//====================================================
--// CHARACTER RESPAWN
--//====================================================

characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    if not helperRunning then
        return
    end

    resetRagdollState()

    task.spawn(function()
        character:WaitForChild("HumanoidRootPart", 5)

        if helperRunning then
            setupRagdollMonitor(character)

            --// Give Roblox a moment to finish character initialization.
            task.wait(0.3)

            if helperRunning and not isCharacterInArena(character) then
                enterArena()
            end
        end
    end)
end)

--//====================================================
--// MINIMIZE
--//====================================================

local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        for _, child in ipairs(Frame:GetChildren()) do
            if child:IsA("TextLabel")
                or child:IsA("TextButton")
                or child:IsA("TextBox")
                or child:IsA("Frame") then

                if child ~= Title
                    and child ~= Close
                    and child ~= Minimize then
                    child.Visible = false
                end
            end
        end

        Frame.Size = UDim2.new(0, 360, 0, 38)
        Minimize.Text = "+"
    else
        Frame.Size = UDim2.new(0, 360, 0, 430)

        for _, child in ipairs(Frame:GetChildren()) do
            if child:IsA("TextLabel")
                or child:IsA("TextButton")
                or child:IsA("TextBox")
                or child:IsA("Frame") then

                if child ~= Title
                    and child ~= Close
                    and child ~= Minimize then
                    child.Visible = true
                end
            end
        end

        Minimize.Text = "_"
    end
end)

--//====================================================
--// CLOSE
--//====================================================

Close.MouseButton1Click:Connect(function()
    stopHelper()

    if characterConnection then
        pcall(function()
            characterConnection:Disconnect()
        end)

        characterConnection = nil
    end

    disconnectRagdollConnection()

    if ScreenGui then
        ScreenGui:Destroy()
    end

    pcall(function()
        getgenv().KsHelper_Loaded = nil
    end)
end)

--//====================================================
--// DISABLE LOBBY BRAZIL TOUCH
--//====================================================

task.spawn(function()
    local lobby = workspace:FindFirstChild("Lobby")

    if not lobby then
        return
    end

    local brazil = lobby:FindFirstChild("brazil")

    if not brazil then
        return
    end

    for _, part in ipairs(brazil:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CanTouch = false
            end)
        end
    end
end)

updateStatus()