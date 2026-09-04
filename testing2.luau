--// ============================================================
--// Killstreak Helper
--// Mobile / Touch compatible
--// ============================================================

local cloneref = cloneref or function(v)
    return v
end

local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer

--// ============================================================
--// Executor compatibility
--// ============================================================

local genv = getgenv and getgenv() or _G

local function safeGetHui()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    return CoreGui
end

local UIParent = safeGetHui()

--// ============================================================
--// Place validation
--// ============================================================

local sbPlaceIds = {
    [6403373529] = true,
    [11520107397] = true,
    [124596094333302] = true,
    [9015014224] = true,
    [78262906459073] = true,
}

if not sbPlaceIds[game.PlaceId] then
    warn("[Killstreak Helper] Unsupported PlaceId:", game.PlaceId)
    return
end

--// ============================================================
--// Cleanup previous instance
--// ============================================================

if genv.__KillstreakHelperCleanup then
    pcall(genv.__KillstreakHelperCleanup)
end

--// ============================================================
--// State
--// ============================================================

local running = false
local destroyed = false

local targetMode = "PLAYER"

local selectedPlayer = nil
local selectedUserId = nil

local savedPosition = nil

local autoReset = true
local resetThreshold = 1

local ragdollsCurrent = 0
local ragdollsTotal = 0
local resetCount = 0

local startTime = 0

local debugLines = {}
local MAX_DEBUG_LINES = 80

local connections = {}

local currentCharacter = nil
local currentHumanoid = nil
local currentRoot = nil

local lastRagdollState = false
local resetDebounce = false

--// ============================================================
--// Debug
--// ============================================================

local function debugLog(message)
    local timestamp = os.date("%H:%M:%S")
    local line = string.format("[%s] %s", timestamp, tostring(message))

    table.insert(debugLines, line)

    while #debugLines > MAX_DEBUG_LINES do
        table.remove(debugLines, 1)
    end

    print("[Killstreak Helper]", line)
end

--// ============================================================
--// Utility
--// ============================================================

local function disconnectAll()
    for _, connection in pairs(connections) do
        if typeof(connection) == "RBXScriptConnection" then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end

    table.clear(connections)
end

local function getCharacter()
    local character = LocalPlayer.Character

    if not character then
        return nil
    end

    return character
end

local function getRoot(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(character)
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

--// ============================================================
--// Character handling
--// ============================================================

local function refreshCharacter(character)
    currentCharacter = character
    currentHumanoid = getHumanoid(character)
    currentRoot = getRoot(character)

    lastRagdollState = false

    if character then
        debugLog("CharacterAdded -> " .. character:GetFullName())
    else
        debugLog("Character cleared")
    end
end

refreshCharacter(getCharacter())

table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(character)
    refreshCharacter(character)

    -- Wait until the important objects exist.
    task.spawn(function()
        local root = character:WaitForChild("HumanoidRootPart", 10)
        local humanoid = character:WaitForChild("Humanoid", 10)

        if character ~= currentCharacter then
            return
        end

        currentRoot = root
        currentHumanoid = humanoid

        debugLog("Character components ready")
    end)
end))

--// ============================================================
--// Arena detection
--// ============================================================

local function isCharacterInArena(character)
    if not character then
        return false
    end

    -- Slap Battles commonly creates "entered" on the character.
    if character:FindFirstChild("entered") then
        return true
    end

    return false
end

--// ============================================================
--// Portal lookup
--// ============================================================

local function getArenaPortal()
    local lobby = Workspace:FindFirstChild("Lobby")

    if not lobby then
        return nil
    end

    local portal = lobby:FindFirstChild("Teleport1")

    if portal and portal:IsA("BasePart") then
        return portal
    end

    return nil
end

--// ============================================================
--// Arena entry
--// ============================================================

local function firePortalTouch(portal, root)
    if type(firetouchinterest) ~= "function" then
        return false, "firetouchinterest unavailable"
    end

    local ok, err = pcall(function()
        firetouchinterest(portal, root, 0)
        task.wait(0.08)
        firetouchinterest(portal, root, 1)
    end)

    if not ok then
        return false, tostring(err)
    end

    return true
