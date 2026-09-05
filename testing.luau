--!strict

--// ============================================================
--// Killstreak Helper - Event Driven Edition
--// ============================================================

local cloneref = cloneref or function<T>(object: T): T
	return object
end

local Players: Players = cloneref(game:GetService("Players"))
local Workspace: Workspace = cloneref(game:GetService("Workspace"))
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer: Player = Players.LocalPlayer

--// ============================================================
--// Types
--// ============================================================

type TargetMode = "PLAYER" | "POSITION"

type State = {
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

	startTime: number,

	ragdollActive: boolean,
	resetDebounce: boolean,
}

--// ============================================================
--// Place validation
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
--// State
--// ============================================================

local state: State = {
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

	startTime = 0,

	ragdollActive = false,
	resetDebounce = false,
}

--// ============================================================
--// Connections / tasks
--// ============================================================

local connections: {RBXScriptConnection} = {}
local tasks: {thread} = {}

local function connect(connection: RBXScriptConnection): RBXScriptConnection
	table.insert(connections, connection)
	return connection
end

local function spawnTask(callback: () -> ()): ()
	local thread: thread = task.spawn(callback)
	table.insert(tasks, thread)
end

local function cleanup(): ()
	state.destroyed = true
	state.running = false

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
--// Debug
--// ============================================================

local debugLines: {string} = {}
local MAX_DEBUG_LINES: number = 60

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
	if type(gethui) == "function" then
		local ok: boolean, result: any = pcall(gethui)

		if ok and typeof(result) == "Instance" then
			return result
		end
	end

	return CoreGui
end

local GuiParent: Instance = getGuiParent()

--// ============================================================
--// GUI
--// ============================================================

local ScreenGui: ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillstreakHelper"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local Main: Frame = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(350, 400)
Main.Position = UDim2.new(0.5, -175, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner: UICorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke: UIStroke = Instance.new("UIStroke")
MainStroke.Transparency = 0.5
MainStroke.Parent = Main

local Title: TextLabel = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.fromOffset(10, 8)
Title.BackgroundTransparency = 1
Title.Text = "Killstreak Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local function createButton(
	name: string,
	text: string,
	position: UDim2,
	size: UDim2
): TextButton

	local button: TextButton = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(235, 235, 240)
	button.TextSize = 13
	button.Font = Enum.Font.GothamMedium
	button.AutoButtonColor = true
	button.Parent = Main

	local corner: UICorner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	return button
end

--// Target

local TargetBox: TextBox = Instance.new("TextBox")
TargetBox.Name = "TargetBox"
TargetBox.Position = UDim2.fromOffset(10, 52)
TargetBox.Size = UDim2.new(1, -20, 0, 38)
TargetBox.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
TargetBox.BorderSizePixel = 0
TargetBox.PlaceholderText = "Username / DisplayName / UserId"
TargetBox.Text = ""
TargetBox.TextColor3 = Color3.fromRGB(240, 240, 240)
TargetBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
TargetBox.TextSize = 13
TargetBox.Font = Enum.Font.Gotham
TargetBox.ClearTextOnFocus = false
TargetBox.Parent = Main

local TargetCorner: UICorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 8)
TargetCorner.Parent = TargetBox

local ModeButton: TextButton = createButton(
	"Mode",
	"PLAYER",
	UDim2.fromOffset(10, 98),
	UDim2.fromOffset(105, 36)
)

local SaveButton: TextButton = createButton(
	"SavePosition",
	"Save Position",
	UDim2.fromOffset(121, 98),
	UDim2.fromOffset(105, 36)
)

local ClearButton: TextButton = createButton(
	"ClearPosition",
	"Clear",
	UDim2.fromOffset(237, 98),
	UDim2.fromOffset(103, 36)
)

--// Auto reset

local ResetButton: TextButton = createButton(
	"AutoReset",
	"Auto Reset: ON",
	UDim2.fromOffset(10, 142),
	UDim2.fromOffset(160, 36)
)

