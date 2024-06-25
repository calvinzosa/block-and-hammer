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
if _condition then
	ownerId.Value = -1
else
	ownerId.Value = game.PrivateServerOwnerId
end
if isMainServer() then
	print("[src/server/testing_server.server.ts:25]", "Server Type: Main")
	if ownerId.Value == GameData.CreatorId then
		while true do
			local _value = task.wait(3)
			if not (_value ~= 0 and _value == _value and _value) then
				break
			end
			local savedServerId = nil
			repeat
				do
					local success, serverId = pcall(function()
						return TestingServerStore:GetAsync("ServerId")
					end)
					if success then
						savedServerId = serverId
						break
					end
				end
				local _value_1 = task.wait(0.5)
			until not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1)
			if not (savedServerId ~= "" and savedServerId) or savedServerId == "none" then
				local serverId = TeleportService:ReserveServer(GameData.TestingPlaceId)
				savedServerId = serverId
				repeat
					do
						local success = pcall(function()
							return TestingServerStore:SetAsync("ServerId", serverId)
						end)
						if success then
							break
						end
					end
					local _value_1 = task.wait(0.5)
				until not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1)
			end
			TeleportService:TeleportToPrivateServer(GameData.TestingPlaceId, savedServerId, Players:GetPlayers())
		end
	end
elseif isTestingServer() then
	print("[src/server/testing_server.server.ts:52]", "Server Type: Testing")
	game:BindToClose(function()
		repeat
			do
				local success = pcall(function()
					return TestingServerStore:SetAsync("ServerId", "none")
				end)
				if success then
					break
				end
			end
			local _value = task.wait(0.5)
		until not (_value ~= 0 and _value == _value and _value)
	end)
end
