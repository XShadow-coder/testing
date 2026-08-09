-- =========================================================
-- SHADOW ESP
-- MoonDex Path ESP + GitHub Cached Images
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- IMAGE URLS
-- =========================================================

local VISIBLE_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"

-- =========================================================
-- DOWNLOAD FUNCTION
-- =========================================================

local function getImage(url, fileName)

    local folder = "ArceusXUIToggle"
    local path = folder .. "/" .. fileName

    if not isfolder(folder) then
        pcall(function()
            makefolder(folder)
        end)
    end

    if isfile(path) then
        local success, asset = pcall(function()
            return getcustomasset(path)
        end)

        if success then
            return asset
        end
    end

    local httpRequest =
        request
        or http_request
        or (syn and syn.request)

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

    if response.Body then

        local writeSuccess = pcall(function()
            writefile(path, response.Body)
        end)

        if writeSuccess then

            local assetSuccess, asset =
                pcall(function()
                    return getcustomasset(path)
                end)

            if assetSuccess then
                return asset
            end

        end

    end

    return nil
end

-- =========================================================
-- LOAD IMAGES
-- =========================================================

local visibleAsset =
    getImage(VISIBLE_URL, "visible.png")

local hiddenAsset =
    getImage(HIDDEN_URL, "hidden.png")

-- =========================================================
-- UI PARENT
-- =========================================================

local targetParent

pcall(function()
    targetParent = gethui()
end)

if not targetParent then
    targetParent = game:GetService("CoreGui")
end

if not targetParent then
    targetParent = LocalPlayer:WaitForChild("PlayerGui")
end

-- =========================================================
-- CREATE GUI
-- =========================================================

local espGui = Instance.new("ScreenGui")

espGui.Name = "ShadowESPInterface"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 2147483646
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

espGui.Parent = targetParent

-- =========================================================
-- MAIN PANEL
-- =========================================================

local main = Instance.new("Frame")

main.Name = "ESPPanel"

main.Size = UDim2.fromOffset(330, 76)
main.Position = UDim2.fromOffset(20, 170)

main.BackgroundColor3 =
    Color3.fromRGB(12, 12, 16)

main.BackgroundTransparency = 0

main.BorderSizePixel = 0

main.Active = true

main.Parent = espGui

-- =========================================================
-- MAIN CORNER
-- =========================================================

local mainCorner = Instance.new("UICorner")

mainCorner.CornerRadius =
    UDim.new(0, 12)

mainCorner.Parent = main

-- =========================================================
-- INTERNAL GRADIENT
-- =========================================================

local gradient = Instance.new("UIGradient")

gradient.Color = ColorSequence.new({

    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(7, 7, 10)
    ),

    ColorSequenceKeypoint.new(
        0.5,
        Color3.fromRGB(28, 28, 35)
    ),

    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(7, 7, 10)
    )

})

gradient.Rotation = 45

gradient.Parent = main

-- =========================================================
-- BORDER
-- =========================================================

local border = Instance.new("UIStroke")

border.Name = "Border"

border.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

border.Thickness = 1.5

border.Color =
    Color3.fromRGB(120, 120, 120)

border.Transparency = 0.3

border.Parent = main

-- =========================================================
-- IMAGE CONTAINER
-- =========================================================

local imageContainer = Instance.new("Frame")

imageContainer.Name = "ImageContainer"

imageContainer.AnchorPoint =
    Vector2.new(0.5, 0.5)

imageContainer.Position =
    UDim2.fromScale(0.11, 0.5)

imageContainer.Size =
    UDim2.fromOffset(52, 52)

imageContainer.BackgroundTransparency = 1

imageContainer.ClipsDescendants = true

imageContainer.Parent = main

-- =========================================================
-- IMAGE CORNER
-- =========================================================

local imageCorner = Instance.new("UICorner")

imageCorner.CornerRadius =
    UDim.new(0, 11)

imageCorner.Parent = imageContainer

-- =========================================================
-- VISIBLE IMAGE
-- =========================================================

local visibleImage = Instance.new("ImageLabel")

visibleImage.Name = "VisibleImage"

visibleImage.Size =
    UDim2.fromScale(1, 1)

visibleImage.Position =
    UDim2.fromScale(0, 0)

visibleImage.BackgroundTransparency = 1

visibleImage.BorderSizePixel = 0

visibleImage.Image =
    visibleAsset or ""

visibleImage.ScaleType =
    Enum.ScaleType.Fit

visibleImage.Visible = false

visibleImage.ZIndex = 5

visibleImage.Parent = imageContainer

local visibleCorner = Instance.new("UICorner")

visibleCorner.CornerRadius =
    UDim.new(0, 11)

visibleCorner.Parent = visibleImage

-- =========================================================
-- HIDDEN IMAGE
-- =========================================================

local hiddenImage = Instance.new("ImageLabel")

hiddenImage.Name = "HiddenImage"

hiddenImage.Size =
    UDim2.fromScale(1, 1)

