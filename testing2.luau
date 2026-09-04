local cloneref = cloneref or function(...)
    return ...
end

--====================================================
-- PLACE CHECK
--====================================================

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

    print("[KsHelper] Wrong game: " .. gameName)
    return
end

if getgenv().KsHelper_Loaded then
    return
end

getgenv().KsHelper_Loaded = true

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--====================================================
-- SERVICES
--====================================================

local Players = cloneref(game:GetService("Players"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer

local guiParent =
    (gethui and gethui())
    or CoreGui:FindFirstChild("RobloxGui")
    or CoreGui

--====================================================
-- CONFIG
--====================================================

local DEFAULT_RAGDOLLS = 1
local ARENA_TIMEOUT = 15
local ARENA_RETRY_DELAY = 0.4
local FOLLOW_DELAY = 0.04
local TARGET_DISTANCE = 4

local DEBUG_LIMIT = 12

--====================================================
-- STATE
--====================================================

local helperRunning = false

local targetPlayer = nil
local targetMode = "PLAYER"

local savedPosition = nil

local autoResetEnabled = true
local resetThreshold = DEFAULT_RAGDOLLS

local ragdollCount = 0
local totalRagdolls = 0
local resetCount = 0

local startTime = nil

local previousRagdolled = false
local alreadyReset = false

local characterConnection
local ragdollConnection

local debugMessages = {}

--====================================================
-- RANDOM GUI NAME
--====================================================

local function randomString()
    local chars = {}

    for i = 1, math.random(10, 20) do
        chars[i] = string.char(math.random(32, 126))
    end

    return table.concat(chars)
end

--====================================================
-- DEBUG
--====================================================

local function debugLog(message)
    message = tostring(message)

    local timestamp = os.date("%H:%M:%S")
    local line = "[" .. timestamp .. "] " .. message

    print("[KsHelper] " .. line)

    table.insert(debugMessages, line)

    if #debugMessages > DEBUG_LIMIT then
        table.remove(debugMessages, 1)
    end
end

local function debugClear()
    table.clear(debugMessages)
end

--====================================================
-- NOTIFY
--====================================================

local function notify(message, title)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Killstreak Helper",
            Text = tostring(message),
            Duration = 3
        })
    end)
end

--====================================================
-- TIME
--====================================================

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

--====================================================
-- GUI
--====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

local Frame = Instance.new("Frame")
Frame.Name = randomString()
Frame.Size = UDim2.new(0, 390, 0, 510)
Frame.Position = UDim2.new(0.5, -195, 0.5, -255)
Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = Frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(65, 65, 67)
frameStroke.Parent = Frame

--====================================================
-- TITLE
--====================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 30, 0, 28)
Minimize.Position = UDim2.new(1, -68, 0, 4)
Minimize.BackgroundColor3 = Color3.fromRGB(55, 55, 57)
Minimize.Text = "_"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.Parent = Frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 28)
Close.Position = UDim2.new(1, -34, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(70, 45, 45)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = Close

--====================================================
-- TARGET MODE
--====================================================

local TargetMode = Instance.new("TextButton")
TargetMode.Position = UDim2.new(0, 20, 0, 45)
TargetMode.Size = UDim2.new(1, -40, 0, 32)
TargetMode.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
TargetMode.Text = "TARGET MODE: PLAYER"
TargetMode.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetMode.Font = Enum.Font.GothamBold
TargetMode.TextSize = 13
TargetMode.Parent = Frame

local targetModeCorner = Instance.new("UICorner")
targetModeCorner.CornerRadius = UDim.new(0, 7)
targetModeCorner.Parent = TargetMode

--====================================================
-- PLAYER INPUT
--====================================================

local TextBox = Instance.new("TextBox")
TextBox.Position = UDim2.new(0, 20, 0, 85)
TextBox.Size = UDim2.new(1, -40, 0, 34)
TextBox.Text = ""
TextBox.PlaceholderText = "Username / DisplayName / UserId"
TextBox.ClearTextOnFocus = false
TextBox.BackgroundColor3 = Color3.fromRGB(43, 43, 45)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Parent = Frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 7)
inputCorner.Parent = TextBox

--====================================================
-- START / STOP
--====================================================

