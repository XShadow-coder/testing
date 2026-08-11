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

-- =========================================================
-- HTTP / ASSET FUNCTIONS
-- =========================================================

local httpRequest =
    request
    or http_request
    or (syn and syn.request)

local getAsset =
    getcustomasset
    or getsynasset

local function downloadImage(url, fileName)

    if not isfolder(FOLDER) then
        pcall(function()
            makefolder(FOLDER)
        end)
    end

    local path =
        FOLDER .. "/" .. fileName

    -- -----------------------------------------------------
    -- Cached asset
    -- -----------------------------------------------------

    if isfile(path) and getAsset then

        local success, asset =
            pcall(function()
                return getAsset(path)
            end)

        if success and asset then
            return asset
        end

    end

    -- -----------------------------------------------------
    -- HTTP request
    -- -----------------------------------------------------

    local body = nil

    if httpRequest then

        local success, response =
            pcall(function()

                return httpRequest({
                    Url = url,
                    Method = "GET"
                })

            end)

        if success
            and response
            and response.Body then

            body = response.Body

        end

    end

    -- -----------------------------------------------------
    -- HttpGet fallback
    -- -----------------------------------------------------

    if not body then

        local success, result =
            pcall(function()
                return game:HttpGet(url)
            end)

        if success and result then
            body = result
        end

    end

    if not body then

        warn(
            "[Shadow Toggle] Image download failed:",
            url
        )

        return nil

    end

    -- -----------------------------------------------------
    -- Write
    -- -----------------------------------------------------

    local writeSuccess =
        pcall(function()

            writefile(
                path,
                body
            )

        end)

    if not writeSuccess then

        warn(
            "[Shadow Toggle] Could not write:",
            path
        )

        return nil

    end

    -- -----------------------------------------------------
    -- Convert to Roblox asset
    -- -----------------------------------------------------

    if getAsset then

        local success, asset =
            pcall(function()
                return getAsset(path)
            end)

        if success and asset then
            return asset
        end

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

    if gethui then
        targetParent = gethui()
    end

end)

if not targetParent then
    targetParent = game:GetService("CoreGui")
end

if not targetParent then
    targetParent = LocalPlayer:WaitForChild("PlayerGui")
end

-- =========================================================
-- REMOVE PREVIOUS UI
-- =========================================================

pcall(function()

    local old =
        targetParent:FindFirstChild(
            "ShadowVisibilityFullbrightToggle"
        )

    if old then
        old:Destroy()
    end

end)

-- =========================================================
-- FIND ARCEUS X
-- =========================================================

local function findArceusX()

    local parents = {
        targetParent,
        game:GetService("CoreGui"),
        LocalPlayer:FindFirstChildOfClass(
            "PlayerGui"
        )
    }

    for _, parent in ipairs(parents) do

        if parent then

            for _, child in ipairs(
                parent:GetChildren()
            ) do

                if child:IsA("ScreenGui") then

                    local name =
                        string.lower(
                            child.Name
                        )

                    if
                        name == "arceusx"
                        or name == "arceus x"
                        or name == "arceus"
                        or string.find(
                            name,
                            "arceusx",
                            1,
                            true
                        )
                        or string.find(
                            name,
                            "arceus x",
                            1,
                            true
                        )
                    then

                        return child

                    end

                end

            end

        end

    end

    return nil

end

-- =========================================================
-- SCREEN GUI
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
    Color3.fromRGB(
        12,
        12,
        16
    )

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
-- IMAGE CONTAINER
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

visibleImage.Position =
    UDim2.fromScale(0, 0)

visibleImage.BackgroundTransparency = 1

visibleImage.Image =
    visibleAsset or ""

visibleImage.ScaleType =
    Enum.ScaleType.Fit

visibleImage.Visible =
    visibleAsset ~= nil

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
        MAIN_X + BUTTON_SIZE + 3,
        MAIN_Y + 7
    )

fullbrightShadow.BackgroundColor3 =
    Color3.fromRGB(0, 0, 0)

fullbrightShadow.BackgroundTransparency =
    0.45

fullbrightShadow.ZIndex = 1
fullbrightShadow.Parent =
    toggleGui

local fullbrightShadowCorner =
    Instance.new("UICorner")

fullbrightShadowCorner.CornerRadius =
    UDim.new(0, 15)

fullbrightShadowCorner.Parent =
    fullbrightShadow

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
        MAIN_X + BUTTON_SIZE,
        MAIN_Y + 4
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
    "InnerGradient"

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
-- LAMP CONTAINER
-- =========================================================

local lampContainer =
    Instance.new("Frame")

lampContainer.Name =
    "LampContainer"

