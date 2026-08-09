local CoreGui = game:GetService("CoreGui")

local targetParent = (gethui and gethui()) or CoreGui

-- Detector

local function findArceusX()
    for _, gui in ipairs(targetParent:GetChildren()) do

        if gui:IsA("ScreenGui") then

            local correctDisplayOrder =
                gui.DisplayOrder == 1999999999

            local correctReset =
                gui.ResetOnSpawn == false

            local correctInset =
                gui.IgnoreGuiInset == true

            local descendantCount =
                #gui:GetDescendants()

            local enoughObjects =
                descendantCount > 3000

            if correctDisplayOrder
                and correctReset
                and correctInset
                and enoughObjects then

                return gui
            end
        end
    end

    return nil
end

-- UI T

local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ArceusXVisibilityToggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.Parent = targetParent

local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.new(0, 145, 0, 45)
button.Position = UDim2.new(0, 20, 0, 100)

button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.BackgroundTransparency = 0.15

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

-- STATE

local hidden = false
local arceusGui = findArceusX()

-- TOGGLE

button.MouseButton1Click:Connect(function()

    -- Detect UI
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
        button.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
    else
        button.Text = "Hide Arceus X"
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)