local ThresholdBox: TextBox = Instance.new("TextBox")
ThresholdBox.Name = "Threshold"
ThresholdBox.Position = UDim2.fromOffset(180, 142)
ThresholdBox.Size = UDim2.fromOffset(160, 36)
ThresholdBox.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
ThresholdBox.BorderSizePixel = 0
ThresholdBox.Text = "1"
ThresholdBox.PlaceholderText = "Ragdolls"
ThresholdBox.TextColor3 = Color3.fromRGB(240, 240, 240)
ThresholdBox.TextSize = 13
ThresholdBox.Font = Enum.Font.Gotham
ThresholdBox.ClearTextOnFocus = false
ThresholdBox.Parent = Main

local ThresholdCorner: UICorner = Instance.new("UICorner")
ThresholdCorner.CornerRadius = UDim.new(0, 8)
ThresholdCorner.Parent = ThresholdBox

--// Start / Stop

local StartButton: TextButton = createButton(
	"Start",
	"START",
	UDim2.fromOffset(10, 190),
	UDim2.fromOffset(160, 42)
)

local StopButton: TextButton = createButton(
	"Stop",
	"STOP",
	UDim2.fromOffset(180, 190),
	UDim2.fromOffset(160, 42)
)

--// Status

local Status: TextLabel = Instance.new("TextLabel")
Status.Name = "Status"
Status.Position = UDim2.fromOffset(10, 242)
Status.Size = UDim2.new(1, -20, 0, 105)
Status.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
Status.BorderSizePixel = 0
Status.TextColor3 = Color3.fromRGB(220, 220, 225)
Status.TextSize = 12
Status.Font = Enum.Font.Code
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextYAlignment = Enum.TextYAlignment.Top
Status.Text = "Status: Stopped"
Status.Parent = Main

local StatusCorner: UICorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = Status

--// ============================================================
--// Character cache
--// ============================================================

local character: Model? = nil
local rootPart: BasePart? = nil
local humanoid: Humanoid? = nil

local ragdollConnections: {RBXScriptConnection} = {}

local function disconnectRagdollConnections(): ()
	for _, connection: RBXScriptConnection in ragdollConnections do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	table.clear(ragdollConnections)
end

local function getCurrentCharacter(): Model?
	local current: Model? = LocalPlayer.Character

	if current and current.Parent == Workspace then
		return current
	end

	return nil
end

local function refreshCharacter(newCharacter: Model?): ()
	disconnectRagdollConnections()

	character = newCharacter
	rootPart = nil
	humanoid = nil
	state.ragdollActive = false

	if not newCharacter then
		debugLog("Character cleared")
		return
	end

	local foundRoot: Instance? = newCharacter:FindFirstChild("HumanoidRootPart")
	local foundHumanoid: Instance? = newCharacter:FindFirstChildOfClass("Humanoid")

	if foundRoot and foundRoot:IsA("BasePart") then
		rootPart = foundRoot
	end

	if foundHumanoid and foundHumanoid:IsA("Humanoid") then
		humanoid = foundHumanoid
	end

	debugLog("CharacterAdded -> " .. newCharacter.Name)

	--// Ragdoll object may already exist.
	local ragdoll: Instance? = newCharacter:FindFirstChild("Ragdolled")

	if ragdoll then
		if ragdoll:IsA("BoolValue") then
			state.ragdollActive = ragdoll.Value

			table.insert(
				ragdollConnections,
				ragdoll:GetPropertyChangedSignal("Value"):Connect(function()
					local active: boolean = ragdoll.Value

					if active and not state.ragdollActive then
						state.currentRagdolls += 1
						state.totalRagdolls += 1

						debugLog(
							string.format(
								"Ragdoll detected -> %d/%d",
								state.currentRagdolls,
								state.resetThreshold
							)
						)
					end

					state.ragdollActive = active
				end)
			)
		end
	end

	--// The object can also be created after the character.
	table.insert(
		ragdollConnections,
		newCharacter.ChildAdded:Connect(function(child: Instance)
			if child.Name ~= "Ragdolled" then
				return
			end

			if not child:IsA("BoolValue") then
				return
			end

			state.ragdollActive = child.Value

			table.insert(
				ragdollConnections,
				child:GetPropertyChangedSignal("Value"):Connect(function()
					local active: boolean = child.Value

					if active and not state.ragdollActive then
						state.currentRagdolls += 1
						state.totalRagdolls += 1

						debugLog(
							string.format(
								"Ragdoll detected -> %d/%d",
								state.currentRagdolls,
								state.resetThreshold
							)
						)
					end

					state.ragdollActive = active
				end)
			)
		end)
	)
