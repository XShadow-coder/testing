--!strict

--// ============================================================
--// Killstreak Helper
--// Event-driven / mobile compatible
--// ============================================================

local cloneref = cloneref or function<T>(object: T): T
	return object
end

local Players: Players = cloneref(game:GetService("Players"))
local Workspace: Workspace = cloneref(game:GetService("Workspace"))
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local StarterGui: StarterGui = cloneref(game:GetService("StarterGui"))
local RunService: RunService = cloneref(game:GetService("RunService"))

local LocalPlayer: Player = cloneref(Players.LocalPlayer)

--// ============================================================
--// Executor globals
--// ============================================================

local GENV: any = _G

pcall(function()
	if type((getgenv :: any)) == "function" then
		GENV = (getgenv :: any)()
	end
end)

local fireTouch: ((BasePart, BasePart, number) -> ())? = nil

pcall(function()
	local fn: any = (firetouchinterest :: any)

	if type(fn) == "function" then
		fireTouch = fn
	end
end)

--// ============================================================
--// Place IDs
--// ============================================================

local SB_PLACE_IDS: {[number]: boolean} = {
	[6403373529] = true,
	[11520107397] = true,
	[124596094333302] = true,
	[9015014224] = true,
	[78262906459073] = true,
}

if not SB_PLACE_IDS[game.PlaceId] then
	warn("[Killstreak Helper] Unsupported PlaceId: " .. tostring(game.PlaceId))
	return
end

--// ============================================================
--// Types
--// ============================================================

export type TargetMode = "PLAYER" | "POSITION"

export type HelperState = {
	running: boolean,
	destroyed: boolean,

	targetMode: TargetMode,
	targetPlayer: Player?,
	targetUserId: number?,

	savedPosition: CFrame?,

	autoReset: boolean,
	resetThreshold: number,

	currentRagdolls: number,
	totalRagdolls: number,
	resets: number,

	ragdollActive: boolean,
	resetDebounce: boolean,

	startTime: number,
}

--// ============================================================
--// Cleanup
--// ============================================================

local connections: {RBXScriptConnection} = {}
local tasks: {thread} = {}

local function addConnection(connection: RBXScriptConnection): ()
	table.insert(connections, connection)
end

local function addTask(thread: thread): ()
	table.insert(tasks, thread)
end

local function cleanup(): ()
	for _, connection: RBXScriptConnection in connections do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, thread: thread in tasks do
		pcall(function()
			task.cancel(thread)
		end)
	end

	table.clear(tasks)
end

--// ============================================================
--// Prevent duplicate execution
--// ============================================================

if GENV.KsHelper_Loaded == true then
	return
end

GENV.KsHelper_Loaded = true

--// ============================================================
--// State
--// ============================================================

local state: HelperState = {
	running = false,
	destroyed = false,

	targetMode = "PLAYER",
	targetPlayer = nil,
	targetUserId = nil,

	savedPosition = nil,

	autoReset = true,
	resetThreshold = 1,

	currentRagdolls = 0,
	totalRagdolls = 0,
	resets = 0,

	ragdollActive = false,
	resetDebounce = false,

	startTime = 0,
}

--// ============================================================
--// Debug
--// ============================================================

local debugLines: {string} = {}
local MAX_DEBUG_LINES: number = 80

local function debugLog(message: string): ()
	local line: string = string.format(
		"[%s] %s",
		os.date("%H:%M:%S"),
		message
	)

	table.insert(debugLines, line)

	if #debugLines > MAX_DEBUG_LINES then
		table.remove(debugLines, 1)
	end

	print("[Killstreak Helper] " .. line)
end

--// ============================================================
--// GUI parent
--// ============================================================

local function getGuiParent(): Instance
	local getHui: any = nil

	pcall(function()
		getHui = (gethui :: any)
	end)

	if type(getHui) == "function" then
		local ok: boolean, result: any = pcall(getHui)

		if ok and typeof(result) == "Instance" then
			return result
		end
	end

	local robloxGui: Instance? = CoreGui:FindFirstChild("RobloxGui")

	if robloxGui then
		return robloxGui
	end

	return CoreGui
end

--// ============================================================
--// GUI
--// ============================================================

local ScreenGui: ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillstreakHelper"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()

