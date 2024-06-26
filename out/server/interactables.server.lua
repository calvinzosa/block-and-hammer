-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local giveBadge = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").giveBadge
local interactablesFolder = Workspace:FindFirstChild("Interactables")
local steelHammer = interactablesFolder:FindFirstChild("SteelHammer")
local glowPart = interactablesFolder:FindFirstChild("Glow");
(steelHammer:FindFirstChild("Interacted")).OnServerEvent:Connect(function(player)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if not _result then
		return nil
	end
	if player:GetAttribute("activeQuest") == "LostSteelHammer" then
		player:SetAttribute("hasSteelHammer", true)
	end
end);
(glowPart:FindFirstChild("Interacted")).OnServerEvent:Connect(function(player)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if not _result then
		return nil
	end
	local _value = player:GetAttribute("glowDebounce")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return nil
	end
	player:SetAttribute("glowDebounce", true)
	task.delay(20, function()
		return player:SetAttribute("glowDebounce", nil)
	end)
	local _condition = player:GetAttribute("glowPhase")
	if _condition == nil then
		_condition = 0
	end
	local currentPhase = _condition + 1
	player:SetAttribute("glowPhase", currentPhase)
	if currentPhase == 5 then
		player:SetAttribute("glowPhase", nil)
		giveBadge(player, 254003402602004)
	end
end)
