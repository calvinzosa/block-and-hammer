-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local convertStudsToMeters = _utils.convertStudsToMeters
local getHammerTexture = _utils.getHammerTexture
local GameSetting = _utils.GameSetting
local Accessories = _utils.Accessories
local getSetting = _utils.getSetting
local numLerp = _utils.numLerp
local PlayerAttributes = _utils.PlayerAttributes
local Music = {
	Jamming = "Jamming",
	StartingOff = "StartingOff",
	SolitaryIsle = "SolitaryIsle",
	CrystalCave = "CrystalCave",
	Mountain = "Mountain",
	Garden = "Garden",
	TheLake = "TheLake",
	HauntedField = "HauntedField",
}
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local valueInstances = GUI:WaitForChild("Values")
local isSpectating = valueInstances:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local musicFolder = ReplicatedStorage:WaitForChild("Music")
local sounds = {
	Jamming = musicFolder:WaitForChild("Jamming"):Clone(),
	StartingOff = musicFolder:WaitForChild("Starting Off"):Clone(),
	SolitaryIsle = musicFolder:WaitForChild("Solitary Isle"):Clone(),
	CrystalCave = musicFolder:WaitForChild("Crystal Cave"):Clone(),
	Mountain = musicFolder:WaitForChild("Mountain"):Clone(),
	Garden = musicFolder:WaitForChild("Garden"):Clone(),
	TheLake = musicFolder:WaitForChild("The Lake"):Clone(),
	HauntedField = musicFolder:WaitForChild("Haunted Field"):Clone(),
}
for _, sound in pairs(sounds) do
	sound:SetAttribute("originalVolume", sound.Volume)
	sound.Volume = 0
	sound.Parent = Workspace
	sound:Play()
end
RunService.RenderStepped:Connect(function(dt)
	local targetPlayer = player
	if isSpectating.Value then
		local otherPlayer = Players:FindFirstChild(spectatePlayer.Name)
		local _result = otherPlayer
		if _result ~= nil then
			_result = _result:IsA("Player")
		end
		if _result then
			targetPlayer = otherPlayer
		end
	end
	local targetCube = Workspace:FindFirstChild(`cube{targetPlayer.UserId}`)
	local replayView = Workspace:FindFirstChild("REPLAY_VIEW")
	local _result = replayView
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if _result then
		targetCube = replayView
	end
	local currentHammer = getHammerTexture(targetPlayer)
	local activeMusic = nil
	local _value = player:GetAttribute(PlayerAttributes.Client.InMainMenu)
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		activeMusic = Music.Jamming
	else
		local _value_1 = player:GetAttribute(PlayerAttributes.InTutorial)
		if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
			activeMusic = Music.CrystalCave
		else
			local _result_1 = targetCube
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			if _result_1 then
				local _binding = convertStudsToMeters(targetCube.Position.Y - 1.9)
				local altitude = _binding[1]
				if altitude < 100 then
					activeMusic = Music.StartingOff
				elseif altitude < 200 then
					activeMusic = Music.SolitaryIsle
				elseif altitude < 300 then
					activeMusic = Music.TheLake
				elseif altitude < 400 then
					activeMusic = Music.Mountain
				elseif altitude < 500 then
					activeMusic = Music.HauntedField
				elseif altitude < 700 then
					activeMusic = Music.Mountain
				else
					activeMusic = Music.Garden
				end
			end
		end
	end
	local _condition = getSetting(GameSetting.Music)
	if _condition then
		local _value_1 = targetPlayer:GetAttribute(PlayerAttributes.InErrorLand)
		_condition = not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1)
	end
	local isMusicEnabled = _condition
	for name, sound in pairs(sounds) do
		local targetVolume = if (name == activeMusic and isMusicEnabled) then (sound:GetAttribute("originalVolume")) else 0
		sound.Volume = numLerp(sound.Volume, targetVolume, dt * 5)
		local _value_1 = (currentHammer == Accessories.HammerTexture.Hammer404 and targetPlayer:GetAttribute(PlayerAttributes.HasModifiers))
		sound.PlaybackSpeed = if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then 0.5 else 1
	end
end)
