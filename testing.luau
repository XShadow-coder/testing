-- =========================================================
-- ESP PANEL
-- MoonDex Path + GitHub Images
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- CONFIG
-- =========================================================

local VISIBLE_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"

local IMAGE_FOLDER = "ShadowESPAssets"

-- =========================================================
-- REQUEST
-- =========================================================

local httpRequest =
    request
    or http_request
    or (syn and syn.request)

local function downloadImage(url, fileName)

    if not httpRequest then
        return nil
    end

    local success, response = pcall(function()
        return httpRequest({
            Url = url,
            Method = "GET"
        })
    end)

    if not success or not response then
        return nil
    end

    if response.StatusCode and response.StatusCode ~= 200 then
        return nil
    end

    local body = response.Body

    if not body then
        return nil
    end

    if makefolder then
        pcall(function()
            makefolder(IMAGE_FOLDER)
        end)
    end

    local path = IMAGE_FOLDER .. "/" .. fileName

    if writefile then
        pcall(function()
            writefile(path, body)
        end)
    else
        return nil
    end

    return path
end

-- =========================================================
-- CUSTOM ASSET
-- =========================================================

local function getAsset(path)

    if not path then
        return nil
    end

    if getcustomasset then
        local success, result = pcall(function()
            return getcustomasset(path)
        end)

        if success then
            return result
        end
    end

    if getsynasset then
        local success, result = pcall(function()
            return getsynasset(path)
        end)

        if success then
            return result
        end
    end

    return nil
end

-- =========================================================
-- DOWNLOAD BOTH IMAGES BEFORE CREATING UI
-- =========================================================

local visibleFile = downloadImage(
    VISIBLE_URL,
    "visible.png"
)

local hiddenFile = downloadImage(
    HIDDEN_URL,
    "hidden.png"
)

local visibleAsset = getAsset(visibleFile)
local hiddenAsset = getAsset(hiddenFile)

-- =========================================================
-- UI ROOT
-- =========================================================

local espGui = Instance.new("ScreenGui")

espGui.Name = "ESPInterface"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 2147483646

local parent

pcall(function()
    parent = gethui()
end)

if not parent then
    parent = game:GetService("CoreGui")
end

if not parent then
    parent = LocalPlayer:WaitForChild("PlayerGui")
end

espGui.Parent = parent

-- =========================================================
-- MAIN PANEL
-- =========================================================

local main = Instance.new("Frame")

main.Name = "ESPPanel"
main.Size = UDim2.new(0, 330, 0, 76)
main.Position = UDim2.new(0, 20, 0, 170)

main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
main.BackgroundTransparency = 0.08

main.BorderSizePixel = 0

main.Parent = espGui

local mainCorner = Instance.new("UICorner")

mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- =========================================================
-- INNER GRADIENT
-- =========================================================

local gradient = Instance.new("UIGradient")

gradient.Rotation = 90

gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.03),
    NumberSequenceKeypoint.new(0.5, 0.10),
    NumberSequenceKeypoint.new(1, 0.38)
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
-- IMAGE CONTAINER
-- =========================================================

local imageContainer = Instance.new("Frame")

imageContainer.Name = "ImageContainer"

imageContainer.Size = UDim2.new(0, 52, 0, 52)
imageContainer.Position = UDim2.new(0, 12, 0.5, -26)

imageContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
imageContainer.BorderSizePixel = 0

imageContainer.ClipsDescendants = true

imageContainer.Parent = main

local imageContainerCorner = Instance.new("UICorner")

imageContainerCorner.CornerRadius = UDim.new(0, 9)
imageContainerCorner.Parent = imageContainer

-- =========================================================
-- PRELOADED VISIBLE IMAGE
-- =========================================================

local visibleImage = Instance.new("ImageLabel")

visibleImage.Name = "VisibleImage"

visibleImage.Size = UDim2.new(1, 0, 1, 0)
visibleImage.Position = UDim2.new(0, 0, 0, 0)

visibleImage.BackgroundTransparency = 1
visibleImage.BorderSizePixel = 0

visibleImage.ScaleType = Enum.ScaleType.Crop

visibleImage.Image = visibleAsset or VISIBLE_URL

visibleImage.Visible = false

visibleImage.Parent = imageContainer

local visibleCorner = Instance.new("UICorner")

