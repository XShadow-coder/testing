-- =========================================================
-- SHDW_FBL_8K4P
-- ARCEUS X DRAG + FULLBRIGHT
-- ISOLATED UI | PC + MOBILE
-- =========================================================

local Players_8K4P = game:GetService("Players")
local UserInputService_8K4P =
    game:GetService("UserInputService")
local ContentProvider_8K4P =
    game:GetService("ContentProvider")
local TweenService_8K4P =
    game:GetService("TweenService")
local Lighting_8K4P =
    game:GetService("Lighting")

local LocalPlayer_8K4P =
    Players_8K4P.LocalPlayer

-- =========================================================
-- CONFIG
-- =========================================================

local VISIBLE_URL_8K4P =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4700.png"

local HIDDEN_URL_8K4P =
    "https://raw.githubusercontent.com/XShadow-coder/ArceusXUIToggle/refs/heads/main/IMG_4701.png"

local ASSET_FOLDER_8K4P =
    "SHDW_FBL_8K4P"

local GUI_NAME_8K4P =
    "SHDW_FBL_Controller_8K4P"

local UI_WIDTH_8K4P = 112
local UI_HEIGHT_8K4P = 54

local ARCEUS_SIZE_8K4P = 54
local STAR_AREA_SIZE_8K4P = 58

local EDGE_PADDING_8K4P = 10
local DRAG_THRESHOLD_8K4P = 8

local START_X_8K4P = 20
local START_Y_8K4P = 100

-- =========================================================
-- ASSET API
-- =========================================================

local httpRequest_8K4P =
    request
    or http_request
    or (syn and syn.request)

local getAsset_8K4P =
    getcustomasset
    or getsynasset

-- =========================================================
-- DOWNLOAD IMAGE
-- =========================================================

