local cloneref = cloneref or function(...)
    return ...
end

--==================================================
-- CONFIGURATION
--==================================================

local sbPlaceIds = {
    [6403373529] = true,
    [11520107397] = true,
    [124596094333302] = true,
    [9015014224] = true,
    [78262906459073] = true,
}

local POST_RESPAWN_DELAY = 0.2
local ARENA_RETRY_DELAY = 0.2
local FOLLOW_DELAY = 0.05
local CHARACTER_CHECK_DELAY = 0.05

--==================================================
-- PLACE CHECK
--==================================================

if not sbPlaceIds[game.PlaceId] then
    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))

    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    local gameName = "another game"

    if success and info and info.Name then
        gameName = info.Name
    end

    print(
        "This script is for Slap Battles, but you are in "
            .. gameName
    )

    return
end

--==================================================
-- DUPLICATE EXECUTION CHECK
--==================================================

if getgenv().KsHelper_Loaded then
    return
end

pcall(function()
    getgenv().KsHelper_Loaded = true
end)

--==================================================
-- GAME LOADED
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--==================================================
-- SERVICES
--==================================================

local CoreGui = cloneref(game:GetService("CoreGui"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local Players = cloneref(game:GetService("Players"))

local LocalPlayer = cloneref(Players.LocalPlayer)

local guiParent =
    (gethui and gethui())
    or CoreGui:FindFirstChild("RobloxGui")
    or CoreGui

--==================================================
-- UTILITY
--==================================================

local function randomString()
    local length = math.random(10, 20)
    local array = {}

    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end

    return table.concat(array)
end

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "KS Helper",
            Text = tostring(message),
            Duration = 3
        })
    end)
end

local function getCharacter()
    local character = LocalPlayer.Character

    if not character or not character.Parent then
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

local function getArenaValue(character)
    if not character then
        return nil
    end

    local value = character:FindFirstChild("isInArena")

    if value and value:IsA("BoolValue") then
        return value
    end

    return nil
end

local function isInArena(character)
    local value = getArenaValue(character)

    return value ~= nil and value.Value == true
end

local function isTargetInArena(character)
    if not character then
        return false
    end

    local arenaValue = character:FindFirstChild("isInArena")

    if arenaValue
        and arenaValue:IsA("BoolValue")
        and arenaValue.Value then

        return true
    end

    -- Keep the original helper's fallback.
    return character:FindFirstChild("KillstreakLevel") ~= nil
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

--==================================================
-- MAIN FRAME
--==================================================

local Frame = Instance.new("Frame")
Frame.Name = randomString()
Frame.Size = UDim2.new(0, 300, 0, 310)
Frame.Position = UDim2.new(0.5, -150, 0.5, -155)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 31)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 1.5
UIStroke.Parent = Frame

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper V3.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 25, 0, 25)
Minimize.Position = UDim2.new(1, -60, 0, 5)
Minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Minimize.Text = "_"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 14
Minimize.Parent = Frame

Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 6)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Frame

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

--==================================================
-- TARGET MODE
--==================================================

local ModeBtn = Instance.new("TextButton")
ModeBtn.Position = UDim2.new(0, 15, 0, 45)
ModeBtn.Size = UDim2.new(1, -30, 0, 30)
ModeBtn.Text = "Target: Player"
ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 150)
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 14
ModeBtn.Parent = Frame

Instance.new("UICorner", ModeBtn).CornerRadius = UDim.new(0, 6)

--==================================================
-- PLAYER INPUT
--==================================================

local PlayerTextBox = Instance.new("TextBox")
PlayerTextBox.Position = UDim2.new(0, 15, 0, 85)
PlayerTextBox.Size = UDim2.new(1, -30, 0, 30)
PlayerTextBox.Text = ""
PlayerTextBox.PlaceholderText = "Player's name"
PlayerTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
PlayerTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PlayerTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerTextBox.Font = Enum.Font.Gotham
PlayerTextBox.TextSize = 14
PlayerTextBox.Visible = true
PlayerTextBox.Parent = Frame

Instance.new("UICorner", PlayerTextBox).CornerRadius = UDim.new(0, 6)

--==================================================
-- POSITION CONTAINER
--==================================================

local PosFrame = Instance.new("Frame")
PosFrame.Position = UDim2.new(0, 15, 0, 85)
PosFrame.Size = UDim2.new(1, -30, 0, 30)
PosFrame.BackgroundTransparency = 1
PosFrame.Visible = false
PosFrame.Parent = Frame

