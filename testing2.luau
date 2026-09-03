local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MatchTest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local parent

if gethui then
    parent = gethui()
else
    parent = player:WaitForChild("PlayerGui")
end

gui.Parent = parent

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "MATCH DETECTOR TEST"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local text = Instance.new("TextLabel")
text.Position = UDim2.fromOffset(10, 50)
text.Size = UDim2.new(1, -20, 0, 80)
text.BackgroundTransparency = 1
text.Text = "UI FUNZIONANTE\n\nAspetto il detector..."
text.TextColor3 = Color3.new(1, 1, 1)
text.TextSize = 16
text.Font = Enum.Font.Gotham
text.Parent = frame

print("[MatchTest] UI creata correttamente")