local function downloadImage_8K4P(
    url,
    fileName
)

    if not isfolder(ASSET_FOLDER_8K4P) then

        pcall(function()

            makefolder(
                ASSET_FOLDER_8K4P
            )

        end)

    end

    local path =
        ASSET_FOLDER_8K4P
        .. "/"
        .. fileName

    -- -----------------------------------------------------
    -- CACHE
    -- -----------------------------------------------------

    if isfile(path)
        and getAsset_8K4P then

        local success, asset =
            pcall(function()

                return getAsset_8K4P(path)

            end)

        if success and asset then
            return asset
        end

    end

    -- -----------------------------------------------------
    -- REQUEST
    -- -----------------------------------------------------

    local body

    if httpRequest_8K4P then

        local success, response =
            pcall(function()

                return httpRequest_8K4P({
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
            "[SHDW_FBL_8K4P] Image download failed."
        )

        return nil

    end

    -- -----------------------------------------------------
    -- WRITE
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
            "[SHDW_FBL_8K4P] File write failed."
        )

        return nil

    end

    -- -----------------------------------------------------
    -- ASSET
    -- -----------------------------------------------------

    if getAsset_8K4P then

        local success, asset =
            pcall(function()

                return getAsset_8K4P(path)

            end)

        if success and asset then
            return asset
        end

    end

    return nil

end

-- =========================================================
-- LOAD ASSETS
-- =========================================================

local visibleAsset_8K4P =
    downloadImage_8K4P(
        VISIBLE_URL_8K4P,
        "arceus_visible.png"
    )

local hiddenAsset_8K4P =
    downloadImage_8K4P(
        HIDDEN_URL_8K4P,
        "arceus_hidden.png"
    )

-- =========================================================
-- FIND UI PARENT
-- =========================================================

local targetParent_8K4P

pcall(function()

    if gethui then

        targetParent_8K4P =
            gethui()

    end

end)

if not targetParent_8K4P then

    targetParent_8K4P =
        game:GetService("CoreGui")

end

if not targetParent_8K4P then

    targetParent_8K4P =
        LocalPlayer_8K4P:WaitForChild(
            "PlayerGui"
        )

end

-- =========================================================
-- REMOVE ONLY OUR OWN GUI
-- =========================================================

pcall(function()

    local oldGui_8K4P =
        targetParent_8K4P:FindFirstChild(
            GUI_NAME_8K4P
        )

    if oldGui_8K4P then

        oldGui_8K4P:Destroy()

    end

end)

-- =========================================================
-- ARCEUS GUI FINDER
-- =========================================================

local function findArceusX_8K4P()

    local parents_8K4P = {

        targetParent_8K4P,

        game:GetService(
            "CoreGui"
        ),

        LocalPlayer_8K4P:
            FindFirstChildOfClass(
                "PlayerGui"
            )

    }

    for _, parent_8K4P in
        ipairs(parents_8K4P)
    do

        if parent_8K4P then

            for _, child_8K4P in
                ipairs(
                    parent_8K4P:GetChildren()
                )
            do

                if child_8K4P:IsA(
                    "ScreenGui"
                ) then

                    local lowerName_8K4P =
                        string.lower(
                            child_8K4P.Name
                        )

                    if
                        lowerName_8K4P ==
                            "arceusx"
                        or
                        lowerName_8K4P ==
                            "arceus x"
                        or
                        lowerName_8K4P ==
                            "arceus"
                        or
                        string.find(
                            lowerName_8K4P,
                            "arceusx",
                            1,
                            true
                        )
                        or
                        string.find(
                            lowerName_8K4P,
                            "arceus x",
                            1,
                            true
                        )
                    then

                        return child_8K4P

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

local shadowGui_8K4P =
    Instance.new("ScreenGui")

shadowGui_8K4P.Name =
    GUI_NAME_8K4P

shadowGui_8K4P.ResetOnSpawn =
    false

shadowGui_8K4P.IgnoreGuiInset =
    true

shadowGui_8K4P.DisplayOrder =
    2147483647

shadowGui_8K4P.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

shadowGui_8K4P.Parent =
    targetParent_8K4P

-- =========================================================
-- SHADOW
-- =========================================================

local shadow_8K4P =
    Instance.new("Frame")

shadow_8K4P.Name =
    "SHDW_FBL_Shadow_8K4P"

shadow_8K4P.Size =
    UDim2.fromOffset(
        UI_WIDTH_8K4P + 8,
        UI_HEIGHT_8K4P + 8
    )

shadow_8K4P.Position =
    UDim2.fromOffset(
        START_X_8K4P + 3,
        START_Y_8K4P + 3
    )

shadow_8K4P.BackgroundColor3 =
    Color3.fromRGB(
        0,
        0,
        0
    )

shadow_8K4P.BackgroundTransparency =
    0.42

shadow_8K4P.BorderSizePixel = 0

shadow_8K4P.ZIndex = 1

shadow_8K4P.Parent =
    shadowGui_8K4P

local shadowCorner_8K4P =
    Instance.new("UICorner")

shadowCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        16
    )

shadowCorner_8K4P.Parent =
    shadow_8K4P

-- =========================================================
-- MAIN PANEL
-- =========================================================

local panel_8K4P =
    Instance.new("Frame")

panel_8K4P.Name =
    "SHDW_FBL_Panel_8K4P"

panel_8K4P.Size =
    UDim2.fromOffset(
        UI_WIDTH_8K4P,
        UI_HEIGHT_8K4P
    )

panel_8K4P.Position =
    UDim2.fromOffset(
        START_X_8K4P,
        START_Y_8K4P
    )

panel_8K4P.BackgroundColor3 =
    Color3.fromRGB(
        12,
        12,
        16
    )

panel_8K4P.BorderSizePixel = 0

panel_8K4P.ZIndex = 5

panel_8K4P.Parent =
    shadowGui_8K4P

local panelCorner_8K4P =
    Instance.new("UICorner")

panelCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        14
    )

panelCorner_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- GRADIENT
-- =========================================================

local panelGradient_8K4P =
    Instance.new("UIGradient")

