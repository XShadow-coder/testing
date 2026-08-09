local CoreGui = game:GetService("CoreGui")

local targetParent = (gethui and gethui()) or CoreGui

-- =========================================================
-- FIND ARCEUS X RECURSIVELY
-- =========================================================

local function findArceusX()

    -- Cerca in tutto il contenitore, non solo nei figli diretti
    for _, obj in ipairs(targetParent:GetDescendants()) do

        if obj:IsA("ScreenGui") then

            if obj.DisplayOrder == 1999999999
                and obj.ResetOnSpawn == true
                and obj.IgnoreGuiInset == true then

                return obj
            end
        end
    end

    return nil
end

-- =========================================================
-- TOGGLE UI
-- =========================================================

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ArceusXVisibilityToggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.Parent = targetParent

local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.new(0, 145, 0, 45)
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

local hidden = false

button.MouseButton1Click:Connect(function()

    local arceusGui = findArceusX()

    if not arceusGui then
        button.Text = "Arceus X Not Found"
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