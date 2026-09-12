local CoreGui = game:GetService("CoreGui")

-- gethui() nel tuo caso restituisce:
-- CoreGui.9rMgS4.mriOy9
local targetParent = (gethui and gethui()) or CoreGui

-- =========================================================
-- REMOVE OLD TOGGLES
-- =========================================================

for _, obj in ipairs(targetParent:GetChildren()) do
    if obj:IsA("ScreenGui") and obj.Name == "ArceusXVisibilityToggle" then
        obj:Destroy()
    end
end

-- =========================================================
-- FIND ARCEUS X
-- =========================================================

local function findArceusX()

    for _, obj in ipairs(targetParent:GetChildren()) do

        if obj:IsA("ScreenGui") then

            if obj.DisplayOrder == 1999999999 then
                return obj
            end

        end
    end

    return nil
end

-- =========================================================
-- ARCEUS X VISIBILITY TOGGLE
-- MOBILE + PC
-- =========================================================

local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

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
    local globalKey = "ArceusX_Asset_" .. fileName

    -- Fix Cache: Usa l'ID se è già stato generato in questa sessione
    if getgenv and getgenv()[globalKey] then
        return getgenv()[globalKey]
    end

    if not isfolder(folder) then
        makefolder(folder)
    end

    if isfile(path) then
        local asset = getcustomasset(path)
        if getgenv then getgenv()[globalKey] = asset end
        return asset
    end

    local httpRequest = request or http_request

    if not httpRequest then
        return nil
    end

    local response = httpRequest({
        Url = url,
        Method = "GET"
    })

    if response and response.Body then
        writefile(path, response.Body)
        local asset = getcustomasset(path)
        if getgenv then getgenv()[globalKey] = asset end
        return asset
    end

    return nil
end

local visibleAsset = getImage(VISIBLE_URL, "visible.png")
local hiddenAsset = getImage(HIDDEN_URL, "hidden.png")

-- =========================================================
-- CREATE GUI
-- =========================================================

local toggleGui = Instance.new("ScreenGui")

toggleGui.Name = "ArceusXVisibilityToggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.DisplayOrder = 2147483647
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

toggleGui.Parent = targetParent

-- =========================================================
-- BUTTON
-- =========================================================

local button = Instance.new("ImageButton")

button.Name = "ToggleButton"

button.Size = UDim2.fromOffset(54, 54)
button.Position = UDim2.fromOffset(20, 100)

button.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
button.BackgroundTransparency = 0

button.Image = ""
button.AutoButtonColor = false

button.Active = true
button.ZIndex = 10

button.Parent = toggleGui

-- =========================================================
-- CORNER
-- =========================================================

local corner = Instance.new("UICorner")

corner.CornerRadius = UDim.new(0, 15)
corner.Parent = button

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
gradient.Parent = button

-- =========================================================
-- IMAGE CONTAINER
-- =========================================================

local imageContainer = Instance.new("Frame")

imageContainer.Name = "ImageContainer"

imageContainer.AnchorPoint = Vector2.new(0.5, 0.5)
imageContainer.Position = UDim2.fromScale(0.5, 0.5)

imageContainer.Size = UDim2.fromOffset(38, 38)

imageContainer.BackgroundTransparency = 1

imageContainer.ZIndex = 11

imageContainer.Parent = button

local imageCorner = Instance.new("UICorner")

imageCorner.CornerRadius = UDim.new(0, 11)
imageCorner.Parent = imageContainer

-- =========================================================
-- VISIBLE IMAGE
-- =========================================================

local visibleImage = Instance.new("ImageLabel")

visibleImage.Name = "VisibleImage"

visibleImage.Size = UDim2.fromScale(1, 1)
visibleImage.Position = UDim2.fromScale(0, 0)

visibleImage.BackgroundTransparency = 1

visibleImage.Image = visibleAsset or ""

visibleImage.ScaleType = Enum.ScaleType.Fit

visibleImage.ZIndex = 12

visibleImage.Parent = imageContainer

local visibleCorner = Instance.new("UICorner")

visibleCorner.CornerRadius = UDim.new(0, 11)
visibleCorner.Parent = visibleImage

-- =========================================================
-- HIDDEN IMAGE
-- =========================================================

local hiddenImage = Instance.new("ImageLabel")

hiddenImage.Name = "HiddenImage"

hiddenImage.Size = UDim2.fromScale(1, 1)
hiddenImage.Position = UDim2.fromScale(0, 0)

hiddenImage.BackgroundTransparency = 1

hiddenImage.Image = hiddenAsset or ""

hiddenImage.ScaleType = Enum.ScaleType.Fit

hiddenImage.Visible = false

hiddenImage.ZIndex = 12

hiddenImage.Parent = imageContainer

local hiddenCorner = Instance.new("UICorner")

hiddenCorner.CornerRadius = UDim.new(0, 11)
hiddenCorner.Parent = hiddenImage

-- =========================================================
-- BORDER
-- =========================================================

local border = Instance.new("UIStroke")

border.Name = "Border"

border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

border.Thickness = 2
border.Color = Color3.fromRGB(0, 200, 255)

border.Parent = button

-- =========================================================
-- NEON GLOW
-- =========================================================

local glow = Instance.new("UIStroke")

glow.Name = "NeonGlow"

glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

glow.Thickness = 5
glow.Transparency = 0.72

glow.Color = Color3.fromRGB(0, 200, 255)

glow.Parent = button

-- =========================================================
-- PRELOAD BOTH IMAGES
-- =========================================================

-- BLOCCO DISABILITATO PER FIXARE IL MEMORY LEAK DELLA CACHE
-- task.spawn(function()
-- 
--     pcall(function()
-- 
--         ContentProvider:PreloadAsync({
--             visibleImage,
--             hiddenImage
--         })
-- 
--     end)
-- 
-- end)

-- =========================================================
-- STATE
-- =========================================================

local hidden = false

-- =========================================================
-- UPDATE APPEARANCE
-- =========================================================

local function updateAppearance()

    if hidden then

        -- Hidden image
        visibleImage.Visible = false
        hiddenImage.Visible = true

        -- White border
        border.Color = Color3.fromRGB(
            255,
            255,
            255
        )

        border.Thickness = 2

        -- Disable neon
        glow.Transparency = 1

    else

        -- Visible image
        visibleImage.Visible = true
        hiddenImage.Visible = false

        -- Cyan border
        border.Color = Color3.fromRGB(
            0,
            200,
            255
        )

        border.Thickness = 2

        -- Enable neon
        glow.Color = Color3.fromRGB(
            0,
            200,
            255
        )

        glow.Thickness = 5
        glow.Transparency = 0.72

    end

end

-- =========================================================
-- CLICK / DRAG SYSTEM
-- MOBILE + PC
-- =========================================================

local dragging = false
local dragStart = nil
local startPosition = nil

local movedDistance = 0

local DRAG_THRESHOLD = 8

button.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPosition = button.Position

        movedDistance = 0

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then

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

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if dragging then

            -- Only toggle if it was a click,
            -- not a drag.
            if movedDistance < DRAG_THRESHOLD then

                local arceusGui = findArceusX()

                if arceusGui then

                    hidden = not hidden

                    arceusGui.Enabled = not hidden

                    updateAppearance()

                end

            end

        end

        dragging = false

    end

end)

-- =========================================================
-- INITIAL STATE
-- =========================================================

updateAppearance()updateVisual()
-- Initial state
updateButton()

print("Arceus X UI Toggle is fully loaded. [V.2.1]")