panelGradient_8K4P.Name =
    "SHDW_FBL_Gradient_8K4P"

panelGradient_8K4P.Color =
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

panelGradient_8K4P.Rotation = 0

panelGradient_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- PANEL BORDER
-- =========================================================

local panelBorder_8K4P =
    Instance.new("UIStroke")

panelBorder_8K4P.Name =
    "SHDW_FBL_Border_8K4P"

panelBorder_8K4P.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

panelBorder_8K4P.Thickness = 2

panelBorder_8K4P.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

panelBorder_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- PANEL GLOW
-- =========================================================

local panelGlow_8K4P =
    Instance.new("UIStroke")

panelGlow_8K4P.Name =
    "SHDW_FBL_Glow_8K4P"

panelGlow_8K4P.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

panelGlow_8K4P.Thickness = 5

panelGlow_8K4P.Transparency =
    0.72

panelGlow_8K4P.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

panelGlow_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- SCALE
-- =========================================================

local panelScale_8K4P =
    Instance.new("UIScale")

panelScale_8K4P.Scale = 1

panelScale_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- ARCEUS DRAG AREA
-- =========================================================

local arceusDrag_8K4P =
    Instance.new("ImageButton")

arceusDrag_8K4P.Name =
    "SHDW_FBL_ArceusDrag_8K4P"

arceusDrag_8K4P.Size =
    UDim2.fromOffset(
        ARCEUS_SIZE_8K4P,
        ARCEUS_SIZE_8K4P
    )

arceusDrag_8K4P.Position =
    UDim2.fromOffset(
        0,
        0
    )

arceusDrag_8K4P.BackgroundTransparency =
    1

arceusDrag_8K4P.Image = ""

arceusDrag_8K4P.AutoButtonColor =
    false

arceusDrag_8K4P.Active = true

arceusDrag_8K4P.ZIndex = 10

arceusDrag_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- IMAGE CONTAINER
-- =========================================================

local imageContainer_8K4P =
    Instance.new("Frame")

imageContainer_8K4P.Name =
    "SHDW_FBL_ImageContainer_8K4P"

imageContainer_8K4P.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

imageContainer_8K4P.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

imageContainer_8K4P.Size =
    UDim2.fromOffset(
        38,
        38
    )

imageContainer_8K4P.BackgroundTransparency =
    1

imageContainer_8K4P.ZIndex = 11

imageContainer_8K4P.Parent =
    arceusDrag_8K4P

local imageCorner_8K4P =
    Instance.new("UICorner")

imageCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        11
    )

imageCorner_8K4P.Parent =
    imageContainer_8K4P

-- =========================================================
-- VISIBLE IMAGE
-- =========================================================

local visibleImage_8K4P =
    Instance.new("ImageLabel")

visibleImage_8K4P.Name =
    "SHDW_FBL_VisibleImage_8K4P"

visibleImage_8K4P.Size =
    UDim2.fromScale(
        1,
        1
    )

visibleImage_8K4P.BackgroundTransparency =
    1

visibleImage_8K4P.Image =
    visibleAsset_8K4P or ""

visibleImage_8K4P.ScaleType =
    Enum.ScaleType.Fit

visibleImage_8K4P.Visible =
    visibleAsset_8K4P ~= nil

visibleImage_8K4P.Active =
    false

visibleImage_8K4P.ZIndex = 12

visibleImage_8K4P.Parent =
    imageContainer_8K4P

local visibleCorner_8K4P =
    Instance.new("UICorner")

visibleCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        11
    )

visibleCorner_8K4P.Parent =
    visibleImage_8K4P

-- =========================================================
-- HIDDEN IMAGE
-- =========================================================

local hiddenImage_8K4P =
    Instance.new("ImageLabel")

hiddenImage_8K4P.Name =
    "SHDW_FBL_HiddenImage_8K4P"

hiddenImage_8K4P.Size =
    UDim2.fromScale(
        1,
        1
    )

