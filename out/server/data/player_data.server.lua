-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local DataStoreService = _services.DataStoreService
local BadgeService = _services.BadgeService
local HttpService = _services.HttpService
local RunService = _services.RunService
local Players = _services.Players
local Workspace = _services.Workspace
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local PlayerAttributes = _utils.PlayerAttributes
local decodeJSONObject = _utils.decodeJSONObject
local encodeObjectToJSON = _utils.encodeObjectToJSON
local getCubeTime = _utils.getCubeTime
local getTime = _utils.getTime
local isTestingServer = _utils.isTestingServer
local accessoryList = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader").accessoryList
local Events = {
	LoadSettingsJSON = ReplicatedStorage:FindFirstChild("LoadSettingsJSON"),
	SaveSettingsJSON = ReplicatedStorage:FindFirstChild("SaveSettingsJSON"),
	SaySystemMessage = ReplicatedStorage:FindFirstChild("SaySystemMessage"),
	LoadPlayerAccessories = ReplicatedStorage:FindFirstChild("LoadPlayerAccessories"),
	ForceEquip = ReplicatedStorage:FindFirstChild("ForceEquip"),
	EquipAccessory = ReplicatedStorage:FindFirstChild("EquipAccessory"),
}
local QuestData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("QuestData"))
local PlayerData = DataStoreService:GetDataStore("player_data")
local accessoryData = {}
local function playerAdded(player)
	player:SetAttribute("serverJoinTime", getTime())
	local playerId = tostring(player.UserId)
	local totalDataChunks = 0
	local data = ""
	local success, errorMessage = pcall(function()
		local pages = PlayerData:ListKeysAsync(playerId, 255)
		while true do
			totalDataChunks += 1
			local currentPage = pages:GetCurrentPage()
			table.sort(currentPage, function(a, b)
				return a.KeyName < b.KeyName
			end)
			if #currentPage > 0 then
				for _, key in currentPage do
					local chunk = PlayerData:GetAsync(key.KeyName)
					if type(chunk) == "string" then
						data ..= chunk
					else
						error(`Data of player {player.Name} is invalid.`)
					end
				end
			else
				break
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
		end
	end)
	if success then
		if #data > 0 then
			local success, jsonData = pcall(function()
				return HttpService:JSONDecode(data)
			end)
			if not success then
				player:Kick("Your data is most likely corrupted! Please go to the discord server and tell the developer of this message and your username")
				return nil
			end
			local decodedData = decodeJSONObject(jsonData)
			local position = decodedData.position
			local velocity = decodedData.velocity
			local destroyedCounter = decodedData.destroyed_counter
			local cube = Workspace:WaitForChild(`cube{player.UserId}`)
			if type(destroyedCounter) == "number" then
				cube:SetAttribute("destroyed_counter", destroyedCounter)
			end
			local _settings_json = decodedData.settings_json
			if type(_settings_json) == "string" then
				Events.LoadSettingsJSON:FireClient(player, decodedData.settings_json)
			end
			local _accessories = decodedData.accessories
			if type(_accessories) == "table" then
				accessoryData[playerId] = decodedData.accessories
				for _, name in pairs(decodedData.accessories) do
					local targetAccessory = accessoryList[name]
					if targetAccessory and (targetAccessory.badge_id == 0 or BadgeService:UserHasBadgeAsync(player.UserId, targetAccessory.badge_id)) then
						player:SetAttribute(targetAccessory.acc_type, name)
					end
				end
				Events.LoadPlayerAccessories:Fire(player, cube)
			else
				accessoryData[playerId] = {}
			end
			local _cube_color = decodedData.cube_color
			if typeof(_cube_color) == "Color3" then
				player:SetAttribute("CUBE_COLOR", decodedData.cube_color)
			end
			if decodedData.time_data then
				if decodedData.time_data.modded then
					player:SetAttribute("modifiers", true)
					cube:SetAttribute("used_modifiers", true)
				end
				player:SetAttribute("finished", decodedData.time_data.finished)
				cube:SetAttribute("extra_time", decodedData.time_data.extra_time)
				cube:SetAttribute("finishTotalTime", decodedData.time_data.finish_total_time)
			end
			local _condition = decodedData.active_quest
			if _condition ~= "" and _condition then
				_condition = QuestData[decodedData.active_quest] ~= nil
			end
			if _condition ~= "" and _condition then
				player:SetAttribute("activeQuest", decodedData.active_quest)
			end
			if decodedData.stats then
				local serverJoinTime = player:GetAttribute("serverJoinTime")
				local _fn = player
				local _condition_1 = decodedData.stats.total_time_played
				if _condition_1 == nil then
					_condition_1 = 0
				end
				_fn:SetAttribute("serverJoinTime", serverJoinTime - _condition_1)
				local _fn_1 = player
				local _condition_2 = decodedData.stats.total_restarts
				if _condition_2 == nil then
					_condition_2 = 0
				end
				_fn_1:SetAttribute("totalRestarts", _condition_2)
				local _fn_2 = player
				local _condition_3 = decodedData.stats.total_ragdolls
				if _condition_3 == nil then
					_condition_3 = 0
				end
				_fn_2:SetAttribute("totalRagdolls", _condition_3)
				local _fn_3 = player
				local _condition_4 = decodedData.stats.times_joined
				if _condition_4 == nil then
					_condition_4 = 0
				end
				_fn_3:SetAttribute("timesJoined", _condition_4 + 1)
				local _fn_4 = player
				local _condition_5 = decodedData.stats.total_wins
				if _condition_5 == nil then
					_condition_5 = 0
				end
				_fn_4:SetAttribute("totalWins", _condition_5)
				local _fn_5 = player
				local _condition_6 = decodedData.stats.total_modded_wins
				if _condition_6 == nil then
					_condition_6 = 0
				end
				_fn_5:SetAttribute("totalModdedWins", _condition_6)
			end
			if typeof(position) == "Vector3" then
				cube.Anchored = true
				cube:PivotTo(CFrame.new(position))
				if typeof(velocity) == "Vector3" then
					cube.AssemblyLinearVelocity = velocity
				end
				task.delay(1, function()
					cube.Anchored = false
					return cube.Anchored
				end)
			end
			print("[src/server/data/player_data.server.ts:162]", `Loaded data for player {player.Name} ({player.UserId}) | Total Data Chunks: {totalDataChunks}`)
		else
			print("[src/server/data/player_data.server.ts:163]", `No data was found for player {player.Name} ({player.UserId})`)
		end
	else
		warn("[src/server/data/player_data.server.ts:165]", `Unable to load data for player {player.Name}`)
		player:Kick(`Unable to load data, please try again later | Error Message: {errorMessage}`)
		return nil
	end
	player:SetAttribute(PlayerAttributes.HasDataLoaded, true)
