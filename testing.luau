-- =========================================================
-- ESP UI
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- GitHub images
local VISIBLE_IMAGE =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_IMAGE =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"


-- =========================================================
-- UI ROOT
-- =========================================================

local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPInterface"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 2147483646
-- Impostato il Parent corretto per farlo apparire nello schermo (CoreGui)
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
espGui.Parent = success and coreGui or Players.LocalPlayer:WaitForChild("PlayerGui")


-- =========================================================
-- MAIN FRAME
-- =========================================================

local main = Instance.new("Frame")
main.Name = "ESPPanel"
main.Size = UDim2.new(0, 330, 0, 76)
main.Position = UDim2.new(0, 20, 0, 170)

main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
main.BackgroundTransparency = 0.08

main.Active = true
main.Parent = espGui


local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main


-- =========================================================
-- INTERNAL GRADIENT
-- =========================================================

local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.05),
    NumberSequenceKeypoint.new(1, 0.35)
})
gradient.Parent = main


-- =========================================================
-- BORDER
-- =========================================================

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.35
stroke.Color = Color3.fromRGB(90, 90, 90)
stroke.Parent = main


-- =========================================================
-- IMAGE
-- =========================================================

local image = Instance.new("ImageLabel")
image.Name = "ESPImage"

image.Size = UDim2.new(0, 52, 0, 52)
image.Position = UDim2.new(0, 12, 0.5, -26)

image.BackgroundTransparency = 1
image.ScaleType = Enum.ScaleType.Crop

image.Parent = main


local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(0, 9)
imageCorner.Parent = image


-- =========================================================
-- TITLE
-- =========================================================

local title = Instance.new("TextLabel")
title.Name = "Title"

title.Size = UDim2.new(0, 100, 0, 25)
title.Position = UDim2.new(0, 76, 0, 9)

title.BackgroundTransparency = 1
title.Text = "ESP"

title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextSize = 17
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left

title.Parent = main


-- =========================================================
-- PATH TEXTBOX
-- =========================================================

local pathBox = Instance.new("TextBox")
pathBox.Name = "PathBox"

pathBox.Size = UDim2.new(1, -135, 0, 24)
pathBox.Position = UDim2.new(0, 76, 1, -30)

pathBox.BackgroundTransparency = 1

pathBox.Text = ""
pathBox.PlaceholderText = "Path..."
pathBox.PlaceholderColor3 = Color3.fromRGB(125, 125, 125)

pathBox.TextColor3 = Color3.fromRGB(220, 220, 220)
pathBox.TextSize = 12
pathBox.Font = Enum.Font.Gotham

pathBox.TextXAlignment = Enum.TextXAlignment.Left
pathBox.ClearTextOnFocus = false

pathBox.Parent = main


-- =========================================================
-- UNDERLINE
-- =========================================================

local line = Instance.new("Frame")
line.Name = "PathLine"

line.Size = UDim2.new(1, -135, 0, 1)
line.Position = UDim2.new(0, 76, 1, -7)

line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
line.BackgroundTransparency = 0.35

line.BorderSizePixel = 0
line.Parent = main


-- =========================================================
-- TOGGLE CIRCLE
-- =========================================================

local toggle = Instance.new("TextButton")
toggle.Name = "ESPToggle"

toggle.Size = UDim2.new(0, 28, 0, 28)
toggle.Position = UDim2.new(1, -42, 0.5, -14)

toggle.BackgroundTransparency = 1

toggle.Text = "○"
toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
toggle.TextSize = 26
toggle.Font = Enum.Font.GothamMedium

toggle.AutoButtonColor = false
toggle.Parent = main


-- =========================================================
-- ESP FUNCTIONS (INTEGRATO)
-- =========================================================

local espEnabled = false
local activeHighlights = {}
local playerConnections = {}

local function applyHighlight(character)
    if not character or character:FindFirstChild("ESPHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(0, 200, 255) 
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    table.insert(activeHighlights, highlight)
end

local function startESP()
    local LocalPlayer = Players.LocalPlayer

    local function setupPlayer(player)
        if player == LocalPlayer then return end

        if player.Character then
            applyHighlight(player.Character)
        end

        local conn = player.CharacterAdded:Connect(function(char)
            if espEnabled then
                task.wait(0.1)
                applyHighlight(char)
            end
        end)
        table.insert(playerConnections, conn)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayer(player)
    end

    local joinConn = Players.PlayerAdded:Connect(setupPlayer)
    table.insert(playerConnections, joinConn)
end

local function stopESP()
    for _, conn in ipairs(playerConnections) do
        conn:Disconnect()
    end
    table.clear(playerConnections)

    for _, highlight in ipairs(activeHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(activeHighlights)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESPHighlight") then
            player.Character.ESPHighlight:Destroy()
        end
    end
end


-- =========================================================
-- TOGGLE
-- =========================================================

local function updateToggle()
    if espEnabled then

        toggle.Text = "●"
        toggle.TextColor3 = Color3.fromRGB(0, 200, 255)

        image.Image = VISIBLE_IMAGE

        stroke.Color = Color3.fromRGB(0, 200, 255)
        stroke.Transparency = 0.15

    else

        toggle.Text = "○"
        toggle.TextColor3 = Color3.fromRGB(220, 220, 220)

        image.Image = HIDDEN_IMAGE

        stroke.Color = Color3.fromRGB(90, 90, 90)
        stroke.Transparency = 0.35

    end
end


toggle.MouseButton1Click:Connect(function()

    espEnabled = not espEnabled

    if espEnabled then
        startESP()
    else
        stopESP()
    end

    updateToggle()

end)


-- =========================================================
-- MOBILE + PC DRAG
-- =========================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)

    local delta = input.Position - dragStart

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end


main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)

    end

end)


UserInputService.InputChanged:Connect(function(input)

    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        updateDrag(input)

    end

end)


-- =========================================================
-- INITIAL STATE
-- =========================================================

image.Image = HIDDEN_IMAGE
updateToggle()
