-- =========================================================
-- SHADOW VISIBILITY + FULLBRIGHT TOGGLE
-- PREMIUM UI | PC + MOBILE
-- =========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- CONFIG
-- =========================================================

local VISIBLE_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"

local FOLDER = "ArceusXUIToggle"

local BUTTON_SIZE = 54
local FULLBRIGHT_SIZE = 46

local EDGE_PADDING = 10
local DRAG_THRESHOLD = 8

local MAIN_X = 20
local MAIN_Y = 100

local FULLBRIGHT_X = 80
local FULLBRIGHT_Y = 104

local GAP = 6

-- =========================================================
-- HTTP / FILE FUNCTIONS
-- =========================================================

local httpRequest =
    request
    or http_request
    or (syn and syn.request)

local function downloadImage(url, fileName)

    if not httpRequest then
        return nil
    end

    if not isfolder(FOLDER) then

        pcall(function()
            makefolder(FOLDER)
        end)

    end

    local path = FOLDER .. "/" .. fileName

    if isfile(path) then

        local success, asset = pcall(function()
            return getcustomasset(path)
        end)

        if success then
            return asset
        end

    end

    local success, response = pcall(function()

        return httpRequest({
            Url = url,
            Method = "GET"
        })

    end)

    if not success
        or not response
        or not response.Body then

        return nil

    end

    pcall(function()
        writefile(path, response.Body)
    end)

    local assetSuccess, asset = pcall(function()
        return getcustomasset(path)
    end)

    if assetSuccess then
        return asset
    end

    return nil

end

-- =========================================================
-- LOAD IMAGES
-- =========================================================

local visibleAsset =
    downloadImage(
        VISIBLE_URL,
        "visible.png"
    )

local hiddenAsset =
    downloadImage(
        HIDDEN_URL,
        "hidden.png"
    )

-- =========================================================
-- GUI PARENT
-- =========================================================

local targetParent

pcall(function()

    targetParent =
        (gethui and gethui())
        or game:GetService("CoreGui")

end)

if not targetParent then

    targetParent =
        LocalPlayer:WaitForChild("PlayerGui")

end

-- =========================================================
-- REMOVE OLD GUI
-- =========================================================

pcall(function()

    local oldGui =
        targetParent:FindFirstChild(
            "ShadowVisibilityFullbrightToggle"
        )

    if oldGui then
        oldGui:Destroy()
    end

end)

-- =========================================================
-- GUI
-- =========================================================

local toggleGui =
    Instance.new("ScreenGui")

toggleGui.Name =
    "ShadowVisibilityFullbrightToggle"

toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.DisplayOrder = 2147483647
toggleGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

toggleGui.Parent = targetParent

-- =========================================================
-- MAIN SHADOW
-- =========================================================

local mainShadow =
    Instance.new("Frame")

mainShadow.Name = "MainShadow"

mainShadow.Size =
    UDim2.fromOffset(
        BUTTON_SIZE + 8,
        BUTTON_SIZE + 8
    )

mainShadow.Position =
    UDim2.fromOffset(
        MAIN_X + 3,
        MAIN_Y + 3
    )

mainShadow.BackgroundColor3 =
    Color3.fromRGB(0, 0, 0)

mainShadow.BackgroundTransparency = 0.45

mainShadow.ZIndex = 1

mainShadow.Parent = toggleGui

local mainShadowCorner =
    Instance.new("UICorner")

mainShadowCorner.CornerRadius =
    UDim.new(0, 17)

mainShadowCorner.Parent =
    mainShadow

-- =========================================================
-- FULLBRIGHT SHADOW
-- =========================================================

local fullbrightShadow =
    Instance.new("Frame")

fullbrightShadow.Name =
    "FullbrightShadow"

fullbrightShadow.Size =
    UDim2.fromOffset(
        FULLBRIGHT_SIZE + 8,
        FULLBRIGHT_SIZE + 8
    )