end

local function enterArena(timeout)
    timeout = timeout or 8

    local character = getCharacter()

    if not character then
        debugLog("Arena entry failed: character missing")
        return false
    end

    local root = getRoot(character)

    if not root then
        debugLog("Arena entry failed: HumanoidRootPart missing")
        return false
    end

    if isCharacterInArena(character) then
        debugLog("Already inside arena")
        return true
    end

    local portal = getArenaPortal()

    if not portal then
        debugLog("Arena portal Teleport1 not found")
        return false
    end

    debugLog("Trying arena entry")

    local deadline = os.clock() + timeout
    local attempt = 0

    while running and os.clock() < deadline do
        attempt += 1

        character = getCharacter()

        if not character then
            debugLog("Arena entry aborted: character disappeared")
            return false
        end

        root = getRoot(character)

        if not root then
            task.wait(0.15)
            continue
        end

        if isCharacterInArena(character) then
            debugLog("Arena entered successfully")
            return true
        end

        portal = getArenaPortal()

        if not portal then
            debugLog("Teleport1 disappeared")
            task.wait(0.25)
            continue
        end

        -- Primary method.
        local touched, touchError = firePortalTouch(portal, root)

        if touched then
            debugLog("Portal touch fired (attempt " .. attempt .. ")")
        elseif touchError then
            debugLog("Portal touch unavailable: " .. touchError)
        end

        -- Fallback method.
        if not isCharacterInArena(character) then
            pcall(function()
                root.CFrame = portal.CFrame + Vector3.new(0, 3, 0)
            end)

            debugLog("Portal CFrame fallback used")
        end

        local checkUntil = os.clock() + 0.8

        while running and os.clock() < checkUntil do
            character = getCharacter()

            if character and isCharacterInArena(character) then
                debugLog("Arena entered successfully")
                return true
            end

            task.wait(0.05)
        end

        task.wait(0.15)
    end

    debugLog("Arena entry timeout")
    return false
end

--// ============================================================
--// Target lookup
--// ============================================================

local function findPlayer(query)
    if not query then
        return nil
    end

    query = tostring(query):gsub("^%s+", ""):gsub("%s+$", "")

    if query == "" then
        return nil
    end

    -- UserId lookup.
    local numericId = tonumber(query)

    if numericId then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == numericId then
                return player
            end
        end
    end

    local lowered = string.lower(query)

    -- Exact Username.
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == lowered then
            return player
        end
    end

    -- Exact DisplayName.
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.DisplayName) == lowered then
            return player
        end
    end

    -- Partial Username / DisplayName.
    for _, player in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), lowered, 1, true)
            or string.find(string.lower(player.DisplayName), lowered, 1, true) then
            return player
        end
    end

    return nil
end

--// ============================================================
--// GUI
--// ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillstreakHelper"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = UIParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(390, 520)
Main.Position = UDim2.new(0.5, -195, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1
Stroke.Transparency = 0.5
Stroke.Parent = Main

--// Title

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.fromOffset(10, 8)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 20)
Subtitle.Position = UDim2.fromOffset(10, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Player / Position automation"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 155)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

--// Target input

local TargetBox = Instance.new("TextBox")
TargetBox.Name = "TargetBox"
TargetBox.Size = UDim2.new(1, -20, 0, 38)
TargetBox.Position = UDim2.fromOffset(10, 70)
TargetBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TargetBox.BorderSizePixel = 0
TargetBox.PlaceholderText = "Username, DisplayName or UserId"
TargetBox.Text = ""
TargetBox.TextColor3 = Color3.fromRGB(240, 240, 240)
TargetBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
TargetBox.TextSize = 14
TargetBox.Font = Enum.Font.Gotham
TargetBox.ClearTextOnFocus = false
TargetBox.Parent = Main

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 8)
TargetCorner.Parent = TargetBox

--// Generic button factory

