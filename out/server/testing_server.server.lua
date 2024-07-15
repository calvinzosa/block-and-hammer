-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local DataStoreService = _services.DataStoreService
local TeleportService = _services.TeleportService
local RunService = _services.RunService
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local isTestingServer = _utils.isTestingServer
local isMainServer = _utils.isMainServer
local GameData = _utils.GameData
local TestingServerStore = DataStoreService:GetDataStore("testing_server")
local forceTestingServer = ReplicatedStorage:FindFirstChild("ForceTestingServer")
local ownerId = ReplicatedStorage:FindFirstChild("PrivateServerOwnerId")
local _condition = RunService:IsStudio()
if _condition then
	local _value = forceTestingServer.Value
	_condition = not (_value ~= 0 and _value == _value and _value)
end
local _condition_1 = _condition
if not _condition_1 then
	_condition_1 = game.PrivateServerOwnerId == 0
end
if _condition_1 then
	ownerId.Value = -1
else
	ownerId.Value = game.PrivateServerOwnerId
end
if isMainServer() then
	print("[src/server/testing_server.server.ts:15]", "Server Type: Main")
	local _creatorIds = GameData.CreatorIds
	local _value = ownerId.Value
	if table.find(_creatorIds, _value) ~= nil then
		while true do
			local _value_1 = task.wait(3)
			if not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1) then
				break
			end
			local savedServerId
			while true do
				local _exitType, _returns = TS.try(function()
					savedServerId = TestingServerStore:GetAsync("ServerId")
					return TS.TRY_BREAK
				end, function(err)
					warn("[src/server/testing_server.server.ts:25]", err)
				end)
				if _exitType then
					break
				end
			end
			local _savedServerId = savedServerId
			local _condition_2 = not (type(_savedServerId) == "string")
			if not _condition_2 then
				_condition_2 = savedServerId == "none"
			end
			if _condition_2 then
				local serverId = TeleportService:ReserveServer(GameData.TestingPlaceId)
				savedServerId = serverId
				while true do
					TS.try(function()
						TestingServerStore:SetAsync("ServerId", serverId)
					end, function(err)
						warn("[src/server/testing_server.server.ts:37]", err)
					end)
				end
			end
			TeleportService:TeleportToPrivateServer(GameData.TestingPlaceId, savedServerId, Players:GetPlayers())
		end
	end
elseif isTestingServer() then
	print("[src/server/testing_server.server.ts:46]", "Server Type: Testing")
	game:BindToClose(function()
		while true do
			local _exitType, _returns = TS.try(function()
				TestingServerStore:SetAsync("ServerId", "none")
				return TS.TRY_BREAK
			end, function(err)
				warn("[src/server/testing_server.server.ts:54]", err)
			end)
			if _exitType then
				break
			end
		end
	end)
end
