-- =========================================================
-- MOONDEX OBJECT ESP
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer


-- =========================================================
-- GITHUB IMAGES
-- =========================================================

local VISIBLE_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"


-- =========================================================
-- LOCAL IMAGE CACHE
-- =========================================================

local VISIBLE_FILE = "ShadowESP_Visible.png"
local HIDDEN_FILE = "ShadowESP_Hidden.png"

local function downloadImage(url, filename)

    if not (request or http_request) then
        return nil
    end

    local req = request or http_request

    local success, response = pcall(function()
        return req({
            Url = url,
            Method = "GET"
        })
    end)

    if not success or not response then
        return nil
    end

    if response.StatusCode ~= 200 then
        return nil
    end

    if not writefile then
        return nil
    end

    local ok = pcall(function()
        writefile(filename, response.Body)
    end)

    if not ok then
        return nil
    end

    if not getcustomasset and not getsynasset then
        return nil
    end

    local assetFunction = getcustomasset or getsynasset

    local asset

    pcall(function()
        asset = assetFunction(filename)
    end)

    return asset
end


local visibleImage
local hiddenImage


-- Try to load cached files first
if getcustomasset or getsynasset then

    local assetFunction = getcustomasset or getsynasset

    if isfile and isfile(VISIBLE_FILE) then
        pcall(function()
            visibleImage = assetFunction(VISIBLE_FILE)
        end)
    end

    if isfile and isfile(HIDDEN_FILE) then
        pcall(function()
            hiddenImage = assetFunction(HIDDEN_FILE)
        end)
    end
end


-- Download only if not already cached
if not visibleImage then
    visibleImage = downloadImage(VISIBLE_URL, VISIBLE_FILE)
end

if not hiddenImage then
    hiddenImage = downloadImage(HIDDEN_URL, HIDDEN_FILE)
end


-- =========================================================
-- GUI
-- =========================================================

local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPInterface"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 2147483646

pcall(function()
    espGui.Parent = CoreGui
end)

if not espGui.Parent then
    espGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end


-- =========================================================
-- MAIN
-- =========================================================

local main = Instance.new("Frame")
main.Name = "ESPPanel"

main.Size = UDim2.new(0, 330, 0, 76)
main.Position = UDim2.new(0, 20, 0, 170)

main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
main.BackgroundTransparency = 0.08

main.BorderSizePixel = 0
main.Active = true

main.Parent = espGui


-- Rounded corners
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
    NumberSequenceKeypoint.new(0.55, 0.15),
    NumberSequenceKeypoint.new(1, 0.45)
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
image.BorderSizePixel = 0

image.ScaleType = Enum.ScaleType.Crop

image.Parent = main


local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(0, 9)
imageCorner.Parent = image


-- =========================================================
-- IMAGE INNER BORDER
-- =========================================================

local imageStroke = Instance.new("UIStroke")

imageStroke.Thickness = 1
imageStroke.Transparency = 0.45
imageStroke.Color = Color3.fromRGB(80, 80, 80)

imageStroke.Parent = image


-- =========================================================
-- TITLE
-- =========================================================

local title = Instance.new("TextLabel")

title.Name = "Title"

title.Size = UDim2.new(0, 100, 0, 24)
title.Position = UDim2.new(0, 76, 0, 8)

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

pathBox.Size = UDim2.new(1, -135, 0, 23)
pathBox.Position = UDim2.new(0, 76, 1, -31)

pathBox.BackgroundTransparency = 1
pathBox.BorderSizePixel = 0

pathBox.Text = ""
pathBox.PlaceholderText = "MoonDex path..."
pathBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)

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
line.Position = UDim2.new(0, 76, 1, -7)

line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
line.BackgroundTransparency = 0.35

line.BorderSizePixel = 0

line.Parent = main


-- =========================================================
-- TOGGLE BUTTON
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
-- ESP DATA
-- =========================================================

local espEnabled = false

local currentHighlights = {}


-- =========================================================
-- PATH RESOLVER
-- =========================================================

local function resolvePath(path)

    if not path or path == "" then
        return nil
    end

    path = path:gsub("^%s+", "")
    path = path:gsub("%s+$", "")

    -- Remove common prefixes
    path = path:gsub("^game%.", "")
    path = path:gsub("^Game%.", "")

    local parts = {}

    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end

    if #parts == 0 then
        return nil
    end

    local first = parts[1]

    local current

    -- workspace
    if first == "workspace" or first == "Workspace" then
        current = workspace

    -- CoreGui
    elseif first == "CoreGui" then
        current = CoreGui

    -- Players
    elseif first == "Players" then
        current = Players

    -- LocalPlayer
    elseif first == "LocalPlayer" then
        current = LocalPlayer

    -- ReplicatedStorage
    elseif first == "ReplicatedStorage" then
        current = game:GetService("ReplicatedStorage")

    -- StarterGui
    elseif first == "StarterGui" then
        current = game:GetService("StarterGui")

    -- Lighting
    elseif first == "Lighting" then
        current = game:GetService("Lighting")

    -- Direct service
    else
        local serviceSuccess, service = pcall(function()
            return game:GetService(first)
        end)

        if serviceSuccess and service then
            current = service
        else
            current = game:FindFirstChild(first)
        end
    end

    if not current then
        return nil
    end

    for i = 2, #parts do

        local childName = parts[i]

        local nextObject = current:FindFirstChild(childName)

        if not nextObject then
            return nil
        end

        current = nextObject
    end

    return current