local function createButton(name, text, x, y, width, height)
    local button = Instance.new("TextButton")

    button.Name = name
    button.Text = text
    button.Size = UDim2.fromOffset(width, height)
    button.Position = UDim2.fromOffset(x, y)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 41)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(240, 240, 240)
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.Parent = Main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    return button
end

local TargetModeButton = createButton(
    "TargetMode",
    "Target: PLAYER",
    10, 116, 180, 36
)

local SavePositionButton = createButton(
    "SavePosition",
    "Save Position",
    200, 116, 180, 36
)

local ClearPositionButton = createButton(
    "ClearPosition",
    "Clear Position",
    10, 160, 180, 36
)

local ResetToggleButton = createButton(
    "AutoReset",
    "Auto Reset: ON",
    200, 160, 180, 36
)

local ThresholdBox = Instance.new("TextBox")
ThresholdBox.Name = "ThresholdBox"
ThresholdBox.Size = UDim2.fromOffset(180, 36)
ThresholdBox.Position = UDim2.fromOffset(10, 204)
ThresholdBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ThresholdBox.BorderSizePixel = 0
ThresholdBox.Text = "1"
ThresholdBox.TextColor3 = Color3.fromRGB(240, 240, 240)
ThresholdBox.TextSize = 13
ThresholdBox.Font = Enum.Font.Gotham
ThresholdBox.PlaceholderText = "Ragdoll threshold"
ThresholdBox.ClearTextOnFocus = false
ThresholdBox.Parent = Main

local ThresholdCorner = Instance.new("UICorner")
ThresholdCorner.CornerRadius = UDim.new(0, 8)
ThresholdCorner.Parent = ThresholdBox

local ThresholdLabel = Instance.new("TextLabel")
ThresholdLabel.Size = UDim2.fromOffset(180, 36)
ThresholdLabel.Position = UDim2.fromOffset(200, 204)
ThresholdLabel.BackgroundTransparency = 1
ThresholdLabel.Text = "Ragdoll threshold"
ThresholdLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
ThresholdLabel.TextSize = 12
ThresholdLabel.Font = Enum.Font.Gotham
ThresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
ThresholdLabel.Parent = Main

local StartButton = createButton(
    "Start",
    "START",
    10, 248, 180, 40
)

local StopButton = createButton(
    "Stop",
    "STOP",
    200, 248, 180, 40
)

local StatusButton = createButton(
    "Status",
    "Status",
    10, 296, 115, 36
)

local DebugButton = createButton(
    "Debug",
    "Debug",
    137, 296, 115, 36
)

local ReportButton = createButton(
    "Report",
    "Copy Report",
    264, 296, 116, 36
)

local IYButton = createButton(
    "InfiniteYield",
    "Infinite Yield",
    10, 340, 370, 36
)

--// Status

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 115)
StatusLabel.Position = UDim2.fromOffset(10, 386)
StatusLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
StatusLabel.BorderSizePixel = 0
StatusLabel.TextColor3 = Color3.fromRGB(215, 215, 220)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextWrapped = false
StatusLabel.Text = "Status: Stopped"
StatusLabel.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

--// ============================================================
--// Status helpers
--// ============================================================

local function getRuntime()
    if not running then
        return 0
    end

    return math.max(0, os.clock() - startTime)
end

local function formatRuntime(seconds)
    seconds = math.floor(seconds)

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function getTargetStatus()
    if targetMode == "POSITION" then
        if savedPosition then
            return "Position saved"
        end

        return "Position not saved"
    end

    if selectedPlayer and selectedPlayer.Parent == Players then
        return string.format(
            "Player (%s / [%d])",
            selectedPlayer.Name,
            selectedPlayer.UserId
        )
    end

    if selectedUserId then
        return string.format("Player ([%d])", selectedUserId)
    end

    return "Player (not selected)"
end