local Frame: Frame = Instance.new("Frame")
Frame.Name = "Main"
Frame.Size = UDim2.fromOffset(250, 205)
Frame.Position = UDim2.new(0.5, -125, 0.5, -102)
Frame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameCorner: UICorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

local FrameStroke: UIStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(60, 60, 60)
FrameStroke.Parent = Frame

local Title: TextLabel = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -85, 0, 30)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Minimize: TextButton = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(25, 25)
Minimize.Position = UDim2.new(1, -60, 0, 2)
Minimize.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Minimize.Text = "_"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.Parent = Frame

local MinCorner: UICorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = Minimize

local Close: TextButton = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(25, 25)
Close.Position = UDim2.new(1, -30, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Frame

local CloseCorner: UICorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

local TargetBox: TextBox = Instance.new("TextBox")
TargetBox.Position = UDim2.fromOffset(25, 40)
TargetBox.Size = UDim2.fromOffset(200, 30)
TargetBox.Text = ""
TargetBox.PlaceholderText = "Username / UserId"
TargetBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
TargetBox.Font = Enum.Font.Gotham
TargetBox.TextSize = 13
TargetBox.ClearTextOnFocus = false
TargetBox.Parent = Frame

local TargetCorner: UICorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 6)
TargetCorner.Parent = TargetBox

local Mode: TextButton = Instance.new("TextButton")
Mode.Position = UDim2.fromOffset(25, 76)
Mode.Size = UDim2.fromOffset(95, 28)
Mode.Text = "PLAYER"
Mode.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Mode.TextColor3 = Color3.fromRGB(255, 255, 255)
Mode.Font = Enum.Font.GothamBold
Mode.TextSize = 12
Mode.Parent = Frame

local ModeCorner: UICorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 6)
ModeCorner.Parent = Mode

local Save: TextButton = Instance.new("TextButton")
Save.Position = UDim2.fromOffset(130, 76)
Save.Size = UDim2.fromOffset(95, 28)
Save.Text = "Save Pos"
Save.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Save.TextColor3 = Color3.fromRGB(255, 255, 255)
Save.Font = Enum.Font.GothamBold
Save.TextSize = 12
Save.Parent = Frame

local SaveCorner: UICorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 6)
SaveCorner.Parent = Save

local Threshold: TextBox = Instance.new("TextBox")
Threshold.Position = UDim2.fromOffset(25, 112)
Threshold.Size = UDim2.fromOffset(95, 28)
Threshold.Text = "1"
Threshold.PlaceholderText = "Ragdolls"
Threshold.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Threshold.TextColor3 = Color3.fromRGB(255, 255, 255)
Threshold.Font = Enum.Font.Gotham
Threshold.TextSize = 12
Threshold.ClearTextOnFocus = false
Threshold.Parent = Frame

local ThresholdCorner: UICorner = Instance.new("UICorner")
ThresholdCorner.CornerRadius = UDim.new(0, 6)
ThresholdCorner.Parent = Threshold

local AutoReset: TextButton = Instance.new("TextButton")
AutoReset.Position = UDim2.fromOffset(130, 112)
AutoReset.Size = UDim2.fromOffset(95, 28)
AutoReset.Text = "Reset: ON"
AutoReset.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
AutoReset.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoReset.Font = Enum.Font.GothamBold
AutoReset.TextSize = 12
AutoReset.Parent = Frame

local AutoCorner: UICorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoReset

local Start: TextButton = Instance.new("TextButton")
Start.Position = UDim2.fromOffset(25, 148)
Start.Size = UDim2.fromOffset(95, 32)
Start.Text = "START"
Start.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
Start.TextColor3 = Color3.fromRGB(255, 255, 255)
Start.Font = Enum.Font.GothamBold
Start.TextSize = 13
Start.Parent = Frame

local StartCorner: UICorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 6)
StartCorner.Parent = Start

local Stop: TextButton = Instance.new("TextButton")
Stop.Position = UDim2.fromOffset(130, 148)
Stop.Size = UDim2.fromOffset(95, 32)
Stop.Text = "STOP"
Stop.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
Stop.TextColor3 = Color3.fromRGB(255, 255, 255)
Stop.Font = Enum.Font.GothamBold
Stop.TextSize = 13
Stop.Parent = Frame

local StopCorner: UICorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 6)
StopCorner.Parent = Stop