local Start = Instance.new("TextButton")
Start.Position = UDim2.new(0, 20, 0, 127)
Start.Size = UDim2.new(0.5, -25, 0, 34)
Start.Text = "START"
Start.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
Start.TextColor3 = Color3.fromRGB(255, 255, 255)
Start.Font = Enum.Font.GothamBold
Start.TextSize = 14
Start.Parent = Frame

local Stop = Instance.new("TextButton")
Stop.Position = UDim2.new(0.5, 5, 0, 127)
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

--====================================================
-- SAVE POSITION
--====================================================

local SavePosition = Instance.new("TextButton")
SavePosition.Position = UDim2.new(0, 20, 0, 169)
SavePosition.Size = UDim2.new(0.5, -25, 0, 34)
SavePosition.Text = "SAVE POSITION"
SavePosition.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
SavePosition.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosition.Font = Enum.Font.GothamBold
SavePosition.TextSize = 12
SavePosition.Parent = Frame

local ClearPosition = Instance.new("TextButton")
ClearPosition.Position = UDim2.new(0.5, 5, 0, 169)
ClearPosition.Size = UDim2.new(0.5, -25, 0, 34)
ClearPosition.Text = "CLEAR POSITION"
ClearPosition.BackgroundColor3 = Color3.fromRGB(65, 65, 67)
ClearPosition.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearPosition.Font = Enum.Font.GothamBold
ClearPosition.TextSize = 12
ClearPosition.Parent = Frame

for _, button in ipairs({SavePosition, ClearPosition}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
end

--====================================================
-- RESET
--====================================================

local ToggleReset = Instance.new("TextButton")
ToggleReset.Position = UDim2.new(0, 20, 0, 211)
ToggleReset.Size = UDim2.new(0.58, -10, 0, 34)
ToggleReset.Text = "AUTO-RESET: ON"
ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 55)
ToggleReset.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleReset.Font = Enum.Font.GothamBold
ToggleReset.TextSize = 12
ToggleReset.Parent = Frame

local RagdollInput = Instance.new("TextBox")
RagdollInput.Position = UDim2.new(0.58, 10, 0, 211)
RagdollInput.Size = UDim2.new(0.42, -30, 0, 34)
RagdollInput.Text = tostring(DEFAULT_RAGDOLLS)
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

--====================================================
-- STATUS
--====================================================

local StatusFrame = Instance.new("Frame")
StatusFrame.Position = UDim2.new(0, 20, 0, 253)
StatusFrame.Size = UDim2.new(1, -40, 0, 130)
StatusFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 36)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = Frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 10, 0, 8)
StatusLabel.Size = UDim2.new(1, -20, 1, -16)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = StatusFrame

--====================================================
-- DEBUG
--====================================================

local DebugFrame = Instance.new("Frame")
DebugFrame.Position = UDim2.new(0, 20, 0, 393)
DebugFrame.Size = UDim2.new(1, -40, 0, 75)
DebugFrame.BackgroundColor3 = Color3.fromRGB(29, 29, 31)
DebugFrame.BorderSizePixel = 0
DebugFrame.Parent = Frame

local debugCorner = Instance.new("UICorner")
debugCorner.CornerRadius = UDim.new(0, 8)
debugCorner.Parent = DebugFrame

local DebugLabel = Instance.new("TextLabel")
DebugLabel.Position = UDim2.new(0, 8, 0, 6)
DebugLabel.Size = UDim2.new(1, -16, 1, -12)
DebugLabel.BackgroundTransparency = 1
DebugLabel.Text = "DEBUG\nWaiting..."
DebugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextSize = 10
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left
DebugLabel.TextYAlignment = Enum.TextYAlignment.Top
DebugLabel.Parent = DebugFrame

--====================================================
-- REPORT / IY
--====================================================

local Report = Instance.new("TextButton")
Report.Position = UDim2.new(0, 20, 0, 477)
Report.Size = UDim2.new(0.5, -25, 0, 25)
Report.Text = "REPORT"
Report.BackgroundColor3 = Color3.fromRGB(65, 65, 68)
Report.TextColor3 = Color3.fromRGB(255, 255, 255)
Report.Font = Enum.Font.GothamBold
Report.TextSize = 11
Report.Parent = Frame

