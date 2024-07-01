-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local DataStoreService = _services.DataStoreService
local HttpService = _services.HttpService
local RunService = _services.RunService
local Players = _services.Players
local isTestingServer = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").isTestingServer
if isTestingServer() then
	warn("[src/server/data/leaderboards.server.ts:8]", "Leaderboards are not enabled in the testing server")
else
	local Events = {
		UpdateLeaderboard = ReplicatedStorage:FindFirstChild("UpdateLeaderboard"),
		UpdatePlayerTime = ReplicatedStorage:FindFirstChild("UpdatePlayerTime"),
	}
	local leaderboardVersion = "LEADERBOARD_V6"
	local GlobalLeaderboard = DataStoreService:GetOrderedDataStore("GlobalLeaderboard", leaderboardVersion)
	local ModdedLeaderboard = DataStoreService:GetOrderedDataStore("ModdedLeaderboard", leaderboardVersion)
	local leaderboardsCache = {
		GlobalLeaderboard = {},
		ModdedLeaderboard = {},
	}
	local dataCache = {
		GlobalLeaderboard = {},
		ModdedLeaderboard = {},
	}
	local processLeaderboardData
	local function updateLeaderboardsCache()
		if not RunService:IsStudio() or true then
			for userId, totalTime in pairs(leaderboardsCache.GlobalLeaderboard) do
				while true do
					local _exitType, _returns = TS.try(function()
						GlobalLeaderboard:UpdateAsync(userId, function(prevValue)
							local _fn = math
							local _condition = prevValue
							if _condition == nil then
								_condition = totalTime
							end
							local newValue = _fn.min(totalTime, _condition)
							print("[src/server/data/leaderboards.server.ts:37]", `Updated global leaderboard value of {userId} | Previous Value: {prevValue} | New Value: {newValue}`)
							return newValue
						end)
						return TS.TRY_BREAK
					end, function(err)
						warn("[src/server/data/leaderboards.server.ts:42]", err)
					end)
					if _exitType then
						break
					end
				end
				leaderboardsCache.GlobalLeaderboard[userId] = nil
			end
			for userId, totalTime in pairs(leaderboardsCache.ModdedLeaderboard) do
				while true do
					local _exitType, _returns = TS.try(function()
						ModdedLeaderboard:UpdateAsync(userId, function(prevValue)
							local _fn = math
							local _condition = prevValue
							if _condition == nil then
								_condition = totalTime
							end
							local newValue = _fn.min(totalTime, _condition)
							print("[src/server/data/leaderboards.server.ts:54]", `Updated modded leaderboard value of {userId} | Previous Value: {prevValue} | New Value: {newValue}`)
							return newValue
						end)
						return TS.TRY_BREAK
					end, function(err)
						warn("[src/server/data/leaderboards.server.ts:59]", err)
					end)
					if _exitType then
						break
					end
				end
				leaderboardsCache.ModdedLeaderboard[userId] = nil
			end
		end
		dataCache = {
			GlobalLeaderboard = {},
			ModdedLeaderboard = {},
		}
		while true do
			local _exitType, _returns = TS.try(function()
				processLeaderboardData(GlobalLeaderboard:GetSortedAsync(true, 100, 1):GetCurrentPage(), "GlobalLeaderboard")
				processLeaderboardData(ModdedLeaderboard:GetSortedAsync(true, 100, 1):GetCurrentPage(), "ModdedLeaderboard")
				return TS.TRY_BREAK
			end, function(err)
				warn("[src/server/data/leaderboards.server.ts:87]", err)
			end)
			if _exitType then
				break
			end
		end
		Events.UpdateLeaderboard:FireAllClients(HttpService:JSONEncode(dataCache))
		print("[src/server/data/leaderboards.server.ts:93]", "Updated all leaderboard info")
	end
	function processLeaderboardData(page, leaderboardName)
		for number, value in pairs(page) do
			local userId = value.key
			local totalTimeMilliseconds = value.value
			local _condition = tonumber(userId)
			if _condition == nil then
				_condition = -1
			end
			dataCache[leaderboardName][number] = { _condition, totalTimeMilliseconds }
		end
	end
	local function playerAdded(player)
		task.wait(5)
		Events.UpdateLeaderboard:FireClient(player, HttpService:JSONEncode(dataCache))
	end
	Events.UpdatePlayerTime.Event:Connect(function(userId, totalTime, leaderboardType)
		if userId <= 0 then
			return nil
		end
		local milliseconds = math.floor(totalTime * 1000)
		local id = tostring(userId)
		if leaderboardType == 0 then
			leaderboardsCache.GlobalLeaderboard[id] = milliseconds
		elseif leaderboardType == 1 then
			leaderboardsCache.ModdedLeaderboard[id] = milliseconds
		end
	end)
	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end
	Players.PlayerAdded:Connect(playerAdded)
	task.wait(5)
	while true do
		TS.try(function()
			updateLeaderboardsCache()
		end, function(err)
			warn("[src/server/data/leaderboards.server.ts:128]", err)
		end)
		task.wait(60)
	end
end