end
local function playerRemoved(player)
	local _value = player:GetAttribute(PlayerAttributes.HasDataLoaded)
	local _condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
	if not _condition then
		_condition = (RunService:IsStudio() and time() < 5) or isTestingServer()
	end
	if _condition then
		return nil
	end
	local playerId = tostring(player.UserId)
	local cube = Workspace:FindFirstChild(`cube{playerId}`)
	local _value_1 = not cube or player.UserId <= 0 or player:GetAttribute("in_tutorial")
	if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
		return nil
	end
	local currentTime = getTime()
	local _condition_1 = player:GetAttribute("serverJoinTime")
	if _condition_1 == nil then
		_condition_1 = currentTime
	end
	local serverJoinTime = _condition_1
	local cubeColor = player:GetAttribute("CUBE_COLOR")
	local destroyedCounter = cube:GetAttribute("destroyed_counter")
	local extraTime = getCubeTime(cube)
	local settingsJSON = player:GetAttribute("settings_json")
	local activeQuest = player:GetAttribute("activeQuest")
	local _object = {
		position = cube.Position,
		velocity = cube.AssemblyLinearVelocity,
		accessories = accessoryData[playerId],
		destroyed_counter = destroyedCounter,
		cube_color = cubeColor,
	}
	local _left = "time_data"
	local _object_1 = {
		extra_time = extraTime,
		finished = player:GetAttribute("finished"),
		finish_total_time = cube:GetAttribute("finishTotalTime"),
	}
	local _left_1 = "modded"
	local _condition_2 = player:GetAttribute("modifiers")
	if not (_condition_2 ~= 0 and _condition_2 == _condition_2 and _condition_2 ~= "" and _condition_2) then
		_condition_2 = cube:GetAttribute("used_modifiers")
	end
	_object_1[_left_1] = _condition_2
	_object[_left] = _object_1
	_object.settings_json = settingsJSON
	_object.active_quest = activeQuest
	_object.stats = {
		total_time_played = (currentTime - serverJoinTime),
		total_restarts = player:GetAttribute("totalRestarts"),
		total_ragdolls = player:GetAttribute("totalRagdolls"),
		times_joined = player:GetAttribute("times_joined"),
		total_wins = player:GetAttribute("totalWins"),
		total_modded_wins = player:GetAttribute("totalModdedWins"),
	}
	local dataToSave = encodeObjectToJSON(_object)
	cube:Destroy()
	local encodedData = HttpService:JSONEncode(dataToSave)
	for retryAttempt = 1, 5 do
		local success, errorMessage = pcall(function()
			local _arg1 = #encodedData
			local currentData = string.sub(encodedData, 1, _arg1)
			local iteration = 0
			local chunkSize = 4194303
			while #currentData > 0 do
				local chunk = string.sub(currentData, 1, chunkSize)
				local key = playerId .. (if iteration > 1 then `_{iteration}` else "")
				PlayerData:SetAsync(key, chunk)
				local _currentData = currentData
				local _arg0 = chunkSize + 1
				currentData = string.sub(_currentData, _arg0)
				iteration += 1
			end
		end)
		if success then
			print("[src/server/data/player_data.server.ts:235]", `Saved data for player {player.Name} ({player.UserId}) succesfully.`)
			break
		else
			warn("[src/server/data/player_data.server.ts:237]", `Could not save data for player {player.Name} ({player.UserId})! | Retrying {5 - retryAttempt} more time(s) | Error: {errorMessage}`)
		end
	end
