local cloneref = cloneref or function(...) return ... end

local sbPlaceIds = {
    [6403373529] = true,
    [11520107397] = true,
    [124596094333302] = true,
    [9015014224] = true,
    [78262906459073] = true,
}

if not sbPlaceIds[game.PlaceId] then
    local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name or "another game"
    print("This script is for Slap Battles, but you are in " .. gameName)
    return
end

if getgenv().KsHelper_Loaded then
    return
end

pcall(function() getgenv().KsHelper_Loaded = true end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = cloneref(game:GetService("CoreGui"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = cloneref(Players.LocalPlayer)

local guiParent = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui

local function randomString()
	local length = math.random(10, 20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

-- === STILE & COLORI ===
local THEME = {
    Background = Color3.fromRGB(24, 24, 28),
    Header = Color3.fromRGB(32, 32, 38),
    Card = Color3.fromRGB(36, 36, 44),
    InputBg = Color3.fromRGB(44, 44, 54),
    Border = Color3.fromRGB(55, 55, 68),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 175),
    AccentGreen = Color3.fromRGB(46, 160, 67),
    AccentRed = Color3.fromRGB(218, 54, 51),
    AccentBlue = Color3.fromRGB(45, 110, 210),
    ButtonHover = Color3.fromRGB(50, 50, 62)
}

-- === INTERFACCIA GRAFICA ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomString()
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = randomString()
MainFrame.Size = UDim2.new(0, 300, 0, 310)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -155)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Top Bar / Header
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = randomString()
HeaderBar.Size = UDim2.new(1, 0, 0, 36)
HeaderBar.BackgroundColor3 = THEME.Header
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderBar

-- Fix per coprire i bordi arrotondati inferiori dell'header
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = THEME.Header
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = HeaderBar

local Title = Instance.new("TextLabel")
Title.Name = randomString()
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Killstreak Helper"
Title.TextColor3 = THEME.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -56, 0.5, -12)
MinimizeBtn.BackgroundColor3 = THEME.InputBg
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = THEME.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
MinimizeBtn.Parent = HeaderBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
CloseBtn.BackgroundColor3 = THEME.AccentRed
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Container Contenuti
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = randomString()
ContentContainer.Size = UDim2.new(1, -24, 1, -48)
ContentContainer.Position = UDim2.new(0, 12, 0, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- 1. Selettore Modalità Target
local ModeSelector = Instance.new("TextButton")
ModeSelector.Size = UDim2.new(1, 0, 0, 32)
ModeSelector.Position = UDim2.new(0, 0, 0, 0)
ModeSelector.BackgroundColor3 = THEME.AccentBlue
ModeSelector.Text = "🎯 Mode: Follow Player"
ModeSelector.TextColor3 = THEME.Text
ModeSelector.Font = Enum.Font.GothamBold
ModeSelector.TextSize = 13
ModeSelector.Parent = ContentContainer

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 7)
ModeCorner.Parent = ModeSelector

-- 2. Input per Player
local PlayerInput = Instance.new("TextBox")
PlayerInput.Size = UDim2.new(1, 0, 0, 32)
PlayerInput.Position = UDim2.new(0, 0, 0, 38)
PlayerInput.PlaceholderText = "Enter target player name..."
PlayerInput.Text = ""
PlayerInput.BackgroundColor3 = THEME.InputBg
PlayerInput.TextColor3 = THEME.Text
PlayerInput.PlaceholderColor3 = THEME.TextDim
PlayerInput.Font = Enum.Font.Gotham
PlayerInput.TextSize = 13
PlayerInput.Parent = ContentContainer

local PlayerInputCorner = Instance.new("UICorner")
PlayerInputCorner.CornerRadius = UDim.new(0, 7)
PlayerInputCorner.Parent = PlayerInput

-- 2b. Bottone Posizione (Visibile solo in modalità Position)
local PosButton = Instance.new("TextButton")
PosButton.Size = UDim2.new(1, 0, 0, 32)
PosButton.Position = UDim2.new(0, 0, 0, 38)
PosButton.Text = "📍 Save Current Position"
PosButton.BackgroundColor3 = THEME.Card
PosButton.TextColor3 = THEME.Text
PosButton.Font = Enum.Font.GothamBold
PosButton.TextSize = 13
PosButton.Visible = false
PosButton.Parent = ContentContainer

local PosCorner = Instance.new("UICorner")
PosCorner.CornerRadius = UDim.new(0, 7)
PosCorner.Parent = PosButton

local PosStroke = Instance.new("UIStroke")
PosStroke.Color = THEME.Border
PosStroke.Parent = PosButton

-- 3. Sezione Auto-Reset & Ragdoll Limit
local ResetFrame = Instance.new("Frame")
ResetFrame.Size = UDim2.new(1, 0, 0, 34)
ResetFrame.Position = UDim2.new(0, 0, 0, 76)
ResetFrame.BackgroundTransparency = 1
ResetFrame.Parent = ContentContainer

local ToggleResetBtn = Instance.new("TextButton")
ToggleResetBtn.Size = UDim2.new(0, 160, 1, 0)
ToggleResetBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleResetBtn.Text = "Auto-Reset: ON"
ToggleResetBtn.BackgroundColor3 = THEME.AccentGreen
ToggleResetBtn.TextColor3 = THEME.Text
ToggleResetBtn.Font = Enum.Font.GothamBold
ToggleResetBtn.TextSize = 12
ToggleResetBtn.Parent = ResetFrame

local ToggleResetCorner = Instance.new("UICorner")
ToggleResetCorner.CornerRadius = UDim.new(0, 7)
ToggleResetCorner.Parent = ToggleResetBtn

local RagdollBox = Instance.new("TextBox")
RagdollBox.Size = UDim2.new(0, 110, 1, 0)
RagdollBox.Position = UDim2.new(1, -110, 0, 0)
RagdollBox.Text = "1"
RagdollBox.PlaceholderText = "Limit"
RagdollBox.BackgroundColor3 = THEME.InputBg
RagdollBox.TextColor3 = THEME.Text
RagdollBox.Font = Enum.Font.GothamBold
RagdollBox.TextSize = 13
RagdollBox.Parent = ResetFrame

local RagdollCorner = Instance.new("UICorner")
RagdollCorner.CornerRadius = UDim.new(0, 7)
RagdollCorner.Parent = RagdollBox

local RagdollLabel = Instance.new("TextLabel")
RagdollLabel.Size = UDim2.new(1, 0, 0, 12)
RagdollLabel.Position = UDim2.new(0, 0, -0.4, 0)
RagdollLabel.BackgroundTransparency = 1
RagdollLabel.Text = "Max Ragdolls:"
RagdollLabel.TextColor3 = THEME.TextDim
RagdollLabel.Font = Enum.Font.Gotham
RagdollLabel.TextSize = 10
RagdollLabel.TextXAlignment = Enum.TextXAlignment.Right
RagdollLabel.Parent = RagdollBox

-- 4. Bottoni Start / Stop
local ActionFrame = Instance.new("Frame")
ActionFrame.Size = UDim2.new(1, 0, 0, 36)
ActionFrame.Position = UDim2.new(0, 0, 0, 120)
ActionFrame.BackgroundTransparency = 1
ActionFrame.Parent = ContentContainer

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.48, 0, 1, 0)
StartBtn.Position = UDim2.new(0, 0, 0, 0)
StartBtn.Text = "▶ Start"
StartBtn.BackgroundColor3 = THEME.AccentGreen
StartBtn.TextColor3 = THEME.Text
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = ActionFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 7)
StartCorner.Parent = StartBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.48, 0, 1, 0)
StopBtn.Position = UDim2.new(0.52, 0, 0, 0)
StopBtn.Text = "⏹ Stop"
StopBtn.BackgroundColor3 = THEME.AccentRed
StopBtn.TextColor3 = THEME.Text
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = ActionFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 7)
StopCorner.Parent = StopBtn

-- 5. Utility
local IYBtn =
