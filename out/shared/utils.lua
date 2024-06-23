-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local CollectionService = _services.CollectionService
local ReplicatedStorage = _services.ReplicatedStorage
local BadgeService = _services.BadgeService
local HttpService = _services.HttpService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local str = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "string-utils")
local player = Players.LocalPlayer
local _result = player
if _result ~= nil then
	_result = _result:WaitForChild("PlayerGui")
end
local GUI = _result
local settingChangedEvent = ReplicatedStorage:WaitForChild("SettingChanged")
local makeReplayEvent = ReplicatedStorage:WaitForChild("MakeReplayEvent")
local placeId = game.PlaceId
local RNG = Random.new()
local GameSetting = {
	HideOthers = "hideothers",
	ShowRange = "showrange",
	Effects = "effects",
	ScreenShake = "screenshake",
	Sounds = "sounds",
	Music = "music",
	TimerGUI = "timergui",
	Modifiers = "modifiers",
	CSG = "csg",
}
local Accessories = {}
do
	local _container = Accessories
	local AccessoryName = {
		hammer_Texture = "HammerTexture",
		cube_Hat = "CubeHat",
		cube_Face = "CubeFace",
		cube_Aura = "CubeAura",
	}
	_container.AccessoryName = AccessoryName
	local HammerTexture = {
		NoHammerTexture = "No Hammer Texture",
		RealGoldenHammer = "REAL Golden Hammer",
		GoldenHammer = "Golden Hammer",
		InverterHammer = "Inverter Hammer",
		BattleAxe = "Battle Axe",
		BuilderHammer = "Builder Hammer",
		SpringHammer = "Spring Hammer",
		Shotgun = "Shotgun",
		Platform = "Platform",
		Hammer404 = "404 Hammer",
		Mallet = "Mallet",
		GodsHammer = "God's Hammer",
		IcyHammer = "Icy Hammer",
		ExplosiveHammer = "Explosive Hammer",
		GrapplingHammer = "Grappling Hammer",
		SteelHammer = "Steel Hammer",
		LongHammer = "Long Hammer",
	}
	_container.HammerTexture = HammerTexture
	local CubeHat = {
		NoHat = "No Hat",
		TopHat404 = "404 TopHat",
		PropellerHat = "Propeller Hat",
		AstronautHelmet = "Astronaut Helmet",
		Trophy35k = "35k Trophy",
		InstantGyro = "Instant Gyro",
		Duck = "Duck",
		PartyHat = "Party Hat",
		Tophat = "Tophat",
		FreeAccessory = "Free Accessory",
	}
	_container.CubeHat = CubeHat
	local CubeFace = {
		DefaultFace = "Default Face",
		UpsideDown = "Upside-down",
		Sad = "Sad",
		Si = "Si",
		Tsu = "Tsu",
	}
	_container.CubeFace = CubeFace
	local CubeAura = {
		NoAura = "No Aura",
		Glow = "Glow",
		Fire = "Fire",
	}
	_container.CubeAura = CubeAura
end
local PlayerAttributes = {
	HammerTexture = "hammer_Texture",
	CubeFace = "cube_Face",
	CubeAura = "cube_Aura",
	CubeHat = "cube_Hat",
}
local SettingChanged = settingChangedEvent.Event
local Settings = {
	hideothers = false,
	showrange = false,
	effects = true,
	screenshake = true,
	sounds = true,
	music = true,
	timergui = true,
	modifiers = false,
	csg = true,
}
local DefaultSettings = table.clone(Settings)
local tweenTypes = {
	linear = {
		short = TweenInfo.new(1, Enum.EasingStyle.Linear),
		medium = TweenInfo.new(2.5, Enum.EasingStyle.Linear),
		long = TweenInfo.new(5, Enum.EasingStyle.Linear),
	},
}
local filterFunctions = {
	startsWith = function(value, _, pattern)
		return str.startsWith(value, pattern)
	end,
}
local settingAlias = {
	[GameSetting.HideOthers] = "Hide Others",
	[GameSetting.ShowRange] = "Show Range",
	[GameSetting.Effects] = "Effects",
	[GameSetting.ScreenShake] = "Screen Shake",
	[GameSetting.Sounds] = "Sounds",
	[GameSetting.Music] = "Music",
	[GameSetting.TimerGUI] = "Timer GUI",
	[GameSetting.Modifiers] = "Modifiers",
	[GameSetting.CSG] = "CSG",
}
local settingOrder = {
	[GameSetting.Modifiers] = 1,
	[GameSetting.Music] = 2,
	[GameSetting.Sounds] = 3,
	[GameSetting.Effects] = 4,
	[GameSetting.CSG] = 5,
	[GameSetting.ScreenShake] = 6,
	[GameSetting.ShowRange] = 7,
	[GameSetting.HideOthers] = 8,
	[GameSetting.TimerGUI] = 9,
}
local PlayerAdmins = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Admins"))
local TextCompression = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("TextCompression"))
local function numLerp(a, b, t)
	return a + (b - a) * t
