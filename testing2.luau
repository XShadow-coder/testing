local REQUIRED_PLACE_ID = 9431156611

if game.PlaceId ~= REQUIRED_PLACE_ID then
    warn("❌ Place ID unverified. Script not executed.")
    return
end

print("✅ Place ID verified. Starting script...")


local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local uiName = "SafetyAdvancedAutoTPUI"

-- 1. Pulizia UI precedente
local existingUi = CoreGui:FindFirstChild(uiName) or player.PlayerGui:FindFirstChild(uiName)
if existingUi then existingUi:Destroy() end

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

local success = pcall(function()
    if gethui then screenGui.Parent = gethui() else screenGui.Parent = CoreGui end
end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 360)
mainFrame.Position = UDim2.new(0, 15, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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
local COOLDOWN_DURATION = 3
local currentAutoTPCategory = nil

task.spawn(function()
    while task.wait(0.1) do
        local now = os.clock()
        local timePassed = now - lastTeleportTime
        
        if timePassed < COOLDOWN_DURATION then
            local timeLeft = math.ceil(COOLDOWN_DURATION - timePassed)
            titleLabel.Text = "In Cooldown... (" .. timeLeft .. "s)"
            titleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        else
            titleLabel.Text = "Items Teleporter"
            titleLabel.TextColor3 = Color3.new(1, 1, 1)
        end
    end
end)

-- ==========================================
-- SISTEMA STATO MATCH (Logica esatta del detector testato)
-- ==========================================
local isMatchReady = false
local working = false

local busDetected = false
local gliderDetected = false
local freefallDetected = false

local cycleId = 0

local function resetMatchState()
    isMatchReady = false
    working = false
    busDetected = false
    gliderDetected = false
    freefallDetected = false
    cycleId = cycleId + 1
end

player.CharacterAdded:Connect(resetMatchState)

task.spawn(function()
    while task.wait(0.1) do
        if working then
            continue
        end

        local char = player.Character
        if not char then
            resetMatchState()
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            continue
        end

        local inBus = char:GetAttribute("InBus")
        local state = humanoid:GetState()
        local glider = char:FindFirstChild("Glider")

        -- Quando siamo pronti, se viene rilevato il Bus, il ciclo riparte da capo
        if isMatchReady then
            if inBus == true then
                resetMatchState()
            end
            continue
        end

        --==================================================
        -- BUS
        --==================================================
        if inBus == true and not busDetected then
            busDetected = true
            gliderDetected = false
            freefallDetected = false
        end

        --==================================================
        -- GLIDER
        --==================================================
        if busDetected
            and inBus == nil
            and glider
            and not gliderDetected then
            
            gliderDetected = true
        end

        --==================================================
        -- FREEFALL
        --==================================================
        if gliderDetected
            and state == Enum.HumanoidStateType.Freefall
            and not freefallDetected then
            
            freefallDetected = true
        end

        --==================================================
        -- RUNNING + INBUS NIL
        --==================================================
        if freefallDetected
            and state == Enum.HumanoidStateType.Running
            and inBus == nil then
            
            working = true
            local thisCycle = cycleId

            task.delay(5, function()
                if thisCycle ~= cycleId then
                    return
                end
                
                isMatchReady = true
                working = false
            end)

            continue
        end

        --==================================================
        -- NO GLIDER / ALREADY ON GROUND
        --==================================================
        if not busDetected
            and state == Enum.HumanoidStateType.Running
            and inBus == nil then
            
            working = true
            local thisCycle = cycleId

            task.delay(0.5, function()
                if thisCycle ~= cycleId then
                    return
                end
                
                isMatchReady = true
                working = false
            end)
        end
    end
end)

-- ==========================================
-- CONTROLLI DI SICUREZZA
-- ==========================================
local function checkSafetyConditions(categoryName)
    -- 1. Aspetta di essere a terra e fuori dal bus (utilizzando il loop in background)
    while not isMatchReady do
        if categoryName and currentAutoTPCategory ~= categoryName then return false end
        task.wait(0.2)
    end
    
    -- 2. Controllo Ragdolled
    local char = player.Character
    if char and char:GetAttribute("Ragdolled") == true then
        while true do
            char = player.Character
            if not char then task.wait(0.5); continue end
            if char:GetAttribute("Ragdolled") ~= true then break end
            
            if categoryName and currentAutoTPCategory ~= categoryName then return false end
            task.wait(0.2)
        end
    end
    
    return true
end

-- ==========================================
-- LOGICA TELETRASPORTO
-- ==========================================
local function teleportTo(targetCFrame)
    local now = os.clock()
    if now - lastTeleportTime < COOLDOWN_DURATION then return false end

    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    lastTeleportTime = now
    local finalCFrame = CFrame.new(targetCFrame.Position + Vector3.new(0, 4, 0))
    
    hrp.CFrame = finalCFrame
    task.delay(0.05, function()
        if char then char:PivotTo(finalCFrame) end
    end)
    return true
end

local function getTargetPosition(item)
    if item:IsA("BasePart") then return item.Position end
    if item:IsA("Model") and item.PrimaryPart then return item.PrimaryPart.Position end
    if item:IsA("Model") then
        local firstPart = item:FindFirstChildWhichIsA("BasePart")
        if firstPart then return firstPart.Position end
    end
    return nil
end

-- ==========================================
-- SISTEMA AUTO TP
-- ==========================================
local categories = {}
local trackedItems = {}

local currentAutoTPTarget = nil
local currentAutoTPTargetPos = nil
local currentAutoTPConnection = nil

local function disableAutoTP()
    if currentAutoTPCategory and categories[currentAutoTPCategory] then
        local btn = categories[currentAutoTPCategory].autoTpBtn
        if btn then
            btn.Text = "Auto: OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    currentAutoTPCategory = nil
    currentAutoTPTarget = nil
    currentAutoTPTargetPos = nil
    if currentAutoTPConnection then
        currentAutoTPConnection:Disconnect()
        currentAutoTPConnection = nil
    end
end

local function doAutoTP(categoryName)
    if currentAutoTPCategory ~= categoryName then return end

    local targetItem = nil
    for item, data in pairs(trackedItems) do
        if data.categoryName == categoryName and item.Parent and item:IsDescendantOf(workspaceItems) then
            targetItem = item
            break
        end
    end

    if not targetItem then disableAutoTP(); return end

    -- 1. Aspetta il Cooldown
    while os.clock() - lastTeleportTime < COOLDOWN_DURATION do
        if currentAutoTPCategory ~= categoryName then return end
        task.wait(0.1)
    end
    
    -- 2. Passa i controlli di sicurezza prima di teletrasportarsi (es. in volo o ragdoll)
    if not checkSafetyConditions(categoryName) then return end

    -- 3. Assicurati che l'oggetto esista ancora dopo l'attesa
    if not targetItem or not targetItem.Parent or not targetItem:IsDescendantOf(workspaceItems) then
        doAutoTP(categoryName)
        return
    end

    currentAutoTPTarget = targetItem
    currentAutoTPTargetPos = getTargetPosition(targetItem)

    if currentAutoTPTargetPos then
        teleportTo(CFrame.new(currentAutoTPTargetPos))
        
        if currentAutoTPConnection then currentAutoTPConnection:Disconnect() end
        currentAutoTPConnection = targetItem.AncestryChanged:Connect(function(_, parent)
            if not parent or not targetItem:IsDescendantOf(workspaceItems) then
                if currentAutoTPConnection then currentAutoTPConnection:Disconnect() end
                
                if currentAutoTPTarget == targetItem then
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp and currentAutoTPTargetPos then
                        local dist = (hrp.Position - currentAutoTPTargetPos).Magnitude
                        if dist <= 30 then
                            local catToProcess = currentAutoTPCategory
                            task.spawn(function() doAutoTP(catToProcess) end)
                        else
                            disableAutoTP()
                        end
                    else
                        disableAutoTP()
                    end
                    
                    currentAutoTPTarget = nil
                    currentAutoTPTargetPos = nil
                end
            end
        end)
    else
        doAutoTP(categoryName)
    end
end

local function toggleAutoTP(categoryName)
    if currentAutoTPCategory == categoryName then
        disableAutoTP()
    else
        disableAutoTP()
        currentAutoTPCategory = categoryName
        local btn = categories[categoryName].autoTpBtn
        btn.Text = "Auto: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        task.spawn(function() doAutoTP(categoryName) end)
    end
end

-- ==========================================
-- GESTIONE DELLE CATEGORIE E TRACKING OGGETTI
-- ==========================================
local function getOrCreateCategory(itemName)
    if categories[itemName] then return categories[itemName] end

    local catFrame = Instance.new("Frame")
    catFrame.Name = itemName
    catFrame.Size = UDim2.new(1, 0, 0, 0)
    catFrame.BackgroundTransparency = 1
    catFrame.AutomaticSize = Enum.AutomaticSize.Y
    catFrame.Parent = scrollFrame

    Instance.new("UIListLayout", catFrame).SortOrder = Enum.SortOrder.LayoutOrder

    local headerContainer = Instance.new("Frame")
    headerContainer.Size = UDim2.new(1, 0, 0, 35)
    headerContainer.BackgroundTransparency = 1
    headerContainer.Parent = catFrame

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(0.65, 0, 1, 0)
    headerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    headerBtn.Text = ""
    headerBtn.AutoButtonColor = true
    headerBtn.Parent = headerContainer
    Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 4)

    local autoTpBtn = Instance.new("TextButton")
    autoTpBtn.Size = UDim2.new(0.35, -5, 0, 30)
    autoTpBtn.Position = UDim2.new(0.65, 5, 0, 2)
    autoTpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    autoTpBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    autoTpBtn.Text = "Auto: OFF"
    autoTpBtn.Font = Enum.Font.GothamBold
    autoTpBtn.TextSize = 11
    autoTpBtn.Parent = headerContainer
    Instance.new("UICorner", autoTpBtn).CornerRadius = UDim.new(0, 4)

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
        headerText.Text = (isOpen and "▼ " or "▶ ") .. itemName .. " (" .. categories[itemName].count .. ")"
    end)

    autoTpBtn.MouseButton1Click:Connect(function()
        toggleAutoTP(itemName)
    end)

    categories[itemName] = {
        frame = catFrame,
        container = itemsContainer,
        headerLabel = headerText,
        autoTpBtn = autoTpBtn,
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
    category.headerLabel.Text = (category.isOpen() and "▼ " or "▶ ") .. item.Name .. " (" .. category.count .. ")"

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
        
        task.spawn(function()
            if checkSafetyConditions() then
                local pos = getTargetPosition(item)
                if pos then teleportTo(CFrame.new(pos)) end
            end
        end)
    end)

    trackedItems[item] = { rowFrame = rowFrame, categoryName = item.Name }
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
-- SCANNER OGNI 2 SECONDI (Pulizia UI)
-- ==========================================
task.spawn(function()
    while task.wait(2) do
        local sortedRequired = false
        
        for item, data in pairs(trackedItems) do
            if not item or not item.Parent or not item:IsDescendantOf(workspaceItems) then
                if data.rowFrame then data.rowFrame:Destroy() end
                
                local catName = data.categoryName
                local category = categories[catName]
                
                if category then
                    category.count = category.count - 1
                    if category.count <= 0 then
                        category.frame:Destroy()
                        categories[catName] = nil
                        sortedRequired = true
                        
                        if currentAutoTPCategory == catName then disableAutoTP() end
                    else
                        category.headerLabel.Text = (category.isOpen() and "▼ " or "▶ ") .. catName .. " (" .. category.count .. ")"
                    end
                end
                trackedItems[item] = nil
            else
                if item == currentAutoTPTarget then
                    currentAutoTPTargetPos = getTargetPosition(item) or currentAutoTPTargetPos
                end
            end
        end
        if sortedRequired then sortCategories() end
    end
end)

-- Avvio iniziale
for _, item in ipairs(workspaceItems:GetChildren()) do addItem(item) end
sortCategories()
workspaceItems.ChildAdded:Connect(function(item)
    addItem(item)
    sortCategories()
end)
