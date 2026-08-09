-- =========================================================
-- ESP INTERFACE
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- GITHUB IMAGES
-- =========================================================

local VISIBLE_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"


-- =========================================================
-- IMAGE DOWNLOADER
-- =========================================================

local requestFunc = request or http_request
local assetFunc = getsynasset or getcustomasset

local function downloadImage(url, filename)

    if not requestFunc then
        warn("[ESP] request/http_request not found")
        return nil
    end

    if not assetFunc then
        warn("[ESP] getsynasset/getcustomasset not found")
        return nil
    end

    local folder = "ArceusXUIToggle"

    pcall(function()
        if not isfolder(folder) then
            makefolder(folder)
        end
    end)

    local path = folder .. "/" .. filename

    -- Usa il file già presente quando possibile
    local success, result = pcall(function()
        if isfile(path) then
            return assetFunc(path)
        end

        local response = requestFunc({
            Url = url,
            Method = "GET"
        })

        if not response then
            error("No response")
        end

        if response.StatusCode and response.StatusCode ~= 200 then
            error("HTTP " .. tostring(response.StatusCode))
        end

        if not response.Body then
            error("Empty response body")
        end

        writefile(path, response.Body)

        return assetFunc(path)
    end)

    if success then
        return result
    end

    warn("[ESP] Failed to load image:", filename, result)

    return nil
end


-- =========================================================
-- LOAD IMAGES
-- =========================================================

local visibleImage = downloadImage(
    VISIBLE_URL,
    "ESP_VISIBLE.png"
)

local hiddenImage = downloadImage(
    HIDDEN_URL,
    "ESP_HIDDEN.png"
)


-- =========================================================
-- UI ROOT
-- =========================================================

local espGui = Instance.new("ScreenGui")

espGui.Name = "ESPInterface"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 2147483646

local success, coreGui = pcall(function()
    return game:GetService("CoreGui")
end)

if success and coreGui then
    espGui.Parent = coreGui
else
    espGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end


-- =========================================================
-- MAIN FRAME
-- =========================================================

local main = Instance.new("Frame")

main.Name = "ESPPanel"
main.Size = UDim2.fromOffset(330, 76)
main.Position = UDim2.fromOffset(20, 170)

main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.08

main.BorderSizePixel = 0
main.Active = true

main.Parent = espGui


-- Rounded corners

local corner = Instance.new("UICorner")

corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main


-- =========================================================
-- INTERNAL FADE
-- =========================================================

local gradient = Instance.new("UIGradient")

gradient.Rotation = 90

gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.02),
    NumberSequenceKeypoint.new(0.5, 0.08),
    NumberSequenceKeypoint.new(1, 0.35)
})

gradient.Parent = main


-- =========================================================
-- BORDER
-- =========================================================

local stroke = Instance.new("UIStroke")

stroke.Thickness = 1
stroke.Transparency = 0.35
stroke.Color = Color3.fromRGB(100, 100, 100)

stroke.Parent = main


-- =========================================================
-- IMAGE CONTAINER
-- =========================================================

local imageContainer = Instance.new("Frame")

imageContainer.Name = "ImageContainer"

imageContainer.Size = UDim2.fromOffset(54, 54)
imageContainer.Position = UDim2.fromOffset(10, 11)

imageContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
imageContainer.BackgroundTransparency = 0.15

imageContainer.BorderSizePixel = 0

imageContainer.Parent = main


local imageContainerCorner = Instance.new("UICorner")

imageContainerCorner.CornerRadius = UDim.new(0, 10)
imageContainerCorner.Parent = imageContainer


-- =========================================================
-- IMAGE BORDER
-- =========================================================

local imageStroke = Instance.new("UIStroke")

imageStroke.Name = "ImageStroke"
imageStroke.Thickness = 1
imageStroke.Transparency = 0.4
imageStroke.Color = Color3.fromRGB(90, 90, 90)

imageStroke.Parent = imageContainer


