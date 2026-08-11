-- =========================================================
-- SHDW_FBL_8K4P
-- ARCEUS X DRAG + FULLBRIGHT
-- STABLE VERSION | PC + MOBILE
-- =========================================================

local Players_8K4P =
    game:GetService("Players")

local UserInputService_8K4P =
    game:GetService("UserInputService")

local ContentProvider_8K4P =
    game:GetService("ContentProvider")

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

-- =========================================================
-- UI DIMENSIONS
-- =========================================================

local ARCEUS_WIDTH_8K4P = 54
local FULLBRIGHT_WIDTH_8K4P = 58

-- They are directly attached.
local UI_WIDTH_8K4P =
    ARCEUS_WIDTH_8K4P
    + FULLBRIGHT_WIDTH_8K4P

local UI_HEIGHT_8K4P = 54

local STAR_SIZE_8K4P = 28

local EDGE_PADDING_8K4P = 10

local DRAG_THRESHOLD_8K4P = 8

local START_X_8K4P = 20
local START_Y_8K4P = 100

-- =========================================================
-- ASSET FUNCTIONS
-- =========================================================

local httpRequest_8K4P =
    request
    or http_request
    or (syn and syn.request)

local getAsset_8K4P =
    getcustomasset
    or getsynasset

local function downloadImage_8K4P(
    url,
    fileName
)

    -- -----------------------------------------------------
    -- CREATE FOLDER
    -- -----------------------------------------------------

    pcall(function()

        if not isfolder(
            ASSET_FOLDER_8K4P
        ) then

            makefolder(
                ASSET_FOLDER_8K4P
            )

        end

    end)

    local path_8K4P =
        ASSET_FOLDER_8K4P
        .. "/"
        .. fileName

    -- -----------------------------------------------------
    -- LOAD FROM CACHE
    -- -----------------------------------------------------

    if
        isfile(path_8K4P)
        and getAsset_8K4P
    then

        local success_8K4P,
            asset_8K4P =
            pcall(function()

                return getAsset_8K4P(
                    path_8K4P
                )

            end)

        if
            success_8K4P
            and asset_8K4P
        then

            return asset_8K4P

        end

    end

    -- -----------------------------------------------------
    -- HTTP REQUEST
    -- -----------------------------------------------------

    local body_8K4P = nil

    if httpRequest_8K4P then

        local success_8K4P,
            response_8K4P =
            pcall(function()

                return httpRequest_8K4P({

                    Url = url,

                    Method = "GET"

                })

            end)

        if
            success_8K4P
            and response_8K4P
            and response_8K4P.Body
        then

            body_8K4P =
                response_8K4P.Body

        end

    end

    -- -----------------------------------------------------
    -- GAME HTTP FALLBACK
    -- -----------------------------------------------------

    if not body_8K4P then

        local success_8K4P,
            result_8K4P =
            pcall(function()

                return game:HttpGet(
                    url
                )

            end)

        if
            success_8K4P
            and result_8K4P
        then

            body_8K4P =
                result_8K4P

        end

    end

    -- -----------------------------------------------------
    -- DOWNLOAD FAILED
    -- -----------------------------------------------------

    if not body_8K4P then

        warn(
            "[SHDW_FBL_8K4P] Failed to download image."
        )

        return nil

    end

    -- -----------------------------------------------------
    -- SAVE IMAGE
    -- -----------------------------------------------------

    local writeSuccess_8K4P =
        pcall(function()

            writefile(
                path_8K4P,
                body_8K4P
            )

        end)

    if not writeSuccess_8K4P then

        warn(
            "[SHDW_FBL_8K4P] Failed to save image."
        )

        return nil

    end

    -- -----------------------------------------------------
    -- CONVERT TO ROBLOX ASSET
    -- -----------------------------------------------------

    if getAsset_8K4P then

        local success_8K4P,
            asset_8K4P =
            pcall(function()

                return getAsset_8K4P(
                    path_8K4P
                )

            end)

        if
            success_8K4P
            and asset_8K4P
        then

            return asset_8K4P

        end

    end

    return nil

end

-- =========================================================
-- LOAD ARCEUS IMAGES
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
-- GUI PARENT
-- =========================================================

local targetParent_8K4P = nil

pcall(function()

    if gethui then

        targetParent_8K4P =
            gethui()

    end

end)

if not targetParent_8K4P then

    targetParent_8K4P =
        game:GetService(
            "CoreGui"
        )

end

if not targetParent_8K4P then

    targetParent_8K4P =
        LocalPlayer_8K4P:
        WaitForChild(
            "PlayerGui"
        )

end

-- =========================================================
-- REMOVE ONLY THIS SCRIPT'S OLD GUI
-- =========================================================

pcall(function()

    local oldGui_8K4P =
        targetParent_8K4P:
        FindFirstChild(
            GUI_NAME_8K4P
        )

    if oldGui_8K4P then

        oldGui_8K4P:Destroy()

    end

end)