end

refreshCharacter(getCurrentCharacter())

connect(
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

			if newCharacter ~= character then
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
--// Target resolution
--// ============================================================

local function findPlayer(query: string): Player?
	local cleaned: string = query:gsub("^%s+", ""):gsub("%s+$", "")

	if cleaned == "" then
		return nil
	end

	local numericId: number? = tonumber(cleaned)

	if numericId then
		for _, player: Player in Players:GetPlayers() do
			if player.UserId == numericId then
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
		if string.find(string.lower(player.Name), lowered, 1, true)
			or string.find(string.lower(player.DisplayName), lowered, 1, true) then
			return player
		end
	end

	return nil
end

local function resolveTarget(): boolean
	if state.targetMode ~= "PLAYER" then
		return true
	end

	local query: string = TargetBox.Text

	local player: Player? = findPlayer(query)

	if not player then
		state.targetPlayer = nil
		state.targetUserId = tonumber(query)

		debugLog("Target not found: " .. query)

		return false
	end

	state.targetPlayer = player
	state.targetUserId = player.UserId

	debugLog(
		string.format(
			"Target resolved -> %s / [%d]",
			player.Name,
			player.UserId
		)
	)

	return true
end

--// ============================================================
--// Arena
--// ============================================================

local function getPortal(): BasePart?
	local lobby: Instance? = Workspace:FindFirstChild("Lobby")

	if not lobby then
		return nil
	end

	local portal: Instance? = lobby:FindFirstChild("Teleport1")

	if portal and portal:IsA("BasePart") then
		return portal
	end

	return nil
end

local function isInArena(): boolean
	if not character then
		return false
	end

	return character:FindFirstChild("entered") ~= nil
end

local function enterArena(): boolean
	if not state.running then
		return false
	end

	if isInArena() then
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

	--// Touch is preferred because this is how the actual portal
	--// normally detects the local character.
	if type(firetouchinterest) == "function" then
		local ok: boolean, err: any = pcall(function()
			firetouchinterest(portal :: BasePart, rootPart :: BasePart, 0)
			task.wait(0.05)
			firetouchinterest(portal :: BasePart, rootPart :: BasePart, 1)
		end)

		if not ok then
			debugLog("firetouchinterest failed: " .. tostring(err))
		end
	end

	if isInArena() then
		debugLog("Arena entered")
		return true
	end

	--// Small fallback.
	local ok: boolean = pcall(function()
		(rootPart :: BasePart).CFrame =
			(portal :: BasePart).CFrame + Vector3.new(0, 3, 0)
	end)

	if not ok then
		debugLog("Portal CFrame fallback failed")
	end

	return isInArena()
end

--// ============================================================
--// Reset
--// ============================================================

local function performReset(): ()
	if state.resetDebounce then
		return
	end

	state.resetDebounce = true
	state.resets += 1

	debugLog("Reset requested")

	local resetRemote: Instance? = LocalPlayer:FindFirstChild("Reset")

	if resetRemote and resetRemote:IsA("RemoteEvent") then
		local ok: boolean, err: any = pcall(function()
			resetRemote:FireServer()
		end)

		if not ok then
			debugLog("Reset failed: " .. tostring(err))
		end
	else
		debugLog("Reset RemoteEvent not found")
	end

	--// Reset only the counter associated with the current cycle.
	state.currentRagdolls = 0

	task.delay(1, function()
		state.resetDebounce = false
	end)
end

--// ============================================================
--// Ragdoll threshold watcher
--// ============================================================

local function checkResetThreshold(): ()
	if not state.running then
		return
	end

	if not state.autoReset then
		return
	end

	if state.currentRagdolls < state.resetThreshold then
		return
	end

	debugLog(
		string.format(
			"Threshold reached: %d/%d",
			state.currentRagdolls,
			state.resetThreshold
		)
	)

	performReset()
end

--// Separate lightweight watcher.
spawnTask(function()
	while not state.destroyed do
		if state.running then
			checkResetThreshold()
		end

		task.wait(0.05)
	end
end)

--// ============================================================
--// Target movement
--// ============================================================

local function teleportToPlayer(player: Player): boolean
	if not rootPart then
		return false
	end

	local targetCharacter: Model? = player.Character

	if not targetCharacter then
		return false
	end

	local targetRoot: Instance? =
		targetCharacter:FindFirstChild("HumanoidRootPart")

	if not targetRoot or not targetRoot:IsA("BasePart") then
		return false
	end

	local ok: boolean, err: any = pcall(function()
		(rootPart :: BasePart).CFrame =
			(targetRoot :: BasePart).CFrame *
			CFrame.new(0, 0, -4)
	end)

	if not ok then
		debugLog("Target teleport failed: " .. tostring(err))
		return false
	end

	return true
end

local function teleportToPosition(): boolean
	if not rootPart or not state.savedPosition then
		return false
	end

	local ok: boolean, err: any = pcall(function()
		(rootPart :: BasePart).CFrame =
			state.savedPosition :: CFrame
	end)

	if not ok then
		debugLog("Position teleport failed: " .. tostring(err))
		return false
	end

	return true
end

--// ============================================================
--// Status
--// ============================================================

local function getRuntime(): string
	if not state.running then
		return "00:00:00"
	end

	local elapsed: number = math.floor(os.clock() - state.startTime)

	local hours: number = math.floor(elapsed / 3600)
	local minutes: number = math.floor((elapsed % 3600) / 60)
	local seconds: number = elapsed % 60

	return string.format(
		"%02d:%02d:%02d",
		hours,
		minutes,
		seconds
	)
end

local function getTargetText(): string
	if state.targetMode == "POSITION" then
		if state.savedPosition then
			return "Position"
		end

		return "Position (not saved)"
	end

	local player: Player? = state.targetPlayer

	if player and player.Parent == Players then
		return string.format(
			"Player (%s / [%d])",
			player.Name,
			player.UserId
		)
	end

	if state.targetUserId then
		return string.format(
			"Player ([%d])",
			state.targetUserId :: number
		)
	end

	return "Player (none)"
end

local function updateStatus(): ()
	Status.Text = string.format(
		"Status: %s\n" ..
		"Runtime: %s\n" ..
		"Target: %s\n" ..
		"Arena: %s\n" ..
		"Ragdolls: %d / %d\n" ..
		"Resets: %d",

		if state.running then "Running" else "Stopped",

		getRuntime(),

		getTargetText(),

		if isInArena() then "YES" else "NO",

		state.currentRagdolls,
		state.resetThreshold,

		state.resets
	)
end

--// ============================================================
--// Main movement loop
--// ============================================================

local movementThread: thread? = nil

local function movementLoop(): ()
	debugLog("Movement loop started")

	while state.running and not state.destroyed do
		if not character then
			task.wait(0.15)
			continue
		end

		if not rootPart then
			local foundRoot: Instance? =
				character:FindFirstChild("HumanoidRootPart")

			if foundRoot and foundRoot:IsA("BasePart") then
				rootPart = foundRoot
			end

			task.wait(0.1)
			continue
		end

		--// Do not block target movement waiting for arena state.
		--// The target can therefore be outside the arena.
		if state.targetMode == "PLAYER" then
			local player: Player? = state.targetPlayer

			if player and player.Parent == Players then
				teleportToPlayer(player)
			end
		else
			teleportToPosition()
		end

		--// Arena entry is independent from target movement.
		if not isInArena() then
			enterArena()
		end

		updateStatus()

		--// 20 Hz is enough for CFrame following and is much cheaper
		--// than repeatedly resolving the target.
		task.wait(0.05)
	end

	debugLog("Movement loop stopped")
end

--// ============================================================
--// Start / Stop
--// ============================================================

local function startHelper(): ()
	debugLog("startHelper() called")

	if state.destroyed then
		debugLog("Start rejected: destroyed")
		return
	end

	if state.running then
		debugLog("Start ignored: already running")
		return
	end

	if state.targetMode == "PLAYER" then
		if not resolveTarget() then
			debugLog("Start aborted: target unavailable")
			updateStatus()
			return
		end
	else
		if not state.savedPosition then
			debugLog("Start aborted: no saved position")
			updateStatus()
			return
		end
	end

	state.running = true
	state.startTime = os.clock()

	state.currentRagdolls = 0
	state.ragdollActive = false
	state.resetDebounce = false

	debugLog("Helper STARTED")

	movementThread = task.spawn(function()
		local ok: boolean, err: any = xpcall(
			movementLoop,
			function(errorObject: any): string
				return debug.traceback(tostring(errorObject), 2)
			end
		)

		if not ok then
			debugLog("Movement loop crashed: " .. tostring(err))
			state.running = false
			updateStatus()
		end
	end)

	updateStatus()
end

local function stopHelper(): ()
	debugLog("stopHelper() called")

	if not state.running then
		updateStatus()
		return
	end

	state.running = false

	if movementThread then
		pcall(function()
			task.cancel(movementThread :: thread)
		end)

		movementThread = nil
	end

	debugLog("Helper STOPPED")
	updateStatus()
end

--// ============================================================
--// UI events
--// ============================================================

connect(
	StartButton.Activated:Connect(function()
		debugLog("START button activated")
		startHelper()
	end)
)

connect(
	StopButton.Activated:Connect(function()
		debugLog("STOP button activated")
		stopHelper()
	end)
)

connect(
	ModeButton.Activated:Connect(function()
		if state.targetMode == "PLAYER" then
			state.targetMode = "POSITION"
			ModeButton.Text = "POSITION"
			debugLog("Target mode -> POSITION")
		else
			state.targetMode = "PLAYER"
			ModeButton.Text = "PLAYER"
			debugLog("Target mode -> PLAYER")
		end

		updateStatus()
	end)
)

connect(
	SaveButton.Activated:Connect(function()
		if not rootPart then
			debugLog("Cannot save position: root missing")
			return
		end

		state.savedPosition = rootPart.CFrame

		debugLog("Position saved")
		updateStatus()
	end)
)

connect(
	ClearButton.Activated:Connect(function()
		state.savedPosition = nil

		debugLog("Saved position cleared")
		updateStatus()
	end)
)

connect(
	ResetButton.Activated:Connect(function()
		state.autoReset = not state.autoReset

		ResetButton.Text =
			"Auto Reset: " ..
			if state.autoReset then "ON" else "OFF"

		debugLog(
			if state.autoReset
				then "Auto-reset enabled"
				else "Auto-reset disabled"
		)

		updateStatus()
	end)
)

connect(
	ThresholdBox.FocusLost:Connect(function()
		local value: number? = tonumber(ThresholdBox.Text)

		if not value then
			ThresholdBox.Text = tostring(state.resetThreshold)
			debugLog("Invalid threshold")
			return
		end

		value = math.floor(value)

		if value < 1 then
			value = 1
		elseif value > 999 then
			value = 999
		end

		state.resetThreshold = value
		ThresholdBox.Text = tostring(value)

		debugLog("Reset threshold -> " .. tostring(value))
		updateStatus()
	end)
)

--// Resolve the target only when the user changes the field.
connect(
	TargetBox.FocusLost:Connect(function()
		if state.targetMode ~= "PLAYER" then
			return
		end

		if resolveTarget() then
			updateStatus()
		end
	end)
)

--// Keep cached target valid if it leaves.
connect(
	Players.PlayerRemoving:Connect(function(player: Player)
		if player == state.targetPlayer then
			debugLog("Target left the server")

			state.targetPlayer = nil
			state.targetUserId = nil

			if state.running then
				debugLog("Target invalidated; helper remains running")
			end

			updateStatus()
		end
	end)
)

--// ============================================================
--// Initial state
--// ============================================================

updateStatus()

debugLog("GUI initialized")
debugLog("PlaceId accepted: " .. tostring(game.PlaceId))
debugLog("Ready")

--// ============================================================
--// Cleanup
--// ============================================================

genv = getgenv and getgenv() or _G

genv.__KillstreakHelperCleanup = cleanup