end
Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoved)
Events.EquipAccessory.OnServerInvoke = function(player, name)
	local _name = name
	if not (type(_name) == "string") then
		return false
	end
	local targetAccessory = accessoryList[name]
	if targetAccessory and (targetAccessory.badge_id == 0 or BadgeService:UserHasBadgeAsync(player.UserId, targetAccessory.badge_id)) then
		if targetAccessory.never then
			return false
		end
		local playerId = tostring(player.UserId)
		local accessoryType = targetAccessory.acc_type
		player:SetAttribute(accessoryType, name)
		accessoryData[playerId][accessoryType] = name
		local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
		if cube then
			Events.LoadPlayerAccessories:Fire(player, cube)
		end
		return true
	end
	return false
end
Events.SaveSettingsJSON.OnServerEvent:Connect(function(player, settingsJSON)
	local _settingsJSON = settingsJSON
	if not (type(_settingsJSON) == "table") then
		return nil
	end
	local success, encodedData = pcall(function()
		return HttpService:JSONEncode(settingsJSON)
	end)
	if success then
		player:SetAttribute("settings_json", encodedData)
		print("[src/server/data/player_data.server.ts:273]", `Updated setting data for player {player.Name}`)
	else
		warn("[src/server/data/player_data.server.ts:274]", `Unable to convert setting data for player {player.Name} into JSON`)
	end
end)
Events.ForceEquip.Event:Connect(function(player, name)
	local _name = name
	local _condition = not (type(_name) == "string")
	if not _condition then
		local _player = player
		_condition = not (typeof(_player) == "Instance")
		if not _condition then
			_condition = not player:IsA("Player")
		end
	end
	if _condition then
		return nil
	end
	local playerId = tostring(player.UserId)
	local targetAccessory = accessoryList[name]
	if targetAccessory then
		local accessoryType = targetAccessory.acc_type
		player:SetAttribute(accessoryType, name)
		accessoryData[playerId][accessoryType] = name
		local cube = Workspace:FindFirstChild(`cube{playerId}`)
		if cube then
			Events.LoadPlayerAccessories:Fire(player, cube)
			if targetAccessory.never then
				cube:SetAttribute("used_admin_hammer", true)
			end
		end
	else
		task.delay(0, function()
			return Events.SaySystemMessage:FireClient(player, `Accessory "{name}" does not exist!`)
		end)
	end
end)