hiddenImage.Position =
    UDim2.fromScale(0, 0)

hiddenImage.BackgroundTransparency = 1

hiddenImage.BorderSizePixel = 0

hiddenImage.Image =
    hiddenAsset or ""

hiddenImage.ScaleType =
    Enum.ScaleType.Fit

hiddenImage.Visible = true

hiddenImage.ZIndex = 5

hiddenImage.Parent = imageContainer

local hiddenCorner = Instance.new("UICorner")

hiddenCorner.CornerRadius =
    UDim.new(0, 11)

hiddenCorner.Parent = hiddenImage

-- =========================================================
-- TITLE
-- =========================================================

local title = Instance.new("TextLabel")

title.Name = "Title"

title.Size =
    UDim2.fromOffset(100, 24)

title.Position =
    UDim2.fromOffset(76, 8)

title.BackgroundTransparency = 1

title.Text = "ESP"

title.TextColor3 =
    Color3.fromRGB(245, 245, 245)

title.TextSize = 17

title.Font =
    Enum.Font.GothamMedium

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent = main

-- =========================================================
-- PATH TEXTBOX
-- =========================================================

local pathBox = Instance.new("TextBox")

pathBox.Name = "PathBox"

pathBox.Size =
    UDim2.new(1, -135, 0, 23)

pathBox.Position =
    UDim2.new(0, 76, 1, -31)

pathBox.BackgroundTransparency = 1

pathBox.Text = ""

pathBox.PlaceholderText =
    "MoonDex path..."

pathBox.PlaceholderColor3 =
    Color3.fromRGB(120, 120, 120)

pathBox.TextColor3 =
    Color3.fromRGB(220, 220, 220)

pathBox.TextSize = 12

pathBox.Font =
    Enum.Font.Gotham

pathBox.TextXAlignment =
    Enum.TextXAlignment.Left

pathBox.ClearTextOnFocus = false

pathBox.Parent = main

-- =========================================================
-- PATH LINE
-- =========================================================

local line = Instance.new("Frame")

line.Name = "PathLine"

line.Size =
    UDim2.new(1, -135, 0, 1)

line.Position =
    UDim2.new(0, 76, 1, -7)

line.BackgroundColor3 =
    Color3.fromRGB(100, 100, 100)

line.BackgroundTransparency = 0.35

line.BorderSizePixel = 0

line.Parent = main

-- =========================================================
-- TOGGLE CIRCLE
-- =========================================================

local toggle = Instance.new("TextButton")

toggle.Name = "ESPToggle"

toggle.Size =
    UDim2.fromOffset(30, 30)

toggle.Position =
    UDim2.new(1, -43, 0.5, -15)

toggle.BackgroundTransparency = 1

toggle.Text = "○"

toggle.TextColor3 =
    Color3.fromRGB(220, 220, 220)

toggle.TextSize = 27

toggle.Font =
    Enum.Font.GothamMedium

toggle.AutoButtonColor = false

toggle.Parent = main

-- =========================================================
-- NEON GLOW
-- =========================================================

local glow = Instance.new("UIStroke")

glow.Name = "NeonGlow"

glow.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

glow.Thickness = 4

glow.Transparency = 1

glow.Color =
    Color3.fromRGB(0, 200, 255)

glow.Parent = main

-- =========================================================
-- PRELOAD BOTH IMAGES
-- =========================================================

task.spawn(function()

    pcall(function()

        ContentProvider:PreloadAsync({
            visibleImage,
            hiddenImage
        })

    end)

end)

-- =========================================================
-- ESP STATE
-- =========================================================

local espEnabled = false

local currentHighlight = nil

local ancestryConnection = nil

-- =========================================================
-- FIND OBJECT FROM MOONDEX PATH
-- =========================================================

local function resolvePath(path)

    if not path or path == "" then
        return nil
    end

    path = path:gsub("^%s+", "")
    path = path:gsub("%s+$", "")

    -- game.Workspace.X
    path = path:gsub("^game%.", "")

    -- workspace.X
    path = path:gsub("^workspace%.", "Workspace.")

    local parts = {}

    for part in path:gmatch("[^%.]+") do

        part = part:gsub("^%[", "")
        part = part:gsub("%]$", "")

        part = part:gsub("^['\"]", "")
        part = part:gsub("['\"]$", "")

        if part ~= "" then
            table.insert(parts, part)
        end

    end

    if #parts == 0 then
        return nil
    end

    local current

    if parts[1] == "Workspace" then

        current = workspace

        table.remove(parts, 1)

    elseif parts[1] == "CoreGui" then

        current =
            game:GetService("CoreGui")

        table.remove(parts, 1)

    elseif parts[1] == "ReplicatedStorage" then

        current =
            game:GetService("ReplicatedStorage")

        table.remove(parts, 1)

    elseif parts[1] == "Players" then

        current =
            game:GetService("Players")

        table.remove(parts, 1)

    elseif parts[1] == "Lighting" then

        current =
            game:GetService("Lighting")

        table.remove(parts, 1)

    else

        current = workspace

    end

    for _, name in ipairs(parts) do

        if not current then
            return nil
        end

        current =
            current:FindFirstChild(name)

        if not current then
            return nil
        end

    end

    return current
