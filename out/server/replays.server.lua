-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local DataStoreService = _services.DataStoreService
local HttpService = _services.HttpService
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local compressData = _utils.compressData
local decompressData = _utils.decompressData
local Events = {
	GetPlayerReplays = ReplicatedStorage:FindFirstChild("GetPlayerReplays"),
	RequestReplay = ReplicatedStorage:FindFirstChild("RequestReplay"),
	DeleteReplay = ReplicatedStorage:FindFirstChild("DeleteReplay"),
	UploadReplay = ReplicatedStorage:FindFirstChild("UploadReplay"),
}
local DataVersion = "v7"
local ReplaysStore = DataStoreService:GetDataStore("player_replays", DataVersion)
local KeysStore = DataStoreService:GetDataStore("player_replay_keys", DataVersion)
local keyCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local replaysCache = {}
local fullData = {}
local function generateRandomKey()
	local result = ""
	for i = 1, 7 do
		local randomIndex = math.random(#keyCharacters)
		result ..= string.sub(keyCharacters, randomIndex, randomIndex)
	end
	return result
end
Players.PlayerRemoving:Connect(function(player)
	if fullData[player.UserId] ~= nil then
		fullData[player.UserId] = nil
	end
	if replaysCache[player.UserId] ~= nil then
		replaysCache[player.UserId] = nil
	end
end)
Events.UploadReplay.OnServerInvoke = function(player, messageType, chunk)
	local _messageType = messageType
	if not (type(_messageType) == "number") then
		return nil
	end
	local userId = player.UserId
	if messageType == 0 then
		fullData[userId] = ""
	elseif messageType == 1 then
		local _chunk = chunk
		if not (type(_chunk) == "string") then
			return false
		end
		fullData[userId] ..= chunk
	elseif messageType == 2 then
		local replayId = HttpService:GenerateGUID(false)
		local key = ""
		local success = false
		repeat
			do
				key = generateRandomKey()
				local _exitType, _returns = TS.try(function()
					local existingKey = KeysStore:GetAsync(key)
					if not (existingKey ~= 0 and existingKey == existingKey and existingKey ~= "" and existingKey) then
						return TS.TRY_BREAK
					end
				end, function(err)
					warn("[src/server/replays.server.ts:70]", err)
				end)
				if _exitType then
					break
				end
				local doesExist
				if doesExist ~= 0 and doesExist == doesExist and doesExist ~= "" and doesExist then
					success = false
				end
			end
		until success
		KeysStore:SetAsync(key, replayId, { player.UserId })
		local data = fullData[userId]
		fullData[userId] = nil
		local decompressedData = decompressData(data, false)
		local newData = compressData({ key, decompressedData }, false)
		local chunkSize = 4194303
		for retryAttempt = 1, 5 do
			local _exitType, _returns = TS.try(function()
				local iteration = 1
				for i = 1, #newData, chunkSize or 1 do
					local j = i + chunkSize - 1
					local chunk = string.sub(newData, i, j)
					ReplaysStore:SetAsync(`{userId}_{replayId}_{iteration}`, chunk)
					iteration += 1
				end
				print("[src/server/replays.server.ts:97]", `Saved replay data for player {player.Name}!`)
				return TS.TRY_BREAK
			end, function(err)
				warn("[src/server/replays.server.ts:100]", `Could not save replay for player {player.Name}! Retrying {5 - retryAttempt} more time(s) | Error: {err}`)
			end)
			if _exitType then
				break
			end
		end
		replaysCache[userId] = nil
	end
	return true
end
Events.DeleteReplay.OnServerInvoke = function(player, replayId)
	local _replayId = replayId
	if not (type(_replayId) == "string") then
		return nil
	end
	local prefix = `{player.UserId}_{replayId}`
	while true do
		local _exitType, _returns = TS.try(function()
			local replayChunks = ReplaysStore:ListKeysAsync(prefix, 0, "", true)
			while true do
				local currentPage = replayChunks:GetCurrentPage()
				for _, key in currentPage do
					ReplaysStore:RemoveAsync(key.KeyName)
				end
				if replayChunks.IsFinished then
					break
				end
				replayChunks:AdvanceToNextPageAsync()
			end
			return TS.TRY_BREAK
		end, function(err)
			warn("[src/server/replays.server.ts:129]", err)
		end)
		if _exitType then
			break
		end
	end
	replaysCache[player.UserId] = nil
end
Events.GetPlayerReplays.OnServerInvoke = function(player)
	local userId = player.UserId
	if replaysCache[userId] ~= nil then
		return replaysCache[userId]
	end
	local _value = player:GetAttribute("requestingReplays")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return -1
	end
	player:SetAttribute("requestingReplays", true)
	local replayList = {}
	while true do
		local _exitType, _returns = TS.try(function()
			local allReplays = ReplaysStore:ListKeysAsync(tostring(userId), nil, nil, true)
			replayList = {}
			while true do
				local currentPage = allReplays:GetCurrentPage()
				for _, key in currentPage do
					local _binding = string.split(key.KeyName, "_")
					local replayId = _binding[2]
					local iteration = _binding[3]
					local data, info = ReplaysStore:GetAsync(key.KeyName)
					if type(data) == "string" then
						if not (replayList[replayId] ~= nil) then
							replayList[replayId] = {
								dateCreated = info.CreatedTime,
								frames = {},
							}
						end
						local _exp = replayList[replayId].frames
						local _condition = tonumber(iteration)
						if _condition == nil then
							_condition = 1
						end
						_exp[_condition] = data
					end
				end
				if allReplays.IsFinished then
					break
				end
				allReplays:AdvanceToNextPageAsync()
			end
			return TS.TRY_BREAK
		end, function(err)
			warn("[src/server/replays.server.ts:171]", err)
		end)
		if _exitType then
			break
		end
	end
	local newList = {}
	for replayId, replayData in pairs(replayList) do
		local _condition = replayData.dateCreated
		if _condition == nil then
			_condition = -1
		end
		local dateCreated = _condition
		local data = replayData.frames
		local concattedData = table.concat(data, "")
		local decompressedData = decompressData(concattedData, false)
		local result
		local key
		if #decompressedData == 2 then
			key = decompressedData[1]
			result = decompressedData[2]
		else
			result = decompressedData
			key = nil
		end
		local _arg0 = { replayId, player.UserId, #data, #concattedData, result, dateCreated, key }
		table.insert(newList, _arg0)
	end
	table.sort(newList, function(a, b)
		return a[6] > b[6]
	end)
	replaysCache[player.UserId] = table.clone(newList)
	player:SetAttribute("requestingReplays", nil)
	return newList
end
Events.RequestReplay.OnServerInvoke = function(player, key)
	local _key = key
	if not (type(_key) == "string") then
		return nil
	end
	if #key ~= 7 then
		return nil, "Key must be 7 characters long"
	end
	for _, character in string.split(key, "") do
		local index = string.find(keyCharacters, character)
		if not (index ~= 0 and index == index and index) then
			return nil, "Key contains invalid character"
		end
	end
	local replayId
	local info
	while true do
		local _exitType, _returns = TS.try(function()
			replayId, info = KeysStore:GetAsync(key)
			return TS.TRY_BREAK
		end, function(err)
			warn("[src/server/replays.server.ts:220]", err)
		end)
		if _exitType then
			break
		end
	end
	local _replayId = replayId
	local _condition = type(_replayId) == "string"
	if _condition then
		local _result = info
		if _result ~= nil then
			_result = _result:IsA("DataStoreKeyInfo")
		end
		_condition = _result
	end
	if _condition then
		local userId = (info:GetUserIds())[1]
		if not (userId ~= 0 and userId == userId and userId) then
			return nil, "Unable to fetch user id from key, try again"
		end
		local prefix = `{player.UserId}_{replayId}`
		local chunks = {}
		while true do
			TS.try(function()
				table.clear(chunks)
				local replayChunks = ReplaysStore:ListKeysAsync(prefix, nil, nil, true)
				while true do
					local currentPage = replayChunks:GetCurrentPage()
					for _, key in currentPage do
						local _binding = string.split(key.KeyName, "_")
						local iteration = _binding[3]
						local data = ReplaysStore:GetAsync(key.KeyName)
						if type(data) == "string" then
							local _exp = chunks
							local _condition_1 = tonumber(iteration)
							if _condition_1 == nil then
								_condition_1 = 1
							end
							_exp[_condition_1 + 1] = data
						end
					end
					if replayChunks.IsFinished then
						break
					end
					replayChunks:AdvanceToNextPageAsync()
				end
			end, function(err)
				warn("[src/server/replays.server.ts:249]", err)
			end)
		end
		local decodedData = decompressData(table.concat(chunks, ""), false)
		if #decodedData > 2 then
			decodedData = { userId, decodedData }
		else
			decodedData[1] = userId
		end
		return decodedData, ""
	else
		return nil, "Key does not exist"
	end
end