-- =========================================================
-- IMAGE
-- =========================================================

local image = Instance.new("ImageLabel")

image.Name = "ESPImage"

image.Size = UDim2.fromScale(1, 1)
image.Position = UDim2.fromScale(0, 0)

image.BackgroundTransparency = 1

image.ScaleType = Enum.ScaleType.Fit

image.Parent = imageContainer


local imageCorner = Instance.new("UICorner")

imageCorner.CornerRadius = UDim.new(0, 10)
imageCorner.Parent = image


-- =========================================================
-- TITLE
-- =========================================================

local title = Instance.new("TextLabel")

title.Name = "Title"

title.Size = UDim2.fromOffset(110, 25)
title.Position = UDim2.fromOffset(76, 8)

title.BackgroundTransparency = 1

title.Text = "ESP"

title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextSize = 17
title.Font = Enum.Font.GothamMedium

title.TextXAlignment = Enum.TextXAlignment.Left

title.Parent = main


-- =========================================================
-- PATH BOX
-- =========================================================

local pathBox = Instance.new("TextBox")

pathBox.Name = "PathBox"

pathBox.Size = UDim2.new(1, -135, 0, 22)
pathBox.Position = UDim2.new(0, 76, 0, 34)

pathBox.BackgroundTransparency = 1

pathBox.Text = ""
pathBox.PlaceholderText = "Path..."
pathBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)

pathBox.TextColor3 = Color3.fromRGB(220, 220, 220)

pathBox.TextSize = 12
pathBox.Font = Enum.Font.Gotham

pathBox.TextXAlignment = Enum.TextXAlignment.Left

pathBox.ClearTextOnFocus = false

pathBox.Parent = main


-- =========================================================
-- PATH UNDERLINE
-- =========================================================

local line = Instance.new("Frame")

line.Name = "PathLine"

line.Size = UDim2.new(1, -135, 0, 1)
line.Position = UDim2.new(0, 76, 0, 59)

line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
line.BackgroundTransparency = 0.35

line.BorderSizePixel = 0

line.Parent = main


-- =========================================================
-- TOGGLE BUTTON
-- =========================================================

local toggle = Instance.new("TextButton")

toggle.Name = "ESPToggle"

toggle.Size = UDim2.fromOffset(28, 28)
toggle.Position = UDim2.new(1, -42, 0.5, -14)

toggle.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
toggle.BackgroundTransparency = 0

toggle.BorderSizePixel = 0

toggle.Text = ""

toggle.AutoButtonColor = false

toggle.Parent = main


local toggleCorner = Instance.new("UICorner")

toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggle


-- Toggle outline

local toggleStroke = Instance.new("UIStroke")

toggleStroke.Thickness = 1
toggleStroke.Color = Color3.fromRGB(130, 130, 130)
toggleStroke.Transparency = 0.15

toggleStroke.Parent = toggle


-- =========================================================
-- TOGGLE INNER DOT
-- =========================================================

local toggleDot = Instance.new("Frame")

toggleDot.Name = "Dot"

toggleDot.AnchorPoint = Vector2.new(0.5, 0.5)
toggleDot.Position = UDim2.fromScale(0.5, 0.5)

toggleDot.Size = UDim2.fromOffset(0, 0)

toggleDot.BackgroundColor3 = Color3.fromRGB(0, 200, 255)

toggleDot.BorderSizePixel = 0

toggleDot.Parent = toggle


local dotCorner = Instance.new("UICorner")

dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = toggleDot


-- =========================================================
-- ESP SYSTEM
-- =========================================================

local espEnabled = false

local activeHighlights = {}
local playerConnections = {}


-- =========================================================
-- APPLY HIGHLIGHT
-- =========================================================

local function applyHighlight(character)

    if not espEnabled then
        return
    end

    if not character then
        return
    end

    if character:FindFirstChild("ESPHighlight") then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "ESPHighlight"

    highlight.Adornee = character

    highlight.FillColor = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency = 0.5

    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent = character

    table.insert(activeHighlights, highlight)
