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

local UI_WIDTH = 112
local UI_HEIGHT = 54

local ARCEUS_SIZE = 54
local STAR_AREA_SIZE = 58

local EDGE_PADDING = 10
local DRAG_THRESHOLD = 8

local START_X = 20
local START_Y = 100

-- =========================================================
-- HTTP / ASSET
-- =========================================================

local httpRequest =
    request
    or http_request
    or (syn and syn.request)

local getAsset =
    getcustomasset
    or getsynasset

local function downloadImage(url, fileName)

    if not isfolder(ASSET_FOLDER) then

        pcall(function()
            makefolder(ASSET_FOLDER)
        end)

    end

    local path =
        ASSET_FOLDER .. "/" .. fileName

    -- -----------------------------------------------------
    -- CACHE
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
    -- REQUEST
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
    -- FALLBACK
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
            "[ShadowToggle] Image download failed:",
            url
        )

        return nil

    end

    -- -----------------------------------------------------
    -- WRITE
    -- -----------------------------------------------------

    local success =
        pcall(function()

            writefile(
                path,
                body
            )

        end)

    if not success then

        warn(
            "[ShadowToggle] Cannot write:",
            path
        )

        return nil

    end

    -- -----------------------------------------------------
    -- ASSET
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

    local old =
        targetParent:FindFirstChild(
            "ShadowToggle"
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
-- SHADOW
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
-- GRADIENT
-- =========================================================

local mainGradient =
    Instance.new("UIGradient")

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
-- BORDER
-- =========================================================

local mainBorder =
    Instance.new("UIStroke")

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
-- GLOW
-- =========================================================

local mainGlow =
    Instance.new("UIStroke")

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
-- SCALE
-- =========================================================

local mainScale =
    Instance.new("UIScale")

mainScale.Scale = 1
mainScale.Parent = main

-- =========================================================
-- ARCEUS BUTTON
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
-- IMAGE CONTAINER
-- =========================================================

local imageContainer =
    Instance.new("Frame")

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
-- VISIBLE IMAGE
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
-- HIDDEN IMAGE
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
-- STAR
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
        28,
        28
    )

star.BackgroundTransparency =
    1

-- OFF = EMPTY STAR
star.Text =
    "☆"

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
-- STAR NEON GLOW
-- =========================================================

local starGlow =
    Instance.new("UIStroke")

starGlow.Name =
    "NeonGlow"

starGlow.Thickness = 1.5

starGlow.Color =
    Color3.fromRGB(
        0,
        210,
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

-- =========================================================
-- INPUT STATE
-- =========================================================

local dragging = false

local dragInput = nil
local dragStart = nil
local startPosition = nil

local movedDistance = 0

local inputOwner = nil

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
-- LIGHTING
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

        -- -------------------------------------------------
        -- FILLED STAR
        -- -------------------------------------------------

        star.Text =
            "★"

        star.TextColor3 =
            Color3.fromRGB(
                0,
                220,
                255
            )

        -- -------------------------------------------------
        -- NEON
        -- -------------------------------------------------

        starGlow.Color =
            Color3.fromRGB(
                0,
                220,
                255
            )

        starGlow.Transparency =
            0.05

    else

        -- -------------------------------------------------
        -- EMPTY STAR
        -- -------------------------------------------------

        star.Text =
            "☆"

        star.TextColor3 =
            Color3.fromRGB(
                235,
                235,
                240
            )

        -- -------------------------------------------------
        -- NO NEON
        -- -------------------------------------------------

        starGlow.Transparency =
            1

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

            local tweenIn =
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

            local tweenOut =
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

            tweenIn:Play()
            tweenIn.Completed:Wait()

            if arceusHidden then
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
-- STAR NEON PULSE
-- =========================================================

task.spawn(function()

    while shadowGui.Parent do

        if fullbrightEnabled then

            local tweenIn =
                TweenService:Create(
                    starGlow,
                    TweenInfo.new(
                        0.8,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.0
                    }
                )

            local tweenOut =
                TweenService:Create(
                    starGlow,
                    TweenInfo.new(
                        0.8,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        Transparency = 0.45
                    }
                )

            tweenIn:Play()
            tweenIn.Completed:Wait()

            if not fullbrightEnabled then
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

end

-- =========================================================
-- BEGIN DRAG / CLICK DETECTION
-- =========================================================

local function beginInteraction(input, owner)

    if
        input.UserInputType ~=
            Enum.UserInputType.MouseButton1
        and
        input.UserInputType ~=
            Enum.UserInputType.Touch
    then

        return

    end

    dragging = true

    dragInput = input

    dragStart =
        input.Position

    startPosition =
        main.Position

    movedDistance = 0

    inputOwner = owner

end

-- =========================================================
-- MAIN INTERACTION
-- =========================================================

main.InputBegan:Connect(function(input)

    beginInteraction(
        input,
        "main"
    )

end)

-- =========================================================
-- ARCEUS INTERACTION
-- =========================================================

arceusButton.InputBegan:Connect(function(input)

    beginInteraction(
        input,
        "arceus"
    )

end)

-- =========================================================
-- FULLBRIGHT INTERACTION
-- =========================================================

fullbrightButton.InputBegan:Connect(function(input)

    beginInteraction(
        input,
        "fullbright"
    )

end)

-- =========================================================
-- DRAG MOVEMENT
-- =========================================================

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    local movementInput = input

    if
        input.UserInputType ==
            Enum.UserInputType.MouseMovement
        or
        input.UserInputType ==
            Enum.UserInputType.Touch
    then

        local delta =
            movementInput.Position
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

        local camera =
            workspace.CurrentCamera

        if not camera then
            return
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

        newX =
            math.clamp(
                newX,
                EDGE_PADDING,
                maxX
            )

        newY =
            math.clamp(
                newY,
                EDGE_PADDING,
                maxY
            )

        main.Position =
            UDim2.fromOffset(
                newX,
                newY
            )

        shadow.Position =
            UDim2.fromOffset(
                newX + 3,
                newY + 3
            )

    end

end)

-- =========================================================
-- END INTERACTION
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

    -- =====================================================
    -- CLICK
    -- =====================================================

    if movedDistance <
        DRAG_THRESHOLD then

        -- -------------------------------------------------
        -- ARCEUS CLICK
        -- -------------------------------------------------

        if inputOwner == "arceus"
            or inputOwner == "main"
        then

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

        -- -------------------------------------------------
        -- FULLBRIGHT CLICK
        -- -------------------------------------------------

        if inputOwner == "fullbright" then

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

        end

    end

    inputOwner = nil
    dragInput = nil

end)

-- =========================================================
-- VIEWPORT
-- =========================================================

workspace.CurrentCamera:GetPropertyChangedSignal(
    "ViewportSize"
):Connect(function()

    local camera =
        workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport =
        camera.ViewportSize

    local x =
        main.Position.X.Offset

    local y =
        main.Position.Y.Offset

    local maxX =
        viewport.X
        - UI_WIDTH
        - EDGE_PADDING

    local maxY =
        viewport.Y
        - UI_HEIGHT
        - EDGE_PADDING

    x =
        math.clamp(
            x,
            EDGE_PADDING,
            maxX
        )

    y =
        math.clamp(
            y,
            EDGE_PADDING,
            maxY
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

end)

-- =========================================================
-- INITIALIZE
-- =========================================================

main.Position =
    UDim2.fromOffset(
        START_X,
        START_Y
    )

shadow.Position =
    UDim2.fromOffset(
        START_X + 3,
        START_Y + 3
    )

updateArceusAppearance()
updateFullbrightAppearance()

print(
    "[ShadowToggle] Loaded successfully."
)