local Status: TextLabel = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(25, 183)
Status.Size = UDim2.fromOffset(200, 18)
Status.BackgroundTransparency = 1
Status.Text = "Stopped | Ragdolls: 0 | Resets: 0"
Status.TextColor3 = Color3.fromRGB(190, 190, 190)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10
Status.TextXAlignment = Enum.TextXAlignment.Center
Status.Parent = Frame

--// ============================================================
--// Notification
--// ============================================================

local function notify(message: string): ()
	local ok: boolean = pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Killstreak Helper",
			Text = message,
			Duration = 3,
		})
	end)

	if not ok then
		debugLog("Notification failed: " .. message)
	end
end

--// ============================================================
--// Character cache
--// ============================================================

local character: Model? = nil
local rootPart: BasePart? = nil
local humanoid: Humanoid? = nil

local ragdollConnection: RBXScriptConnection? = nil
local ragdollAddedConnection: RBXScriptConnection? = nil

local function disconnectRagdollEvents(): ()
	if ragdollConnection and ragdollConnection.Connected then
		ragdollConnection:Disconnect()
	end

	if ragdollAddedConnection and ragdollAddedConnection.Connected then
		ragdollAddedConnection:Disconnect()
	end

	ragdollConnection = nil
	ragdollAddedConnection = nil
end

local function processRagdollValue(value: Instance): ()
	if not value:IsA("BoolValue") then
		return
	end

	state.ragdollActive = value.Value

	if ragdollConnection and ragdollConnection.Connected then
		ragdollConnection:Disconnect()
	end

	ragdollConnection = value:GetPropertyChangedSignal("Value"):Connect(function()
		if state.destroyed then
			return
		end

		local active: boolean = value.Value

		--// Count only the rising edge:
		--// false -> true = one new ragdoll.
		if active and not state.ragdollActive then
			state.currentRagdolls += 1
			state.totalRagdolls += 1

			debugLog(
				string.format(
					"Ragdoll #%d | cycle %d/%d",
					state.totalRagdolls,
					state.currentRagdolls,
					state.resetThreshold
				)
			)

			if state.running
				and state.autoReset
				and state.currentRagdolls >= state.resetThreshold
				and not state.resetDebounce then

				state.resetDebounce = true

				local resetRemote: Instance? =
					LocalPlayer:FindFirstChild("Reset")

				if resetRemote and resetRemote:IsA("RemoteEvent") then
					local ok: boolean, err: any = pcall(function()
						resetRemote:FireServer()
					end)

					if ok then
						state.resets += 1
						debugLog(
							"Reset executed after " ..
							tostring(state.currentRagdolls) ..
							" ragdoll(s)"
						)
					else
						debugLog(
							"Reset failed: " .. tostring(err)
						)
					end
				else
					debugLog("Reset RemoteEvent not found")
				end

				state.currentRagdolls = 0

				-- task.spawn + task.wait instead of task.delay.
				local resetThread: thread = task.spawn(function()
					task.wait(1)

					if not state.destroyed then
						state.resetDebounce = false
					end
				end)

				addTask(resetThread)
			end
		end

		state.ragdollActive = active
	end)
end

local function refreshCharacter(newCharacter: Model?): ()
	disconnectRagdollEvents()

	character = newCharacter
	rootPart = nil
	humanoid = nil
	state.ragdollActive = false
	state.currentRagdolls = 0
	state.resetDebounce = false

	if not newCharacter then
		debugLog("Character cleared")
		return
	end

	local foundRoot: Instance? =
		newCharacter:FindFirstChild("HumanoidRootPart")

	if foundRoot and foundRoot:IsA("BasePart") then
		rootPart = foundRoot
	end

	local foundHumanoid: Instance? =
		newCharacter:FindFirstChildOfClass("Humanoid")

	if foundHumanoid and foundHumanoid:IsA("Humanoid") then
		humanoid = foundHumanoid
	end

	debugLog("Character -> " .. newCharacter.Name)

	local ragdolled: Instance? =
		newCharacter:FindFirstChild("Ragdolled")

	if ragdolled then
		processRagdollValue(ragdolled)
	end

	ragdollAddedConnection =
		newCharacter.ChildAdded:Connect(function(child: Instance)
			if child.Name == "Ragdolled" then
				processRagdollValue(child)
			end
		end)
