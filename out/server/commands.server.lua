-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local TeleportService = _services.TeleportService
local TweenService = _services.TweenService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local startsWith = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "string-utils").startsWith
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local isTestingServer = _utils.isTestingServer
local getPlayerRank = _utils.getPlayerRank
local giveBadge = _utils.giveBadge
local numLerp = _utils.numLerp
local accessoryList = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader").accessoryList
local Events = {
	SaySystemMessage = ReplicatedStorage:FindFirstChild("SaySystemMessage"),
	StartErrorEvent = ReplicatedStorage:FindFirstChild("StartErrorEvent"),
	FlipGravity = ReplicatedStorage:FindFirstChild("FlipGravity"),
	ForceEquip = ReplicatedStorage:FindFirstChild("ForceEquip"),
}
local prefixes = { ";", ":", "/" }
local connections = {}
local Commands
Commands = {
	cmds = {
		rank = 0,
		parameters = {},
		callback = function(sender)
			local rank = getPlayerRank(sender)
			local message = "Available commands you can use:"
			for name, data in pairs(Commands) do
				if data.rank > rank then
					continue
				end
				message ..= `\n  ;{name}`
				if #data.parameters > 0 then
					message ..= ` [{table.concat(data.parameters, "] [")}]`
				end
			end
			task.wait(0)
			Events.SaySystemMessage:FireClient(sender, message)
		end,
	},
	rejoin = {
		rank = 0,
		parameters = {},
		callback = function(sender)
			local options = Instance.new("TeleportOptions")
			options.ServerInstanceId = game.JobId
			options.ShouldReserveServer = false
			TeleportService:TeleportAsync(game.PlaceId, { sender }, options)
		end,
	},
	equip = {
		rank = if isTestingServer() then 0 else 2,
		parameters = { "string" },
		callback = function(sender, a)
			local accessoryName = a
			local allowedEquips = { "Icy Hammer" }
			if table.find(allowedEquips, accessoryName) ~= nil then
				Events.ForceEquip:Fire(sender, accessoryName)
			else
				task.wait()
				if accessoryList[accessoryName] ~= nil then
					Events.SaySystemMessage:FireClient(sender, "You are not allowed to equip that!", Color3.fromRGB(255, 170, 0))
				else
					Events.SaySystemMessage:FireClient(sender, "Not found", Color3.fromRGB(255, 128, 128))
				end
			end
		end,
	},
	flip = {
		rank = 1,
		parameters = { "players" },
		callback = function(sender, a)
			local targets = a
			for _, target in targets do
				Events.FlipGravity:FireClient(target)
				giveBadge(target, 2146247056)
			end
		end,
	},
	fequip = {
		rank = 1,
		parameters = { "players", "string" },
		callback = function(sender, a, b)
			local targets = a
			local accessoryName = b
			for _, target in targets do
				Events.ForceEquip:Fire(target, accessoryName)
			end
		end,
	},
	alist = {
		rank = 1,
		parameters = {},
		callback = function(sender)
			task.wait(0)
			Events.SaySystemMessage:FireClient(sender, "Accessory List:", Color3.fromRGB(0, 200, 255))
			for name in pairs(accessoryList) do
				Events.SaySystemMessage:FireClient(sender, `> {name}`, Color3.fromRGB(0, 200, 255))
			end
		end,
	},
	goto = {
		rank = 1,
		parameters = { "players" },
		callback = function(sender, a)
			local targets = a
			if #targets ~= 1 then
				return nil
			end
			local player = targets[1]
			local targetCube = Workspace:FindFirstChild(`cube{sender.UserId}`)
			local teleportCube = Workspace:FindFirstChild(`cube{player.UserId}`)
			if not targetCube or not teleportCube then
				return nil
			end
			task.spawn(function()
				targetCube.Anchored = true
				targetCube.AssemblyLinearVelocity = Vector3.new()
				task.wait(0.1)
				local _fn = targetCube
				local _cFrame = teleportCube.CFrame
				local _cFrame_1 = CFrame.new(0, 5, 0)
				_fn:PivotTo(_cFrame * _cFrame_1)
				task.wait(0.1)
				targetCube.Anchored = false
			end)
		end,
	},
	bring = {
		rank = 1,
		parameters = { "players" },
		callback = function(sender, a)
			local targets = a
			if #targets ~= 1 then
				return nil
			end
			local player = targets[1]
			local targetCube = Workspace:FindFirstChild(`cube{player.UserId}`)
			local teleportCube = Workspace:FindFirstChild(`cube{sender.UserId}`)
			if not targetCube or not teleportCube then
				return nil
			end
			targetCube.Anchored = true
			targetCube.AssemblyLinearVelocity = Vector3.new()
			task.wait(0.1)
			local _fn = targetCube
			local _cFrame = teleportCube.CFrame
			local _cFrame_1 = CFrame.new(0, 5, 0)
			_fn:PivotTo(_cFrame * _cFrame_1)
			task.wait(0.1)
			targetCube.Anchored = false
		end,
	},
	scale = {
		rank = 2,
		parameters = { "players", "number" },
		callback = function(sender, a, b)
			local targets = a
			local newScale = b
			if not (type(newScale) == "number") then
				Events.SaySystemMessage:FireClient(sender, "Second parameter must be a number", Color3.fromRGB(255, 170, 0))
				return nil
			end
			for _, player in targets do
				local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
				local _condition = cube
				if _condition then
					local _value = cube:GetAttribute("isScaling")
					_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
				end
				if _condition then
					cube:SetAttribute("isScaling", true)
					task.spawn(function()
						local _condition_1 = cube:GetAttribute("scale")
						if _condition_1 == nil then
							_condition_1 = 1
						end
						local previousScale = _condition_1
						local model = Instance.new("Model")
						model:ScaleTo(previousScale)
						model.Parent = Workspace
						cube.Parent = model
						local currentTime = time()
						local startTime = currentTime
						local totalTime = 0.4
						while (currentTime - startTime) < totalTime do
							local alpha = TweenService:GetValue((currentTime - startTime) / totalTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
							local currentScale = numLerp(previousScale, newScale, alpha)
							model:ScaleTo(currentScale)
							currentTime = time()
							RunService.Heartbeat:Wait()
						end
						model:ScaleTo(newScale)
						cube:SetAttribute("isScaling", nil)
						cube:SetAttribute("scale", newScale)
						cube.Parent = Workspace
					end)
				end
			end
		end,
	},
	error = {
		rank = 2,
		parameters = { "players" },
		callback = function(sender, a)
			local targets = a
			for _, player in targets do
				local _value = player:GetAttribute("ERROR_LAND")
				if _value ~= 0 and _value == _value and _value ~= "" and _value then
					continue
				end
				task.spawn(function()
					local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
					if cube then
						cube:Destroy()
						player:SetAttribute("ERROR_LAND", true)
						Events.StartErrorEvent:FireClient(player)
						giveBadge(player, 2146357550)
					end
				end)
			end
		end,
	},
}
local function parseCommand(message)
	local prefix
	for _, p in prefixes do
		if string.sub(message, 1, 1) == p then
			prefix = p
			break
		end
	end
	if not (prefix ~= "" and prefix) then
		return nil, {}
	end
	message = string.sub(message, 2)
	local _binding = { string.match(message, "^(%S+)%s*(.*)") } or {}
	local command = _binding[1]
	local argsString = _binding[2]
	if not (command ~= 0 and command == command and command ~= "" and command) then
		return nil, {}
	end
	local function splitArgs(args)
		local results = {}
		local currentArg = ""
		local inSingleQuote = false
		local inDoubleQuote = false
		local escaping = false
		for i = 1, #args do
			local char = string.sub(args, i, i)
			if escaping then
				currentArg ..= char
				escaping = false
			elseif char == "\\" then
				escaping = true
			elseif char == "\'" and not inDoubleQuote then
				if inSingleQuote then
					local _currentArg = currentArg
					table.insert(results, _currentArg)
					currentArg = ""
					inSingleQuote = false
				else
					inSingleQuote = true
				end
			elseif char == '"' and not inSingleQuote then
				if inDoubleQuote then
					local _currentArg = currentArg
					table.insert(results, _currentArg)
					currentArg = ""
					inDoubleQuote = false
				else
					inDoubleQuote = true
				end
			elseif char == " " and not inSingleQuote and not inDoubleQuote then
				if #currentArg > 0 then
					local _currentArg = currentArg
					table.insert(results, _currentArg)
					currentArg = ""
				end
			else
				currentArg ..= char
			end
		end
		if #currentArg > 0 then
			local _currentArg = currentArg
			table.insert(results, _currentArg)
		end
		return results
	end
	local _condition = argsString
	if _condition == nil then
		_condition = ""
	end
	return command, splitArgs(_condition)
end
local function getPlayers(name, sender)
	local players = {}
	if name == "all" or name == "others" then
		for _, otherPlayer in Players:GetPlayers() do
			if name == "all" or otherPlayer ~= sender then
				table.insert(players, otherPlayer)
			end
		end
	elseif name == "me" then
		local _sender = sender
		table.insert(players, _sender)
	else
		local validPlayerNames = {}
		for _, otherPlayer in Players:GetPlayers() do
			if startsWith(string.lower(otherPlayer.Name), string.lower(name)) then
				local _name = otherPlayer.Name
				table.insert(validPlayerNames, _name)
			end
		end
		if #validPlayerNames > 0 then
			table.sort(validPlayerNames)
			local _arg0 = Players:FindFirstChild(validPlayerNames[1])
			table.insert(players, _arg0)
		end
	end
	return players
end
local function chatted(player, message)
	local commandName, args = parseCommand(message)
	if not (commandName ~= 0 and commandName == commandName and commandName ~= "" and commandName) then
		return nil
	end
	local rank = getPlayerRank(player)
	local command = Commands[commandName]
	if not command then
		return nil
	end
	if rank < command.rank then
		task.wait(0)
		Events.SaySystemMessage:FireClient(player, "You are not allowed to use this command!", Color3.fromRGB(255, 170, 0))
		return nil
	end
	if #args ~= #command.parameters then
		task.wait(0)
		Events.SaySystemMessage:FireClient(player, "Invalid command syntax, use ;cmds to see how to use this command", Color3.fromRGB(0, 0, 255))
		return nil
	end
	local parsedParameters = {}
	for i, parameterType in pairs(command.parameters) do
		if parameterType == "players" then
			local _arg0 = getPlayers(args[i], player)
			table.insert(parsedParameters, _arg0)
		elseif parameterType == "string" then
			local _arg0 = args[i]
			table.insert(parsedParameters, _arg0)
		elseif parameterType == "number" then
			local _condition = tonumber(args[i])
			if _condition == nil then
				_condition = args[i]
			end
			table.insert(parsedParameters, _condition)
		end
	end
	command.callback(player, unpack(parsedParameters))
end
Players.PlayerAdded:Connect(function(player)
	local _player = player
	local _arg1 = player.Chatted:Connect(function(message)
		return chatted(player, message)
	end)
	connections[_player] = _arg1
end)
Players.PlayerRemoving:Connect(function(player)
	local _player = player
	local _result = connections[_player]
	if _result ~= nil then
		_result:Disconnect()
	end
end)