visibleCorner.CornerRadius = UDim.new(0, 9)
visibleCorner.Parent = visibleImage

-- =========================================================
-- PRELOADED HIDDEN IMAGE
-- =========================================================

local hiddenImage = Instance.new("ImageLabel")

hiddenImage.Name = "HiddenImage"

hiddenImage.Size = UDim2.new(1, 0, 1, 0)
hiddenImage.Position = UDim2.new(0, 0, 0, 0)

hiddenImage.BackgroundTransparency = 1
hiddenImage.BorderSizePixel = 0

hiddenImage.ScaleType = Enum.ScaleType.Crop

hiddenImage.Image = hiddenAsset or HIDDEN_URL

hiddenImage.Visible = true

hiddenImage.Parent = imageContainer

local hiddenCorner = Instance.new("UICorner")

hiddenCorner.CornerRadius = UDim.new(0, 9)
hiddenCorner.Parent = hiddenImage

-- =========================================================
-- TITLE
-- =========================================================

local title = Instance.new("TextLabel")

title.Name = "Title"

title.Size = UDim2.new(0, 100, 0, 25)
title.Position = UDim2.new(0, 76, 0, 8)

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

pathBox.Size = UDim2.new(1, -135, 0, 23)
pathBox.Position = UDim2.new(0, 76, 1, -31)

pathBox.BackgroundTransparency = 1

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
-- PATH LINE
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
-- ESP TOGGLE
-- =========================================================

local toggle = Instance.new("TextButton")

toggle.Name = "ESPToggle"

toggle.Size = UDim2.new(0, 30, 0, 30)
toggle.Position = UDim2.new(1, -43, 0.5, -15)

toggle.BackgroundTransparency = 1

toggle.Text = "○"

toggle.TextColor3 = Color3.fromRGB(220, 220, 220)

toggle.TextSize = 27
toggle.Font = Enum.Font.GothamMedium

toggle.AutoButtonColor = false

toggle.Parent = main

-- =========================================================
-- ESP VARIABLES
-- =========================================================

local espEnabled = false
local currentHighlight = nil

local characterConnection
local ancestryConnection

-- =========================================================
-- RESOLVE MOONDEX PATH
-- =========================================================

local function resolvePath(path)

    if not path or path == "" then
        return nil
    end

    path = path:gsub("^%s+", "")
    path = path:gsub("%s+$", "")

    -- Remove quotes if MoonDex copied them
    path = path:gsub("^['\"]", "")
    path = path:gsub("['\"]$", "")

    -- Convert game.Workspace.X -> Workspace.X
    path = path:gsub("^game%.", "")

    -- Convert workspace.X -> Workspace.X
    path = path:gsub("^workspace%.", "Workspace.")

    local parts = {}

    for part in path:gmatch("[^%.]+") do
        part = part:gsub("^%[", "")
        part = part:gsub("%]$", "")
        part = part:gsub("^[\"']", "")
        part = part:gsub("[\"']$", "")

        if part ~= "" then
            table.insert(parts, part)
        end
    end

    if #parts == 0 then
        return nil
    end

    local current

    -- Services
    if parts[1] == "Workspace" then

        current = workspace
        table.remove(parts, 1)

    elseif parts[1] == "CoreGui" then

        current = game:GetService("CoreGui")
        table.remove(parts, 1)

    elseif parts[1] == "ReplicatedStorage" then

        current = game:GetService("ReplicatedStorage")
        table.remove(parts, 1)

    elseif parts[1] == "Players" then

        current = game:GetService("Players")
        table.remove(parts, 1)

    elseif parts[1] == "Lighting" then

        current = game:GetService("Lighting")
        table.remove(parts, 1)

    elseif parts[1] == "ReplicatedFirst" then

        current = game:GetService("ReplicatedFirst")
        table.remove(parts, 1)

    else

        -- If MoonDex gives something like:
        -- Workspace.Part
        current = workspace

    end

    for _, name in ipairs(parts) do

        if not current then
            return nil
        end

        current = current:FindFirstChild(name)

        if not current then
            return nil
        end
    end

    return current
end

-- =========================================================
-- CREATE HIGHLIGHT
-- =========================================================

local function removeHighlight()

    if currentHighlight then

        pcall(function()
            currentHighlight:Destroy()
        end)

        currentHighlight = nil
    end

end

