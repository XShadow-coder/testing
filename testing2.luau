local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ==========================================
-- UI
-- ==========================================

local gui = Instance.new("ScreenGui")
gui.Name = "MatchStateTester"
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 280)
frame.Position = UDim2.new(0, 20, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Match State Tester"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 10, 0, 40)
status.Size = UDim2.new(1, -20, 0, 25)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.Text = "Starting..."
status.Parent = frame

local labels = {}

local names = {
    "InBus",
    "Bus Detected",
    "Glider Detected",
    "Freefall Detected",
    "Ready Timer",
    "isMatchReady",
    "Humanoid State"
}

for i, name in ipairs(names) do
    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 12, 0, 68 + ((i - 1) * 27))
    label.Size = UDim2.new(1, -24, 0, 24)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Text = name .. ": false"
    label.Parent = frame

    labels[name] = label
end

local function setValue(name, value)
    local label = labels[name]
    if not label then return end

    label.Text = name .. ": " .. tostring(value)

    if value == true then
        label.TextColor3 = Color3.fromRGB(80, 220, 100)
    else
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end

-- ==========================================
-- SISTEMA STATO MATCH
-- ==========================================

local isMatchReady = false

local busDetected = false
local gliderDetected = false
local freefallDetected = false

local cycleId = 0
local readyTimerActive = false

local function resetMatchState()
    isMatchReady = false

    busDetected = false
    gliderDetected = false
    freefallDetected = false

    readyTimerActive = false
    cycleId = cycleId + 1

    status.Text = "Waiting..."
end

local function startReadyTimer(delayTime, expectedCycle, expectedCharacter)

    if readyTimerActive then
        return
    end

    readyTimerActive = true

    status.Text = "Timer: " .. delayTime .. "s"

    task.delay(delayTime, function()

        if expectedCycle ~= cycleId then
            readyTimerActive = false
            return
        end

        if player.Character ~= expectedCharacter then
            readyTimerActive = false
            return
        end

        if expectedCharacter:GetAttribute("InBus") == true then
            readyTimerActive = false
            return
        end

        local humanoid = expectedCharacter:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            readyTimerActive = false
            return
        end

        if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
            readyTimerActive = false
            return
        end

        isMatchReady = true
        readyTimerActive = false

        status.Text = "READY"
    end)
end

player.CharacterAdded:Connect(function(character)
    resetMatchState()

    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 5)

        if player.Character ~= character then
            return
        end

        if not humanoid then
            return
        end
    end)
end)

-- ==========================================
-- DETECTION
-- ==========================================

task.spawn(function()

    while task.wait(0.1) do

        local char = player.Character

        if not char then
            resetMatchState()
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            continue
        end

        local inBus = char:GetAttribute("InBus")
        local state = humanoid:GetState()
        local glider = char:FindFirstChild("Glider")

        -- UI
        setValue("InBus", inBus == true)
        setValue("Bus Detected", busDetected)
        setValue("Glider Detected", gliderDetected)
        setValue("Freefall Detected", freefallDetected)
        setValue("Ready Timer", readyTimerActive)
        setValue("isMatchReady", isMatchReady)

        labels["Humanoid State"].Text = "Humanoid State: " .. state.Name

        -- READY
        if isMatchReady then

            if inBus == true then
                status.Text = "New cycle detected"
                resetMatchState()
            end

            continue
        end

        -- BUS
        if inBus == true and not busDetected then

            busDetected = true
            gliderDetected = false
            freefallDetected = false
            readyTimerActive = false

            status.Text = "BUS detected"
        end

        -- GLIDER
        if busDetected
            and inBus == nil
            and glider
            and not gliderDetected then

            gliderDetected = true
            status.Text = "GLIDER detected"
        end

        -- FREEFALL
        if gliderDetected
            and state == Enum.HumanoidStateType.Freefall
            and not freefallDetected then

            freefallDetected = true
            status.Text = "FREEFALL detected"
        end

        -- FULL CYCLE
        if freefallDetected
            and state == Enum.HumanoidStateType.Running
            and inBus == nil
            and not readyTimerActive then

            status.Text = "Full cycle → waiting 5s"

            local thisCycle = cycleId

            startReadyTimer(
                5,
                thisCycle,
                char
            )

            continue
        end

        -- FALLBACK
        if not busDetected
            and not gliderDetected
            and not freefallDetected
            and state == Enum.HumanoidStateType.Running
            and inBus == nil
            and not readyTimerActive then

            status.Text = "Already on ground → waiting 0.5s"

            local thisCycle = cycleId

            startReadyTimer(
                0.5,
                thisCycle,
                char
            )
        end
    end
end)