end

local initialCharacter: Model? = LocalPlayer.Character

if initialCharacter then
	refreshCharacter(initialCharacter)
end

addConnection(
	LocalPlayer.CharacterAdded:Connect(function(newCharacter: Model)
		refreshCharacter(newCharacter)

		task.defer(function()
			if state.destroyed then
				return
			end

			local foundRoot: Instance? =
				newCharacter:WaitForChild("HumanoidRootPart", 10)

			local foundHumanoid: Instance? =
				newCharacter:WaitForChild("Humanoid", 10)

			if character ~= newCharacter then
				return
			end

			if foundRoot and foundRoot:IsA("BasePart") then
				rootPart = foundRoot
			end

			if foundHumanoid and foundHumanoid:IsA("Humanoid") then
				humanoid = foundHumanoid
			end

			debugLog("Character components ready")
		end)
	end)
)

--// ============================================================
--// Player lookup
--// ============================================================

local function findPlayer(query: string): Player?
	local cleaned: string =
		query:gsub("^%s+", ""):gsub("%s+$", "")

	if cleaned == "" then
		return nil
	end

	local userId: number? = tonumber(cleaned)

	if userId then
		for _, player: Player in Players:GetPlayers() do
			if player.UserId == userId then
				return player
			end
		end
	end

	local lowered: string = string.lower(cleaned)

	for _, player: Player in Players:GetPlayers() do
		if string.lower(player.Name) == lowered then
			return player
		end
	end

	for _, player: Player in Players:GetPlayers() do
		if string.lower(player.DisplayName) == lowered then
			return player
		end
	end

	for _, player: Player in Players:GetPlayers() do
		if string.find(
			string.lower(player.Name),
			lowered,
			1,
			true
		) ~= nil then
			return player
		end

		if string.find(
			string.lower(player.DisplayName),
			lowered,
			1,
			true
		) ~= nil then
			return player
		end
	end

	return nil
end

local function resolveTarget(): boolean
	if state.targetMode ~= "PLAYER" then
		return true
	end

	local player: Player? = findPlayer(TargetBox.Text)

	if not player then
		state.targetPlayer = nil
		state.targetUserId = tonumber(TargetBox.Text)

		debugLog("Target not found: " .. TargetBox.Text)

		return false
	end

	state.targetPlayer = player
	state.targetUserId = player.UserId

	debugLog(
		string.format(
			"Target -> %s / [%d]",
			player.Name,
			player.UserId
		)
	)

	return true
end

--// ============================================================
--// Arena
--// ============================================================

local function isLocalPlayerInArena(): boolean
	if not character then
		return false
	end

	local arenaFlag: Instance? =
		character:FindFirstChild("isInArena")

	if arenaFlag and arenaFlag:IsA("BoolValue") then
		return arenaFlag.Value
	end

	local killstreak: Instance? =
		character:FindFirstChild("KillstreakLevel")

	if killstreak then
		return true
	end

	return false
end

local function getPortal(): BasePart?
	local lobby: Instance? =
		Workspace:FindFirstChild("Lobby")

	if not lobby then
		return nil
	end

	local portal: Instance? =
		lobby:FindFirstChild("Teleport1")

	if portal and portal:IsA("BasePart") then
		return portal
	end

	return nil
end

local function enterArena(): boolean
	if not state.running then
		return false
	end

	if isLocalPlayerInArena() then
		return true
	end

	if not rootPart then
		return false
	end

	local portal: BasePart? = getPortal()

	if not portal then
		debugLog("Teleport1 not found")
		return false
	end

	--// This deliberately checks ONLY the local player.
	--// The target is allowed to be outside the arena.
	if fireTouch then
		local ok: boolean, err: any = pcall(function()
			(fireTouch :: any)(
				portal :: BasePart,
				rootPart :: BasePart,
				0
			)

			task.wait(0.05)

			(fireTouch :: any)(
				portal :: BasePart,
				rootPart :: BasePart,
				1
			)
		end)

		if not ok then
			debugLog(
				"firetouchinterest failed: " ..
				tostring(err)
			)
		end
	end

	if isLocalPlayerInArena() then
		return true
	end

	--// Same fallback used by the reference implementation.
	local ok: boolean, err: any = pcall(function()
		(rootPart :: BasePart).CFrame =
			(portal :: BasePart).CFrame
	end)

	if not ok then
		debugLog(
			"Portal CFrame failed: " ..
			tostring(err)
		)
	end

	return isLocalPlayerInArena()
