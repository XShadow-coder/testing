local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local uiName = "SafeDropdownTeleportUI"

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

-- Protezione per Executor
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

-- Frame principale
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 350)
mainFrame.Position = UDim2.new(0, 15, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

-- Barra superiore (Draggable e Indicatore Cooldown)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 6)
topBarCorner.Parent = topBar

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 6)
topBarFix.Position = UDim2.new(0, 0, 1, -6)
topBarFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
titleLabel.TextSize = 13
titleLabel.Parent = topBar

-- Sistema di trascinamento
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

-- Contenitore Scorrevole Principale
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Parent = scrollFrame
scrollLayout.Padding = UDim.new(0, 5)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.Parent = scrollFrame

-- ==========================================
-- SISTEMA DI COOLDOWN GLOBALE
-- ==========================================
local lastTeleportTime = 0
local COOLDOWN_DURATION = 7

-- Aggiorna visivamente il titolo per mostrare il cooldown
task.spawn(function()
    while task.wait(0.1) do
        local now = os.clock()
        local timePassed = now - lastTeleportTime
        
        if timePassed < COOLDOWN_DURATION then
            local timeLeft = math.ceil(COOLDOWN_DURATION - timePassed)
            titleLabel.Text = "In Cooldown... (" .. timeLeft .. "s)"
            titleLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Testo Rosso
        else
            titleLabel.Text = "Items Teleporter"
            titleLabel.TextColor3 = Color3.new(1, 1, 1) -- Testo Bianco
        end
    end
end)

-- ==========================================
-- LOGICA DI TELETRASPORTO
-- ==========================================
local function teleportTo(targetCFrame)
    local now = os.clock()
    -- Controlla se il cooldown è attivo
    if now - lastTeleportTime < COOLDOWN_DURATION then
        return -- Blocca il teletrasporto
    end

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Registra il tempo dell'ultimo teletrasporto
    lastTeleportTime = now

    local targetPosition = targetCFrame.Position
    local finalCFrame = CFrame.new(targetPosition + Vector3.new(0, 4, 0))
    
    hrp.CFrame = finalCFrame
    task.delay(0.05, function()
        if char then char:PivotTo(finalCFrame) end
    end)
end

-- ==========================================
-- GESTIONE DELLE CATEGORIE E TRACKING OGGETTI
-- ==========================================
local categories = {}
local trackedItems = {}

local function getOrCreateCategory(itemName)
    if categories[itemName] then return categories[itemName] end

    local catFrame = Instance.new("Frame")
    catFrame.Name = itemName
    catFrame.Size = UDim2.new(1, 0, 0, 0)
    catFrame.BackgroundTransparency = 1
    catFrame.AutomaticSize = Enum.AutomaticSize.Y
    catFrame.Parent = scrollFrame

    local catLayout = Instance.new("UIListLayout")
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Parent = catFrame

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 35)
    headerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    headerBtn.Text = ""
    headerBtn.AutoButtonColor = true
    headerBtn.Parent = catFrame

    Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 4)

    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -10, 1, 0)
    headerText.Position = UDim2.new(0, 10, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "▶ " .. itemName .. " (0)"
    headerText.TextColor3 = Color3.new(1, 1, 1)
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Font = Enum.Font.GothamMedium
    headerText.TextSize = 13
    headerText.Parent = headerBtn

    local itemsContainer = Instance.new("Frame")
    itemsContainer.Size = UDim2.new(1, 0, 0, 0)
    itemsContainer.BackgroundTransparency = 1
    itemsContainer.AutomaticSize = Enum.AutomaticSize.Y
    itemsContainer.Visible = false
    itemsContainer.Parent = catFrame

    local itemsLayout = Instance.new("UIListLayout")
    itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemsLayout.Padding = UDim.new(0, 2)
    itemsLayout.Parent = itemsContainer

    local itemsPadding = Instance.new("UIPadding")
    itemsPadding.PaddingTop = UDim.new(0, 2)
    itemsPadding.Parent = itemsContainer

    local isOpen = false
    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        itemsContainer.Visible = isOpen
        local count = categories[itemName].count
        if isOpen then
            headerText.Text = "▼ " .. itemName .. " (" .. count .. ")"
        else
            headerText.Text = "▶ " .. itemName .. " (" .. count .. ")"
        end
    end)

    categories[itemName] = {
        frame = catFrame,
        container = itemsContainer,
        headerLabel = headerText,
        isOpen = function() return isOpen end,
        count = 0
    }
    
    return categories[itemName]