local PosLabel = Instance.new("TextLabel")
PosLabel.Size = UDim2.new(0.62, -5, 1, 0)
PosLabel.Position = UDim2.new(0, 0, 0, 0)
PosLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PosLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PosLabel.Text = "None saved"
PosLabel.Font = Enum.Font.Gotham
PosLabel.TextSize = 12
PosLabel.TextTruncate = Enum.TextTruncate.AtEnd
PosLabel.Parent = PosFrame

Instance.new("UICorner", PosLabel).CornerRadius = UDim.new(0, 6)

local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Size = UDim2.new(0.38, -5, 1, 0)
SavePosBtn.Position = UDim2.new(0.62, 5, 0, 0)
SavePosBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SavePosBtn.Text = "Save Pos"
SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.Font = Enum.Font.GothamBold
SavePosBtn.TextSize = 13
SavePosBtn.Parent = PosFrame

Instance.new("UICorner", SavePosBtn).CornerRadius = UDim.new(0, 6)

--==================================================
-- AUTO RESET CONTAINER
--==================================================

-- The container itself is constrained to the Frame.
-- This prevents the label/button from exceeding the UI.
local ResetContainer = Instance.new("Frame")
ResetContainer.Position = UDim2.new(0, 15, 0, 125)
ResetContainer.Size = UDim2.new(1, -30, 0, 30)
ResetContainer.BackgroundTransparency = 1
ResetContainer.Parent = Frame

local ToggleReset = Instance.new("TextButton")
ToggleReset.Position = UDim2.new(0, 0, 0, 0)
ToggleReset.Size = UDim2.new(0.62, -5, 1, 0)
ToggleReset.Text = "Auto-Reset: ON"
ToggleReset.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ToggleReset.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleReset.Font = Enum.Font.GothamBold
ToggleReset.TextSize = 14
ToggleReset.Parent = ResetContainer

Instance.new("UICorner", ToggleReset).CornerRadius = UDim.new(0, 6)

local RagdollInput = Instance.new("TextBox")
RagdollInput.Position = UDim2.new(0.62, 5, 0, 0)
RagdollInput.Size = UDim2.new(0.38, -5, 1, 0)
RagdollInput.Text = "1"
RagdollInput.PlaceholderText = "Limit"
RagdollInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RagdollInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RagdollInput.Font = Enum.Font.GothamBold
RagdollInput.TextSize = 14
RagdollInput.Parent = ResetContainer

Instance.new("UICorner", RagdollInput).CornerRadius = UDim.new(0, 6)

--==================================================
-- ACTION BUTTONS
--==================================================

local StartBtn = Instance.new("TextButton")
StartBtn.Position = UDim2.new(0, 15, 0, 165)
StartBtn.Size = UDim2.new(0.5, -20, 0, 35)
StartBtn.Text = "START"
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = Frame

Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton")
StopBtn.Position = UDim2.new(0.5, 5, 0, 165)
StopBtn.Size = UDim2.new(0.5, -20, 0, 35)
StopBtn.Text = "STOP"
StopBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = Frame

Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

--==================================================
-- STATS
--==================================================

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Position = UDim2.new(0, 15, 0, 210)
StatsLabel.Size = UDim2.new(1, -30, 0, 25)
StatsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.Text = "Time: 00:00 | Ragdolls: 0 | Resets: 0"
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.Parent = Frame

Instance.new("UICorner", StatsLabel).CornerRadius = UDim.new(0, 4)

--==================================================
-- INFINITE YIELD
--==================================================

local IY = Instance.new("TextButton")
IY.Position = UDim2.new(0, 15, 0, 260)
IY.Size = UDim2.new(1, -30, 0, 30)
IY.Text = "Execute Infinite Yield"
IY.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
IY.TextColor3 = Color3.fromRGB(255, 255, 255)
IY.Font = Enum.Font.GothamBold
IY.TextSize = 13
IY.Parent = Frame

Instance.new("UICorner", IY).CornerRadius = UDim.new(0, 6)

--==================================================
-- STATE
--==================================================

local helperRunning = false
local autoResetEnabled = true

local targetPlayer = nil
local targetMode = "Player"

local savedCFrame = nil

local ragdollLimit = 1
local currentRagdolls = 0

local wasRagdolled = false
local alreadyReset = false