hiddenImage_8K4P.BackgroundTransparency =
    1

hiddenImage_8K4P.Image =
    hiddenAsset_8K4P or ""

hiddenImage_8K4P.ScaleType =
    Enum.ScaleType.Fit

hiddenImage_8K4P.Visible = false

hiddenImage_8K4P.Active =
    false

hiddenImage_8K4P.ZIndex = 12

hiddenImage_8K4P.Parent =
    imageContainer_8K4P

local hiddenCorner_8K4P =
    Instance.new("UICorner")

hiddenCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        11
    )

hiddenCorner_8K4P.Parent =
    hiddenImage_8K4P

-- =========================================================
-- SEPARATOR
-- =========================================================

local separator_8K4P =
    Instance.new("Frame")

separator_8K4P.Name =
    "SHDW_FBL_Separator_8K4P"

separator_8K4P.Size =
    UDim2.fromOffset(
        1,
        28
    )

separator_8K4P.Position =
    UDim2.fromOffset(
        ARCEUS_SIZE_8K4P,
        13
    )

separator_8K4P.BackgroundColor3 =
    Color3.fromRGB(
        65,
        65,
        72
    )

separator_8K4P.BackgroundTransparency =
    0.35

separator_8K4P.BorderSizePixel = 0

separator_8K4P.ZIndex = 11

separator_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- FULLBRIGHT BUTTON
-- =========================================================

local starButton_8K4P =
    Instance.new("ImageButton")

starButton_8K4P.Name =
    "SHDW_FBL_StarButton_8K4P"

starButton_8K4P.Size =
    UDim2.fromOffset(
        STAR_AREA_SIZE_8K4P,
        UI_HEIGHT_8K4P
    )

starButton_8K4P.Position =
    UDim2.fromOffset(
        ARCEUS_SIZE_8K4P + 1,
        0
    )

starButton_8K4P.BackgroundTransparency =
    1

starButton_8K4P.Image = ""

starButton_8K4P.AutoButtonColor =
    false

starButton_8K4P.Active = true

starButton_8K4P.ZIndex = 10

starButton_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- STAR
-- =========================================================

local star_8K4P =
    Instance.new("TextLabel")

star_8K4P.Name =
    "SHDW_FBL_Star_8K4P"

star_8K4P.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

star_8K4P.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

star_8K4P.Size =
    UDim2.fromOffset(
        28,
        28
    )

star_8K4P.BackgroundTransparency =
    1

star_8K4P.Text =
    "☆"

star_8K4P.TextScaled = true

star_8K4P.Font =
    Enum.Font.GothamBold

star_8K4P.TextColor3 =
    Color3.fromRGB(
        235,
        235,
        240
    )

star_8K4P.Active = false

star_8K4P.ZIndex = 11

star_8K4P.Parent =
    starButton_8K4P

-- =========================================================
-- STAR GLOW
-- =========================================================

local starGlow_8K4P =
    Instance.new("UIStroke")

starGlow_8K4P.Name =
    "SHDW_FBL_StarGlow_8K4P"

starGlow_8K4P.Thickness =
    1.5

starGlow_8K4P.Color =
    Color3.fromRGB(
        0,
        225,
        255
    )

starGlow_8K4P.Transparency = 1

starGlow_8K4P.Parent =
    star_8K4P

-- =========================================================
-- STAR SCALE
-- =========================================================

local starScale_8K4P =
    Instance.new("UIScale")

starScale_8K4P.Scale = 1

starScale_8K4P.Parent =
    starButton_8K4P

-- =========================================================
-- PRELOAD
-- =========================================================

task.spawn(function()

    pcall(function()

        ContentProvider_8K4P:PreloadAsync({

            visibleImage_8K4P,
            hiddenImage_8K4P

        })

    end)

end)

-- =========================================================
-- STATE
-- =========================================================

local fullbrightEnabled_8K4P =
    false

local arceusHidden_8K4P =
    false