local function updateStatus()
    if destroyed or not StatusLabel then
        return
    end

    local character = getCharacter()

    local inArena = false

    if character then
        inArena = isCharacterInArena(character)
    end

    StatusLabel.Text = string.format(
        "Status: %s\nRuntime: %s\nTarget: %s\nArena: %s\nAuto-Reset: %s\nThreshold: %d\nCurrent Ragdolls: %d\nTotal Ragdolls: %d\nResets: %d",
        running and "Running" or "Stopped",
        formatRuntime(getRuntime()),
        getTargetStatus(),
        inArena and "YES" or "NO",
        autoReset and "ON" or "OFF",
        resetThreshold,
        ragdollsCurrent,
        ragdollsTotal,
        resetCount
    )
end

--// ============================================================
--// Target mode
--// ============================================================

local function setTargetMode(mode)
    if mode ~= "PLAYER" and mode ~= "POSITION" then
        return
    end

    targetMode = mode
    TargetModeButton.Text = "Target: " .. mode

    debugLog("Target mode changed -> " .. mode)
    updateStatus()
end

--// ============================================================
--// Save position
--// ============================================================

local function saveCurrentPosition()
    local character = getCharacter()
    local root = getRoot(character)

    if not root then
        debugLog("Save position failed: HumanoidRootPart missing")
        return
    end

    savedPosition = root.CFrame

    debugLog("Position saved successfully")
    updateStatus()
end

local function clearSavedPosition()
    savedPosition = nil

    debugLog("Saved position cleared")
    updateStatus()
end

--// ============================================================
--// Player target
--// ============================================================

local function resolvePlayerTarget()
    local query = TargetBox.Text

    if query == "" then
        selectedPlayer = nil
        selectedUserId = nil

        debugLog("Target lookup failed: input empty")
        return nil
    end

    local player = findPlayer(query)

    if not player then
        selectedPlayer = nil
        selectedUserId = tonumber(query)

        debugLog("Target not found: " .. query)
        return nil
    end

    selectedPlayer = player
    selectedUserId = player.UserId

    debugLog(string.format(
        "Target resolved -> %s / [%d]",
        player.Name,
        player.UserId
    ))

    return player
end

--// ============================================================
--// Reset
--// ============================================================

local function performReset()
    if resetDebounce then
        return
    end

    resetDebounce = true
    resetCount += 1

    debugLog("Reset requested")

    local resetObject = LocalPlayer:FindFirstChild("Reset")

    if resetObject and resetObject:IsA("RemoteEvent") then
        local ok, err = pcall(function()
            resetObject:FireServer()
        end)

        if not ok then
            debugLog("Reset FireServer failed: " .. tostring(err))
        end
    else
        debugLog("Reset remote not found")
    end

    task.delay(1, function()
        resetDebounce = false
    end)
end

--// ============================================================
--// Ragdoll
--// ============================================================

local function getRagdollState(character)
    if not character then
        return false
    end

    local ragdolled = character:FindFirstChild("Ragdolled")

    if not ragdolled then
        return false
    end

    if ragdolled:IsA("BoolValue") then
        return ragdolled.Value
    end

    -- If the object exists but is not a BoolValue,
    -- existence itself is treated as active.
    return true
end

local function updateRagdoll()
    local character = getCharacter()

    if not character then
        ragdollsCurrent = 0
        lastRagdollState = false
        return
    end

    local active = getRagdollState(character)

    if active and not lastRagdollState then
        ragdollsTotal += 1
        ragdollsCurrent += 1

        debugLog(
            "Ragdoll detected -> current=" ..
            ragdollsCurrent ..
            ", total=" ..
            ragdollsTotal
        )

        if autoReset and ragdollsCurrent >= resetThreshold then
            performReset()
            ragdollsCurrent = 0
        end
    elseif not active then
        ragdollsCurrent = 0
    end

    lastRagdollState = active
end

--// ============================================================
--// Target positioning
--// ============================================================

local function followPlayer(player)
    if not player then
        return false
    end

    local targetCharacter = player.Character

    if not targetCharacter then
        return false
    end

    local targetRoot = getRoot(targetCharacter)

    if not targetRoot then
        return false
    end

    local character = getCharacter()
    local root = getRoot(character)

    if not root then
        return false
    end

    local ok, err = pcall(function()
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
    end)

    if not ok then
        debugLog("Follow player failed: " .. tostring(err))
        return false
    end

    return true
