local cloneref = cloneref or function(...) return ... end

--==================================================
-- PLACE CHECK
--==================================================

local sbPlaceIds = {
    [6403373529] = true,
    [11520107397] = true,
    [124596094333302] = true,
    [9015014224] = true,
    [78262906459073] = true,
}

if not sbPlaceIds[game.PlaceId] then
    local MarketplaceService =
        cloneref(game:GetService("MarketplaceService"))

    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    local gameName =
        success and info and info.Name
        or "another game"

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

getgenv().KsHelper_Loaded = true

--==================================================
-- SERVICES
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui =
    cloneref(game:GetService("CoreGui"))

local StarterGui =
    cloneref(game:GetService("StarterGui"))

local Players =
    cloneref(game:GetService("Players"))

local LocalPlayer =
    cloneref(Players.LocalPlayer)

local guiParent =
    (gethui and gethui())
    or CoreGui:FindFirstChild("RobloxGui")
    or CoreGui

--==================================================
-- RANDOM NAME
--==================================================

local function randomString()
    local length = math.random(10, 20)
    local array = {}

    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end

    return table.concat(array)
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

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
Title.Size = UDim2.new(1, -60, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper V3.2"
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

Instance.new("UICorner", Minimize).CornerRadius =
    UDim.new(0, 6)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Frame

Instance.new("UICorner", Close).CornerRadius =
    UDim.new(0, 6)

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

Instance.new("UICorner", ModeBtn).CornerRadius =
    UDim.new(0, 6)

--==================================================
-- PLAYER INPUT
--==================================================

local PlayerTextBox = Instance.new("TextBox")
PlayerTextBox.Position = UDim2.new(0, 15, 0, 85)
PlayerTextBox.Size = UDim2.new(1, -30, 0, 30)
PlayerTextBox.Text = ""
PlayerTextBox.PlaceholderText = "Player's name"
PlayerTextBox.PlaceholderColor3 =
    Color3.fromRGB(150, 150, 150)
PlayerTextBox.BackgroundColor3 =
    Color3.fromRGB(45, 45, 45)
PlayerTextBox.TextColor3 =
    Color3.fromRGB(255, 255, 255)
PlayerTextBox.Font = Enum.Font.Gotham
PlayerTextBox.TextSize = 14
PlayerTextBox.Visible = true
PlayerTextBox.Parent = Frame

Instance.new("UICorner", PlayerTextBox).CornerRadius =
    UDim.new(0, 6)

--==================================================
-- POSITION
--==================================================

local PosFrame = Instance.new("Frame")
PosFrame.Position = UDim2.new(0, 15, 0, 85)
PosFrame.Size = UDim2.new(1, -30, 0, 30)
PosFrame.BackgroundTransparency = 1
PosFrame.Visible = false
PosFrame.Parent = Frame

local PosLabel = Instance.new("TextLabel")
PosLabel.Size = UDim2.new(0.65, -5, 1, 0)
PosLabel.Position = UDim2.new(0, 0, 0, 0)
PosLabel.BackgroundColor3 =
    Color3.fromRGB(45, 45, 45)
PosLabel.TextColor3 =
    Color3.fromRGB(200, 200, 200)
PosLabel.Text = "None saved"
PosLabel.Font = Enum.Font.Gotham
PosLabel.TextSize = 12
PosLabel.Parent = PosFrame

Instance.new("UICorner", PosLabel).CornerRadius =
    UDim.new(0, 6)

local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Size = UDim2.new(0.35, -5, 1, 0)
SavePosBtn.Position = UDim2.new(0.65, 5, 0, 0)
SavePosBtn.BackgroundColor3 =
    Color3.fromRGB(100, 100, 100)
SavePosBtn.Text = "Save Pos"
SavePosBtn.TextColor3 =
    Color3.fromRGB(255, 255, 255)
SavePosBtn.Font = Enum.Font.GothamBold
SavePosBtn.TextSize = 13
SavePosBtn.Parent = PosFrame

Instance.new("UICorner", SavePosBtn).CornerRadius =
    UDim.new(0, 6)

--==================================================
-- AUTO RESET
--==================================================

local ToggleReset = Instance.new("TextButton")
ToggleReset.Position = UDim2.new(0, 15, 0, 125)
ToggleReset.Size = UDim2.new(0.65, -5, 0, 30)
ToggleReset.Text = "Auto-Reset: ON"
ToggleReset.BackgroundColor3 =
    Color3.fromRGB(40, 120, 40)
ToggleReset.TextColor3 =
    Color3.fromRGB(255, 255, 255)
ToggleReset.Font = Enum.Font.GothamBold
ToggleReset.TextSize = 14
ToggleReset.Parent = Frame

Instance.new("UICorner", ToggleReset).CornerRadius =
    UDim.new(0, 6)

local RagdollInput = Instance.new("TextBox")
RagdollInput.Position = UDim2.new(0.65, 5, 0, 125)
RagdollInput.Size = UDim2.new(0.35, -20, 0, 30)
RagdollInput.Text = "1"
RagdollInput.PlaceholderText = "Limit"
RagdollInput.BackgroundColor3 =
    Color3.fromRGB(45, 45, 45)
RagdollInput.TextColor3 =
    Color3.fromRGB(255, 255, 255)
RagdollInput.Font = Enum.Font.GothamBold
RagdollInput.TextSize = 14
RagdollInput.Parent = Frame

Instance.new("UICorner", RagdollInput).CornerRadius =
    UDim.new(0, 6)

--==================================================
-- START / STOP
--==================================================

local StartBtn = Instance.new("TextButton")
StartBtn.Position = UDim2.new(0, 15, 0, 165)
StartBtn.Size = UDim2.new(0.5, -20, 0, 35)
StartBtn.Text = "START"
StartBtn.BackgroundColor3 =
    Color3.fromRGB(40, 120, 40)
StartBtn.TextColor3 =
    Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = Frame

Instance.new("UICorner", StartBtn).CornerRadius =
    UDim.new(0, 6)

local StopBtn = Instance.new("TextButton")
StopBtn.Position = UDim2.new(0.5, 5, 0, 165)
StopBtn.Size = UDim2.new(0.5, -20, 0, 35)
StopBtn.Text = "STOP"
StopBtn.BackgroundColor3 =
    Color3.fromRGB(120, 40, 40)
StopBtn.TextColor3 =
    Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = Frame

Instance.new("UICorner", StopBtn).CornerRadius =
    UDim.new(0, 6)

--==================================================
-- STATS
--==================================================

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Position = UDim2.new(0, 15, 0, 210)
StatsLabel.Size = UDim2.new(1, -30, 0, 25)
StatsLabel.BackgroundColor3 =
    Color3.fromRGB(20, 20, 20)
StatsLabel.TextColor3 =
    Color3.fromRGB(200, 200, 200)
StatsLabel.Text =
    "Time: 00:00 | Ragdolls: 0 | Resets: 0"
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.Parent = Frame

Instance.new("UICorner", StatsLabel).CornerRadius =
    UDim.new(0, 4)

--==================================================
-- INFINITE YIELD
--==================================================

local IY = Instance.new("TextButton")
IY.Position = UDim2.new(0, 15, 0, 260)
IY.Size = UDim2.new(1, -30, 0, 30)
IY.Text = "Execute Infinite Yield"
IY.BackgroundColor3 =
    Color3.fromRGB(60, 60, 60)
IY.TextColor3 =
    Color3.fromRGB(255, 255, 255)
IY.Font = Enum.Font.GothamBold
IY.TextSize = 13
IY.Parent = Frame

Instance.new("UICorner", IY).CornerRadius =
    UDim.new(0, 6)

--==================================================
-- NOTIFICATIONS
--==================================================

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "KS Helper",
            Text = message,
            Duration = 3
        })
    end)