-- =========================================================
-- DRAG STATE
-- =========================================================

local dragging_8K4P =
    false

local dragStart_8K4P =
    nil

local startPosition_8K4P =
    nil

local movedDistance_8K4P =
    0

-- =========================================================
-- ORIGINAL LIGHTING
-- =========================================================

local originalLighting_8K4P = {

    Brightness =
        Lighting_8K4P.Brightness,

    ClockTime =
        Lighting_8K4P.ClockTime,

    FogEnd =
        Lighting_8K4P.FogEnd,

    GlobalShadows =
        Lighting_8K4P.GlobalShadows,

    OutdoorAmbient =
        Lighting_8K4P.OutdoorAmbient

}

-- =========================================================
-- SAVE LIGHTING
-- =========================================================

local function saveLighting_8K4P()

    originalLighting_8K4P.Brightness =
        Lighting_8K4P.Brightness

    originalLighting_8K4P.ClockTime =
        Lighting_8K4P.ClockTime

    originalLighting_8K4P.FogEnd =
        Lighting_8K4P.FogEnd

    originalLighting_8K4P.GlobalShadows =
        Lighting_8K4P.GlobalShadows

    originalLighting_8K4P.OutdoorAmbient =
        Lighting_8K4P.OutdoorAmbient

end

-- =========================================================
-- ENABLE FULLBRIGHT
-- =========================================================

local function enableFullbright_8K4P()

    saveLighting_8K4P()

    Lighting_8K4P.Brightness =
        2

    Lighting_8K4P.ClockTime =
        14

    Lighting_8K4P.FogEnd =
        100000

    Lighting_8K4P.GlobalShadows =
        false

    Lighting_8K4P.OutdoorAmbient =
        Color3.fromRGB(
            128,
            128,
            128
        )

end

-- =========================================================
-- DISABLE FULLBRIGHT
-- =========================================================

local function disableFullbright_8K4P()

    Lighting_8K4P.Brightness =
        originalLighting_8K4P.Brightness

    Lighting_8K4P.ClockTime =
        originalLighting_8K4P.ClockTime

    Lighting_8K4P.FogEnd =
        originalLighting_8K4P.FogEnd

    Lighting_8K4P.GlobalShadows =
        originalLighting_8K4P.GlobalShadows

    Lighting_8K4P.OutdoorAmbient =
        originalLighting_8K4P.OutdoorAmbient

end

-- =========================================================
-- ARCEUS APPEARANCE
-- =========================================================

local function updateArceusAppearance_8K4P()

    if arceusHidden_8K4P then

        visibleImage_8K4P.Visible =
            false

        hiddenImage_8K4P.Visible =
            hiddenAsset_8K4P ~= nil

        panelBorder_8K4P.Color =
            Color3.fromRGB(
                255,
                255,
                255
            )

        panelGlow_8K4P.Transparency =
            1

    else

        visibleImage_8K4P.Visible =
            visibleAsset_8K4P ~= nil

        hiddenImage_8K4P.Visible =
            false

        panelBorder_8K4P.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        panelGlow_8K4P.Color =
            Color3.fromRGB(
                0,
                200,
                255
            )

        panelGlow_8K4P.Transparency =
            0.72

    end

end

-- =========================================================
-- STAR APPEARANCE
-- =========================================================

local function updateStarAppearance_8K4P()

    if fullbrightEnabled_8K4P then

        star_8K4P.Text =
            "★"

        star_8K4P.TextColor3 =
            Color3.fromRGB(
                0,
                225,
                255
            )

        starGlow_8K4P.Color =
            Color3.fromRGB(
                0,
                225,
                255
            )

        starGlow_8K4P.Transparency =
            0

    else

        star_8K4P.Text =
            "☆"

        star_8K4P.TextColor3 =
            Color3.fromRGB(
                235,
                235,
                240
            )

        starGlow_8K4P.Transparency =
            1

    end

end