end

--// ============================================================
--// Target teleport
--// ============================================================

local function teleportToTarget(): ()
	if not state.running then
		return
	end

	if not rootPart then
		return
	end

	if state.targetMode == "POSITION" then
		local position: CFrame? = state.savedPosition

		if position then
			(rootPart :: BasePart).CFrame = position
		end

		return
	end

	local player: Player? = state.targetPlayer

	if not player or player.Parent ~= Players then
		return
	end

	local targetCharacter: Model? = player.Character

	if not targetCharacter then
		return
	end

	local targetHumanoid: Humanoid? =
		targetCharacter:FindFirstChildOfClass("Humanoid")

	local targetRoot: Instance? =
		targetCharacter:FindFirstChild("HumanoidRootPart")

	if not targetHumanoid then
		return
	end

	if targetHumanoid.Health <= 0 then
		return
	end

	if not targetRoot or not targetRoot:IsA("BasePart") then
		return
	end

	--// IMPORTANT:
	--// No target isInArena check exists here.
	--// This allows following a target outside the arena.
	local ok: boolean, err: any = pcall(function()
		(rootPart :: BasePart).CFrame =
			(targetRoot :: BasePart).CFrame *
			CFrame.new(0, 0, -4)
	end)

	if not ok then
		debugLog(
			"Target teleport failed: " ..
			tostring(err)
		)
	end
end

--// ============================================================
--// Heartbeat controller
--// ============================================================

local heartbeatAccumulator: number = 0
local STATUS_INTERVAL: number = 0.25
local statusAccumulator: number = 0

local function updateStatus(): ()
	local runtime: number = 0

	if state.running then
		runtime = os.clock() - state.startTime
	end

	local seconds: number = math.floor(runtime)

	local targetText: string

	if state.targetMode == "POSITION" then
		targetText =
			state.savedPosition
			and "Position"
			or "Position (none)"
	else
		if state.targetPlayer
			and state.targetPlayer.Parent == Players then

			targetText = string.format(
				"%s / [%d]",
				state.targetPlayer.Name,
				state.targetPlayer.UserId
			)
		elseif state.targetUserId then
			targetText = "[" ..
				tostring(state.targetUserId) ..
				"]"
		else
			targetText = "None"
		end
	end

	Status.Text = string.format(
		"%s | %02d:%02d | %s | R:%d/%d | X:%d",
		state.running and "RUNNING" or "STOPPED",
		math.floor(seconds / 60),
		seconds % 60,
		targetText,
		state.currentRagdolls,
		state.resetThreshold,
		state.resets
	)
end

local heartbeatConnection: RBXScriptConnection =
	RunService.Heartbeat:Connect(function(deltaTime: number)
		if state.destroyed or not state.running then
			return
		end

		heartbeatAccumulator += deltaTime
		statusAccumulator += deltaTime

		--// Movement runs once per frame.
		--// No repeated target lookup is performed.
		teleportToTarget()

		--// Arena entry is independent of target state.
		if not isLocalPlayerInArena() then
			if heartbeatAccumulator >= 0.20 then
				heartbeatAccumulator = 0
				enterArena()
			end
		else
			heartbeatAccumulator = 0
		end

		if statusAccumulator >= STATUS_INTERVAL then
			statusAccumulator = 0
			updateStatus()
		end
	end)

addConnection(heartbeatConnection)

--// ============================================================
--// UI
--// ============================================================

addConnection(
	TargetBox.FocusLost:Connect(function()
		if state.targetMode ~= "PLAYER" then
			return
		end

		resolveTarget()
		updateStatus()
	end)
)

addConnection(
	Mode.Activated:Connect(function()
		if state.targetMode == "PLAYER" then
			state.targetMode = "POSITION"
			Mode.Text = "POSITION"
			debugLog("Mode -> POSITION")
		else
			state.targetMode = "PLAYER"
			Mode.Text = "PLAYER"
			debugLog("Mode -> PLAYER")
		end

		updateStatus()
	end)
)

