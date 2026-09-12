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
-- PREMIUM UI | PC + MOBILE
-- =========================================================

local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

-- =========================================================
-- CONFIG
-- =========================================================

local VISIBLE_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"

local FOLDER = "ArceusXUIToggle"

local BUTTON_SIZE = 54
local EDGE_PADDING = 10
local DRAG_THRESHOLD = 8

-- =========================================================
-- HTTP / FILE FUNCTIONS
-- =========================================================

local httpRequest = request or http_request

local function downloadImage(url, fileName)

    local path = FOLDER .. "/" .. fileName
    local globalKey = "ArceusX_Asset_" .. fileName

    -- Fix Cache: Usa l'ID se è già stato generato in questa sessione
    if getgenv and getgenv()[globalKey] then
        return getgenv()[globalKey]
    end

    if not httpRequest then
        return nil
    end

    if not isfolder(FOLDER) then
        pcall(function()
            makefolder(FOLDER)
        end)
    end

    if isfile(path) then
        local success, asset = pcall(function()
            return getcustomasset(path)
        end)

        if success then
            if getgenv then getgenv()[globalKey] = asset end
            return asset
        end
    end

    local success, response = pcall(function()
        return httpRequest({
            Url = url,
            Method = "GET"
        })
    end)

    if not success or not response or not response.Body then
        return nil
    end

    pcall(function()
        writefile(path, response.Body)
    end)

    local assetSuccess, asset = pcall(function()
        return getcustomasset(path)
    end)

    if assetSuccess then
        if getgenv then getgenv()[globalKey] = asset end
        return asset
    end

    return nil
end

-- =========================================================
-- LOAD IMAGES
-- =========================================================

local visibleAsset =
    downloadImage(VISIBLE_URL, "visible.png")

local hiddenAsset =
    downloadImage(HIDDEN_URL, "hidden.png")

-- =========================================================
-- GUI
-- =========================================================

local toggleGui = Instance.new("ScreenGui")

toggleGui.Name = "ArceusXVisibilityToggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.DisplayOrder = 2147483647
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

toggleGui.Parent = targetParent

-- =========================================================
-- SHADOW
-- =========================================================

local shadow = Instance.new("Frame")

shadow.Name = "Shadow"

shadow.Size = UDim2.fromOffset(
    BUTTON_SIZE + 8,
    BUTTON_SIZE + 8
)

shadow.Position = UDim2.fromOffset(
    23,
    103
)

shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.45

shadow.ZIndex = 1

shadow.Parent = toggleGui

local shadowCorner = Instance.new("UICorner")

shadowCorner.CornerRadius = UDim.new(0, 17)
shadowCorner.Parent = shadow

-- =========================================================
-- MAIN BUTTON
-- =========================================================

local button = Instance.new("ImageButton")

button.Name = "ToggleButton"

button.Size = UDim2.fromOffset(
    BUTTON_SIZE,
    BUTTON_SIZE
)

button.Position = UDim2.fromOffset(
    20,
    100
)

button.BackgroundColor3 =
    Color3.fromRGB(12, 12, 16)

button.BackgroundTransparency = 0

button.Image = ""
button.AutoButtonColor = false

button.Active = true

button.ZIndex = 10

button.Parent = toggleGui

-- =========================================================
-- BUTTON CORNER
-- =========================================================

local buttonCorner = Instance.new("UICorner")

buttonCorner.CornerRadius = UDim.new(0, 15)
buttonCorner.Parent = button

-- =========================================================
-- INNER GRADIENT
-- =========================================================

local gradient = Instance.new("UIGradient")

gradient.Name = "InnerGradient"