local stats_StartTime = 0
local stats_Ragdolls = 0
local stats_Resets = 0

-- Every arena worker receives a unique token.
-- Starting/stopping/respawning invalidates older workers.
local arenaWorkerToken = 0

--==================================================
-- STATS
--==================================================

local function resetStatsUI()
    stats_Ragdolls = 0
    stats_Resets = 0

    StatsLabel.Text =
        "Time: 00:00 | Ragdolls: 0 | Resets: 0"
end

local function updateStatsLoop()
    while helperRunning do
        local elapsed = math.max(
            0,
            math.floor(os.clock() - stats_StartTime)
        )

        local minutes = math.floor(elapsed / 60)
        local seconds = elapsed % 60

        StatsLabel.Text = string.format(
            "Time: %02d:%02d | Ragdolls: %d | Resets: %d",
            minutes,
            seconds,
            stats_Ragdolls,
            stats_Resets
        )

        task.wait(1)
    end
end

--==================================================
-- PLAYER SEARCH
--==================================================

local function findPlayer(nickname)
    nickname = tostring(nickname):lower()

    if nickname == "" then
        return nil
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local username = player.Name:lower()
        local displayName = player.DisplayName:lower()

        if username:find(nickname, 1, true)
            or displayName:find(nickname, 1, true) then

            return player
        end
    end

    return nil
end

--==================================================
-- PORTAL
--==================================================

local function getPortal()
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

local function triggerPortal(rootPart)
    if not rootPart or not rootPart.Parent then
        return false
    end

    local portal = getPortal()

    if not portal then
        return false
    end

    if not firetouchinterest then
        return false
    end

    local success = pcall(function()
        firetouchinterest(rootPart, portal, 0)

        task.wait()

        firetouchinterest(rootPart, portal, 1)
    end)

    return success
end

--==================================================
-- TARGET READY CHECK
--==================================================

local function targetIsReady()
    if targetMode ~= "Player" then
        return true
    end

    if not targetPlayer or targetPlayer.Parent ~= Players then
        return false
    end

    local character = targetPlayer.Character

    if not character then
        return false
    end

    local humanoid = getHumanoid(character)
    local rootPart = getRoot(character)

    if not humanoid
        or humanoid.Health <= 0
        or not rootPart then

        return false
    end

    return isTargetInArena(character)
end

--==================================================
-- ENTER ARENA
--==================================================

local function enterArena()
    arenaWorkerToken += 1

    local myToken = arenaWorkerToken

    while helperRunning and myToken == arenaWorkerToken do

        --==========================================
        -- WAIT FOR CHARACTER
        --==========================================

        local character = getCharacter()

        if not character then
            task.wait(CHARACTER_CHECK_DELAY)
            continue
        end

        --==========================================
        -- WAIT FOR ROOT
        --==========================================

        local rootPart = getRoot(character)

        if not rootPart then
            task.wait(CHARACTER_CHECK_DELAY)
            continue
        end

        --==========================================
        -- ALREADY IN ARENA
        --==========================================

        if isInArena(character) then
            return
        end

        --==========================================
        -- PLAYER MODE
        --==========================================

        if targetMode == "Player" then
            if not targetIsReady() then
                task.wait(ARENA_RETRY_DELAY)
                continue
            end
        end

        --==========================================
        -- POSITION MODE
        --==========================================

        -- Position mode doesn't require a target.
        -- The saved position has already been validated
        -- when it was created.

        --==========================================
        -- PORTAL TOUCH
        --==========================================

        triggerPortal(rootPart)

        -- Required delay before checking isInArena.
        task.wait(POST_RESPAWN_DELAY)

        --==========================================
        -- REFRESH CHARACTER
        --==========================================

        character = getCharacter()

        if character and isInArena(character) then
            return
        end

        -- Still not in arena.
        -- Loop and touch the portal again after 0.2 sec.
        task.wait(ARENA_RETRY_DELAY)
    end
end

--==================================================
-- FOLLOW LOOP
--==================================================