addConnection(
	Save.Activated:Connect(function()
		if not rootPart then
			notify("HumanoidRootPart non trovato")
			return
		end

		state.savedPosition =
			(rootPart :: BasePart).CFrame

		debugLog("Position saved")
		notify("Position saved")
	end)
)

addConnection(
	AutoReset.Activated:Connect(function()
		state.autoReset = not state.autoReset

		if state.autoReset then
			AutoReset.Text = "Reset: ON"
			AutoReset.BackgroundColor3 =
				Color3.fromRGB(40, 120, 40)
		else
			AutoReset.Text = "Reset: OFF"
			AutoReset.BackgroundColor3 =
				Color3.fromRGB(120, 40, 40)
		end

		debugLog(
			state.autoReset
				and "Auto-reset enabled"
				or "Auto-reset disabled"
		)
	end)
)

addConnection(
	Threshold.FocusLost:Connect(function()
		local value: number? =
			tonumber(Threshold.Text)

		if not value then
			Threshold.Text =
				tostring(state.resetThreshold)

			notify("Threshold non valido")
			return
		end

		value = math.floor(value)

		if value < 1 then
			value = 1
		elseif value > 999 then
			value = 999
		end

		state.resetThreshold = value
		Threshold.Text = tostring(value)

		debugLog(
			"Reset threshold -> " ..
			tostring(value)
		)
	end)
)

addConnection(
	Start.Activated:Connect(function()
		debugLog("START button activated")

		if state.running then
			debugLog("Already running")
			return
		end

		if state.targetMode == "PLAYER" then
			if not resolveTarget() then
				notify("Player non trovato")
				return
			end
		else
			if not state.savedPosition then
				notify("Salva prima una posizione")
				return
			end
		end

		state.running = true
		state.startTime = os.clock()
		state.currentRagdolls = 0
		state.ragdollActive = false
		state.resetDebounce = false

		debugLog("Helper STARTED")
		notify("Helper started")

		updateStatus()
	end)
)

addConnection(
	Stop.Activated:Connect(function()
		debugLog("STOP button activated")

		state.running = false

		updateStatus()

		debugLog("Helper STOPPED")
	end)
)

--// ============================================================
--// Minimize
--// ============================================================

local minimized: boolean = false

addConnection(
	Minimize.Activated:Connect(function()
		minimized = not minimized

		TargetBox.Visible = not minimized
		Mode.Visible = not minimized
		Save.Visible = not minimized
		Threshold.Visible = not minimized
		AutoReset.Visible = not minimized
		Start.Visible = not minimized
		Stop.Visible = not minimized
		Status.Visible = not minimized

		if minimized then
			Frame.Size = UDim2.fromOffset(250, 30)
			Minimize.Text = "+"
		else
			Frame.Size = UDim2.fromOffset(250, 205)
			Minimize.Text = "_"
		end
	end)
)

--// ============================================================
--// Close
--// ============================================================

addConnection(
	Close.Activated:Connect(function()
		debugLog("GUI closing")

		cleanup()

		state.destroyed = true
		state.running = false

		GENV.KsHelper_Loaded = nil
		GENV.__KillstreakHelperCleanup = nil

		if ScreenGui.Parent then
			ScreenGui:Destroy()
		end
	end)
)

--// ============================================================
--// Player removal
--// ============================================================

addConnection(
	Players.PlayerRemoving:Connect(function(player: Player)
		if player ~= state.targetPlayer then
			return
		end

		debugLog("Target left server")

		state.targetPlayer = nil
		state.targetUserId = nil

		if state.running then
			notify("Target disconnected")
		end

		updateStatus()
	end)
)

--// ============================================================
--// Global cleanup
--// ============================================================

GENV.__KillstreakHelperCleanup = function(): ()
	if state.destroyed then
		return
	end

	state.running = false
	state.destroyed = true

	cleanup()

	if ScreenGui.Parent then
		ScreenGui:Destroy()
	end

	GENV.KsHelper_Loaded = nil
	GENV.__KillstreakHelperCleanup = nil
end

--// ============================================================
--// Initialisation
--// ============================================================

updateStatus()

debugLog(
	"Initialized | PlaceId=" ..
	tostring(game.PlaceId)
)

debugLog("Target movement does not require target isInArena")
debugLog("Ragdoll detection is event-driven")
debugLog("Ready")