end
local function getPartId(part)
	local tags = part:GetTags()
	for _, tag in tags do
		if str.startsWith(tag, "mapPart-") then
			return tag
		end
	end
	return ""
end
local function getPartFromId(id)
	if not (id ~= "" and id) then
		return nil
	end
	return CollectionService:GetTagged(id)[2]
end
local function getTime()
	return Workspace:GetServerTimeNow()
end
local function roundDecimalPlaces(x, decimalPlaces)
	if decimalPlaces == nil then
		decimalPlaces = 3
	end
	local multiplier = bit32.bxor(10, decimalPlaces)
	return math.round(x * multiplier) / multiplier
end
local function randomFloat(min, max)
	return math.random() * (max - min) + min
end
local function randomDirection(length)
	if length == nil then
		length = 1
	end
	local _exp = RNG:NextUnitVector()
	local _length = length
	return _exp * _length
end
local function waitUntil(callback, maxTime)
	if maxTime == nil then
		maxTime = math.huge
	end
	local startTime = time()
	while not callback() and (time() - startTime) < maxTime do
		task.wait()
	end
end
local function canUseSetting(name)
	if name == "modifiers" then
		local cube = Workspace:FindFirstChild(`cube\{player.UserId\}`)
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		local modifierDisablers = Workspace:FindFirstChild("ForceDisableModifiers")
		if modifierDisablers ~= nil then
			params.FilterDescendantsInstances = { modifierDisablers }
		end
		local _condition = player:GetAttribute("ERROR_LAND")
		if not (_condition ~= 0 and _condition == _condition and _condition ~= "" and _condition) then
			_condition = player:GetAttribute("in_tutorial")
		end
		local _condition_1 = _condition
		if not (_condition_1 ~= 0 and _condition_1 == _condition_1 and _condition_1 ~= "" and _condition_1) then
			_condition_1 = (player and cube and #Workspace:GetPartsInPart(cube, params) > 0)
		end
		if _condition_1 ~= 0 and _condition_1 == _condition_1 and _condition_1 ~= "" and _condition_1 then
			return false
		end
	end
	local _condition = name == "hideothers"
	if _condition then
		local _result_1 = GUI
		if _result_1 ~= nil then
			_result_1 = _result_1:FindFirstChild("ReplayGui")
		end
		_condition = _result_1
		if _condition then
			local _result_2 = (GUI:FindFirstChild("ReplayGui"))
			if _result_2 ~= nil then
				_result_2 = _result_2.Enabled
			end
			_condition = _result_2
		end
	end
	if _condition then
		return true
	end
	return true
end
local function getSetting(name)
	if not canUseSetting(name) then
		return false
	end
	local value = Settings[name]
	if value == nil then
		return DefaultSettings[name]
	end
	return value
end
local function setSetting(name, value)
	if not canUseSetting(name) then
		return nil
	end
	Settings[name] = value
	settingChangedEvent:Fire(name, value)
end
local function getSettingAlias(name)
	local _condition = settingAlias[name]
	if _condition == nil then
		_condition = name
	end
	return _condition
end
local function getSettingOrder(name)
	local _condition = settingOrder[name]
	if _condition == nil then
		_condition = -1
	end
	return _condition
end
local function fixSettings()
	for name, value in pairs(DefaultSettings) do
		local _condition = Settings[name]
		if _condition == nil then
			_condition = value
		end
		Settings[name] = _condition
	end
end
local function getHammerTexture(player)
	if player == nil then
		player = nil
	end
	if player == nil then
		player = Players.LocalPlayer
	end
	local _value = player:GetAttribute("in_tutorial")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return Accessories.HammerTexture.NoHammerTexture
	end
	return (player:GetAttribute("hammer_Texture")) or Accessories.HammerTexture.NoHammerTexture
end
local function getCubeFace(player)
	if player == nil then
		player = nil
	end
	if player == nil then
		player = Players.LocalPlayer
	end
	local _value = player:GetAttribute("in_tutorial")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return Accessories.CubeFace.DefaultFace
	end
	return (player:GetAttribute("cube_Face")) or Accessories.CubeFace.DefaultFace
end
local function getCubeHat(player)
	if player == nil then
		player = nil
	end
	if player == nil then
		player = Players.LocalPlayer
	end
	local _value = player:GetAttribute("in_tutorial")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return Accessories.CubeHat.NoHat
	end
	return (player:GetAttribute("cube_Hat")) or Accessories.CubeHat.NoHat
end
local function getCubeAura(player)
	if player == nil then
		player = Players.LocalPlayer
	end
	local _value = player:GetAttribute("in_tutorial")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return Accessories.CubeAura.NoAura
	end
	return (player:GetAttribute("cube_Aura")) or Accessories.CubeAura.NoAura
end
local function isClientCube(cube)
	local _result_1 = cube
	if _result_1 ~= nil then
		_result_1 = _result_1.Name
	end
	return _result_1 == `cube{player.UserId}`
end
local function playSound(name, properties, ignoreReplay)
	if properties == nil then
		properties = {}
	end
	if ignoreReplay == nil then
		ignoreReplay = false
	end
	if not getSetting(GameSetting.Sounds) then
		properties.Volume = 0
	end
	local dataString = `sound,{name}`
	local _result_1 = ReplicatedStorage:FindFirstChild("SFX")
	if _result_1 ~= nil then
		_result_1 = _result_1:FindFirstChild(name)
		if _result_1 ~= nil then
			_result_1 = _result_1:Clone()
		end
	end
	local sound = _result_1
	if sound == nil then
		return nil
	end
	sound.PlayOnRemove = false
	if properties then
		for name, value in pairs(properties) do
			pcall(function()
				sound[name] = value
				return sound[name]
			end)
			if type(value) == "number" then
				dataString ..= `,{name}={math.round(value * 1000)}`
			else
				dataString ..= `,{name}={tostring(value)}`
			end
		end
	end
	local _value = player:GetAttribute("ERROR_LAND")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		sound.PlaybackSpeed *= 0.5
	end
	sound.Volume = math.min(sound.Volume, 1.5)
	sound.Parent = Workspace
	if not ignoreReplay then
		makeReplayEvent:Fire(dataString)
	end
	if player:GetAttribute("hammer_Texture") == "404 Hammer" and getSetting(GameSetting.Modifiers) then
		sound.PlaybackSpeed *= 0.5
		local pitchShift = Instance.new("PitchShiftSoundEffect")
		pitchShift.Octave = 2
		pitchShift.Parent = sound
	end
	sound:Play()
	sound.Ended:Connect(function()
		return sound:Destroy()
	end)
end
local function getCubeTime(cube)
	local currentTime = getTime()
	local finishTotalTime = cube:GetAttribute("finishTotalTime")
	if type(finishTotalTime) == "number" then
		return finishTotalTime, getTime() - finishTotalTime
	end
	local extraTime = cube:GetAttribute("extra_time")
	local _extraTime = extraTime
	if not (type(_extraTime) == "number") then
		extraTime = 0
	end
	local startTime = cube:GetAttribute("start_time")
	local _startTime = startTime
	if not (type(_startTime) == "number") then
		startTime = 0
	end
	return math.min((currentTime - startTime) + extraTime, 3599), startTime
end
local function getTimeUnits(ms)
	local hours = math.floor(ms / (1000 * 60 * 60))
	local minutes = math.floor((ms % (1000 * 60 * 60)) / (1000 * 60))
	local seconds = math.floor((ms % (1000 * 60)) / 1000)
	local milliseconds = ms % 1000
	return hours, minutes, seconds, milliseconds
end
local function formatBytes(bytes)
	local units = { "bytes", "kb", "mb", "gb", "tb" }
	local scale = 1024
	local unitIndex = 1
	while bytes >= scale and unitIndex < #units do
		bytes /= scale
		unitIndex += 1
	end
	local roundedBytes = string.format(if bytes % 1 == 0 then "%d" else "%.1f", bytes)
	return `{roundedBytes} {units[unitIndex + 1]}`
end
local function computeNameColor(playerName)
	local nameColors = { Color3.fromRGB(253, 41, 67), Color3.fromRGB(1, 162, 255), Color3.fromRGB(2, 184, 87), BrickColor.new("Bright violet").Color, BrickColor.new("Bright orange").Color, BrickColor.new("Bright yellow").Color, BrickColor.new("Light reddish violet").Color, BrickColor.new("Brick yellow").Color }
	local nameLength = #playerName
	local value = 0
	do
		local i = 1
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i <= nameLength) then
				break
			end
			local _fn = string
			local _playerName = playerName
			local _i = i
			local _i_1 = i
			local cValue = _fn.byte(string.sub(_playerName, _i, _i_1))
			local reverseIndex = nameLength - i + 1
			if nameLength % 2 == 1 then
				reverseIndex -= 1
			end
			if reverseIndex % 4 >= 2 then
				cValue *= -1
			end
			value += cValue
		end
	end
	return nameColors[value % #nameColors + 1]
end
local function convertStudsToMeters(studs)
	local meters = studs * 0.28
	local kilometers = meters / 1000
	local megameters = kilometers / 1000
	local gigameters = megameters / 1000
	local terameters = gigameters / 1000
	if terameters >= 1 then
		return { meters, string.format("%.1fTm", terameters) }
	elseif gigameters >= 1 then
		return { meters, string.format("%.1fGm", gigameters) }
	elseif megameters >= 1 then
		return { meters, string.format("%.1fMm", megameters) }
	elseif kilometers >= 1 then
		return { meters, string.format("%.1fkm", kilometers) }
	end
	return { meters, string.format("%.1fm", meters) }
end
local function convertMetersToStuds(meters)
	return roundDecimalPlaces(meters / 0.28)
end
local function getPlayerRank(player)
	if player.UserId == game.CreatorId or player.UserId <= 0 then
		return 2
	else
		-- ▼ ReadonlyArray.findIndex ▼
		local _callback = function(userId)
			return userId == player.UserId
		end
		local _result_1 = -1
		for _i, _v in PlayerAdmins do
			if _callback(_v, _i - 1, PlayerAdmins) == true then
				_result_1 = _i - 1
				break
			end
		end
		-- ▲ ReadonlyArray.findIndex ▲
		if _result_1 ~= 0 and _result_1 == _result_1 and _result_1 then
			return 1
		end
	end
	return 0
end
local function encodeObjectToJSON(object)
	local _object = object
	if typeof(_object) == "Vector3" then
		return {
			datatype = "Vector3",
			value = { roundDecimalPlaces(object.X), roundDecimalPlaces(object.Y), roundDecimalPlaces(object.Z) },
		}
	else
		local _object_1 = object
		if typeof(_object_1) == "CFrame" then
			local _object_2 = {
				datatype = "CFrame",
			}
			local _left = "value"
			local _array = {}
			local _length = #_array
			local _array_1 = { object:GetComponents() }
			table.move(_array_1, 1, #_array_1, _length + 1, _array)
			_object_2[_left] = _array
			return _object_2
		else
			local _object_2 = object
			if typeof(_object_2) == "Color3" then
				return {
					datatype = "Color3",
					value = object:ToHex(),
				}
			else
				local _object_3 = object
				if type(_object_3) == "table" then
					local dict = object
					for key, value in pairs(dict) do
						dict[key] = encodeObjectToJSON(value)
					end
				end
			end
		end
	end
	return object
end
local function decodeJSONObject(object)
	local _object = object
	if type(_object) == "table" then
		local dictTable = object
		local datatype = dictTable.datatype
		local value = dictTable.value
		if type(value) == "string" then
			if datatype == "Color3" then
				local success, hex = pcall(Color3.fromHex, value)
				if success then
					return hex
				else
					return nil
				end
			end
		elseif value == nil then
			for key, value in pairs(dictTable) do
				dictTable[key] = decodeJSONObject(value)
			end
		else
			if datatype == "Vector3" then
				return Vector3.new(unpack(value))
			elseif datatype == "CFrame" then
				return CFrame.new(unpack(value))
			end
		end
	end
	return object
end
local function compressData(data, isJSON)
	if isJSON then
		data = encodeObjectToJSON(data)
	end
	return TextCompression:compress(HttpService:JSONEncode(data))
end
local function decompressData(data, isJSON)
	local decompressedData = HttpService:JSONDecode(TextCompression:decompress(data))
	if isJSON then
		return decodeJSONObject(decompressedData)
	end
	return decompressedData
end
local isTestingServer
local function giveBadge(player, badgeId)
	if not RunService:IsServer() then
		return nil
	end
	if isTestingServer() then
		warn("[src/shared/utils.ts:457]", "Badges are disabled in the Testing Server.")
		return nil
	end
	local userId = player.UserId
	task.spawn(function()
		while true do
			local _value = player:GetAttribute("badgeDebounce")
			if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
				break
			end
			player.AttributeChanged:Wait()
		end
		player:SetAttribute("badgeDebounce", true)
		local success = false
		repeat
			do
				success = pcall(function()
					if not BadgeService:UserHasBadgeAsync(userId, badgeId) then
						BadgeService:AwardBadge(userId, badgeId)
					end
				end)
			end
		until success
		task.wait(1)
		player:SetAttribute("badgeDebounce", nil)
	end)
end
function isTestingServer()
	if RunService:IsStudio() then
		return false
	end
	return placeId == 17837400665
end
local function isMainServer()
	if RunService:IsStudio() then
		return true
	end
	return placeId == 13458875976
end
return {
	numLerp = numLerp,
	getPartId = getPartId,
	getPartFromId = getPartFromId,
	getTime = getTime,
	roundDecimalPlaces = roundDecimalPlaces,
	randomFloat = randomFloat,
	randomDirection = randomDirection,
	waitUntil = waitUntil,
	canUseSetting = canUseSetting,
	getSetting = getSetting,
	setSetting = setSetting,
	getSettingAlias = getSettingAlias,
	getSettingOrder = getSettingOrder,
	fixSettings = fixSettings,
	getHammerTexture = getHammerTexture,
	getCubeFace = getCubeFace,
	getCubeHat = getCubeHat,
	getCubeAura = getCubeAura,
	isClientCube = isClientCube,
	playSound = playSound,
	getCubeTime = getCubeTime,
	getTimeUnits = getTimeUnits,
	formatBytes = formatBytes,
	computeNameColor = computeNameColor,
	convertStudsToMeters = convertStudsToMeters,
	convertMetersToStuds = convertMetersToStuds,
	getPlayerRank = getPlayerRank,
	encodeObjectToJSON = encodeObjectToJSON,
	decodeJSONObject = decodeJSONObject,
	compressData = compressData,
	decompressData = decompressData,
	giveBadge = giveBadge,
	isTestingServer = isTestingServer,
	isMainServer = isMainServer,
	GameSetting = GameSetting,
	Accessories = Accessories,
	PlayerAttributes = PlayerAttributes,
	SettingChanged = SettingChanged,
	Settings = Settings,
	DefaultSettings = DefaultSettings,
	tweenTypes = tweenTypes,
	filterFunctions = filterFunctions,
}