lampContainer.AnchorPoint =
    Vector2.new(0.5, 0.5)

lampContainer.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

lampContainer.Size =
    UDim2.fromOffset(
        28,
        28
    )

lampContainer.BackgroundTransparency = 1
lampContainer.ZIndex = 11
lampContainer.Parent =
    fullbrightButton

-- =========================================================
-- LAMP SHADE
-- =========================================================

local lampShade =
    Instance.new("Frame")

lampShade.Name =
    "Shade"

lampShade.AnchorPoint =
    Vector2.new(0.5, 0)

lampShade.Position =
    UDim2.fromScale(
        0.5,
        0.08
    )

lampShade.Size =
    UDim2.fromOffset(
        18,
        11
    )

lampShade.BackgroundColor3 =
    Color3.fromRGB(
        245,
        245,
        245
    )

lampShade.BorderSizePixel = 0
lampShade.ZIndex = 12
lampShade.Parent =
    lampContainer

local lampShadeCorner =
    Instance.new("UICorner")

lampShadeCorner.CornerRadius =
    UDim.new(0, 7)

lampShadeCorner.Parent =
    lampShade

-- =========================================================
-- BLACK SHADE OUTLINE
-- =========================================================

local lampShadeStroke =
    Instance.new("UIStroke")

lampShadeStroke.Thickness = 1.5
lampShadeStroke.Color =
    Color3.fromRGB(
        25,
        25,
        25
    )

lampShadeStroke.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

lampShadeStroke.Parent =
    lampShade

-- =========================================================
-- LAMP BASE / STEM
-- =========================================================

local lampStem =
    Instance.new("Frame")

lampStem.Name =
    "Stem"

lampStem.AnchorPoint =
    Vector2.new(0.5, 0)

lampStem.Position =
    UDim2.fromScale(
        0.5,
        0.47
    )

lampStem.Size =
    UDim2.fromOffset(
        3,
        6
    )

lampStem.BackgroundColor3 =
    Color3.fromRGB(
        245,
        245,
        245
    )

lampStem.BorderSizePixel = 0
lampStem.ZIndex = 12
lampStem.Parent =
    lampContainer

local lampStemCorner =
    Instance.new("UICorner")

lampStemCorner.CornerRadius =
    UDim.new(1, 0)

lampStemCorner.Parent =
    lampStem

-- =========================================================
-- LAMP BASE
-- =========================================================

local lampBase =
    Instance.new("Frame")

lampBase.Name =
    "Base"

lampBase.AnchorPoint =
    Vector2.new(0.5, 0)

lampBase.Position =
    UDim2.fromScale(
        0.5,
        0.70
    )

lampBase.Size =
    UDim2.fromOffset(
        12,
        3
    )

lampBase.BackgroundColor3 =
    Color3.fromRGB(
        245,
        245,
        245
    )

lampBase.BorderSizePixel = 0
lampBase.ZIndex = 12
lampBase.Parent =
    lampContainer

local lampBaseCorner =
    Instance.new("UICorner")

lampBaseCorner.CornerRadius =
    UDim.new(1, 0)

lampBaseCorner.Parent =
    lampBase

-- =========================================================
-- LAMP BLACK DETAILS
-- =========================================================

local lampDetail =
    Instance.new("Frame")

lampDetail.Name =
    "Detail"

lampDetail.AnchorPoint =
    Vector2.new(0.5, 0.5)

lampDetail.Position =
    UDim2.fromScale(
        0.5,
        0.38
    )

lampDetail.Size =
    UDim2.fromOffset(
        9,
        1
    )

lampDetail.BackgroundColor3 =
    Color3.fromRGB(
        25,
        25,
        25
    )

lampDetail.BorderSizePixel = 0
lampDetail.ZIndex = 13
lampDetail.Parent =
    lampContainer

local lampDetailCorner =
    Instance.new("UICorner")

lampDetailCorner.CornerRadius =
    UDim.new(1, 0)

lampDetailCorner.Parent =
    lampDetail

-- =========================================================
-- LAMP SCALE
-- =========================================================

local fullbrightScale =
    Instance.new("UIScale")

fullbrightScale.Scale = 1
fullbrightScale.Parent =
    fullbrightButton

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
-- STATES
-- =========================================================

local hidden = false
local fullbright = false

local dragging = false
local dragStart = nil
local startPosition = nil
local movedDistance = 0

-- =========================================================
-- ORIGINAL LIGHTING
-- =========================================================

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- =========================================================
-- LIGHTING FUNCTIONS
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
-- MAIN APPEARANCE
-- =========================================================