-- =========================================================
-- FIND ARCEUS X GUI
-- =========================================================

local function findArceusX_8K4P()

    local possibleParents_8K4P = {

        targetParent_8K4P,

        game:GetService(
            "CoreGui"
        ),

        LocalPlayer_8K4P:
        FindFirstChildOfClass(
            "PlayerGui"
        )

    }

    for _,
        parent_8K4P
        in ipairs(
            possibleParents_8K4P
        )
    do

        if parent_8K4P then

            for _,
                child_8K4P
                in ipairs(
                    parent_8K4P:GetChildren()
                )
            do

                if child_8K4P:IsA(
                    "ScreenGui"
                ) then

                    local name_8K4P =
                        string.lower(
                            child_8K4P.Name
                        )

                    if
                        name_8K4P ==
                            "arceusx"
                        or
                        name_8K4P ==
                            "arceus x"
                        or
                        name_8K4P ==
                            "arceus"
                        or
                        string.find(
                            name_8K4P,
                            "arceusx",
                            1,
                            true
                        )
                        or
                        string.find(
                            name_8K4P,
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
    Instance.new(
        "ScreenGui"
    )

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

shadow_8K4P.BorderSizePixel =
    0

shadow_8K4P.ZIndex =
    1

shadow_8K4P.Parent =
    shadowGui_8K4P

local shadowCorner_8K4P =
    Instance.new(
        "UICorner"
    )

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

panel_8K4P.BorderSizePixel =
    0

panel_8K4P.ZIndex =
    5

panel_8K4P.Parent =
    shadowGui_8K4P

local panelCorner_8K4P =
    Instance.new(
        "UICorner"
    )

panelCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        14
    )

panelCorner_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- DARK GRADIENT
-- =========================================================

local panelGradient_8K4P =
    Instance.new(
        "UIGradient"
    )

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

panelGradient_8K4P.Rotation =
    0

panelGradient_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- OUTER BORDER
-- =========================================================

local panelBorder_8K4P =
    Instance.new(
        "UIStroke"
    )

panelBorder_8K4P.Name =
    "SHDW_FBL_Border_8K4P"

panelBorder_8K4P.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

panelBorder_8K4P.Thickness =
    2

panelBorder_8K4P.Color =
    Color3.fromRGB(
        0,
        200,
        255
    )

panelBorder_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- OUTER GLOW
-- =========================================================

local panelGlow_8K4P =
    Instance.new(
        "UIStroke"
    )

panelGlow_8K4P.Name =
    "SHDW_FBL_Glow_8K4P"

panelGlow_8K4P.ApplyStrokeMode =
    Enum.ApplyStrokeMode.Border

panelGlow_8K4P.Thickness =
    5

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
-- ARCEUS DRAG AREA
-- ONLY THIS AREA CAN MOVE THE UI
-- =========================================================

local arceusDrag_8K4P =
    Instance.new(
        "ImageButton"
    )

arceusDrag_8K4P.Name =
    "SHDW_FBL_ArceusDrag_8K4P"

arceusDrag_8K4P.Size =
    UDim2.fromOffset(
        ARCEUS_WIDTH_8K4P,
        UI_HEIGHT_8K4P
    )

arceusDrag_8K4P.Position =
    UDim2.fromOffset(
        0,
        0
    )

arceusDrag_8K4P.BackgroundTransparency =
    1

arceusDrag_8K4P.Image =
    ""

arceusDrag_8K4P.AutoButtonColor =
    false

arceusDrag_8K4P.Active =
    true

arceusDrag_8K4P.ZIndex =
    10

arceusDrag_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- ARCEUS IMAGE CONTAINER
-- =========================================================

local imageContainer_8K4P =
    Instance.new(
        "Frame"
    )

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

imageContainer_8K4P.ZIndex =
    11

imageContainer_8K4P.Parent =
    arceusDrag_8K4P

local imageCorner_8K4P =
    Instance.new(
        "UICorner"
    )

imageCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        11
    )

imageCorner_8K4P.Parent =
    imageContainer_8K4P

-- =========================================================
-- VISIBLE ARCEUS IMAGE
-- =========================================================

local visibleImage_8K4P =
    Instance.new(
        "ImageLabel"
    )

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

visibleImage_8K4P.ZIndex =
    12

visibleImage_8K4P.Parent =
    imageContainer_8K4P

local visibleCorner_8K4P =
    Instance.new(
        "UICorner"
    )

visibleCorner_8K4P.CornerRadius =
    UDim.new(
        0,
        11
    )

visibleCorner_8K4P.Parent =
    visibleImage_8K4P

-- =========================================================
-- HIDDEN ARCEUS IMAGE
-- =========================================================

local hiddenImage_8K4P =
    Instance.new(
        "ImageLabel"
    )

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

hiddenImage_8K4P.Visible =
    false

hiddenImage_8K4P.Active =
    false

hiddenImage_8K4P.ZIndex =
    12

hiddenImage_8K4P.Parent =
    imageContainer_8K4P