end

local function addItem(item)
    if not item:IsA("BasePart") and not item:IsA("Model") then return end
    if trackedItems[item] then return end

    local category = getOrCreateCategory(item.Name)
    category.count = category.count + 1

    local arrow = category.isOpen() and "▼ " or "▶ "
    category.headerLabel.Text = arrow .. item.Name .. " (" .. category.count .. ")"

    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, -15, 0, 30)
    rowFrame.Position = UDim2.new(0, 15, 0, 0)
    rowFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = category.container

    Instance.new("UICorner", rowFrame).CornerRadius = UDim.new(0, 4)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.65, -5, 1, 0)
    nameLabel.Position = UDim2.new(0, 8, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "• " .. item.Name
    nameLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 12
    nameLabel.Parent = rowFrame

    local tpButton = Instance.new("TextButton")
    tpButton.Size = UDim2.new(0.35, -5, 0.7, 0)
    tpButton.Position = UDim2.new(0.65, 0, 0.15, 0)
    tpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    tpButton.TextColor3 = Color3.new(1, 1, 1)
    tpButton.Text = "Vai"
    tpButton.Font = Enum.Font.GothamBold
    tpButton.TextSize = 11
    tpButton.Parent = rowFrame

    Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 4)

    tpButton.MouseButton1Click:Connect(function()
        if not item or not item.Parent then return end
        
        local targetCFrame
        if item:IsA("BasePart") then
            targetCFrame = item.CFrame
        elseif item:IsA("Model") and item.PrimaryPart then
            targetCFrame = item.PrimaryPart.CFrame
        elseif item:IsA("Model") then
            local firstPart = item:FindFirstChildWhichIsA("BasePart")
            if firstPart then targetCFrame = firstPart.CFrame end
        end
        
        if targetCFrame then
            teleportTo(targetCFrame)
        end
    end)

    -- Salviamo il riferimento della riga nella tabella per eliminarla dopo facilmente
    trackedItems[item] = {
        rowFrame = rowFrame,
        categoryName = item.Name
    }
end

local function sortCategories()
    local frames = {}
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then table.insert(frames, child) end
    end
    table.sort(frames, function(a, b) return a.Name:lower() < b.Name:lower() end)
    for i, frame in ipairs(frames) do frame.LayoutOrder = i end
end

-- ==========================================
-- SCANNER OGNI 2 SECONDI (Pulizia Automatica)
-- ==========================================
task.spawn(function()
    while task.wait(2) do
        local sortedRequired = false
        
        -- Controlliamo tutti gli oggetti tracciati
        for item, data in pairs(trackedItems) do
            -- Se l'oggetto è stato distrutto o non è più in workspace.Items
            if not item or not item.Parent or not item:IsDescendantOf(workspaceItems) then
                
                -- Distruggi la riga UI specifica di quell'oggetto
                if data.rowFrame then
                    data.rowFrame:Destroy()
                end
                
                -- Aggiorna la categoria
                local catName = data.categoryName
                local category = categories[catName]
                
                if category then
                    category.count = category.count - 1
                    
                    if category.count <= 0 then
                        -- Se non ci sono più oggetti, distruggi l'intera categoria
                        category.frame:Destroy()
                        categories[catName] = nil
                        sortedRequired = true
                    else
                        -- Altrimenti, aggiorna il testo del contatore
                        local arrow = category.isOpen() and "▼ " or "▶ "
                        category.headerLabel.Text = arrow .. catName .. " (" .. category.count .. ")"
                    end
                end
                
                -- Rimuovi dalla tabella
                trackedItems[item] = nil
            end
        end
        
        -- Se abbiamo eliminato un'intera categoria, riordiniamo l'alfabeto
        if sortedRequired then
            sortCategories()
        end
    end
end)

-- Avvio iniziale
for _, item in ipairs(workspaceItems:GetChildren()) do
    addItem(item)
end
sortCategories()

-- Ascolta i nuovi oggetti
workspaceItems.ChildAdded:Connect(function(item)
    addItem(item)
    sortCategories()
end)
