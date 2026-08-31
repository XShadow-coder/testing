local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local uiName = "SortedExecutorTeleportUI"

-- 1. Pulizia UI precedente
local existingUi = CoreGui:FindFirstChild(uiName) or player.PlayerGui:FindFirstChild(uiName)
if existingUi then
    existingUi:Destroy()
end

-- 2. Verifica Cartella
local workspaceItems = workspace:FindFirstChild("Items")
if not workspaceItems then
    warn("Errore: La cartella 'Items' non esiste in questo gioco!")
    return
end

-- 3. Creazione UI di Base
local screenGui = Instance.new("ScreenGui")
screenGui.Name = uiName
screenGui.ResetOnSpawn = false

-- Protezione UI per Executor
local success = pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Frame principale (Quello che verrà trascinato)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0, 15, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

-- Barra superiore per trascinare la UI
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 25)
topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 6)
topBarCorner.Parent = topBar

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 6)
topBarFix.Position = UDim2.new(0, 0, 1, -6)
topBarFix.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Items Teleporter"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Parent = topBar

-- Sistema di trascinamento personalizzato (funziona sempre)
local dragging, dragInput, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Contenitore Scorrevole per gli elementi
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -25)
scrollFrame.Position = UDim2.new(0, 0, 0, 25)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder -- Necessario per ordinare in base al nome (LayoutOrder)

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.Parent = scrollFrame

-- Funzione di Teletrasporto sicura per Executor
local function teleportTo(targetCFrame)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Calcola la posizione finale
    local finalCFrame = targetCFrame + Vector3.new(0, 4, 0)
    
    -- Metodo 1: CFrame diretto (spesso funziona)
    hrp.CFrame = finalCFrame
    
    -- Metodo 2: PivotTo (più robusto contro alcuni anti-cheat/modelli complessi)
    task.delay(0.05, function()
        if char then
            char:PivotTo(finalCFrame)
        end
    end)
end

-- Tabella per tracciare gli elementi già aggiunti
local trackedItems = {}

local function createRow(item)
    if not item:IsA("BasePart") and not item:IsA("Model") then return end
    if trackedItems[item] then return end -- Evita duplicati

    trackedItems[item] = true

    local rowFrame = Instance.new("Frame")
    rowFrame.Name = item.Name -- Usiamo il nome dell'oggetto per il Frame
    rowFrame.Size = UDim2.new(1, 0, 0, 35)
    rowFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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

    tpButton.MouseButton1Click:Connect(function()
        if not item or not item.Parent then 
            rowFrame:Destroy() -- Se l'oggetto non esiste più, rimuovi la riga
            trackedItems[item] = nil
            return 
        end
        
        local targetCFrame
        if item:IsA("BasePart") then
            targetCFrame = item.CFrame
        elseif item:IsA("Model") and item.PrimaryPart then
            targetCFrame = item.PrimaryPart.CFrame
        elseif item:IsA("Model") then
            -- Fallback se il modello non ha PrimaryPart ma ha dei figli BasePart
            local firstPart = item:FindFirstChildWhichIsA("BasePart")
            if firstPart then targetCFrame = firstPart.CFrame end
        end
        
        if targetCFrame then
            teleportTo(targetCFrame)
        else
            warn("Impossibile trovare le coordinate per " .. item.Name)
        end
    end)
end

-- Funzione per ricalcolare l'ordine alfabetico
local function sortItems()
    local frames = {}
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            table.insert(frames, child)
        end
    end
    
    -- Ordina i Frame in base al nome (alfabetico), che raggrupperà automaticamente i nomi uguali
    table.sort(frames, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    -- Assegna il LayoutOrder in base alla posizione ordinata
    for i, frame in ipairs(frames) do
        frame.LayoutOrder = i
    end
end

-- 1. Popola la lista iniziale
for _, item in ipairs(workspaceItems:GetChildren()) do
    createRow(item)
end
sortItems() -- Ordina dopo aver inserito tutto

-- 2. Ascolta l'aggiunta di nuovi oggetti e riordina
workspaceItems.ChildAdded:Connect(function(item)
    createRow(item)
    sortItems()
end)

-- 3. Rimuovi la riga se un oggetto viene eliminato dal gioco
workspaceItems.ChildRemoved:Connect(function(item)
    if trackedItems[item] then
        trackedItems[item] = nil
        for _, child in ipairs(scrollFrame:GetChildren()) do
            -- Dobbiamo identificare il frame corretto (potrebbero esserci nomi uguali, ma ogni oggetto è un'istanza unica)
            -- Una soluzione rapida è pulire e ricreare se ci sono molti delete, oppure per ora la rimozione la fa il bottone.
            -- Per semplificare: se l'oggetto scompare, il bottone al click si autodistruggerà (gestito sopra nel MouseButton1Click).
        end
    end
end)