end

--==================================================
-- VARIABLES
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

local arenaWorkerId = 0

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
    local startTime = stats_StartTime

    while helperRunning
        and stats_StartTime == startTime do

        local activeTime =
            math.floor(os.clock() - startTime)

        local mins =
            math.floor(activeTime / 60)

        local secs =
            activeTime % 60

        StatsLabel.Text = string.format(
            "Time: %02d:%02d | Ragdolls: %d | Resets: %d",
            mins,
            secs,
            stats_Ragdolls,
            stats_Resets
        )

        task.wait(1)
    end
end

--==================================================
-- CHARACTER HELPERS
--==================================================

local function getCharacter(player)
    if not player then
        return nil
    end

    local character = player.Character

    if character and character.Parent then
        return character
    end

    return nil
end

local function getHumanoid(character)
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

local function getRootPart(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- OUR ARENA CHECK
--==================================================

local function isPlayerInArena(player)
    local character =
        getCharacter(player)

    if not character then
        return false
    end

    local isInArena =
        character:FindFirstChild("isInArena")

    if not isInArena then
        return false
    end

    return isInArena.Value == true
end

--==================================================
-- ORIGINAL TARGET CHECK
--==================================================

local function isTargetReady(player)

    if not player
        or player.Parent ~= Players then

        return false
    end

    local targetCharacter =
        player.Character

    if not targetCharacter then
        return false
    end

    local isTargetInArena =
        targetCharacter:FindFirstChild("isInArena")

    local targetHumanoid =
        targetCharacter:FindFirstChildOfClass("Humanoid")

    local targetRoot =
        targetCharacter:FindFirstChild("HumanoidRootPart")

        if not isTargetInArena
        or not targetRoot
        or not targetHumanoid
        or targetHumanoid.Health <= 0 then

        return false
    end

    if not isTargetInArena.Value then
        return false
    end

    return true
end

--==================================================
-- GET TARGET
--==================================================

local function getValidTarget()

    if targetMode ~= "Player" then
        return nil
    end

    if not targetPlayer
        or targetPlayer.Parent ~= Players then

        return nil
    end

    local targetCharacter =
        targetPlayer.Character

    if not targetCharacter then
        return nil
    end

    local targetHumanoid =
        targetCharacter:FindFirstChildOfClass("Humanoid")

    local targetRoot =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    local targetIsInArena =
        targetCharacter:FindFirstChild("isInArena")

    local targetKillstreak =
        targetCharacter:FindFirstChild("KillstreakLevel")

    if not targetIsInArena
        or not targetRoot
        or not targetHumanoid
        or targetHumanoid.Health <= 0 then

        return nil
    end

    if not targetKillstreak
        and not targetIsInArena.Value then

        return nil
    end

    return targetCharacter,
        targetHumanoid,
        targetRoot
end

--==================================================
-- PLAYER SEARCH
--==================================================

local function findPlayer(input)
    input = tostring(input or ""):gsub("^%s*(.-)%s*$", "%1")
    if input == "" then return nil end

    if tonumber(input) then
        local success, player = pcall(function()
            return Players:GetPlayerByUserId(tonumber(input))
        end)
        if success and player then
            return player
        end
    end

    local lowerInput = input:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == lowerInput or player.DisplayName:lower() == lowerInput then
            return player
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(lowerInput, 1, true) or player.DisplayName:lower():find(lowerInput, 1, true) then
            return player
        end
    end

    return nil
end

--==================================================
-- TARGET MODE
--==================================================

ModeBtn.MouseButton1Click:Connect(function()

    if targetMode == "Player" then

        targetMode = "Position"

        ModeBtn.Text =
            "Target: Saved Position"

        ModeBtn.BackgroundColor3 =
            Color3.fromRGB(150, 100, 40)

        PlayerTextBox.Visible = false
        PosFrame.Visible = true

    else

        targetMode = "Player"

        ModeBtn.Text =
            "Target: Player"

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

    local character =
        getCharacter(LocalPlayer)

    if not character then
        notify("Character not found.")
        return
    end

    local rootPart =
        getRootPart(character)

    if not rootPart then
        notify("HumanoidRootPart not found.")
        return
    end

    if not isPlayerInArena(LocalPlayer) then
        notify("You must be in the arena to save a position.")
        return
    end

    savedCFrame =
        rootPart.CFrame

    PosLabel.Text = string.format(
        "%.1f, %.1f, %.1f",
        savedCFrame.X,
        savedCFrame.Y,
        savedCFrame.Z
    )

    PosLabel.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    notify("Position saved successfully.")
end)

--==================================================
-- RAGDOLL INPUT
--==================================================

RagdollInput.FocusLost:Connect(function()

    local num =
        tonumber(RagdollInput.Text)

    if num and num > 0 then

        ragdollLimit =
            math.floor(num)

        RagdollInput.Text =
            tostring(ragdollLimit)

    else

        RagdollInput.Text =
            tostring(ragdollLimit)

        notify("Invalid ragdoll limit.")
    end
end)

--==================================================
-- AUTO RESET
--==================================================

ToggleReset.MouseButton1Click:Connect(function()

    autoResetEnabled =
        not autoResetEnabled

    if autoResetEnabled then

        ToggleReset.Text =
            "Auto-Reset: ON"

        ToggleReset.BackgroundColor3 =
            Color3.fromRGB(40, 120, 40)

    else

        ToggleReset.Text =
            "Auto-Reset: OFF"

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

    local success =
        pcall(function()

            loadstring(
                game:HttpGet(
                    "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
                )
            )()

        end)

    if not success then
        notify("Failed to load Infinite Yield.")
    end
end)

--==================================================
-- BRAZIL PARTS
--==================================================

pcall(function()

    local lobby =
        workspace:WaitForChild("Lobby")

    local brazil =
        lobby:WaitForChild("brazil")

    for _, part in ipairs(
        brazil:GetDescendants()
    ) do

        if part:IsA("BasePart") then
            part.CanTouch = false
        end
    end
end)

--==================================================
-- PORTAL
--==================================================

local function getPortal()

    local lobby =
        workspace:FindFirstChild("Lobby")

    if not lobby then
        return nil
    end

    local portal =
        lobby:FindFirstChild("Teleport1")

    if portal
        and portal:IsA("BasePart") then

        return portal
    end

    return nil
end

local function triggerPortal(rootPart)

    if not rootPart then
        return false
    end

    local portal =
        getPortal()

    if not portal then
        return false
    end

    if firetouchinterest then

        local success, err =
            pcall(function()

                firetouchinterest(
                    rootPart,
                    portal,
                    0
                )

                task.wait(0.05)

                firetouchinterest(
                    rootPart,
                    portal,
                    1
                )
            end)

        if not success then
            warn(
                "[KS Helper] firetouchinterest failed: "
                .. tostring(err)
            )

            return false
        end

        return true
    end

    return false
end

--==================================================
-- ENTER ARENA
--==================================================

local function enterArena(workerId)
    while helperRunning and workerId == arenaWorkerId do
        -- Controlla prima se il target esiste ed è valido
        if not targetPlayer or targetPlayer.Parent ~= Players then
            task.wait(0.5)
            continue
        end

        local targetCharacter = targetPlayer.Character
        local targetIsInArena = targetCharacter and targetCharacter:FindFirstChild("isInArena")

        -- SE IL TARGET NON È IN ARENA, NON FARE NULLA E ASPETTA
        if not targetIsInArena or not targetIsInArena.Value then
            task.wait(0.5)
            continue
        end

        -- Se il target è in arena, controlla il nostro personaggio
        local character = getCharacter(LocalPlayer)
        if not character then
            task.wait(0.2)
            continue
        end

        local humanoid = getHumanoid(character)
        local rootPart = getRootPart(character)

        if not humanoid or humanoid.Health <= 0 or not rootPart then
            task.wait(0.2)
            continue
        end

        local isInArena = character:FindFirstChild("isInArena")
        if isInArena and isInArena.Value then
            return -- Già dentro, il follow loop penserà a teletrasportarlo sul target
        end

        -- Tocca il portale solo ora che il target è dentro l'arena
        local touched = triggerPortal(rootPart)
        if not touched then
            task.wait(0.2)
            continue
        end

        task.wait(0.2)
    end
end

--==================================================
-- FOLLOW TARGET
-- Based on original main.luau
--==================================================

local function followLoop()

    while helperRunning
        and (
            targetMode == "Position"
            or targetPlayer
        ) do

        --==================================================
        -- LOCAL CHARACTER
        --==================================================

        local character =
            LocalPlayer.Character

        if not character then
            task.wait()
            continue
        end

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

        if not humanoid
            or humanoid.Health <= 0 then

            task.wait()
            continue
        end

        --==================================================
        -- LOCAL ARENA
        --==================================================

        local isInArena =
            character:FindFirstChild("isInArena")

        if not isInArena
            or not isInArena.Value then

            task.wait()
            continue
        end

        --==================================================
        -- LOCAL ROOT
        --==================================================

        local rootPart =
            character:FindFirstChild("HumanoidRootPart")

        if not rootPart then
            task.wait()
            continue
        end

        --==================================================
        -- RAGDOLL
        --==================================================

        local ragdolled =
            character:FindFirstChild("Ragdolled")

        local isCurrentlyRagdolled =
            ragdolled
            and ragdolled:IsA("BoolValue")
            and ragdolled.Value

        --==================================================
        -- RAGDOLL COUNT
        --==================================================

        if isCurrentlyRagdolled
            and not wasRagdolled then

            wasRagdolled = true

            currentRagdolls += 1
            stats_Ragdolls += 1

        elseif not isCurrentlyRagdolled then

            wasRagdolled = false
        end

        --==================================================
        -- AUTO RESET
        --==================================================

        if isCurrentlyRagdolled
            and autoResetEnabled
            and currentRagdolls >= ragdollLimit
            and not alreadyReset then

            local resetEvent =
                LocalPlayer:FindFirstChild("Reset")

            if resetEvent then

                local success, err =
                    pcall(function()
                        resetEvent:FireServer()
                    end)

                if success then

                    alreadyReset = true

                    currentRagdolls = 0
                    stats_Resets += 1

                else

                    warn(
                        "[KS Helper] Reset failed: "
                        .. tostring(err)
                    )
                end
            end
        end

        if not isCurrentlyRagdolled then
            alreadyReset = false
        end

        if alreadyReset then
            task.wait()
            continue
        end

        --==================================================
        -- PLAYER TARGET
        --==================================================

        if targetMode == "Player" then

            local targetCharacter, targetHumanoid, targetRoot = getValidTarget()

            if not targetCharacter or not targetRoot then
                task.wait()
                continue
            end

            if not isCurrentlyRagdolled then

                pcall(function()

                    rootPart.CFrame =
                        targetRoot.CFrame
                        * CFrame.new(0, 0, -4)

                end)
            end

                --==================================================
        -- POSITION MODE
        --==================================================

        elseif targetMode == "Position" then

            if savedCFrame
                and not isCurrentlyRagdolled then

                pcall(function()

                    rootPart.CFrame =
                        savedCFrame

                end)
            end
        end

        task.wait()
    end
end

--==================================================
-- START
--==================================================

StartBtn.MouseButton1Click:Connect(function()

    if helperRunning then
        return
    end

    --==================================================
    -- PLAYER MODE
    --==================================================

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

        if player == LocalPlayer then
            notify("You cannot target yourself.")
            return
        end

        targetPlayer = player

    --==================================================
    -- POSITION MODE
    --==================================================

    elseif targetMode == "Position" then

        if not savedCFrame then
            notify("You need to save a position first.")
            return
        end
    end

    --==================================================
    -- START STATE
    --==================================================

    helperRunning = true

    currentRagdolls = 0
    wasRagdolled = false
    alreadyReset = false

    stats_StartTime =
        os.clock()

    resetStatsUI()

    arenaWorkerId += 1

    local workerId =
        arenaWorkerId

    --==================================================
    -- START WORKERS
    --==================================================

    task.spawn(updateStatsLoop)

    task.spawn(followLoop)

    task.spawn(function()
        enterArena(workerId)
    end)

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

    -- Invalidate active arena workers.
    arenaWorkerId += 1

    notify("Helper stopped.")
end)

--==================================================
-- MINIMIZE
--==================================================

local isMinimized = false

Minimize.MouseButton1Click:Connect(function()

    isMinimized =
        not isMinimized

    if isMinimized then

        for _, child in ipairs(
            Frame:GetChildren()
        ) do

            if child ~= Title
                and child ~= Close
                and child ~= Minimize
                and not child:IsA("UICorner")
                and not child:IsA("UIStroke") then

                child.Visible = false
            end
        end

        Frame.Size =
            UDim2.new(0, 300, 0, 35)

    else

        for _, child in ipairs(
            Frame:GetChildren()
        ) do

            if child ~= Title
                and child ~= Close
                and child ~= Minimize
                and not child:IsA("UICorner")
                and not child:IsA("UIStroke") then

                child.Visible = true
            end
        end

        PlayerTextBox.Visible =
            targetMode == "Player"

        PosFrame.Visible =
            targetMode == "Position"

        Frame.Size =
            UDim2.new(0, 300, 0, 310)
    end
end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()

    helperRunning = false

    arenaWorkerId += 1

    if ScreenGui then
        ScreenGui:Destroy()
    end

    getgenv().KsHelper_Loaded = nil
end)

--==================================================
-- CHARACTER ADDED
--==================================================

LocalPlayer.CharacterAdded:Connect(function(character)

    if not helperRunning then
        return
    end

    -- Invalidate previous worker.
    arenaWorkerId += 1

    local workerId =
        arenaWorkerId

    alreadyReset = false
    wasRagdolled = false
    currentRagdolls = 0

    task.spawn(function()

        local root =
            character:WaitForChild(
                "HumanoidRootPart",
                10
            )

        if not root then
            return
        end

        task.wait(0.2)

        if not helperRunning
            or workerId ~= arenaWorkerId then

            return
        end

        -- Directly use Teleport1 again after respawn.
        enterArena(workerId)
    end)
end)