fullbrightShadow.Position =
    UDim2.fromOffset(
        FULLBRIGHT_X + 3,
        FULLBRIGHT_Y + 3
    )

fullbrightShadow.BackgroundColor3 =
    Color3.fromRGB(0, 0, 0)

fullbrightShadow.BackgroundTransparency =
    0.45

fullbrightShadow.ZIndex = 1

fullbrightShadow.Parent = toggleGui

local fullbrightShadowCorner =
    Instance.new("UICorner")

fullbrightShadowCorner.CornerRadius =
    UDim.new(0, 15)

fullbrightShadowCorner.Parent =
    fullbrightShadow

-- =========================================================
-- MAIN BUTTON
-- =========================================================

local button =
    Instance.new("ImageButton")

button.Name =
    "ToggleButton"

button.Size =
    UDim2.fromOffset(
        BUTTON_SIZE,
        BUTTON_SIZE
    )

button.Position =
    UDim2.fromOffset(
        MAIN_X,
        MAIN_Y
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
-- MAIN CORNER
-- =========================================================

local buttonCorner =
    Instance.new("UICorner")

buttonCorner.CornerRadius =
    UDim.new(0, 15)

buttonCorner.Parent =
    button

-- =========================================================
-- MAIN GRADIENT
-- =========================================================

local gradient =
    Instance.new("UIGradient")

gradient.Name =
    "InnerGradient"

gradient.Color =
    ColorSequence.new({

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
-- MAIN IMAGE CONTAINER
-- =========================================================

local imageContainer =
    Instance.new("Frame")

imageContainer.Name =
    "ImageContainer"

imageContainer.AnchorPoint =
    Vector2.new(0.5, 0.5)

imageContainer.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

imageContainer.Size =
    UDim2.fromOffset(
        38,
        38
    )

imageContainer.BackgroundTransparency = 1

imageContainer.ZIndex = 11
imageContainer.Parent = button

local imageContainerCorner =
    Instance.new("UICorner")

imageContainerCorner.CornerRadius =
    UDim.new(0, 11)

imageContainerCorner.Parent =
    imageContainer

-- =========================================================
-- VISIBLE IMAGE
-- =========================================================

local visibleImage =
    Instance.new("ImageLabel")

visibleImage.Name =
    "VisibleImage"

visibleImage.Size =
    UDim2.fromScale(1, 1)

visibleImage.BackgroundTransparency = 1

visibleImage.Image =
    visibleAsset or ""

visibleImage.ScaleType =
    Enum.ScaleType.Fit

visibleImage.ZIndex = 12
visibleImage.Parent =
    imageContainer

local visibleCorner =
    Instance.new("UICorner")

visibleCorner.CornerRadius =
    UDim.new(0, 11)

visibleCorner.Parent =
    visibleImage

-- =========================================================
-- HIDDEN IMAGE
-- =========================================================

local hiddenImage =
    Instance.new("ImageLabel")

hiddenImage.Name =
    "HiddenImage"

hiddenImage.Size =
    UDim2.fromScale(1, 1)

hiddenImage.BackgroundTransparency = 1

hiddenImage.Image =
    hiddenAsset or ""

hiddenImage.ScaleType =
    Enum.ScaleType.Fit

hiddenImage.Visible = false

hiddenImage.ZIndex = 12
hiddenImage.Parent =
    imageContainer

local hiddenCorner =
    Instance.new("UICorner")

hiddenCorner.CornerRadius =
    UDim.new(0, 11)

hiddenCorner.Parent =
    hiddenImage

-- =========================================================
-- MAIN BORDER
-- =========================================================

local border =
    Instance.new("UIStroke")

border.Name = "Border"

border.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

border.Thickness = 2

border.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

border.Parent = button

-- =========================================================
-- MAIN GLOW
-- =========================================================

local glow =
    Instance.new("UIStroke")

glow.Name =
    "NeonGlow"

glow.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

glow.Thickness = 5

glow.Transparency = 0.72

glow.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

glow.Parent = button

-- =========================================================
-- MAIN SCALE
-- =========================================================

local scale =
    Instance.new("UIScale")

scale.Scale = 1
scale.Parent = button

-- =========================================================
-- FULLBRIGHT BUTTON
-- =========================================================

local fullbrightButton =
    Instance.new("ImageButton")

fullbrightButton.Name =
    "FullbrightButton"

fullbrightButton.Size =
    UDim2.fromOffset(
        FULLBRIGHT_SIZE,
        FULLBRIGHT_SIZE
    )

fullbrightButton.Position =
    UDim2.fromOffset(
        FULLBRIGHT_X,
        FULLBRIGHT_Y
    )

fullbrightButton.BackgroundColor3 =
    Color3.fromRGB(
        12,
        12,
        16
    )

fullbrightButton.BackgroundTransparency = 0

fullbrightButton.Image = ""

fullbrightButton.AutoButtonColor = false
fullbrightButton.Active = true

fullbrightButton.ZIndex = 10
fullbrightButton.Parent = toggleGui

-- =========================================================
-- FULLBRIGHT CORNER
-- =========================================================

local fullbrightCorner =
    Instance.new("UICorner")

fullbrightCorner.CornerRadius =
    UDim.new(0, 13)

fullbrightCorner.Parent =
    fullbrightButton

-- =========================================================
-- FULLBRIGHT GRADIENT
-- =========================================================

local fullbrightGradient =
    Instance.new("UIGradient")

fullbrightGradient.Name =
    "FullbrightGradient"

fullbrightGradient.Color =
    ColorSequence.new({

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

fullbrightGradient.Rotation = 45

fullbrightGradient.Parent =
    fullbrightButton

-- =========================================================
-- FULLBRIGHT ICON CONTAINER
-- =========================================================

local iconContainer =
    Instance.new("Frame")

iconContainer.Name =
    "IconContainer"

iconContainer.AnchorPoint =
    Vector2.new(0.5, 0.5)

iconContainer.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

iconContainer.Size =
    UDim2.fromOffset(
        30,
        30
    )

iconContainer.BackgroundTransparency = 1

iconContainer.ClipsDescendants = true

iconContainer.ZIndex = 11
iconContainer.Parent =
    fullbrightButton

local iconCorner =
    Instance.new("UICorner")

iconCorner.CornerRadius =
    UDim.new(0, 9)

iconCorner.Parent =
    iconContainer

-- =========================================================
-- FULLBRIGHT FILL
-- =========================================================

local fullbrightFill =
    Instance.new("Frame")

fullbrightFill.Name =
    "Fill"

fullbrightFill.AnchorPoint =
    Vector2.new(0.5, 1)

fullbrightFill.Position =
    UDim2.fromScale(
        0.5,
        1
    )

fullbrightFill.Size =
    UDim2.fromScale(
        1,
        0
    )

fullbrightFill.BackgroundColor3 =
    Color3.fromRGB(
        0,
        200,
        255
    )

fullbrightFill.BackgroundTransparency =
    0.10

fullbrightFill.BorderSizePixel = 0

fullbrightFill.ZIndex = 11

fullbrightFill.Parent =
    iconContainer

local fillGradient =
    Instance.new("UIGradient")

fillGradient.Color =
    ColorSequence.new({

        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(
                0,
                120,
                255
            )
        ),

        ColorSequenceKeypoint.new(
            0.5,
            Color3.fromRGB(
                0,
                220,
                255
            )
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(
                0,
                150,
                255
            )
        )

    })

fillGradient.Rotation = 90
fillGradient.Parent = fullbrightFill

-- =========================================================
-- SUN ICON
-- =========================================================

local sunIcon =
    Instance.new("TextLabel")

sunIcon.Name =
    "SunIcon"

sunIcon.AnchorPoint =
    Vector2.new(0.5, 0.5)

sunIcon.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

sunIcon.Size =
    UDim2.fromScale(
        1,
        1
    )

sunIcon.BackgroundTransparency = 1

sunIcon.Text = "☀"

sunIcon.TextColor3 =
    Color3.fromRGB(
        235,
        235,
        240
    )

sunIcon.TextScaled = true

sunIcon.Font =
    Enum.Font.GothamBold

sunIcon.ZIndex = 12

sunIcon.Parent =
    iconContainer

-- =========================================================
-- FULLBRIGHT BORDER
-- =========================================================

local fullbrightBorder =
    Instance.new("UIStroke")

fullbrightBorder.Name =
    "Border"

fullbrightBorder.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

fullbrightBorder.Thickness = 2

fullbrightBorder.Color =
    Color3.fromRGB(
        255,
        255,
        255
    )

fullbrightBorder.Parent =
    fullbrightButton

-- =========================================================
-- FULLBRIGHT GLOW
-- =========================================================

local fullbrightGlow =
    Instance.new("UIStroke")

fullbrightGlow.Name =
    "NeonGlow"

fullbrightGlow.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

fullbrightGlow.Thickness = 5

fullbrightGlow.Transparency = 1

fullbrightGlow.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

fullbrightGlow.Parent =
    fullbrightButton

-- =========================================================
-- FULLBRIGHT SCALE
-- =========================================================

local fullbrightScale =
    Instance.new("UIScale")

fullbrightScale.Scale = 1

fullbrightScale.Parent =
    fullbrightButton

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
-- STATE
-- =========================================================

local hidden = false
local fullbright = false

local dragging = false
local dragStart = nil
local startPosition = nil

local movedDistance = 0

local fullbrightDragging = false
local fullbrightDragStart = nil
local fullbrightStartPosition = nil

local fullbrightMovedDistance = 0

local hover = false
local fullbrightHover = false

-- =========================================================
-- SAVE ORIGINAL LIGHTING
-- =========================================================

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- =========================================================
-- FULLBRIGHT FUNCTIONS
-- =========================================================

local function saveLighting()

    originalLighting.Brightness =
        Lighting.Brightness

    originalLighting.ClockTime =
        Lighting.ClockTime

    originalLighting.FogEnd =
        Lighting.FogEnd

    originalLighting.GlobalShadows =
        Lighting.GlobalShadows

    originalLighting.OutdoorAmbient =
        Lighting.OutdoorAmbient

end

local function enableFullbright()

    saveLighting()

    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient =
        Color3.fromRGB(
            128,
            128,
            128
        )

end

local function disableFullbright()

    Lighting.Brightness =
        originalLighting.Brightness

    Lighting.ClockTime =
        originalLighting.ClockTime

    Lighting.FogEnd =
        originalLighting.FogEnd

    Lighting.GlobalShadows =
        originalLighting.GlobalShadows

    Lighting.OutdoorAmbient =
        originalLighting.OutdoorAmbient

end

-- =========================================================
-- FULLBRIGHT VISUAL STATE
-- =========================================================

local function updateFullbrightAppearance()

    if fullbright then

        fullbrightBorder.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        fullbrightBorder.Thickness = 2

        fullbrightGlow.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        fullbrightGlow.Thickness = 5
        fullbrightGlow.Transparency = 0.65

        TweenService:Create(
            fullbrightFill,
            TweenInfo.new(
                0.20,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.fromScale(
                        1,
                        1
                    )
            }
        ):Play()

        TweenService:Create(
            sunIcon,
            TweenInfo.new(
                0.18,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                TextColor3 =
                    Color3.fromRGB(
                        255,
                        255,
                        255
                    )
            }
        ):Play()

    else

        fullbrightBorder.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        fullbrightBorder.Thickness = 2

        fullbrightGlow.Transparency = 1

        TweenService:Create(
            fullbrightFill,
            TweenInfo.new(
                0.20,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.fromScale(
                        1,
                        0
                    )
            }
        ):Play()

        TweenService:Create(
            sunIcon,
            TweenInfo.new(
                0.18,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                TextColor3 =
                    Color3.fromRGB(
                        235,
                        235,
                        240
                    )
            }
        ):Play()

    end

end

-- =========================================================
-- MAIN VISUAL STATE
-- =========================================================

local function updateAppearance()

    if hidden then

        visibleImage.Visible = false
        hiddenImage.Visible = true

        border.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        border.Thickness = 2

        glow.Transparency = 1

    else

        visibleImage.Visible = true
        hiddenImage.Visible = false

        border.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        border.Thickness = 2

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
-- ANIMATION
-- =========================================================

local function clickAnimation(targetScale)

    local downTween =
        TweenService:Create(
            targetScale,
            TweenInfo.new(
                0.06,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Scale = 0.90
            }
        )

    local upTween =
        TweenService:Create(
            targetScale,
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
-- MAIN GLOW PULSE
-- =========================================================

task.spawn(function()

    while toggleGui.Parent do

        if not hidden then

            local tweenIn =
                TweenService:Create(
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

            local tweenOut =
                TweenService:Create(
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
-- FULLBRIGHT GLOW PULSE
-- =========================================================

task.spawn(function()

    while toggleGui.Parent do

        if fullbright then

            local tweenIn =
                TweenService:Create(
                    fullbrightGlow,
                    TweenInfo.new(
                        1.0,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.45
                    }
                )

            local tweenOut =
                TweenService:Create(
                    fullbrightGlow,
                    TweenInfo.new(
                        1.0,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.75
                    }
                )

            tweenIn:Play()
            tweenIn.Completed:Wait()

            if not fullbright then
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

    fullbrightButton.MouseEnter:Connect(function()

        fullbrightHover = true

        TweenService:Create(
            fullbrightScale,
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

    fullbrightButton.MouseLeave:Connect(function()

        fullbrightHover = false

        if not fullbrightDragging then

            TweenService:Create(
                fullbrightScale,
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
-- MAIN DRAG START
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
-- FULLBRIGHT DRAG START
-- =========================================================

fullbrightButton.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        fullbrightDragging = true

        fullbrightDragStart =
            input.Position

        fullbrightStartPosition =
            fullbrightButton.Position

        fullbrightMovedDistance = 0

    end

end)

-- =========================================================
-- POSITION CLAMP
-- =========================================================

local function clampMainPosition(x, y)

    local viewport =
        workspace.CurrentCamera.ViewportSize

    local maxX =
        viewport.X
        - BUTTON_SIZE
        - EDGE_PADDING

    local maxY =
        viewport.Y
        - BUTTON_SIZE
        - EDGE_PADDING

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
-- FULL POSITION CLAMP
-- =========================================================

local function clampFullbrightPosition(x, y)

    local viewport =
        workspace.CurrentCamera.ViewportSize

    local maxX =
        viewport.X
        - FULLBRIGHT_SIZE
        - EDGE_PADDING

    local maxY =
        viewport.Y
        - FULLBRIGHT_SIZE
        - EDGE_PADDING

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
-- DRAG MOVEMENT
-- =========================================================

UserInputService.InputChanged:Connect(function(input)

    -- =====================================================
    -- MAIN
    -- =====================================================

    if dragging then

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            -- Continue below for fullbright
        else

            local delta =
                input.Position
                - dragStart

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
                clampMainPosition(
                    newX,
                    newY
                )

            button.Position =
                UDim2.fromOffset(
                    newX,
                    newY
                )

            mainShadow.Position =
                UDim2.fromOffset(
                    newX + 3,
                    newY + 3
                )

            -- Keep Fullbright attached
            fullbrightButton.Position =
                UDim2.fromOffset(
                    newX
                    + BUTTON_SIZE
                    + GAP,
                    newY + 4
                )

            fullbrightShadow.Position =
                UDim2.fromOffset(
                    newX
                    + BUTTON_SIZE
                    + GAP
                    + 3,
                    newY + 7
                )

        end

    end

    -- =====================================================
    -- FULLBRIGHT
    -- =====================================================

    if fullbrightDragging then

        if input.UserInputType ~=
            Enum.UserInputType.MouseMovement
            and input.UserInputType ~=
            Enum.UserInputType.Touch then

            return

        end

        local delta =
            input.Position
            - fullbrightDragStart

        fullbrightMovedDistance =
            math.max(
                fullbrightMovedDistance,
                math.abs(delta.X)
                + math.abs(delta.Y)
            )

        local newX =
            fullbrightStartPosition.X.Offset
            + delta.X

        local newY =
            fullbrightStartPosition.Y.Offset
            + delta.Y

        newX, newY =
            clampFullbrightPosition(
                newX,
                newY
            )

        fullbrightButton.Position =
            UDim2.fromOffset(
                newX,
                newY
            )

        fullbrightShadow.Position =
            UDim2.fromOffset(
                newX + 3,
                newY + 3
            )

    end

end)

-- =========================================================
-- INPUT ENDED
-- =========================================================

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ~=
        Enum.UserInputType.MouseButton1
        and input.UserInputType ~=
        Enum.UserInputType.Touch then

        return

    end

    -- =====================================================
    -- MAIN
    -- =====================================================

    if dragging then

        dragging = false

        if movedDistance <
            DRAG_THRESHOLD then

            clickAnimation(scale)

            hidden = not hidden

            -- =================================================
            -- ORIGINAL ARCEUS X FUNCTION
            -- =================================================

            local arceusGui

            pcall(function()

                for _, gui in ipairs(
                    targetParent:GetChildren()
                ) do

                    if gui ~= toggleGui
                        and gui:IsA("ScreenGui")
                        and (
                            string.find(
                                string.lower(gui.Name),
                                "arceus"
                            )
                            or string.find(
                                string.lower(gui.Name),
                                "arceusx"
                            )
                        ) then

                        arceusGui = gui
                        break

                    end

                end

            end)

            if arceusGui then
                arceusGui.Enabled =
                    not hidden
            end

            updateAppearance()

        end

    end

    -- =====================================================
    -- FULLBRIGHT
    -- =====================================================

    if fullbrightDragging then

        fullbrightDragging = false

        if fullbrightMovedDistance <
            DRAG_THRESHOLD then

            clickAnimation(
                fullbrightScale
            )

            fullbright =
                not fullbright

            if fullbright then
                enableFullbright()
            else
                disableFullbright()
            end

            updateFullbrightAppearance()

        end

    end

end)

-- =========================================================
-- VIEWPORT CHANGE
-- =========================================================

workspace.CurrentCamera:GetPropertyChangedSignal(
    "ViewportSize"
):Connect(function()

    -- Main button
    local x =
        button.Position.X.Offset

    local y =
        button.Position.Y.Offset

    x, y =
        clampMainPosition(
            x,
            y
        )

    button.Position =
        UDim2.fromOffset(
            x,
            y
        )

    mainShadow.Position =
        UDim2.fromOffset(
            x + 3,
            y + 3
        )

    -- Keep Fullbright attached
    local fullX =
        x
        + BUTTON_SIZE
        + GAP

    local fullY =
        y + 4

    fullX, fullY =
        clampFullbrightPosition(
            fullX,
            fullY
        )

    fullbrightButton.Position =
        UDim2.fromOffset(
            fullX,
            fullY
        )

    fullbrightShadow.Position =
        UDim2.fromOffset(
            fullX + 3,
            fullY + 3
        )

end)

-- =========================================================
-- INITIALIZE
-- =========================================================

updateAppearance()
updateFullbrightAppearance()