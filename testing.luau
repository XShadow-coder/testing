local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local uiName = "ExecutorTeleportUI"

-- 1. Elimina la vecchia UI se premi "Execute" più volte
local existingUi = CoreGui:FindFirstChild(uiName) or player.PlayerGui:FindFirstChild(uiName)
if existingUi then
    existingUi:Destroy()
end

-- 2. Cerca la cartella "Items" nel Workspace
local workspaceItems = workspace:FindFirstChild("Items")
if not workspaceItems then
    warn("Errore: La cartella 'Items' non esiste in questo gioco!")
    return
end

-- 3. Creazione della UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = uiName
screenGui.ResetOnSpawn = false

-- Prova a nascondere la UI in CoreGui (metodo sicuro per executor)
-- Se l'executor non lo supporta, usa PlayerGui come piano B
local success = pcall(function()
    -- Alcuni executor recenti usano gethui() per la massima sicurezza
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 220, 0, 300)
scrollFrame.Position = UDim2.new(0, 15, 0.5, -150)
scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scrollFrame.BorderSizePixel = 0
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 6
scrollFrame.Active = true
scrollFrame.Draggable = true -- Rende la UI trascinabile sullo schermo!
scrollFrame.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 5)

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.Parent = scrollFrame

local function createRow(item)
    if not item:IsA("BasePart") and not item:IsA("Model") then return end

    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 35)
    rowFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = scrollFrame

    local cornerFrame = Instance.new("UICorner")
    cornerFrame.CornerRadius = UDim.new(0, 4)
    cornerFrame.Parent = rowFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.65, -5, 1, 0)
    nameLabel.Position = UDim2.new(0, 8, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 13
    nameLabel.Parent = rowFrame

    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0.35, -8, 0.7, 0)
    tpButton.Position = UDim2.new(0.65, 0, 0.15, 0)
    tpButton.BackgroundColor3 = Color3.fromRGB(0, 136, 255)
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Text = "Vai"
    tpButton.Font = Enum.Font.GothamBold
    tpButton.TextSize = 12
    tpButton.Parent = rowFrame
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 4)
    cornerBtn.Parent = tpButton

    -- Teletrasporto locale
    tpButton.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local targetCFrame
            
            if item:IsA("BasePart") then
                targetCFrame = item.CFrame
            elseif item:IsA("Model") and item.PrimaryPart then
                targetCFrame = item.PrimaryPart.CFrame
            end
            
            if targetCFrame then
                char.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 4, 0)
            end
        end
    end)
end

-- Genera i bottoni per gli oggetti esistenti
for _, item in ipairs(workspaceItems:GetChildren()) do
    createRow(item)
end

-- Ascolta i nuovi oggetti che spawnano
workspaceItems.ChildAdded:Connect(createRow)