local IY = Instance.new("TextButton")
IY.Position = UDim2.new(0.5, 5, 0, 477)
IY.Size = UDim2.new(0.5, -25, 0, 25)
IY.Text = "Infinite Yield"
IY.BackgroundColor3 = Color3.fromRGB(55, 55, 57)
IY.TextColor3 = Color3.fromRGB(255, 255, 255)
IY.Font = Enum.Font.GothamBold
IY.TextSize = 11
IY.Parent = Frame

for _, button in ipairs({Report, IY}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

--====================================================
-- DEBUG UI UPDATE
--====================================================

local function updateDebug()
    if #debugMessages == 0 then
        DebugLabel.Text = "DEBUG\nWaiting..."
        return
    end

    local lines = {"DEBUG"}

    local startIndex = math.max(1, #debugMessages - 5)

    for i = startIndex, #debugMessages do
        table.insert(lines, debugMessages[i])
    end

    DebugLabel.Text = table.concat(lines, "\n")
end

task.spawn(function()
    while ScreenGui.Parent do
        updateDebug()
        task.wait(0.15)
    end
end)

--====================================================
-- STATUS UPDATE
--====================================================

local function updateStatus()
    local status = helperRunning and "Running" or "Stopped"

    local targetText = "None"

    if targetMode == "POSITION" then
        if savedPosition then
            targetText = "Position"
        else
            targetText = "Position (not saved)"
        end
    elseif targetPlayer then
        targetText = string.format(
            "Player (%s / [%d])",
            targetPlayer.Name,
            targetPlayer.UserId
        )
    end

    local arenaText = "Unknown"

    local character = LocalPlayer.Character

    if character then
        if isCharacterInArena then
            arenaText = tostring(
                character:FindFirstChild("isInArena")
                and character.isInArena.Value
                or false
            )
        end
    end

    StatusLabel.Text = string.format(
        "Status: %s\nRuntime: %s\nTarget: %s\nArena: %s\nRagdolls: %d / %d\nTotal Ragdolls: %d\nResets: %d",
        status,
        getRuntime(),
        targetText,
        arenaText,
        ragdollCount,
        resetThreshold,
        totalRagdolls,
        resetCount
    )
end

--====================================================
-- CHARACTER / ARENA
--====================================================

function isCharacterInArena(character)
    if not character then
        return false
    end

    local value = character:FindFirstChild("isInArena")

    if value and value:IsA("BoolValue") then
        return value.Value
    end

    return false
end

local function getPortal()
    local lobby = workspace:FindFirstChild("Lobby")

    if not lobby then
        debugLog("Arena: Lobby not found")
        return nil
    end

    local portal = lobby:FindFirstChild("Teleport1")

    if not portal then
        debugLog("Arena: Teleport1 not found")
        return nil
    end

    if not portal:IsA("BasePart") then
        debugLog("Arena: Teleport1 is not BasePart")
        return nil
    end

    return portal
end

local function tryEnterArena()
    local character = LocalPlayer.Character

    if not character then
        debugLog("Arena: Character missing")
        return false
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        debugLog("Arena: HumanoidRootPart missing")
        return false
    end

    if isCharacterInArena(character) then
        debugLog("Arena: already inside")
        return true
    end

    local portal = getPortal()

    if not portal then
        return false
    end

    debugLog("Arena: attempting portal")

    if typeof(firetouchinterest) == "function" then
        local success, err = pcall(function()
            firetouchinterest(root, portal, 0)
            task.wait(0.08)
            firetouchinterest(root, portal, 1)
        end)

        if success then
            debugLog("Arena: firetouchinterest sent")
        else
            debugLog("Arena: firetouchinterest error: " .. tostring(err))
        end
    else
        debugLog("Arena: firetouchinterest unavailable")
    end

    pcall(function()
        root.CFrame = portal.CFrame + Vector3.new(0, 2, 0)
    end)

    task.wait(0.25)

    if isCharacterInArena(character) then
        debugLog("Arena: SUCCESS")
        return true
    end

    debugLog("Arena: not confirmed yet")
    return false
end

local function enterArena()
    debugLog("Arena: starting entry routine")

    local started = os.clock()

    while helperRunning do
        if isCharacterInArena(LocalPlayer.Character) then
            debugLog("Arena: confirmed")
            return true
        end

        if os.clock() - started >= ARENA_TIMEOUT then
            debugLog("Arena: TIMEOUT")
            return false
        end

        tryEnterArena()

        task.wait(ARENA_RETRY_DELAY)
    end

    debugLog("Arena: cancelled")
    return false
end

--====================================================
-- FIND PLAYER
--====================================================

local function findPlayer(input)
    input = tostring(input or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if input == "" then
        return nil, "empty input"
    end

    debugLog("Target search: " .. input)

    -- UserId
    local numericId = tonumber(input)

    if numericId then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == numericId then
                debugLog("Target found by UserId: " .. player.Name)
                return player
            end
        end

        debugLog("No player with UserId " .. input)
        return nil, "UserId not found"
    end

    local lowered = input:lower()

    -- Exact username
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == lowered then
            debugLog("Target found by username: " .. player.Name)
            return player
        end
    end

    -- Exact display name
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName:lower() == lowered then
            debugLog("Target found by DisplayName: " .. player.Name)
            return player
        end
    end

    -- Partial username/display name
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(lowered, 1, true)
            or player.DisplayName:lower():find(lowered, 1, true) then

            debugLog("Target found by partial match: " .. player.Name)
            return player
        end
    end

    debugLog("Target NOT found")
    return nil, "player not found"
end

--====================================================
-- RAGDOLL
--====================================================

local function disconnectRagdoll()
    if ragdollConnection then
        pcall(function()
            ragdollConnection:Disconnect()
        end)

        ragdollConnection = nil
    end
end

local function performReset()
    if not autoResetEnabled then
        return false
    end

    if alreadyReset then
        debugLog("Reset skipped: already reset")
        return false
    end

    local resetEvent = LocalPlayer:FindFirstChild("Reset")

    if not resetEvent then
        debugLog("Reset ERROR: LocalPlayer.Reset missing")
        notify("Reset event not found.", "DEBUG")
        return false
    end

    local success, err = pcall(function()
        resetEvent:FireServer()
    end)

    if not success then
        debugLog("Reset ERROR: " .. tostring(err))
        notify("Reset failed. Check Debug.", "DEBUG")
        return false
    end

    alreadyReset = true
    resetCount += 1
    ragdollCount = 0

    debugLog("Reset SUCCESS")

    return true
end

local function setupRagdoll(character)
    disconnectRagdoll()

    previousRagdolled = false
    alreadyReset = false

    if not character then
        debugLog("Ragdoll: character missing")
        return
    end

    local ragdolled = character:FindFirstChild("Ragdolled")

    if not ragdolled then
        debugLog("Ragdoll: Ragdolled value missing")
        return
    end

    if not ragdolled:IsA("BoolValue") then
        debugLog("Ragdoll: Ragdolled is not BoolValue")
        return
    end

    previousRagdolled = ragdolled.Value

    debugLog("Ragdoll monitor connected")

    ragdollConnection = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
        if not helperRunning then
            previousRagdolled = ragdolled.Value
            return
        end

        local current = ragdolled.Value

        if current and not previousRagdolled then
            ragdollCount += 1
            totalRagdolls += 1

            debugLog(
                string.format(
                    "Ragdoll detected: %d/%d",
                    ragdollCount,
                    resetThreshold
                )
            )

            if autoResetEnabled
                and ragdollCount >= resetThreshold then

                performReset()
            end
        end

        previousRagdolled = current
    end)
end

--====================================================
-- TARGET CFRAME
--====================================================

local function getTargetCFrame()
    if targetMode == "POSITION" then
        if not savedPosition then
            return nil
        end

        return savedPosition
    end

    if not targetPlayer then
        return nil
    end

    local character = targetPlayer.Character

    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not root then
        return nil
    end

    return root.CFrame
end

--====================================================
-- FOLLOW
--====================================================

local function followTarget()
    debugLog("Follow loop started")

    while helperRunning do
        local character = LocalPlayer.Character

        if not character then
            task.wait(0.1)
            continue
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or humanoid.Health <= 0 or not root then
            task.wait(0.1)
            continue
        end

        if not isCharacterInArena(character) then
            debugLog("Follow: outside Arena")

            enterArena()

            task.wait(0.2)
            continue
        end

        local ragdolled = character:FindFirstChild("Ragdolled")

        if ragdolled
            and ragdolled:IsA("BoolValue")
            and ragdolled.Value then

            task.wait(0.1)
            continue
        end

        local targetCFrame = getTargetCFrame()

        if targetCFrame then
            pcall(function()
                root.CFrame =
                    targetCFrame
                    * CFrame.new(0, 0, -TARGET_DISTANCE)
            end)
        end

        task.wait(FOLLOW_DELAY)
    end

    debugLog("Follow loop stopped")
end

--====================================================
-- START
--====================================================

local function startHelper()
    debugClear()

    debugLog("========== START ==========")

    if helperRunning then
        debugLog("Start ignored: already running")
        notify("Helper is already running.")
        return
    end

    local number = tonumber(RagdollInput.Text)

    if not number then
        debugLog("Invalid ragdoll threshold")
        notify("Invalid ragdoll value.")
        return
    end

    number = math.floor(number)

    if number < 1 then
        debugLog("Ragdoll threshold below 1")
        notify("Ragdolls must be >= 1.")
        return
    end

    resetThreshold = number
    RagdollInput.Text = tostring(number)

    -- PLAYER MODE
    if targetMode == "PLAYER" then
        local player, reason = findPlayer(TextBox.Text)

        if not player then
            debugLog("Start failed: " .. tostring(reason))
            notify("Target player not found.", "Start")
            return
        end

        targetPlayer = player

        debugLog(
            string.format(
                "Target: %s [%d]",
                player.Name,
                player.UserId
            )
        )

    -- POSITION MODE
    elseif targetMode == "POSITION" then
        if not savedPosition then
            debugLog("Start failed: no saved position")
            notify("Save a position first.", "Start")
            return
        end

        targetPlayer = nil

        debugLog("Target: saved position")
    end

    helperRunning = true
    startTime = os.clock()

    ragdollCount = 0
    totalRagdolls = 0
    resetCount = 0

    alreadyReset = false

    local character = LocalPlayer.Character

    if character then
        setupRagdoll(character)
    else
        debugLog("Start: character not available")
    end

    debugLog("Helper state = RUNNING")

    updateStatus()

    task.spawn(function()
        debugLog("Starting Arena task")

        local arenaSuccess = enterArena()

        if not helperRunning then
            debugLog("Arena task cancelled")
            return
        end

        if not arenaSuccess then
            debugLog("Arena entry FAILED")
            notify("Arena entry failed. Check DEBUG.", "Arena")
            return
        end

        debugLog("Arena entry SUCCESS")

        task.spawn(followTarget)
    end)
end

--====================================================
-- STOP
--====================================================

local function stopHelper()
    debugLog("========== STOP ==========")

    helperRunning = false
    targetPlayer = nil

    disconnectRagdoll()

    ragdollCount = 0
    alreadyReset = false
    previousRagdolled = false

    debugLog("Helper state = STOPPED")

    updateStatus()
end

--====================================================
-- TARGET MODE
--====================================================

TargetMode.MouseButton1Click:Connect(function()
    if targetMode == "PLAYER" then
        targetMode = "POSITION"

        TargetMode.Text = "TARGET MODE: POSITION"
        TargetMode.BackgroundColor3 = Color3.fromRGB(60, 70, 95)

        debugLog("Target mode changed -> POSITION")
    else
        targetMode = "PLAYER"

        TargetMode.Text = "TARGET MODE: PLAYER"
        TargetMode.BackgroundColor3 = Color3.fromRGB(55, 55, 65)

        debugLog("Target mode changed -> PLAYER")
    end

    updateStatus()
end)

--====================================================
-- SAVE POSITION
--====================================================

SavePosition.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character

    if not character then
        debugLog("SavePosition: character missing")
        notify("Character not found.")
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        debugLog("SavePosition: HumanoidRootPart missing")
        notify("HumanoidRootPart not found.")
        return
    end

    local success, result = pcall(function()
        return root.CFrame
    end)

    if not success or not result then
        debugLog("SavePosition ERROR")
        notify("Failed to save position.")
        return
    end

    savedPosition = result

    SavePosition.Text = "POSITION SAVED"
    SavePosition.BackgroundColor3 = Color3.fromRGB(50, 105, 135)

    debugLog("Position saved successfully")

    notify("Position saved.", "Target")
    updateStatus()
end)

--====================================================
-- CLEAR POSITION
--====================================================

ClearPosition.MouseButton1Click:Connect(function()
    savedPosition = nil

    SavePosition.Text = "SAVE POSITION"
    SavePosition.BackgroundColor3 = Color3.fromRGB(60, 70, 95)

    debugLog("Saved position cleared")

    notify("Saved position cleared.", "Target")
    updateStatus()
end)

--====================================================
-- AUTO RESET
--====================================================

ToggleReset.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled

    if autoResetEnabled then
        ToggleReset.Text = "AUTO-RESET: ON"
        ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 55)

        debugLog("Auto-reset enabled")
    else
        ToggleReset.Text = "AUTO-RESET: OFF"
        ToggleReset.BackgroundColor3 = Color3.fromRGB(125, 45, 45)

        debugLog("Auto-reset disabled")
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

    debugLog("Reset threshold = " .. number)

    updateStatus()