local function followLoop()
    while helperRunning do
        task.wait(FOLLOW_DELAY)

        if not helperRunning then
            break
        end

        local character = getCharacter()

        if not character then
            continue
        end

        local humanoid = getHumanoid(character)
        local rootPart = getRoot(character)

        if not humanoid
            or humanoid.Health <= 0
            or not rootPart then

            continue
        end

        -- Never move the character outside the arena.
        if not isInArena(character) then
            continue
        end

        --==========================================
        -- RAGDOLL
        --==========================================

        local ragdolled = character:FindFirstChild("Ragdolled")

        local isCurrentlyRagdolled =
            ragdolled ~= nil
            and ragdolled:IsA("BoolValue")
            and ragdolled.Value == true

        if isCurrentlyRagdolled and not wasRagdolled then
            wasRagdolled = true

            currentRagdolls += 1
            stats_Ragdolls += 1

            if autoResetEnabled
                and currentRagdolls >= ragdollLimit then

                local resetEvent =
                    LocalPlayer:FindFirstChild("Reset")

                if not alreadyReset and resetEvent then
                    local success = pcall(function()
                        resetEvent:FireServer()
                    end)

                    if success then
                        alreadyReset = true

                        currentRagdolls = 0
                        stats_Resets += 1
                    end
                end
            end

        elseif not isCurrentlyRagdolled then
            wasRagdolled = false
            alreadyReset = false
        end

        -- Don't move while reset/ragdoll handling is active.
        if alreadyReset then
            continue
        end

        if isCurrentlyRagdolled
            and autoResetEnabled
            and currentRagdolls >= ragdollLimit then

            continue
        end

        --==========================================
        -- PLAYER MODE
        --==========================================

        if targetMode == "Player" then

            if not targetPlayer
                or targetPlayer.Parent ~= Players then

                continue
            end

            local targetCharacter = targetPlayer.Character

            if not targetCharacter then
                continue
            end

            local targetHumanoid =
                getHumanoid(targetCharacter)

            local targetRoot =
                getRoot(targetCharacter)

            if not targetHumanoid
                or targetHumanoid.Health <= 0
                or not targetRoot then

                continue
            end

            if not isTargetInArena(targetCharacter) then
                continue
            end

            if not isCurrentlyRagdolled then
                pcall(function()
                    rootPart.CFrame =
                        targetRoot.CFrame
                        * CFrame.new(0, 0, -4)
                end)
            end

        --==========================================
        -- POSITION MODE
        --==========================================

        elseif targetMode == "Position" then

            if savedCFrame and not isCurrentlyRagdolled then
                pcall(function()
                    rootPart.CFrame = savedCFrame
                end)
            end
        end
    end
end

--==================================================
-- MODE BUTTON
--==================================================

ModeBtn.MouseButton1Click:Connect(function()
    if targetMode == "Player" then
        targetMode = "Position"

        ModeBtn.Text = "Target: Saved Position"
        ModeBtn.BackgroundColor3 =
            Color3.fromRGB(150, 100, 40)

        PlayerTextBox.Visible = false
        PosFrame.Visible = true
    else
        targetMode = "Player"

        ModeBtn.Text = "Target: Player"
        ModeBtn.BackgroundColor3 =
            Color3.fromRGB(40, 100, 150)

        PlayerTextBox.Visible = true
        PosFrame.Visible = false
    end
end)

--==================================================
-- SAVE POSITION
--==================================================

SavePosBtn.MouseButton1Click:Connect(function()
    local character = getCharacter()

    if not character then
        notify("Character not found.")
        return
    end

    local rootPart = getRoot(character)

    if not rootPart then
        notify("HumanoidRootPart not found.")
        return
    end

    -- Position can ONLY be saved from inside the arena.
    if not isInArena(character) then
        notify("You must be in the arena to save a position.")
        return
    end

    savedCFrame = rootPart.CFrame

    local position = savedCFrame.Position

    PosLabel.Text = string.format(
        "%.1f, %.1f, %.1f",
        position.X,
        position.Y,
        position.Z
    )

    PosLabel.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    notify("Position saved successfully.")
end)

--==================================================
-- RAGDOLL LIMIT
--==================================================

RagdollInput.FocusLost:Connect(function()
    local number = tonumber(RagdollInput.Text)

    if number
        and number > 0
        and number < math.huge then

        ragdollLimit = math.max(
            1,
            math.floor(number)
        )

        RagdollInput.Text =
            tostring(ragdollLimit)
    else
        RagdollInput.Text =
            tostring(ragdollLimit)

        notify("Invalid ragdoll limit.")
    end
end)

--==================================================
-- AUTO RESET TOGGLE
--==================================================

