-- =========================================================
-- SHADOW TOGGLE
-- ARCEUS X + FULLBRIGHT
-- PREMIUM RECTANGULAR UI | PC + MOBILE
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

local ASSET_FOLDER = "ShadowToggle"

-- ---------------------------------------------------------
-- UI SIZE
-- ---------------------------------------------------------

local UI_WIDTH = 112
local UI_HEIGHT = 54

local ARCEUS_SIZE = 54
local STAR_AREA_SIZE = 46

local EDGE_PADDING = 10
local DRAG_THRESHOLD = 8

local START_X = 20
local START_Y = 100

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

    -- -----------------------------------------------------
    -- Folder
    -- -----------------------------------------------------

    if not isfolder(ASSET_FOLDER) then

        pcall(function()
            makefolder(ASSET_FOLDER)
        end)

    end

    local path =
        ASSET_FOLDER .. "/" .. fileName

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

    -- -----------------------------------------------------
    -- Failed
    -- -----------------------------------------------------

    if not body then

        warn(
            "[ShadowToggle] Could not download:",
            url
        )

        return nil

    end

    -- -----------------------------------------------------
    -- Write file
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
            "[ShadowToggle] Could not write:",
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
-- LOAD ARCEUS IMAGES
-- =========================================================

local visibleAsset =
    downloadImage(
        VISIBLE_URL,
        "arceus_visible.png"
    )