end)

--====================================================
-- CHARACTER ADDED
--====================================================

characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    debugLog("CharacterAdded")

    if not helperRunning then
        return
    end

    task.spawn(function()
        local root = character:WaitForChild("HumanoidRootPart", 5)

        if not root then
            debugLog("Respawn: HumanoidRootPart timeout")
            return
        end

        task.wait(0.25)

        if not helperRunning then
            return
        end

        setupRagdoll(character)

        debugLog("Respawn: attempting Arena re-entry")

        if not isCharacterInArena(character) then
            enterArena()
        end
    end)
end)

--====================================================
-- REPORT
--====================================================

Report.MouseButton1Click:Connect(function()
    local target

    if targetMode == "POSITION" then
        target = "Position"
    elseif targetPlayer then
        target = string.format(
            "Player (%s / [%d])",
            targetPlayer.Name,
            targetPlayer.UserId
        )
    else
        target = "None"
    end

    local report = string.format(
        "Killstreak Helper Report\n\n" ..
        "Status: %s\n" ..
        "Runtime: %s\n" ..
        "Target: %s\n" ..
        "Auto-Reset: %s\n" ..
        "Reset Threshold: %d\n" ..
        "Current Ragdolls: %d\n" ..
        "Total Ragdolls: %d\n" ..
        "Resets: %d\n\n" ..
        "Debug:\n%s",
        helperRunning and "Running" or "Stopped",
        getRuntime(),
        target,
        autoResetEnabled and "ON" or "OFF",
        resetThreshold,
        ragdollCount,
        totalRagdolls,
        resetCount,
        table.concat(debugMessages, "\n")
    )

    if typeof(setclipboard) == "function" then
        local success, err = pcall(function()
            setclipboard(report)
        end)

        if success then
            notify("Report copied to clipboard.", "Report")
        else
            debugLog("Clipboard ERROR: " .. tostring(err))
            notify("Clipboard failed. Report available in console.", "Report")
            print(report)
        end
    else
        print(report)
        notify("Report printed to console.", "Report")
    end
end)

