local CoreGui = game:GetService("CoreGui")

local targetParent = (gethui and gethui()) or CoreGui

-- =========================================================
-- CONFIG
-- =========================================================

local ARCEUS_DISPLAY_ORDER = 1999999999

-- =========================================================
-- FIND ARCEUS X
-- =========================================================

local function findArceusX()
    local bestGui = nil
    local bestScore = 0

    for _, gui in ipairs(targetParent:GetChildren()) do

        if gui:IsA("ScreenGui") then

            local score = 0

            -- Caratteristiche osservate nella GUI di Arceus X
            if gui.DisplayOrder == ARCEUS_DISPLAY_ORDER then
                score += 5
            end

            if gui.ResetOnSpawn == true then
                score += 1
            end

            if gui.IgnoreGuiInset == true then
                score += 1
            end

            -- La GUI osservata aveva oltre 4000 descendants
            local descendants = #gui:GetDescendants()

            if descendants >= 3000 then
                score += 3
            end

            -- La GUI di Arceus X contiene moltissimi elementi UI
            if descendants >= 4000 then
                score += 1
            end

            if score > bestScore then
                bestScore = score
                bestGui = gui
            end
        end
    end

    -- Richiediamo almeno una corrispondenza forte.
    if bestScore >= 5 then
        return bestGui
    end

    return nil
end

-- =========================================================
-- CREATE TOGGLE UI
-- =========================================================

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ArceusXVisibilityToggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.Parent = targetParent

local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.new(0, 140, 0, 45)
button.Position = UDim2.new(0, 20, 0, 100)

button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.BackgroundTransparency = 0.1

button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.Text = "Hide Arceus X"

button.Active = true
button.Draggable = true

button.Parent = toggleGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- =========================================================
-- TOGGLE
-- =========================================================

local arceusGui = findArceusX()
local hidden = false

button.MouseButton1Click:Connect(function()

    -- Cerca nuovamente la GUI se è stata ricreata
    -- oppure se non era disponibile inizialmente.
    if not arceusGui or not arceusGui.Parent then
        arceusGui = findArceusX()
    end

    if not arceusGui then
        button.Text = "Arceus X not found"
        return
    end

    hidden = not hidden

    arceusGui.Enabled = not hidden

    if hidden then
        button.Text = "Show Arceus X"
        button.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
    else
        button.Text = "Hide Arceus X"
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
end)