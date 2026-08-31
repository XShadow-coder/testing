local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ==========================================
-- 1. FUNZIONE DI TELETRASPORTO
-- ==========================================
local function teleportTo(targetCFrame)
    local char = player.Character
    if not char then return end

    local targetPosition = targetCFrame.Position
    local finalCFrame = CFrame.new(targetPosition + Vector3.new(0, 4, 0))
    char:PivotTo(finalCFrame)
end

-- ==========================================
-- 2. SETUP INTERFACCIA PRINCIPALE
-- ==========================================
if CoreGui:FindFirstChild("ArceusItemHub") then
    CoreGui.ArceusItemHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArceusItemHub"
screenGui.Parent = CoreGui

-- Main Frame (Trascinabile)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 45)
mainFrame.Position = UDim2.new(0.5, -120, 0.2, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Intestazione Principale
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0.75, 0, 1, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 14
mainButton.Text = "📦 Items.Workspace"
mainButton.Parent = mainFrame

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 6)
corner1.Parent = mainButton

-- Bottone Aggiorna (🔄)
local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0.22, 0, 1, 0)
refreshButton.Position = UDim2.new(0.78, 0, 0, 0)
refreshButton.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Font = Enum.Font.GothamBold
refreshButton.TextSize = 14
refreshButton.Text = "🔄"
refreshButton.Parent = mainFrame

local cornerRefresh = Instance.new("UICorner")
cornerRefresh.CornerRadius = UDim.new(0, 6)
cornerRefresh.Parent = refreshButton

-- Contenitore principale della lista
local mainScrollingFrame = Instance.new("ScrollingFrame")
mainScrollingFrame.Size = UDim2.new(1, 0, 0, 220)
mainScrollingFrame.Position = UDim2.new(0, 0, 0, 50)
mainScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainScrollingFrame.BorderSizePixel = 0
mainScrollingFrame.ScrollBarThickness = 4
mainScrollingFrame.Visible = false
mainScrollingFrame.Parent = mainFrame

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 6)
corner2.Parent = mainScrollingFrame

local mainListLayout = Instance.new("UIListLayout")
mainListLayout.Padding = UDim.new(0, 4)
mainListLayout.Parent = mainScrollingFrame

-- Logica apertura menu principale
local isMainOpen = false
mainButton.MouseButton1Click:Connect(function()
    isMainOpen = not isMainOpen
    mainScrollingFrame.Visible = isMainOpen
end)

-- ==========================================
-- 3. SISTEMA DI SCANSIONE E RAGGRUPPAMENTO
-- ==========================================
local function scanItemsFolder()
    -- Pulisce la lista precedente
    for _, child in pairs(mainScrollingFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            if child ~= mainListLayout then
                child:Destroy()
            end
        end
    end

    local itemsFolder = Workspace:FindFirstChild("Items")
    if not itemsFolder then
        mainButton.Text = "Folder 'Items' non trovato!"
        task.wait(2)
        mainButton.Text = "📦 Items.Workspace"
        return
    end

    -- Tabella per raggruppare gli oggetti per nome: { ["NomeOggetto"] = {part1, part2, ...} }
    local groupedItems = {}

    for _, obj in pairs(itemsFolder:GetChildren()) do
        local targetPart = nil
        
        if obj:IsA("BasePart") then
            targetPart = obj
        elseif obj:IsA("Model") then
            targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        end

        if targetPart then
            local name = obj.Name
            if not groupedItems[name] then
                groupedItems[name] = {}
            end
            table.insert(groupedItems[name], targetPart)
        end
    end

    -- Crea un dropdown per ogni gruppo di oggetti trovato
    for itemName, partsList in pairs(groupedItems) do
        -- Contenitore del singolo dropdown
        local dropContainer = Instance.new("Frame")
        dropContainer.Size = UDim2.new(1, 0, 0, 35)
        dropContainer.BackgroundTransparency = 1
        dropContainer.Parent = mainScrollingFrame

        -- Bottone del Dropdown (es. "> Bull’s essence (3)")
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(1, 0, 0, 35)
        dropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
        dropBtn.Font = Enum.Font.GothamBold
        dropBtn.TextSize = 13
        dropBtn.Text = "▶️ " .. itemName .. " (" .. #partsList .. ")"
        dropBtn.Parent = dropContainer

        local cornerDrop = Instance.new("UICorner")
        cornerDrop.CornerRadius = UDim.new(0, 4)
        cornerDrop.Parent = dropBtn

        -- Lista interna degli elementi di quel gruppo (nascosta di default)
        local subScrolling = Instance.new("ScrollingFrame")
        subScrolling.Size = UDim2.new(1, 0, 0, 0) -- Parte chiuso
        subScrolling.Position = UDim2.new(0, 0, 0, 38)
        subScrolling.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        subScrolling.BorderSizePixel = 0
        subScrolling.ScrollBarThickness = 3
        subScrolling.Visible = false
        subScrolling.Parent = dropContainer

        local cornerSub = Instance.new("UICorner")
        cornerSub.CornerRadius = UDim.new(0, 4)
        cornerSub.Parent = subScrolling

        local subLayout = Instance.new("UIListLayout")
        subLayout.Padding = UDim.new(0, 2)
        subLayout.Parent = subScrolling

        -- Popola la sotto-lista con le singole istanze trovate
        for index, part in ipairs(partsList) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            itemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextSize = 12
            itemBtn.Text = itemName .. " #" .. index
            itemBtn.Parent = subScrolling

            local cornerBtn = Instance.new("UICorner")
            cornerBtn.CornerRadius = UDim.new(0, 3)
            cornerBtn.Parent = itemBtn

            -- Teletrasporto al singolo oggetto specifico
            itemBtn.MouseButton1Click:Connect(function()
                if part and part.Parent then
                    teleportTo(part.CFrame)
                else
                    itemBtn.Text = "Non disponibile"
                    itemBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                    task.wait(1)
                    itemBtn:Destroy()
                end
            end)
        end

        -- Logica di apertura/chiusura del singolo dropdown
        local isOpen = false
        dropBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            subScrolling.Visible = isOpen
            
            local targetHeight = isOpen and math.min(#partsList * 32, 120) or 0
            subScrolling.Size = UDim2.new(1, 0, 0, targetHeight)
            
            -- Ridimensiona dinamicamente il contenitore principale per fare spazio
            if isOpen then
                dropContainer.Size = UDim2.new(1, 0, 0, 35 + targetHeight + 4)
                dropBtn.Text = "▼ " .. itemName .. " (" .. #partsList .. ")"
            else
                dropContainer.Size = UDim2.new(1, 0, 0, 35)
                dropBtn.Text = "▶️ " .. itemName .. " (" .. #partsList .. ")"
            end
            
            mainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, mainListLayout.AbsoluteContentSize.Y + 20)
        end)
    end

    mainScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, mainListLayout.AbsoluteContentSize.Y + 20)
end

refreshButton.MouseButton1Click:Connect(scanItemsFolder)

-- Prima scansione automatica all'avvio
scanItemsFolder()