end

local function followSavedPosition()
    if not savedPosition then
        return false
    end

    local character = getCharacter()
    local root = getRoot(character)

    if not root then
        return false
    end

    local ok, err = pcall(function()
        root.CFrame = savedPosition
    end)

    if not ok then
        debugLog("Follow position failed: " .. tostring(err))
        return false
    end

    return true
end

--// ============================================================
--// Main loop
--// ============================================================

local helperThread = nil

local function helperLoop()
    debugLog("Main helper loop started")

    while running and not destroyed do
        local character = getCharacter()

        if not character then
            task.wait(0.25)
            continue
        end

        currentCharacter = character
        currentRoot = getRoot(character)
        currentHumanoid = getHumanoid(character)

        if not isCharacterInArena(character) then
            enterArena(3)
        end

        if running then
            if targetMode == "PLAYER" then
                local player = selectedPlayer

                if not player or player.Parent ~= Players then
                    player = resolvePlayerTarget()
                end

                if player then
                    followPlayer(player)
                end

            elseif targetMode == "POSITION" then
                followSavedPosition()
            end
        end

        updateRagdoll()
        updateStatus()

        task.wait(0.10)
    end

    debugLog("Main helper loop stopped")
end

--// ============================================================
--// Start / Stop
--// ============================================================

local function startHelper()
    debugLog("startHelper() called")

    if destroyed then
        debugLog("Start rejected: GUI destroyed")
        return
    end

    if running then
        debugLog("Start ignored: already running")
        return
    end

    if targetMode == "PLAYER" then
        if not resolvePlayerTarget() then
            debugLog("Start aborted: player target unavailable")
            updateStatus()
            return
        end
    elseif targetMode == "POSITION" then
        if not savedPosition then
            debugLog("Start aborted: saved position unavailable")
            updateStatus()
            return
        end
    end

    running = true
    startTime = os.clock()
    ragdollsCurrent = 0
    lastRagdollState = false
    resetDebounce = false

    debugLog("Helper STARTED")

    updateStatus()

    helperThread = task.spawn(function()
        local ok, err = xpcall(
            helperLoop,
            function(e)
                return debug.traceback(tostring(e), 2)
            end
        )

        if not ok then
            debugLog("Helper loop crashed: " .. tostring(err))
            running = false
            updateStatus()
        end
    end)
end

local function stopHelper()
    debugLog("stopHelper() called")

    if not running then
        debugLog("Stop ignored: already stopped")
        updateStatus()
        return
    end

    running = false

    debugLog("Helper STOPPED")
    updateStatus()
end

--// ============================================================
--// UI Events
--// IMPORTANT: Activated works on touch/mobile and mouse.
--// ============================================================

table.insert(connections, StartButton.Activated:Connect(function()
    debugLog("START button activated")
    startHelper()
end))

table.insert(connections, StopButton.Activated:Connect(function()
    debugLog("STOP button activated")
    stopHelper()
end))

table.insert(connections, TargetModeButton.Activated:Connect(function()
    if targetMode == "PLAYER" then
        setTargetMode("POSITION")
    else
        setTargetMode("PLAYER")
    end
end))

table.insert(connections, SavePositionButton.Activated:Connect(function()
    saveCurrentPosition()
end))

table.insert(connections, ClearPositionButton.Activated:Connect(function()
    clearSavedPosition()
end))

table.insert(connections, ResetToggleButton.Activated:Connect(function()
    autoReset = not autoReset

    ResetToggleButton.Text = "Auto Reset: " ..
        (autoReset and "ON" or "OFF")

    debugLog(
        "Auto-reset " ..
        (autoReset and "enabled" or "disabled")
    )

    updateStatus()
end))

table.insert(connections, StatusButton.Activated:Connect(function()
    updateStatus()
    debugLog("Status manually updated")
end))

table.insert(connections, DebugButton.Activated:Connect(function()
    for _, line in ipairs(debugLines) do
        print("[Killstreak Helper]", line)
    end

    debugLog("Debug buffer printed to console")
end))

