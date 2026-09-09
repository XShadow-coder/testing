local result = "game:GetService("RunService").Stepped:Connect(function()
    local target = 1000
    local result = math.random(target - 10,target)
    game:GetService("ReplicatedStorage").UpdateFPS:FireServer(result)
end)"

toclipboard(result)