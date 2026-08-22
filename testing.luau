--// R6/R15 Animation Checker
--// Client-side / Executor
--// Copies diagnostic results to clipboard

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local results = {}
local function log(label, value)
    table.insert(results, string.format("[%s] %s", label, tostring(value)))
end

local function section(name)
    table.insert(results, "")
    table.insert(results, "========== " .. name .. " ==========")
end

local function safe(name, callback)
    local ok, result = pcall(callback)

    if ok then
        log(name, result)
        return result
    else
        log(name, "ERROR: " .. tostring(result))
        return nil
    end
end

section("PLAYER")

log("Player", player and player.Name or "N/A")
log("UserId", player and player.UserId or "N/A")

section("CHARACTER")

local character = player.Character

if not character then
    log("Character", "NOT FOUND")
else
    log("Character", character:GetFullName())

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local animate = character:FindFirstChild("Animate")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

    section("RIG")

    if humanoid then
        log("Humanoid", "FOUND")
        log("RigType", humanoid.RigType.Name)
        log("HipHeight", humanoid.HipHeight)
        log("WalkSpeed", humanoid.WalkSpeed)
        log("JumpPower", humanoid.JumpPower)
    else
        log("Humanoid", "NOT FOUND")
    end

    log("HumanoidRootPart", rootPart and "FOUND" or "NOT FOUND")

    section("ANIMATE")

    log("Animate", animate and "FOUND" or "NOT FOUND")

    if animate then
        log("Animate.Disabled", animate.Disabled)

        local playEmote = animate:FindFirstChild("PlayEmote")

        log("PlayEmote", playEmote and "FOUND" or "NOT FOUND")

        local animationObjects = {
            "idle",
            "walk",
            "run",
            "jump",
            "fall",
            "climb",
            "sit",
            "toolnone",
            "toolslash",
            "toollunge",
            "wave",
            "point",
            "dance",
            "dance2",
            "dance3",
            "laugh",
            "cheer"
        }

        for _, name in ipairs(animationObjects) do
            local obj = animate:FindFirstChild(name)

            if obj then
                log(name, "FOUND")
            else
                log(name, "MISSING")
            end
        end
    end

    section("ANIMATOR")

    if animator then
        log("Animator", "FOUND")

        local tracks = animator:GetPlayingAnimationTracks()

        log("Playing tracks", #tracks)

        if #tracks > 0 then
            for i, track in ipairs(tracks) do
                log(
                    "Track #" .. i,
                    string.format(
                        "%s | Looped=%s | Speed=%.2f | Weight=%.2f",
                        track.Name,
                        tostring(track.Looped),
                        track.Speed,
                        track.WeightCurrent
                    )
                )

                if track.Animation then
                    log(
                        "Track #" .. i .. " AnimationId",
                        track.Animation.AnimationId
                    )
                end
            end
        end
    else
        log("Animator", "NOT FOUND")
    end

    section("RIG PARTS")

    local r6Parts = {
        "Head",
        "Torso",
        "Left Arm",
        "Right Arm",
        "Left Leg",
        "Right Leg"
    }

    local r15Parts = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperArm",
        "LeftLowerArm",
        "LeftHand",
        "RightUpperArm",
        "RightLowerArm",
        "RightHand",
        "LeftUpperLeg",
        "LeftLowerLeg",
        "LeftFoot",
        "RightUpperLeg",
        "RightLowerLeg",
        "RightFoot"
    }

    local r6Count = 0
    local r15Count = 0

    for _, part in ipairs(r6Parts) do
        if character:FindFirstChild(part) then
            r6Count += 1
        end
    end

    for _, part in ipairs(r15Parts) do
        if character:FindFirstChild(part) then
            r15Count += 1
        end
    end

    log("R6 parts detected", r6Count .. "/" .. #r6Parts)
    log("R15 parts detected", r15Count .. "/" .. #r15Parts)

    section("EXPECTED RESULT")

    if humanoid then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            log("Rig conclusion", "R6")
        elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
            log("Rig conclusion", "R15")

            if animate then
                log(
                    "Animation conclusion",
                    animate.Disabled
                        and "Animate exists but is DISABLED"
                        or "Animate exists and is ENABLED"
                )
            end
        else
            log("Rig conclusion", "UNKNOWN")
        end
    else
        log("Rig conclusion", "Cannot determine")
    end

    section("R6 ANIMATION ASSETS")

    local r6Animations = {
        idle = {
            "rbxassetid://12521158637",
            "rbxassetid://12521162526"
        },

        walk = {
            "rbxassetid://12518152696"
        },

        run = {
            "rbxassetid://12518152696"
        },

        jump = {
            "rbxassetid://12520880485"
        },

        fall = {
            "rbxassetid://12520972571"
        },

        climb = {
            "rbxassetid://12520982150"
        },

        sit = {
            "rbxassetid://12520993168"
        }
    }

    for name, ids in pairs(r6Animations) do
        log(name, table.concat(ids, ", "))
    end
end

section("SUMMARY")

if character then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animate = character:FindFirstChild("Animate")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

    if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
        log("Test", "You are currently R15")
        log("R6 animation compatibility", "YES - script is designed to target R15")
    elseif humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
        log("Test", "You are currently R6")
        log("Original script behavior", "It would RETURN immediately")
    else
        log("Test", "Unable to determine rig")
    end

    log("Animate object", animate and "OK" or "MISSING")
    log("Animator object", animator and "OK" or "MISSING")
else
    log("Test", "Character unavailable")
end

local output = table.concat(results, "\n")

-- Console
print(output)

-- Clipboard
if typeof(setclipboard) == "function" then
    setclipboard(output)
    print("\n[+] Results copied to clipboard.")
elseif typeof(toclipboard) == "function" then
    toclipboard(output)
    print("\n[+] Results copied to clipboard.")
else
    warn("\n[!] Clipboard function not supported by this executor.")
end