-- =========================================================
-- SAFE STAR CLICK ANIMATION
-- =========================================================

local starTween_8K4P

local function animateStar_8K4P()

    if starTween_8K4P then

        pcall(function()

            starTween_8K4P:Cancel()

        end)

    end

    starScale_8K4P.Scale =
        0.86

    starTween_8K4P =
        TweenService_8K4P:Create(

            starScale_8K4P,

            TweenInfo.new(
                0.14,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            ),

            {
                Scale = 1
            }

        )

    starTween_8K4P:Play()

end

-- =========================================================
-- MAIN GLOW PULSE
-- =========================================================

task.spawn(function()

    while shadowGui_8K4P.Parent do

        if not arceusHidden_8K4P then

            local tweenIn_8K4P =
                TweenService_8K4P:Create(

                    panelGlow_8K4P,

                    TweenInfo.new(
                        1.1,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),

                    {
                        Transparency =
                            0.52
                    }

                )

            local tweenOut_8K4P =
                TweenService_8K4P:Create(

                    panelGlow_8K4P,

                    TweenInfo.new(
                        1.1,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),

                    {
                        Transparency =
                            0.78
                    }

                )

            tweenIn_8K4P:Play()

            tweenIn_8K4P.Completed:Wait()

            if arceusHidden_8K4P then
                continue
            end

            tweenOut_8K4P:Play()

            tweenOut_8K4P.Completed:Wait()

        else

            task.wait(0.25)

        end

    end

end)

-- =========================================================
-- STAR NEON PULSE
-- =========================================================

task.spawn(function()

    while shadowGui_8K4P.Parent do

        if fullbrightEnabled_8K4P then

            local tweenIn_8K4P =
                TweenService_8K4P:Create(

                    starGlow_8K4P,

                    TweenInfo.new(
                        0.75,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),

                    {
                        Transparency =
                            0.02
                    }

                )

            local tweenOut_8K4P =
                TweenService_8K4P:Create(

                    starGlow_8K4P,

                    TweenInfo.new(
                        0.75,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),

                    {
                        Transparency =
                            0.42
                    }

                )

            tweenIn_8K4P:Play()

            tweenIn_8K4P.Completed:Wait()

            if not fullbrightEnabled_8K4P then
                continue
            end

            tweenOut_8K4P:Play()

            tweenOut_8K4P.Completed:Wait()

        else

            task.wait(0.20)

        end

    end

end)

-- =========================================================
-- DRAG START
-- ONLY ARCEUS IMAGE
-- =========================================================

arceusDrag_8K4P.InputBegan:Connect(
    function(input)

        if
            input.UserInputType ==
                Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
                Enum.UserInputType.Touch
        then

            dragging_8K4P =
                true

            dragStart_8K4P =
                input.Position

            startPosition_8K4P =
                panel_8K4P.Position

            movedDistance_8K4P =
                0

        end

    end
)

-- =========================================================
-- DRAG MOVEMENT
-- =========================================================

UserInputService_8K4P.InputChanged:Connect(
    function(input)

        if not dragging_8K4P then
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

        local delta_8K4P =
            input.Position
            - dragStart_8K4P

        movedDistance_8K4P =
            math.max(

                movedDistance_8K4P,

                math.abs(
                    delta_8K4P.X
                )
                +
                math.abs(
                    delta_8K4P.Y
                )

            )

        local x_8K4P =
            startPosition_8K4P.X.Offset
            + delta_8K4P.X

        local y_8K4P =
            startPosition_8K4P.Y.Offset
            + delta_8K4P.Y

        local camera_8K4P =
            workspace.CurrentCamera

        if not camera_8K4P then
            return
        end

        local viewport_8K4P =
            camera_8K4P.ViewportSize

        local maxX_8K4P =
            viewport_8K4P.X
            - UI_WIDTH_8K4P
            - EDGE_PADDING_8K4P

        local maxY_8K4P =
            viewport_8K4P.Y
            - UI_HEIGHT_8K4P
            - EDGE_PADDING_8K4P

        x_8K4P =
            math.clamp(
                x_8K4P,
                EDGE_PADDING_8K4P,
                maxX_8K4P
            )

        y_8K4P =
            math.clamp(
                y_8K4P,
                EDGE_PADDING_8K4P,
                maxY_8K4P
            )

        panel_8K4P.Position =
            UDim2.fromOffset(
                x_8K4P,
                y_8K4P
            )

        shadow_8K4P.Position =
            UDim2.fromOffset(
                x_8K4P + 3,
                y_8K4P + 3
            )

    end
)