local hiddenAsset =
    downloadImage(
        HIDDEN_URL,
        "arceus_hidden.png"
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
    targetParent =
        LocalPlayer:WaitForChild(
            "PlayerGui"
        )
end

-- =========================================================
-- REMOVE OLD GUI
-- =========================================================

pcall(function()

    local oldGui =
        targetParent:FindFirstChild(
            "ShadowToggle"
        )

    if oldGui then
        oldGui:Destroy()
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
-- MAIN SCREEN GUI
-- =========================================================

local shadowGui =
    Instance.new("ScreenGui")

shadowGui.Name =
    "ShadowToggle"

shadowGui.ResetOnSpawn = false
shadowGui.IgnoreGuiInset = true
shadowGui.DisplayOrder = 2147483647
shadowGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

shadowGui.Parent =
    targetParent

-- =========================================================
-- MAIN SHADOW
-- =========================================================

local shadow =
    Instance.new("Frame")

shadow.Name =
    "Shadow"

shadow.Size =
    UDim2.fromOffset(
        UI_WIDTH + 8,
        UI_HEIGHT + 8
    )

shadow.Position =
    UDim2.fromOffset(
        START_X + 3,
        START_Y + 3
    )

shadow.BackgroundColor3 =
    Color3.fromRGB(
        0,
        0,
        0
    )

shadow.BackgroundTransparency =
    0.42

shadow.ZIndex = 1
shadow.Parent = shadowGui

local shadowCorner =
    Instance.new("UICorner")

shadowCorner.CornerRadius =
    UDim.new(
        0,
        16
    )

shadowCorner.Parent =
    shadow

-- =========================================================
-- MAIN RECTANGLE
-- =========================================================

local main =
    Instance.new("Frame")

main.Name =
    "Main"

main.Size =
    UDim2.fromOffset(
        UI_WIDTH,
        UI_HEIGHT
    )

main.Position =
    UDim2.fromOffset(
        START_X,
        START_Y
    )

main.BackgroundColor3 =
    Color3.fromRGB(
        12,
        12,
        16
    )

main.BackgroundTransparency = 0

main.Active = true

main.ZIndex = 5
main.Parent = shadowGui

-- =========================================================
-- MAIN CORNER
-- =========================================================

local mainCorner =
    Instance.new("UICorner")

mainCorner.CornerRadius =
    UDim.new(
        0,
        14
    )

mainCorner.Parent =
    main

-- =========================================================
-- MAIN GRADIENT
-- =========================================================

local mainGradient =
    Instance.new("UIGradient")

mainGradient.Name =
    "Gradient"

mainGradient.Color =
    ColorSequence.new({

        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(
                7,
                7,
                10
            )
        ),

        ColorSequenceKeypoint.new(
            0.5,
            Color3.fromRGB(
                30,
                30,
                38
            )
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(
                7,
                7,
                10
            )
        )

    })

mainGradient.Rotation = 0

mainGradient.Parent =
    main

-- =========================================================
-- MAIN BORDER
-- =========================================================

local mainBorder =
    Instance.new("UIStroke")

mainBorder.Name =
    "Border"

mainBorder.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

mainBorder.Thickness = 2

mainBorder.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

mainBorder.Parent =
    main

-- =========================================================
-- MAIN GLOW
-- =========================================================

local mainGlow =
    Instance.new("UIStroke")

mainGlow.Name =
    "Glow"

mainGlow.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

mainGlow.Thickness = 5

mainGlow.Transparency =
    0.72

mainGlow.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

mainGlow.Parent =
    main

-- =========================================================
-- MAIN SCALE
-- =========================================================

local mainScale =
    Instance.new("UIScale")

mainScale.Scale = 1

mainScale.Parent =
    main

-- =========================================================
-- ARCEUS IMAGE BUTTON
-- =========================================================

local arceusButton =
    Instance.new("ImageButton")

arceusButton.Name =
    "ArceusToggle"

arceusButton.Size =
    UDim2.fromOffset(
        ARCEUS_SIZE,
        ARCEUS_SIZE
    )

arceusButton.Position =
    UDim2.fromOffset(
        0,
        0
    )

arceusButton.BackgroundTransparency =
    1

arceusButton.Image = ""

arceusButton.AutoButtonColor =
    false

arceusButton.ZIndex = 7

arceusButton.Parent =
    main

-- =========================================================
-- ARCEUS IMAGE CONTAINER
-- =========================================================

local imageContainer =
    Instance.new("Frame")

imageContainer.Name =
    "ImageContainer"

imageContainer.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

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

imageContainer.BackgroundTransparency =
    1

imageContainer.ZIndex = 8

imageContainer.Parent =
    arceusButton

local imageContainerCorner =
    Instance.new("UICorner")

imageContainerCorner.CornerRadius =
    UDim.new(
        0,
        11
    )

imageContainerCorner.Parent =
    imageContainer

-- =========================================================
-- VISIBLE ARCEUS IMAGE
-- =========================================================

local visibleImage =
    Instance.new("ImageLabel")

visibleImage.Name =
    "VisibleImage"

visibleImage.Size =
    UDim2.fromScale(
        1,
        1
    )

visibleImage.BackgroundTransparency =
    1

visibleImage.Image =
    visibleAsset or ""

visibleImage.ScaleType =
    Enum.ScaleType.Fit

visibleImage.Visible =
    visibleAsset ~= nil

visibleImage.ZIndex = 9

visibleImage.Parent =
    imageContainer

local visibleCorner =
    Instance.new("UICorner")

visibleCorner.CornerRadius =
    UDim.new(
        0,
        11
    )

visibleCorner.Parent =
    visibleImage

-- =========================================================
-- HIDDEN ARCEUS IMAGE
-- =========================================================

local hiddenImage =
    Instance.new("ImageLabel")

hiddenImage.Name =
    "HiddenImage"

hiddenImage.Size =
    UDim2.fromScale(
        1,
        1
    )

hiddenImage.BackgroundTransparency =
    1

hiddenImage.Image =
    hiddenAsset or ""

hiddenImage.ScaleType =
    Enum.ScaleType.Fit

hiddenImage.Visible = false

hiddenImage.ZIndex = 9

hiddenImage.Parent =
    imageContainer

local hiddenCorner =
    Instance.new("UICorner")

hiddenCorner.CornerRadius =
    UDim.new(
        0,
        11
    )

hiddenCorner.Parent =
    hiddenImage

-- =========================================================
-- SEPARATOR
-- =========================================================

local separator =
    Instance.new("Frame")

separator.Name =
    "Separator"

separator.Size =
    UDim2.fromOffset(
        1,
        28
    )

separator.Position =
    UDim2.fromOffset(
        ARCEUS_SIZE,
        13
    )

separator.BackgroundColor3 =
    Color3.fromRGB(
        65,
        65,
        72
    )

separator.BackgroundTransparency =
    0.35

separator.BorderSizePixel = 0

separator.ZIndex = 8

separator.Parent =
    main

-- =========================================================
-- FULLBRIGHT BUTTON
-- =========================================================

local fullbrightButton =
    Instance.new("ImageButton")

fullbrightButton.Name =
    "FullbrightToggle"

fullbrightButton.Size =
    UDim2.fromOffset(
        STAR_AREA_SIZE,
        UI_HEIGHT
    )

fullbrightButton.Position =
    UDim2.fromOffset(
        ARCEUS_SIZE + 1,
        0
    )

fullbrightButton.BackgroundTransparency =
    1

fullbrightButton.Image = ""

fullbrightButton.AutoButtonColor =
    false

fullbrightButton.ZIndex = 7

fullbrightButton.Parent =
    main

-- =========================================================
-- STAR ICON
-- =========================================================

local star =
    Instance.new("TextLabel")

star.Name =
    "Star"

star.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

star.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

star.Size =
    UDim2.fromOffset(
        29,
        29
    )

star.BackgroundTransparency =
    1

star.Text =
    "★"

star.TextScaled = true

star.Font =
    Enum.Font.GothamBold

star.TextColor3 =
    Color3.fromRGB(
        235,
        235,
        240
    )

star.ZIndex = 9

star.Parent =
    fullbrightButton

-- =========================================================
-- STAR OUTLINE
-- =========================================================

local starStroke =
    Instance.new("UIStroke")

starStroke.Thickness =
    1.2

starStroke.Color =
    Color3.fromRGB(
        15,
        15,
        18
    )

starStroke.Transparency =
    0.15

starStroke.Parent =
    star

-- =========================================================
-- FULLBRIGHT INDICATOR
-- =========================================================

local starGlow =
    Instance.new("UIStroke")

starGlow.Name =
    "StarGlow"

starGlow.Thickness =
    0.8

starGlow.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

starGlow.Transparency = 1

starGlow.Parent =
    star

-- =========================================================
-- FULLBRIGHT SCALE
-- =========================================================

local fullbrightScale =
    Instance.new("UIScale")

fullbrightScale.Scale = 1

fullbrightScale.Parent =
    fullbrightButton

-- =========================================================
-- FULLBRIGHT INTERNAL BORDER
-- =========================================================

local fullbrightBorder =
    Instance.new("UIStroke")

fullbrightBorder.Name =
    "FullbrightBorder"

fullbrightBorder.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

fullbrightBorder.Thickness = 1

fullbrightBorder.Transparency = 1

fullbrightBorder.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

fullbrightBorder.Parent =
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

local arceusHidden = false
local fullbrightEnabled = false

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
-- ARCEUS APPEARANCE
-- =========================================================

local function updateArceusAppearance()

    if arceusHidden then

        visibleImage.Visible = false

        hiddenImage.Visible =
            hiddenAsset ~= nil

        mainBorder.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        mainGlow.Transparency = 1

    else

        visibleImage.Visible =
            visibleAsset ~= nil

        hiddenImage.Visible = false

        mainBorder.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        mainGlow.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        mainGlow.Transparency =
            0.72

    end

end

-- =========================================================
-- FULLBRIGHT APPEARANCE
-- =========================================================

local function updateFullbrightAppearance()

    if fullbrightEnabled then

        star.TextColor3 =
            Color3.fromRGB(
                255,
                255,
                255
            )

        starGlow.Transparency =
            0

        fullbrightBorder.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        fullbrightBorder.Transparency =
            0.55

    else

        star.TextColor3 =
            Color3.fromRGB(
                235,
                235,
                240
            )

        starGlow.Transparency =
            1

        fullbrightBorder.Transparency =
            1

    end

end

-- =========================================================
-- CLICK ANIMATION
-- =========================================================

local function clickAnimation(target)

    local down =
        TweenService:Create(
            target,
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
            target,
            TweenInfo.new(
                0.11,
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

    while shadowGui.Parent do

        if not arceusHidden then

            local inTween =
                TweenService:Create(
                    mainGlow,
                    TweenInfo.new(
                        1.1,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.52
                    }
                )

            local outTween =
                TweenService:Create(
                    mainGlow,
                    TweenInfo.new(
                        1.1,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.78
                    }
                )

            inTween:Play()
            inTween.Completed:Wait()

            if arceusHidden then
                continue
            end

            outTween:Play()
            outTween.Completed:Wait()

        else

            task.wait(0.25)

        end

    end

end)

-- =========================================================
-- FULLBRIGHT STAR PULSE
-- =========================================================

task.spawn(function()

    while shadowGui.Parent do

        if fullbrightEnabled then

            local inTween =
                TweenService:Create(
                    starGlow,
                    TweenInfo.new(
                        0.9,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.15
                    }
                )

            local outTween =
                TweenService:Create(
                    starGlow,
                    TweenInfo.new(
                        0.9,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.55
                    }
                )

            inTween:Play()
            inTween.Completed:Wait()

            if not fullbrightEnabled then
                continue
            end

            outTween:Play()
            outTween.Completed:Wait()

        else

            task.wait(0.25)

        end

    end

end)

-- =========================================================
-- HOVER
-- =========================================================

if not UserInputService.TouchEnabled then

    main.MouseEnter:Connect(function()

        TweenService:Create(
            mainScale,
            TweenInfo.new(
                0.15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Scale = 1.04
            }
        ):Play()

    end)

    main.MouseLeave:Connect(function()

        if not dragging then

            TweenService:Create(
                mainScale,
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
                Scale = 1.08
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
-- DRAG START
-- =========================================================

main.InputBegan:Connect(function(input)

    if
        input.UserInputType ==
            Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
            Enum.UserInputType.Touch
    then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            main.Position

        movedDistance = 0

    end

end)

-- =========================================================
-- POSITION CLAMP
-- =========================================================

local function clampPosition(x, y)

    local camera =
        workspace.CurrentCamera

    if not camera then
        return x, y
    end

    local viewport =
        camera.ViewportSize

    local maxX =
        viewport.X
        - UI_WIDTH
        - EDGE_PADDING

    local maxY =
        viewport.Y
        - UI_HEIGHT
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
-- UPDATE POSITION
-- =========================================================

local function updatePosition(x, y)

    x, y =
        clampPosition(
            x,
            y
        )

    main.Position =
        UDim2.fromOffset(
            x,
            y
        )

    shadow.Position =
        UDim2.fromOffset(
            x + 3,
            y + 3
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

    updatePosition(
        newX,
        newY
    )

end)

-- =========================================================
-- INPUT ENDED
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

    -- -----------------------------------------------------
    -- CLICK ON ARCEUS IMAGE
    -- -----------------------------------------------------

    if movedDistance <
        DRAG_THRESHOLD then

        clickAnimation(
            mainScale
        )

        arceusHidden =
            not arceusHidden

        local arceusGui =
            findArceusX()

        if arceusGui then

            arceusGui.Enabled =
                not arceusHidden

        else

            warn(
                "[ShadowToggle] Arceus X GUI not found."
            )

        end

        updateArceusAppearance()

    end

end)

-- =========================================================
-- FULLBRIGHT CLICK
-- =========================================================

fullbrightButton.Activated:Connect(function()

    clickAnimation(
        fullbrightScale
    )

    fullbrightEnabled =
        not fullbrightEnabled

    if fullbrightEnabled then

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

    updatePosition(
        main.Position.X.Offset,
        main.Position.Y.Offset
    )

end)

-- =========================================================
-- INITIALIZE
-- =========================================================

updatePosition(
    START_X,
    START_Y
)

updateArceusAppearance()
updateFullbrightAppearance()

print(
    "[ShadowToggle] Loaded."
)