ToggleReset.MouseButton1Click:Connect(function()
    autoResetEnabled = not autoResetEnabled

    if autoResetEnabled then
        ToggleReset.Text = "Auto-Reset: ON"
        ToggleReset.BackgroundColor3 =
            Color3.fromRGB(40, 120, 40)
    else
        ToggleReset.Text = "Auto-Reset: OFF"
        ToggleReset.BackgroundColor3 =
            Color3.fromRGB(120, 40, 40)
    end
end)

--==================================================
-- INFINITE YIELD
--==================================================

IY.MouseButton1Click:Connect(function()
    if getgenv().IY_LOADED then
        notify("Infinite Yield is already running.")
        return
    end

    local success = pcall(function()
        loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
            )
        )()
    end)

    if success then
        notify("Infinite Yield loaded successfully.")
    else
        notify("Failed to load Infinite Yield.")
    end
end)

--==================================================
-- DISABLE BRAZIL TOUCH
--==================================================

pcall(function()
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
            part.CanTouch = false
        end
    end
end)

--==================================================
-- START
--==================================================

StartBtn.MouseButton1Click:Connect(function()
    if helperRunning then
        return
    end

    --==============================================
    -- VALIDATE TARGET
    --==============================================

    if targetMode == "Player" then
        local nameInput =
            PlayerTextBox.Text

        if nameInput == "" then
            notify("Please enter a player's name.")
            return
        end

        local player =
            findPlayer(nameInput)

        if not player then
            notify("Player not found.")
            return
        end

        targetPlayer = player

    elseif targetMode == "Position" then

        if not savedCFrame then
            notify("You need to save a position first.")
            return
        end
    end

    --==============================================
    -- START STATE
    --==============================================

    helperRunning = true

    currentRagdolls = 0
    wasRagdolled = false
    alreadyReset = false

    stats_StartTime = os.clock()

    resetStatsUI()

    -- Invalidate any old arena worker.
    arenaWorkerToken += 1

    --==============================================
    -- START ALL WORKERS IMMEDIATELY
    --==============================================

    -- Timer does NOT wait for arena.
    task.spawn(updateStatsLoop)

    -- Follow loop does NOT wait for arena.
    -- It simply ignores movement until isInArena == true.
    task.spawn(followLoop)

    -- Arena entry runs independently.
    task.spawn(enterArena)

    notify("Helper started.")
end)

--==================================================
-- STOP
--==================================================

StopBtn.MouseButton1Click:Connect(function()
    if not helperRunning then
        return
    end

    helperRunning = false

    -- Invalidate any active arena worker.
    arenaWorkerToken += 1

    resetStatsUI()

    notify("Helper stopped.")
end)

--==================================================
-- MINIMIZE
--==================================================

Minimize.MouseButton1Click:Connect(function()
    local minimized =
        StartBtn.Visible == false

    for _, child in ipairs(Frame:GetChildren()) do

        if child ~= Title
            and child ~= Close
            and child ~= Minimize
            and not child:IsA("UICorner")
            and not child:IsA("UIStroke") then

            if child == PosFrame then
                child.Visible =
                    minimized
                    and targetMode == "Position"

            elseif child == PlayerTextBox then
                child.Visible =
                    minimized
                    and targetMode == "Player"

            else
                child.Visible = minimized
            end
        end
    end

    if minimized then
        Frame.Size =
            UDim2.new(0, 300, 0, 310)
    else
        Frame.Size =
            UDim2.new(0, 300, 0, 35)
    end
end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()
    helperRunning = false

    arenaWorkerToken += 1

    if ScreenGui then
        ScreenGui:Destroy()
    end

    getgenv().KsHelper_Loaded = nil
end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

LocalPlayer.CharacterAdded:Connect(function(character)

    if not helperRunning then
        return
    end

    -- Invalidate the previous arena-entry worker.
    arenaWorkerToken += 1

    alreadyReset = false
    wasRagdolled = false
    currentRagdolls = 0

    local myToken = arenaWorkerToken

    task.spawn(function()

        --==========================================
        -- WAIT FOR NEW CHARACTER
        --==========================================

        local rootPart =
            character:WaitForChild(
                "HumanoidRootPart",
                10
            )

        if not rootPart then
            return
        end

        --==========================================
        -- POST-RESPAWN DELAY
        --==========================================

        task.wait(POST_RESPAWN_DELAY)

        if not helperRunning then
            return
        end

        if myToken ~= arenaWorkerToken then
            return
        end

        --==========================================
        -- ENTER ARENA
        --==========================================

        enterArena()
    end)
end)