local hiddenCorner_8K4P =
    Instance.new(
        "UICorner"
    )

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
    Instance.new(
        "Frame"
    )

separator_8K4P.Name =
    "SHDW_FBL_Separator_8K4P"

separator_8K4P.Size =
    UDim2.fromOffset(
        1,
        28
    )

separator_8K4P.Position =
    UDim2.fromOffset(
        ARCEUS_WIDTH_8K4P,
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

separator_8K4P.BorderSizePixel =
    0

separator_8K4P.ZIndex =
    13

separator_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- FULLBRIGHT BUTTON
-- =========================================================

local starButton_8K4P =
    Instance.new(
        "ImageButton"
    )

starButton_8K4P.Name =
    "SHDW_FBL_Fullbright_8K4P"

starButton_8K4P.Size =
    UDim2.fromOffset(
        FULLBRIGHT_WIDTH_8K4P,
        UI_HEIGHT_8K4P
    )

starButton_8K4P.Position =
    UDim2.fromOffset(
        ARCEUS_WIDTH_8K4P,
        0
    )

starButton_8K4P.BackgroundTransparency =
    1

starButton_8K4P.Image =
    ""

starButton_8K4P.AutoButtonColor =
    false

starButton_8K4P.Active =
    true

starButton_8K4P.ZIndex =
    14

starButton_8K4P.Parent =
    panel_8K4P

-- =========================================================
-- STAR
-- =========================================================

local star_8K4P =
    Instance.new(
        "TextLabel"
    )

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
        STAR_SIZE_8K4P,
        STAR_SIZE_8K4P
    )

star_8K4P.BackgroundTransparency =
    1

star_8K4P.Text =
    "☆"

star_8K4P.TextScaled =
    true

star_8K4P.Font =
    Enum.Font.GothamBold

star_8K4P.TextColor3 =
    Color3.fromRGB(
        235,
        235,
        240
    )

star_8K4P.TextStrokeTransparency =
    0.85

star_8K4P.Active =
    false

star_8K4P.ZIndex =
    15

star_8K4P.Parent =
    starButton_8K4P

-- =========================================================
-- STAR NEON
-- NO TWEEN / NO PULSE
-- =========================================================

local starGlow_8K4P =
    Instance.new(
        "UIStroke"
    )

starGlow_8K4P.Name =
    "SHDW_FBL_StarNeon_8K4P"

starGlow_8K4P.Thickness =
    2

starGlow_8K4P.Color =
    Color3.fromRGB(
        0,
        220,
        255
    )

starGlow_8K4P.Transparency =
    1

starGlow_8K4P.Parent =
    star_8K4P

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
-- STATES
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
-- SAVE ORIGINAL LIGHTING
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

        -- FILLED STAR
        star_8K4P.Text =
            "★"

        star_8K4P.TextColor3 =
            Color3.fromRGB(
                0,
                225,
                255
            )

        star_8K4P.TextStrokeColor3 =
            Color3.fromRGB(
                0,
                220,
                255
            )

        star_8K4P.TextStrokeTransparency =
            0.15

        -- NEON ON
        starGlow_8K4P.Color =
            Color3.fromRGB(
                0,
                220,
                255
            )

        starGlow_8K4P.Transparency =
            0

    else

        -- EMPTY STAR
        star_8K4P.Text =
            "☆"

        star_8K4P.TextColor3 =
            Color3.fromRGB(
                235,
                235,
                240
            )

        star_8K4P.TextStrokeColor3 =
            Color3.fromRGB(
                20,
                20,
                25
            )

        star_8K4P.TextStrokeTransparency =
            0.75

        -- NEON OFF
        starGlow_8K4P.Transparency =
            1

    end

end

-- =========================================================
-- ARCEUS DRAG START
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

        local newX_8K4P =
            startPosition_8K4P.X.Offset
            + delta_8K4P.X

        local newY_8K4P =
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

        newX_8K4P =
            math.clamp(
                newX_8K4P,
                EDGE_PADDING_8K4P,
                maxX_8K4P
            )

        newY_8K4P =
            math.clamp(
                newY_8K4P,
                EDGE_PADDING_8K4P,
                maxY_8K4P
            )

        panel_8K4P.Position =
            UDim2.fromOffset(
                newX_8K4P,
                newY_8K4P
            )

        shadow_8K4P.Position =
            UDim2.fromOffset(
                newX_8K4P + 3,
                newY_8K4P + 3
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

    end
)

-- =========================================================
-- PC HOVER
-- =========================================================

if not UserInputService_8K4P.TouchEnabled then

    arceusDrag_8K4P.MouseEnter:Connect(
        function()

            panelBorder_8K4P.Thickness =
                2

            panelGlow_8K4P.Thickness =
                6

        end
    )

    arceusDrag_8K4P.MouseLeave:Connect(
        function()

            panelGlow_8K4P.Thickness =
                5

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
    "[SHDW_FBL_8K4P] Stable version loaded."
)