gradient.Color = ColorSequence.new({

    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(7, 7, 10)
    ),

    ColorSequenceKeypoint.new(
        0.5,
        Color3.fromRGB(30, 30, 38)
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

imageContainer.AnchorPoint =
    Vector2.new(0.5, 0.5)

imageContainer.Position =
    UDim2.fromScale(0.5, 0.5)

imageContainer.Size =
    UDim2.fromOffset(38, 38)

imageContainer.BackgroundTransparency = 1

imageContainer.ZIndex = 11

imageContainer.Parent = button

local imageContainerCorner = Instance.new("UICorner")

imageContainerCorner.CornerRadius =
    UDim.new(0, 11)

imageContainerCorner.Parent =
    imageContainer

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

visibleImage.Image =
    visibleAsset or ""

visibleImage.ScaleType =
    Enum.ScaleType.Fit

visibleImage.ZIndex = 12

visibleImage.Parent =
    imageContainer

local visibleCorner = Instance.new("UICorner")

visibleCorner.CornerRadius =
    UDim.new(0, 11)

visibleCorner.Parent =
    visibleImage

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

hiddenImage.Image =
    hiddenAsset or ""

hiddenImage.ScaleType =
    Enum.ScaleType.Fit

hiddenImage.Visible = false

hiddenImage.ZIndex = 12

hiddenImage.Parent =
    imageContainer

local hiddenCorner = Instance.new("UICorner")

hiddenCorner.CornerRadius =
    UDim.new(0, 11)

hiddenCorner.Parent =
    hiddenImage

-- =========================================================
-- BORDER
-- =========================================================

local border = Instance.new("UIStroke")

border.Name = "Border"

border.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

border.Thickness = 2

border.Color =
    Color3.fromRGB(0, 200, 255)

border.Parent = button

-- =========================================================
-- NEON GLOW
-- =========================================================

local glow = Instance.new("UIStroke")

glow.Name = "NeonGlow"

glow.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

glow.Thickness = 5

glow.Transparency = 0.72

glow.Color =
    Color3.fromRGB(0, 200, 255)

glow.Parent = button

-- =========================================================
-- SCALE
-- =========================================================

local scale = Instance.new("UIScale")

scale.Scale = 1

scale.Parent = button

-- =========================================================
-- PRELOAD
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

local dragging = false
local dragStart = nil
local startPosition = nil

local movedDistance = 0

local hover = false

-- =========================================================
-- POSITION LIMIT
-- =========================================================

local function clampPosition(x, y)

    local viewport =
        workspace.CurrentCamera.ViewportSize

    local maxX =
        viewport.X - BUTTON_SIZE - EDGE_PADDING

    local maxY =
        viewport.Y - BUTTON_SIZE - EDGE_PADDING

    x = math.clamp(
        x,
        EDGE_PADDING,
        maxX
    )

    y = math.clamp(
        y,
        EDGE_PADDING,
        maxY
    )

    return x, y

end

-- =========================================================
-- MOVE SHADOW
-- =========================================================

local function updateShadow()

    shadow.Position = UDim2.fromOffset(
        button.Position.X.Offset + 3,
        button.Position.Y.Offset + 3
    )

end

button:GetPropertyChangedSignal(
    "Position"
):Connect(updateShadow)

-- =========================================================
-- VISUAL STATE
-- =========================================================

local function updateAppearance()

    if hidden then

        -- Hidden image
        visibleImage.Visible = false
        hiddenImage.Visible = true

        -- White border
        border.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        border.Thickness = 2

        -- No neon
        glow.Transparency = 1

    else

        -- Visible image
        visibleImage.Visible = true
        hiddenImage.Visible = false

        -- Cyan border
        border.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        border.Thickness = 2

        -- Cyan glow
        glow.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        glow.Thickness = 5
        glow.Transparency = 0.72

    end

end

-- =========================================================
-- CLICK ANIMATION
-- =========================================================

local function clickAnimation()

    local downTween = TweenService:Create(
        scale,
        TweenInfo.new(
            0.06,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Scale = 0.90
        }
    )

    local upTween = TweenService:Create(
        scale,
        TweenInfo.new(
            0.10,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Scale = 1
        }
    )

    downTween:Play()

    downTween.Completed:Once(function()
        upTween:Play()
    end)

end

-- =========================================================
-- GLOW PULSE
-- =========================================================

task.spawn(function()

    while toggleGui.Parent do

        if not hidden then

            local tweenIn = TweenService:Create(
                glow,
                TweenInfo.new(
                    1.1,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    Transparency = 0.52
                }
            )

            local tweenOut = TweenService:Create(
                glow,
                TweenInfo.new(
                    1.1,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    Transparency = 0.78
                }
            )

            tweenIn:Play()
            tweenIn.Completed:Wait()

            if hidden then
                continue
            end

            tweenOut:Play()
            tweenOut.Completed:Wait()

        else

            task.wait(0.25)

        end

    end

end)

-- =========================================================
-- PC HOVER
-- =========================================================

if not UserInputService.TouchEnabled then

    button.MouseEnter:Connect(function()

        hover = true

        TweenService:Create(
            scale,
            TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Scale = 1.06
            }
        ):Play()

    end)

    button.MouseLeave:Connect(function()

        hover = false

        if not dragging then

            TweenService:Create(
                scale,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),
                {
                    Scale = 1
                }
            ):Play()

        end

    end)

end

-- =========================================================
-- DRAG START
-- =========================================================

button.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            button.Position

        movedDistance = 0

    end

end)

-- =========================================================
-- DRAG MOVEMENT
-- =========================================================

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

    local delta =
        input.Position - dragStart

    movedDistance =
        math.max(
            movedDistance,
            math.abs(delta.X)
            + math.abs(delta.Y)
        )

    local newX =
        startPosition.X.Offset
        + delta.X

    local newY =
        startPosition.Y.Offset
        + delta.Y

    newX, newY =
        clampPosition(
            newX,
            newY
        )

    button.Position =
        UDim2.fromOffset(
            newX,
            newY
        )

end)

-- =========================================================
-- DRAG END / CLICK
-- =========================================================

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

    -- It was a click
    if movedDistance <
        DRAG_THRESHOLD then

        clickAnimation()

        local arceusGui =
            findArceusX()

        if not arceusGui then
            return
        end

        hidden = not hidden

        arceusGui.Enabled =
            not hidden

        updateAppearance()

    end

end)

-- =========================================================
-- VIEWPORT CHANGE
-- =========================================================

workspace.CurrentCamera:GetPropertyChangedSignal(
    "ViewportSize"
):Connect(function()

    local x =
        button.Position.X.Offset

    local y =
        button.Position.Y.Offset

    x, y =
        clampPosition(
            x,
            y
        )

    button.Position =
        UDim2.fromOffset(
            x,
            y
        )

end)

-- =========================================================
-- INITIALIZE
-- =========================================================

updateAppearance()
updateShadow()