end


-- =========================================================
-- CREATE HIGHLIGHT
-- =========================================================

local function createHighlight(object)

    if not object then
        return
    end

    -- Remove old highlight from this object
    local existing = object:FindFirstChild("ShadowESPHighlight")

    if existing then
        existing:Destroy()
    end


    -- Model
    if object:IsA("Model") or object:IsA("BasePart") then

        local highlight = Instance.new("Highlight")

        highlight.Name = "ShadowESPHighlight"
        highlight.Adornee = object

        highlight.FillColor = Color3.fromRGB(0, 200, 255)
        highlight.FillTransparency = 0.5

        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0

        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        highlight.Parent = object

        table.insert(currentHighlights, highlight)

        return
    end


    -- Folder / container
    if object:IsA("Folder") then

        for _, descendant in ipairs(object:GetDescendants()) do

            if descendant:IsA("Model") then

                local highlight = Instance.new("Highlight")

                highlight.Name = "ShadowESPHighlight"
                highlight.Adornee = descendant

                highlight.FillColor = Color3.fromRGB(0, 200, 255)
                highlight.FillTransparency = 0.5

                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0

                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                highlight.Parent = descendant

                table.insert(currentHighlights, highlight)

            elseif descendant:IsA("BasePart") then

                local highlight = Instance.new("Highlight")

                highlight.Name = "ShadowESPHighlight"
                highlight.Adornee = descendant

                highlight.FillColor = Color3.fromRGB(0, 200, 255)
                highlight.FillTransparency = 0.5

                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0

                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                highlight.Parent = descendant

                table.insert(currentHighlights, highlight)
            end
        end
    end
end


-- =========================================================
-- REMOVE ESP
-- =========================================================

local function removeESP()

    for _, highlight in ipairs(currentHighlights) do

        if highlight and highlight.Parent then
            highlight:Destroy()
        end

    end

    table.clear(currentHighlights)
end


-- =========================================================
-- START ESP
-- =========================================================

local function startESP()

    removeESP()

    local path = pathBox.Text

    local target = resolvePath(path)

    if not target then

        pathBox.TextColor3 = Color3.fromRGB(255, 100, 100)

        task.delay(1.2, function()

            if pathBox then
                pathBox.TextColor3 = Color3.fromRGB(220, 220, 220)
            end

        end)

        return false
    end

    createHighlight(target)

    return #currentHighlights > 0
end


-- =========================================================
-- UPDATE UI
-- =========================================================

local function updateToggle()

    if espEnabled then

        toggle.Text = "●"

        toggle.TextColor3 = Color3.fromRGB(0, 200, 255)

        stroke.Color = Color3.fromRGB(0, 200, 255)
        stroke.Transparency = 0.08

        imageStroke.Color = Color3.fromRGB(0, 200, 255)
        imageStroke.Transparency = 0.05

        if visibleImage then
            image.Image = visibleImage
        end

    else

        toggle.Text = "○"

        toggle.TextColor3 = Color3.fromRGB(220, 220, 220)

        stroke.Color = Color3.fromRGB(90, 90, 90)
        stroke.Transparency = 0.35

        imageStroke.Color = Color3.fromRGB(100, 100, 100)
        imageStroke.Transparency = 0.45

        if hiddenImage then
            image.Image = hiddenImage
        end

    end
end


-- =========================================================
-- TOGGLE
-- =========================================================

toggle.MouseButton1Click:Connect(function()

    if espEnabled then

        espEnabled = false

        removeESP()

        updateToggle()

    else

        -- Don't enable if there is no path
        if pathBox.Text == "" then

            pathBox.PlaceholderText = "Enter a MoonDex path"

            task.delay(1.5, function()

                if pathBox then
                    pathBox.PlaceholderText = "MoonDex path..."
                end

            end)

            return
        end

        local success = startESP()

        if success then

            espEnabled = true
            updateToggle()

        else

            espEnabled = false
            updateToggle()

        end
    end
end)


-- =========================================================
-- PATH CHANGED WHILE ESP IS ACTIVE
-- =========================================================

pathBox.FocusLost:Connect(function()

    if espEnabled then

        local success = startESP()

        if not success then
            espEnabled = false
            updateToggle()
        end

    end
end)


-- =========================================================
-- DRAG SYSTEM
-- =========================================================
-- Drag only from image/title/background.
-- The textbox and toggle remain clickable.

local dragging = false
local dragStart
local startPosition


local function beginDrag(input)

    dragging = true

    dragStart = input.Position
    startPosition = main.Position

end


local function updateDrag(input)

    if not dragging then
        return
    end

    local delta = input.Position - dragStart

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end


local function endDrag()

    dragging = false

end


-- Image can be used as drag handle
image.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        beginDrag(input)

    end

end)


-- Title can be used as drag handle
title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        beginDrag(input)

    end

end)


UserInputService.InputChanged:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        updateDrag(input)

    end

end)


UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        endDrag()

    end

end)


-- =========================================================
-- INITIAL STATE
-- =========================================================

if hiddenImage then
    image.Image = hiddenImage
end

updateToggle()