local function updateAppearance()

    if hidden then

        visibleImage.Visible = false
        hiddenImage.Visible =
            hiddenAsset ~= nil

        border.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        border.Thickness = 2
        glow.Transparency = 1

    else

        visibleImage.Visible =
            visibleAsset ~= nil

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
-- FULLBRIGHT APPEARANCE
-- =========================================================

local function updateFullbrightAppearance()

    local onColor =
        Color3.fromRGB(
            0,
            200,
            255
        )

    local offColor =
        Color3.fromRGB(
            245,
            245,
            245
        )

    if fullbright then

        fullbrightBorder.Color = onColor
        fullbrightGlow.Color = onColor
        fullbrightGlow.Transparency = 0.65

        -- White lamp
        lampShade.BackgroundColor3 =
            Color3.fromRGB(
                255,
                255,
                255
            )

        lampStem.BackgroundColor3 =
            Color3.fromRGB(
                255,
                255,
                255
            )

        lampBase.BackgroundColor3 =
            Color3.fromRGB(
                255,
                255,
                255
            )

        TweenService:Create(
            lampDetail,
            TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                BackgroundColor3 = onColor
            }
        ):Play()

    else

        fullbrightBorder.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        fullbrightGlow.Transparency = 1

        -- White / black minimal lamp
        lampShade.BackgroundColor3 =
            offColor

        lampStem.BackgroundColor3 =
            offColor

        lampBase.BackgroundColor3 =
            offColor

        TweenService:Create(
            lampDetail,
            TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        25,
                        25,
                        25
                    )
            }
        ):Play()

    end

end

-- =========================================================
-- CLICK ANIMATION
-- =========================================================

local function clickAnimation(targetScale)

    local down =
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

    local up =
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

    down:Play()

    down.Completed:Once(function()
        up:Play()
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
                        1,
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
                        1,
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

    end)

end

-- =========================================================
-- MAIN DRAG START
-- =========================================================

button.InputBegan:Connect(function(input)

    if
        input.UserInputType ==
            Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
            Enum.UserInputType.Touch
    then

        dragging = true
        dragStart = input.Position
        startPosition = button.Position
        movedDistance = 0

    end

end)

-- =========================================================
-- POSITION CLAMP
-- =========================================================

local function clampPosition(x, y)

    local viewport =
        workspace.CurrentCamera.ViewportSize

    -- Full group width
    local groupWidth =
        BUTTON_SIZE
        + FULLBRIGHT_SIZE

    local maxX =
        viewport.X
        - groupWidth
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
-- UPDATE GROUP POSITION
-- =========================================================

local function updateGroupPosition(x, y)

    x, y =
        clampPosition(
            x,
            y
        )

    -- -----------------------------------------------------
    -- Main
    -- -----------------------------------------------------

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

    -- -----------------------------------------------------
    -- Fullbright
    -- ZERO GAP
    -- -----------------------------------------------------

    local fullX =
        x + BUTTON_SIZE

    local fullY =
        y + 4

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

end

-- =========================================================
-- DRAG MOVEMENT
-- =========================================================

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if
        input.UserInputType ~=
            Enum.UserInputType.MouseMovement
        and
        input.UserInputType ~=
            Enum.UserInputType.Touch
    then

        return

    end

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

    updateGroupPosition(
        newX,
        newY
    )

end)

-- =========================================================
-- DRAG END / MAIN CLICK
-- =========================================================

UserInputService.InputEnded:Connect(function(input)

    if
        input.UserInputType ~=
            Enum.UserInputType.MouseButton1
        and
        input.UserInputType ~=
            Enum.UserInputType.Touch
    then

        return

    end

    if not dragging then
        return
    end

    dragging = false

    if movedDistance <
        DRAG_THRESHOLD then

        clickAnimation(scale)

        hidden =
            not hidden

        local arceusGui =
            findArceusX()

        if arceusGui then

            arceusGui.Enabled =
                not hidden

        else

            warn(
                "[Shadow Toggle] Arceus X GUI not found."
            )

        end

        updateAppearance()

    end

end)

-- =========================================================
-- FULLBRIGHT CLICK
-- =========================================================

fullbrightButton.Activated:Connect(function()

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

end)

-- =========================================================
-- VIEWPORT CHANGE
-- =========================================================

workspace.CurrentCamera:GetPropertyChangedSignal(
    "ViewportSize"
):Connect(function()

    updateGroupPosition(
        button.Position.X.Offset,
        button.Position.Y.Offset
    )

end)

-- =========================================================
-- INITIALIZE
-- =========================================================

updateGroupPosition(
    MAIN_X,
    MAIN_Y
)

updateAppearance()
updateFullbrightAppearance()

print(
    "[Shadow Toggle] Loaded successfully."
)