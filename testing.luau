-- =========================================================
-- SHADOW ESP
-- MoonDex Path ESP + GitHub Cached Images
-- PC + MOBILE
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
-- IMAGE CACHE
-- =========================================================

local function getImage(url, fileName)

    local folder = "ArceusXUIToggle"
    local path = folder .. "/" .. fileName

    pcall(function()
        if not isfolder(folder) then
            makefolder(folder)
        end
    end)

    -- Already cached
    if isfile(path) then

        local success, asset = pcall(function()
            return getcustomasset(path)
        end)

        if success and asset then
            return asset
        end
    end

    -- Request function
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

    if not response.Body then
        return nil
    end

    local writeSuccess = pcall(function()
        writefile(path, response.Body)
    end)

    if not writeSuccess then
        return nil
    end

    local assetSuccess, asset = pcall(function()
        return getcustomasset(path)
    end)

    if assetSuccess then
        return asset
    end

    return nil
end

-- =========================================================
-- LOAD BOTH IMAGES BEFORE UI
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
    pcall(function()
        targetParent = game:GetService("CoreGui")
    end)
end

if not targetParent then
    targetParent =
        LocalPlayer:WaitForChild("PlayerGui")
end

-- =========================================================
-- GUI
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
-- CORNER
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

border.Thickness = 2

border.Color =
    Color3.fromRGB(255, 255, 255)

border.Transparency = 0.1

border.Parent = main

-- =========================================================
-- NEON GLOW
-- =========================================================

local glow = Instance.new("UIStroke")

glow.Name = "NeonGlow"

glow.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

glow.Thickness = 5

glow.Transparency = 1

glow.Color =
    Color3.fromRGB(0, 200, 255)

glow.Parent = main

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

imageContainer.ZIndex = 5

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

visibleImage.AnchorPoint =
    Vector2.new(0.5, 0.5)

visibleImage.Position =
    UDim2.fromScale(0.5, 0.5)

visibleImage.Size =
    UDim2.fromScale(1, 1)

visibleImage.BackgroundTransparency = 1

visibleImage.BorderSizePixel = 0

visibleImage.Image =
    visibleAsset or ""

visibleImage.ScaleType =
    Enum.ScaleType.Fit

visibleImage.Visible = false

visibleImage.ZIndex = 6

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

hiddenImage.AnchorPoint =
    Vector2.new(0.5, 0.5)

hiddenImage.Position =
    UDim2.fromScale(0.5, 0.5)

hiddenImage.Size =
    UDim2.fromScale(1, 1)

hiddenImage.BackgroundTransparency = 1

hiddenImage.BorderSizePixel = 0

hiddenImage.Image =
    hiddenAsset or ""

hiddenImage.ScaleType =
    Enum.ScaleType.Fit

hiddenImage.Visible = true

hiddenImage.ZIndex = 6

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

title.ZIndex = 4

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

pathBox.ZIndex = 4

pathBox.Parent = main

-- =========================================================
-- UNDERLINE
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

line.ZIndex = 4

line.Parent = main

-- =========================================================
-- TOGGLE
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

toggle.ZIndex = 10

toggle.Parent = main

-- =========================================================
-- PRELOAD
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
-- RESOLVE MOONDEX PATH
-- =========================================================

local function resolvePath(path)

    if not path or path == "" then
        return nil
    end

    path = path:gsub("^%s+", "")
    path = path:gsub("%s+$", "")

    path = path:gsub("^game%.", "")

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

    else

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

    highlight.FillTransparency =
        0.5

    highlight.OutlineColor =
        Color3.fromRGB(255, 255, 255)

    highlight.OutlineTransparency =
        0

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    -- Put it directly into the target's parent
    -- so Roblox renders the Highlight correctly.
    local parent =
        adornee.Parent or workspace

    highlight.Parent = parent

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
        ancestryConnection = nil
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
-- UPDATE UI
-- =========================================================

local function updateAppearance()

    if espEnabled then

        -- IMAGE
        hiddenImage.Visible = false
        visibleImage.Visible = true

        -- BORDER
        border.Color =
            Color3.fromRGB(0, 200, 255)

        border.Thickness = 2
        border.Transparency = 0

        -- GLOW
        glow.Color =
            Color3.fromRGB(0, 200, 255)

        glow.Thickness = 5
        glow.Transparency = 0.72

        -- CIRCLE
        toggle.Text = "●"

        toggle.TextColor3 =
            Color3.fromRGB(0, 200, 255)

    else

        -- IMAGE
        visibleImage.Visible = false
        hiddenImage.Visible = true

        -- BORDER
        border.Color =
            Color3.fromRGB(255, 255, 255)

        border.Thickness = 2
        border.Transparency = 0.1

        -- GLOW OFF
        glow.Transparency = 1

        -- CIRCLE
        toggle.Text = "○"

        toggle.TextColor3 =
            Color3.fromRGB(220, 220, 220)

    end

end

-- =========================================================
-- TOGGLE BUTTON
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

local dragStart = nil
local startPosition = nil

local dragInput = nil

local movedDistance = 0

local DRAG_THRESHOLD = 8

-- ---------------------------------------------------------
-- Check whether position is over a protected control
-- ---------------------------------------------------------

local function isOverControl(position)

    local controls = {
        pathBox,
        toggle
    }

    for _, object in ipairs(controls) do

        if object.Visible then

            local pos =
                object.AbsolutePosition

            local size =
                object.AbsoluteSize

            if position.X >= pos.X
                and position.X <= pos.X + size.X
                and position.Y >= pos.Y
                and position.Y <= pos.Y + size.Y then

                return true
            end

        end

    end

    return false
end

-- ---------------------------------------------------------
-- Start drag
-- ---------------------------------------------------------

UserInputService.InputBegan:Connect(function(input)

    if input.UserInputType ~=
        Enum.UserInputType.MouseButton1
        and input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    local position =
        input.Position

    local mainPos =
        main.AbsolutePosition

    local mainSize =
        main.AbsoluteSize

    -- Check if input is inside panel
    local insidePanel =
        position.X >= mainPos.X
        and position.X <= mainPos.X + mainSize.X
        and position.Y >= mainPos.Y
        and position.Y <= mainPos.Y + mainSize.Y

    if not insidePanel then
        return
    end

    -- Don't drag when typing/clicking toggle
    if isOverControl(position) then
        return
    end

    dragging = true

    dragInput = input

    dragStart = position

    startPosition =
        main.Position

    movedDistance = 0

end)

-- ---------------------------------------------------------
-- Mouse / Touch movement
-- ---------------------------------------------------------

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~=
        Enum.UserInputType.MouseMovement
        and input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    local currentPosition =
        input.Position

    local delta =
        currentPosition - dragStart

    movedDistance = math.max(
        movedDistance,
        math.abs(delta.X) +
        math.abs(delta.Y)
    )

    main.Position = UDim2.new(

        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,

        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y

    )

end)

-- ---------------------------------------------------------
-- End drag
-- ---------------------------------------------------------

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ~=
        Enum.UserInputType.MouseButton1
        and input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    if not dragging then
        return
    end

    dragging = false

    dragInput = nil
    dragStart = nil
    startPosition = nil

end)

-- =========================================================
-- INITIAL STATE
-- =========================================================

espEnabled = false

updateAppearance()