end

-- =========================================================
-- REMOVE HIGHLIGHT
-- =========================================================

local function removeHighlight()

    if currentHighlight then

        pcall(function()
            currentHighlight:Destroy()
        end)

        currentHighlight = nil

    end

end

-- =========================================================
-- CREATE HIGHLIGHT
-- =========================================================

local function createHighlight(target)

    removeHighlight()

    if not target then
        return false
    end

    local adornee = nil

    if target:IsA("Model")
        or target:IsA("BasePart") then

        adornee = target

    elseif target:IsA("Folder") then

        adornee =
            target:FindFirstChildWhichIsA(
                "Model",
                true
            )

        if not adornee then

            adornee =
                target:FindFirstChildWhichIsA(
                    "BasePart",
                    true
                )

        end

    end

    if not adornee then
        return false
    end

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "ShadowESP"

    highlight.Adornee =
        adornee

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

    local target =
        resolvePath(pathBox.Text)

    if not target then

        pathBox.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        return false
    end

    local success =
        createHighlight(target)

    if not success then

        pathBox.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        return false
    end

    pathBox.TextColor3 =
        Color3.fromRGB(220, 220, 220)

    if ancestryConnection then
        ancestryConnection:Disconnect()
    end

    ancestryConnection =
        target.AncestryChanged:Connect(
            function(_, parent)

                if not espEnabled then
                    return
                end

                if not parent then

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

            end
        )

    return true
end

-- =========================================================
-- STOP ESP
-- =========================================================

local function stopESP()

    removeHighlight()

    if ancestryConnection then

        ancestryConnection:Disconnect()

        ancestryConnection = nil

    end

end

-- =========================================================
-- UPDATE VISUAL
-- =========================================================

local function updateAppearance()

    if espEnabled then

        -- Visible image
        hiddenImage.Visible = false
        visibleImage.Visible = true

        -- Cyan border
        border.Color =
            Color3.fromRGB(0, 200, 255)

        border.Thickness = 2

        border.Transparency = 0

        -- Neon
        glow.Color =
            Color3.fromRGB(0, 200, 255)

        glow.Thickness = 5

        glow.Transparency = 0.72

        -- Filled circle
        toggle.Text = "●"

        toggle.TextColor3 =
            Color3.fromRGB(0, 200, 255)

    else

        -- Hidden image
        visibleImage.Visible = false
        hiddenImage.Visible = true

        -- White border
        border.Color =
            Color3.fromRGB(255, 255, 255)

        border.Thickness = 2

        border.Transparency = 0.1

        -- No neon
        glow.Transparency = 1

        -- Empty circle
        toggle.Text = "○"

        toggle.TextColor3 =
            Color3.fromRGB(220, 220, 220)

    end

end

-- =========================================================
-- TOGGLE
-- =========================================================

toggle.MouseButton1Click:Connect(function()

    if espEnabled then

        espEnabled = false

        stopESP()

        updateAppearance()

        return

    end

    local target =
        resolvePath(pathBox.Text)

    if not target then

        pathBox.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        return
    end

    local success =
        createHighlight(target)

    if not success then

        pathBox.TextColor3 =
            Color3.fromRGB(255, 100, 100)

        return
    end

    pathBox.TextColor3 =
        Color3.fromRGB(220, 220, 220)

    espEnabled = true

    updateAppearance()

end)

-- =========================================================
-- ENTER PATH
-- =========================================================

pathBox.FocusLost:Connect(function(enterPressed)

    if not enterPressed then
        return
    end

    if espEnabled then
        startESP()
    end

end)

-- =========================================================
-- DRAG SYSTEM
-- PC + MOBILE
-- =========================================================

local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

local movedDistance = 0
local DRAG_THRESHOLD = 8

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragInput = input
        dragStart = input.Position
        startPosition = button.Position
        movedDistance = 0

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragInput = nil
            end

        end)

    end

end)

button.InputChanged:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        dragInput = input

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input ~= dragInput then
        return
    end

    local delta = input.Position - dragStart

    movedDistance = math.max(
        movedDistance,
        math.abs(delta.X) + math.abs(delta.Y)
    )

    button.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,

        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not dragging then
        return
    end

    -- Se si è mosso meno di 8 pixel,
    -- viene considerato un click.
    if movedDistance < DRAG_THRESHOLD then

        local arceusGui = findArceusX()

        if arceusGui then

            hidden = not hidden

            arceusGui.Enabled = not hidden

            updateAppearance()

        end

    end

    dragging = false
    dragInput = nil

end)

-- =========================================================
-- INITIAL STATE
-- =========================================================

espEnabled = false

updateAppearance()