--====================================================
-- INFINITE YIELD
--====================================================

IY.MouseButton1Click:Connect(function()
    if getgenv().IY_LOADED then
        notify("Infinite Yield is already running!")
        return
    end

    debugLog("Loading Infinite Yield")

    local success, err = pcall(function()
        loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
            )
        )()
    end)

    if not success then
        debugLog("Infinite Yield ERROR: " .. tostring(err))
        notify("Infinite Yield failed. Check DEBUG.")
    else
        debugLog("Infinite Yield loaded")
    end
end)

--====================================================
-- MINIMIZE
--====================================================

local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        for _, child in ipairs(Frame:GetChildren()) do
            if child:IsA("GuiObject")
                and child ~= Title
                and child ~= Close
                and child ~= Minimize then

                child.Visible = false
            end
        end

        Frame.Size = UDim2.new(0, 390, 0, 40)
        Minimize.Text = "+"

    else
        Frame.Size = UDim2.new(0, 390, 0, 510)

        for _, child in ipairs(Frame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end

        Minimize.Text = "_"
    end
end)

--====================================================
-- CLOSE
--====================================================

Close.MouseButton1Click:Connect(function()
    debugLog("GUI closing")

    helperRunning = false

    if characterConnection then
        pcall(function()
            characterConnection:Disconnect()
        end)

        characterConnection = nil
    end

    disconnectRagdoll()

    if ScreenGui then
        ScreenGui:Destroy()
    end

    getgenv().KsHelper_Loaded = nil
end)

--====================================================
-- INITIAL STATUS
--====================================================

debugLog("Script loaded successfully")
updateStatus()