local CoreGui = game:GetService("CoreGui")
local targetParent = (gethui and gethui()) or CoreGui

-- =========================================================
-- FIND ARCEUS X
-- =========================================================

local function findArceusX()
    for _, gui in ipairs(targetParent:GetChildren()) do
        if gui:IsA("ScreenGui") then

            local descendants = #gui:GetDescendants()

            if gui.DisplayOrder == 1999999999
                and gui.ResetOnSpawn == true
                and gui.IgnoreGuiInset == true
                and descendants > 3000 then

                return gui
            end
        end
    end

    return nil
end

-- =========================================================
-- CREATE TOGGLE
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
-- STATE
-- =========================================================

local arceusGui = findArceusX()
local hidden = false

button.MouseButton1Click:Connect(function()

    -- Re-scan every time
    arceusGui = findArceusX()

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