end


-- =========================================================
-- SETUP PLAYER
-- =========================================================

local function setupPlayer(player)

    if player == LocalPlayer then
        return
    end

    if player.Character then
        applyHighlight(player.Character)
    end

    local connection = player.CharacterAdded:Connect(function(character)

        if not espEnabled then
            return
        end

        task.wait(0.1)

        applyHighlight(character)

    end)

    table.insert(playerConnections, connection)
end


-- =========================================================
-- START ESP
-- =========================================================

local function startESP()

    -- Safety cleanup
    for _, connection in ipairs(playerConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(playerConnections)

    -- Existing players

    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayer(player)
    end

    -- New players

    local connection = Players.PlayerAdded:Connect(function(player)

        if espEnabled then
            setupPlayer(player)
        end

    end)

    table.insert(playerConnections, connection)
end


-- =========================================================
-- STOP ESP
-- =========================================================

local function stopESP()

    -- Disconnect events

    for _, connection in ipairs(playerConnections) do

        pcall(function()
            connection:Disconnect()
        end)

    end

    table.clear(playerConnections)


    -- Remove tracked highlights

    for _, highlight in ipairs(activeHighlights) do

        if highlight and highlight.Parent then
            highlight:Destroy()
        end

    end

    table.clear(activeHighlights)


    -- Safety cleanup

    for _, player in ipairs(Players:GetPlayers()) do

        if player.Character then

            local highlight =
                player.Character:FindFirstChild("ESPHighlight")

            if highlight then
                highlight:Destroy()
            end

        end

    end

end


-- =========================================================
-- UPDATE UI
-- =========================================================

local function updateToggle()

    if espEnabled then

        -- Image

        if visibleImage then
            image.Image = visibleImage
        end


        -- Main border

        stroke.Color = Color3.fromRGB(0, 200, 255)
        stroke.Transparency = 0.05


        -- Image border

        imageStroke.Color = Color3.fromRGB(0, 200, 255)
        imageStroke.Transparency = 0


        -- Toggle

        toggleStroke.Color = Color3.fromRGB(0, 200, 255)
        toggleStroke.Transparency = 0


        -- Dot

        toggleDot.Size = UDim2.fromOffset(16, 16)

        toggleDot.BackgroundColor3 =
            Color3.fromRGB(0, 200, 255)

    else

        -- Image

        if hiddenImage then
            image.Image = hiddenImage
        end


        -- Main border

        stroke.Color = Color3.fromRGB(90, 90, 90)
        stroke.Transparency = 0.35


        -- Image border

        imageStroke.Color = Color3.fromRGB(100, 100, 100)
        imageStroke.Transparency = 0.4


        -- Toggle

        toggleStroke.Color = Color3.fromRGB(130, 130, 130)
        toggleStroke.Transparency = 0.15


        -- Dot

        toggleDot.Size = UDim2.fromOffset(0, 0)

    end

end


-- =========================================================
-- TOGGLE CLICK
-- =========================================================

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

    if not dragging then
        return
    end

    local delta =
        input.Position - dragStart

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,

        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end


-- Start dragging only when clicking the panel,
-- NOT the toggle or textbox.

main.InputBegan:Connect(function(input)

    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    -- Don't start dragging from toggle

    if input.Target == toggle
    or input.Target == toggleDot then
        return
    end

    -- Don't start dragging while editing textbox

    if input.Target == pathBox then
        return
    end


    dragging = true

    dragStart = input.Position

    startPosition = main.Position


    input.Changed:Connect(function()

        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end

    end)

end)


UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        updateDrag(input)

    end

end)


-- =========================================================
-- INITIAL STATE
-- =========================================================

espEnabled = false

updateToggle()


-- =========================================================
-- DONE
-- =========================================================

print("[Arceus X ESP] Interface loaded")