local function createHighlight(target)

    removeHighlight()

    if not target then
        return false
    end

    if not target:IsA("Model")
        and not target:IsA("BasePart")
        and not target:IsA("Folder") then

        return false
    end

    local adornee = target

    -- Highlight works directly with Model/BasePart.
    -- If MoonDex gives a Folder, try to find a suitable object.
    if target:IsA("Folder") then

        adornee =
            target:FindFirstChildWhichIsA("Model", true)
            or target:FindFirstChildWhichIsA("BasePart", true)

        if not adornee then
            return false
        end

    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "ShadowESP"

    highlight.Adornee = adornee

    highlight.FillColor =
        Color3.fromRGB(0, 200, 255)

    highlight.FillTransparency = 0.5

    highlight.OutlineColor =
        Color3.fromRGB(255, 255, 255)

    highlight.OutlineTransparency = 0

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent = espGui

    currentHighlight = highlight

    return true
end

-- =========================================================
-- START ESP
-- =========================================================

local function startESP()

    local path = pathBox.Text

    local target = resolvePath(path)

    if not target then

        pathBox.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        return false
    end

    local success = createHighlight(target)

    if not success then

        pathBox.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        return false
    end

    pathBox.TextColor3 =
        Color3.fromRGB(220, 220, 220)

    -- Recreate if the target gets destroyed/recreated.
    if ancestryConnection then
        ancestryConnection:Disconnect()
    end

    ancestryConnection = target.AncestryChanged:Connect(function(_, parent)

        if espEnabled and not parent then

            task.defer(function()

                if not espEnabled then
                    return
                end

                local newTarget =
                    resolvePath(pathBox.Text)

                if newTarget then
                    createHighlight(newTarget)
                end

            end)

        end

    end)

    return true
end

-- =========================================================
-- STOP ESP
-- =========================================================

local function stopESP()

    removeHighlight()

    if characterConnection then
        characterConnection:Disconnect()
        characterConnection = nil
    end

    if ancestryConnection then
        ancestryConnection:Disconnect()
        ancestryConnection = nil
    end

end

-- =========================================================
-- UPDATE UI
-- =========================================================

local function updateUI()

    if espEnabled then

        -- Filled circle
        toggle.Text = "●"
        toggle.TextColor3 =
            Color3.fromRGB(0, 200, 255)

        -- INSTANT IMAGE SWITCH
        hiddenImage.Visible = false
        visibleImage.Visible = true

        -- Neon cyan border
        stroke.Color =
            Color3.fromRGB(0, 200, 255)

        stroke.Transparency = 0.05

        -- Slight glow effect
        stroke.Thickness = 1.5

    else

        -- Empty circle
        toggle.Text = "○"
        toggle.TextColor3 =
            Color3.fromRGB(220, 220, 220)

        -- INSTANT IMAGE SWITCH
        visibleImage.Visible = false
        hiddenImage.Visible = true

        -- Normal white/gray border
        stroke.Color =
            Color3.fromRGB(120, 120, 120)

        stroke.Transparency = 0.35

        stroke.Thickness = 1

    end

end

-- =========================================================
-- TOGGLE CLICK
-- =========================================================

toggle.MouseButton1Click:Connect(function()

    if not espEnabled then

        local target = resolvePath(pathBox.Text)

        if not target then

            pathBox.TextColor3 =
                Color3.fromRGB(255, 100, 100)

            return
        end

        espEnabled = true

        startESP()

    else

        espEnabled = false

        stopESP()

    end

    updateUI()

end)

-- =========================================================
-- PATH ENTER
-- =========================================================

pathBox.FocusLost:Connect(function(enterPressed)

    if not enterPressed then
        return
    end

    if not espEnabled then
        return
    end

    startESP()

end)

-- =========================================================
-- DRAG SYSTEM
-- =========================================================

local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)

    local delta =
        input.Position - dragStart

    main.Position =
        UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,

            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

end

main.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        -- Don't start dragging when interacting
        -- with the textbox or toggle.
        if input.Target == toggle
            or input.Target == pathBox then

            return
        end

        dragging = true

        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

main.InputChanged:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragInput = input

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if input == dragInput and dragging then

        updateDrag(input)

    end

end)

-- =========================================================
-- INITIAL STATE
-- =========================================================

espEnabled = false

updateUI()