-- =========================================================
-- DRAG END
-- =========================================================

UserInputService_8K4P.InputEnded:Connect(
    function(input)

        if
            input.UserInputType ~=
                Enum.UserInputType.MouseButton1
            and
            input.UserInputType ~=
                Enum.UserInputType.Touch
        then

            return

        end

        if not dragging_8K4P then
            return
        end

        dragging_8K4P =
            false

        -- Arceus image is ONLY drag.
        -- No click action here.

    end
)

-- =========================================================
-- FULLBRIGHT CLICK
-- =========================================================

starButton_8K4P.Activated:Connect(
    function()

        fullbrightEnabled_8K4P =
            not fullbrightEnabled_8K4P

        if fullbrightEnabled_8K4P then

            enableFullbright_8K4P()

        else

            disableFullbright_8K4P()

        end

        updateStarAppearance_8K4P()

        animateStar_8K4P()

    end
)

-- =========================================================
-- PC HOVER
-- =========================================================

if not UserInputService_8K4P.TouchEnabled then

    arceusDrag_8K4P.MouseEnter:Connect(
        function()

            TweenService_8K4P:Create(

                panelScale_8K4P,

                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                ),

                {
                    Scale = 1.04
                }

            ):Play()

        end
    )

    arceusDrag_8K4P.MouseLeave:Connect(
        function()

            if not dragging_8K4P then

                TweenService_8K4P:Create(

                    panelScale_8K4P,

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

        end
    )

end

-- =========================================================
-- VIEWPORT CHANGE
-- =========================================================

workspace.CurrentCamera:
    GetPropertyChangedSignal(
        "ViewportSize"
    ):
    Connect(function()

        local camera_8K4P =
            workspace.CurrentCamera

        if not camera_8K4P then
            return
        end

        local viewport_8K4P =
            camera_8K4P.ViewportSize

        local x_8K4P =
            panel_8K4P.Position.X.Offset

        local y_8K4P =
            panel_8K4P.Position.Y.Offset

        local maxX_8K4P =
            viewport_8K4P.X
            - UI_WIDTH_8K4P
            - EDGE_PADDING_8K4P

        local maxY_8K4P =
            viewport_8K4P.Y
            - UI_HEIGHT_8K4P
            - EDGE_PADDING_8K4P

        x_8K4P =
            math.clamp(
                x_8K4P,
                EDGE_PADDING_8K4P,
                maxX_8K4P
            )

        y_8K4P =
            math.clamp(
                y_8K4P,
                EDGE_PADDING_8K4P,
                maxY_8K4P
            )

        panel_8K4P.Position =
            UDim2.fromOffset(
                x_8K4P,
                y_8K4P
            )

        shadow_8K4P.Position =
            UDim2.fromOffset(
                x_8K4P + 3,
                y_8K4P + 3
            )

    end)

-- =========================================================
-- INITIALIZE
-- =========================================================

panel_8K4P.Position =
    UDim2.fromOffset(
        START_X_8K4P,
        START_Y_8K4P
    )

shadow_8K4P.Position =
    UDim2.fromOffset(
        START_X_8K4P + 3,
        START_Y_8K4P + 3
    )

updateArceusAppearance_8K4P()
updateStarAppearance_8K4P()

print(
    "[SHDW_FBL_8K4P] Loaded successfully."
)