--// ============================================================
--// Threshold
--// ============================================================

table.insert(connections, ThresholdBox.FocusLost:Connect(function()
    local value = tonumber(ThresholdBox.Text)

    if not value then
        ThresholdBox.Text = tostring(resetThreshold)
        debugLog("Invalid threshold input")
        return
    end

    value = math.floor(value)

    if value < 1 then
        value = 1
    end

    if value > 999 then
        value = 999
    end

    resetThreshold = value
    ThresholdBox.Text = tostring(value)

    debugLog("Reset threshold changed -> " .. value)
    updateStatus()
end))

--// ============================================================
--// Report
--// ============================================================

local function generateReport()
    local report = {}

    table.insert(report, "Killstreak Helper Report")
    table.insert(report, "")
    table.insert(report, "PlaceId: " .. tostring(game.PlaceId))
    table.insert(report, "JobId: " .. tostring(game.JobId))
    table.insert(report, "")

    table.insert(
        report,
        "Status: " .. (running and "Running" or "Stopped")
    )

    table.insert(
        report,
        "Runtime: " .. formatRuntime(getRuntime())
    )

    table.insert(
        report,
        "Target: " .. getTargetStatus()
    )

    table.insert(
        report,
        "Target Mode: " .. targetMode
    )

    table.insert(
        report,
        "Auto-Reset: " .. (autoReset and "ON" or "OFF")
    )

    table.insert(
        report,
        "Reset Threshold: " .. tostring(resetThreshold)
    )

    table.insert(
        report,
        "Current Ragdolls: " .. tostring(ragdollsCurrent)
    )

    table.insert(
        report,
        "Total Ragdolls: " .. tostring(ragdollsTotal)
    )

    table.insert(
        report,
        "Resets: " .. tostring(resetCount)
    )

    table.insert(report, "")
    table.insert(report, "Debug:")

    for _, line in ipairs(debugLines) do
        table.insert(report, line)
    end

    return table.concat(report, "\n")
end

table.insert(connections, ReportButton.Activated:Connect(function()
    local report = generateReport()

    if type(setclipboard) == "function" then
        local ok, err = pcall(function()
            setclipboard(report)
        end)

        if ok then
            debugLog("Report copied to clipboard")
        else
            debugLog("Clipboard failed: " .. tostring(err))
            print(report)
        end
    elseif type(toclipboard) == "function" then
        local ok, err = pcall(function()
            toclipboard(report)
        end)

        if ok then
            debugLog("Report copied to clipboard")
        else
            debugLog("Clipboard failed: " .. tostring(err))
            print(report)
        end
    else
        debugLog("Clipboard API unavailable")
        print(report)
    end
end))

--// ============================================================
--// Infinite Yield
--// ============================================================

table.insert(connections, IYButton.Activated:Connect(function()
    if type(loadstring) ~= "function" then
        debugLog("Infinite Yield failed: loadstring unavailable")
        return
    end

    local ok, err = pcall(function()
        local source = game:HttpGet(
            "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
        )

        local fn, compileError = loadstring(source)

        if not fn then
            error(compileError or "loadstring compilation failed")
        end

        task.spawn(fn)
    end)

    if not ok then
        debugLog("Infinite Yield failed: " .. tostring(err))
    else
        debugLog("Infinite Yield loaded")
    end
end))

--// ============================================================
--// Initial state
--// ============================================================

updateStatus()

debugLog("GUI initialized successfully")
debugLog("PlaceId accepted -> " .. tostring(game.PlaceId))
debugLog("Touch-compatible Activated events installed")
debugLog("Ready")

--// ============================================================
--// Global cleanup
--// ============================================================

genv.__KillstreakHelperCleanup = function()
    if destroyed then
        return
    end

    destroyed = true
    running = false

    disconnectAll()

    if ScreenGui then
        pcall(function()
            ScreenGui:Destroy()
        end)
    end

    genv.__KillstreakHelperCleanup = nil
end