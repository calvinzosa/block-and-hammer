-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local BadgeService = _services.BadgeService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local Chat = _services.Chat
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local convertStudsToMeters = _utils.convertStudsToMeters
local PlayerAttributes = _utils.PlayerAttributes
local computeNameColor = _utils.computeNameColor
local Accessories = _utils.Accessories
local giveBadge = _utils.giveBadge
local getTime = _utils.getTime
local getTimeUnits = _utils.getTimeUnits
local getHammerTexture = _utils.getHammerTexture
local reloadAccessories = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader").reloadAccessories
local startsWith = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "string-utils").startsWith
local Admins = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "admins").Admins
local Events = {
	SayMessageRequest = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"),
	SetModifiersSetting = ReplicatedStorage:FindFirstChild("SetModifiersSetting"),
	SaySystemMessage = ReplicatedStorage:FindFirstChild("SaySystemMessage"),
	AddRagdollCount = ReplicatedStorage:FindFirstChild("AddRagdollCount"),
	ShowChatBubble = ReplicatedStorage:FindFirstChild("ShowChatBubble"),
	DestroyedPart = ReplicatedStorage:FindFirstChild("DestroyedPart"),
	SetDeviceType = ReplicatedStorage:FindFirstChild("SetDeviceType"),
	CompleteGame = ReplicatedStorage:FindFirstChild("CompleteGame"),
	GroundImpact = ReplicatedStorage:FindFirstChild("GroundImpact"),
	FlipGravity = ReplicatedStorage:FindFirstChild("FlipGravity"),
	Reset = ReplicatedStorage:FindFirstChild("Reset"),
	LoadPlayerAccessories = ReplicatedStorage:FindFirstChild("LoadPlayerAccessories"),
	UpdatePlayerTime = ReplicatedStorage:FindFirstChild("UpdatePlayerTime"),
	ForceReset = ReplicatedStorage:FindFirstChild("ForceReset"),
}
local cubeTemplate = ReplicatedStorage:FindFirstChild("Cube")
local targetCenter = Workspace:FindFirstChild("TargetCenter")
local mapFolder = Workspace:FindFirstChild("Map")
local trappedArea = mapFolder:FindFirstChild("trapped_area")
local gravityFlipper = mapFolder:WaitForChild("gravity_flipper")
local function createCube(player, firstTime)
	local _result = Workspace:FindFirstChild(`cube{player.Name}`)
	if _result ~= nil then
		_result:Destroy()
	end
	if player.UserId == -1 then
		player:SetAttribute(PlayerAttributes.HammerTexture, Accessories.HammerTexture.GrapplingHammer)
	end
	Events.FlipGravity:FireClient(player, false)
	local cube = cubeTemplate:Clone()
	cube.Name = `cube{player.UserId}`
	cube.Color = computeNameColor(player.Name)
	cube.Parent = Workspace
	local head = cube:FindFirstChild("Head")
	local overheadGui = cube:FindFirstChild("OverheadGUI")
	local icons = overheadGui:FindFirstChild("Icons");
	(overheadGui:FindFirstChild("Username")).Text = `{player.DisplayName} (@{player.Name})`
	local device = player:GetAttribute(PlayerAttributes.Device)
	if device == 0 then
		(icons:FindFirstChild("Desktop")).Visible = true
	elseif device == 1 then
		(icons:FindFirstChild("Mobile")).Visible = true
	end
	if player.MembershipType == Enum.MembershipType.Premium then
		(icons:FindFirstChild("Premium")).Visible = true
	end
	if player:IsFriendsWith(game.CreatorId) then
		(icons:FindFirstChild("Friend")).Visible = true
	end
	-- ▼ ReadonlyArray.find ▼
	local _callback = function(userId)
		return userId == player.UserId
	end
	local _result_1
	for _i, _v in Admins do
		if _callback(_v, _i - 1, Admins) == true then
			_result_1 = _v
			break
		end
	end
	-- ▲ ReadonlyArray.find ▲
	if _result_1 ~= 0 and _result_1 == _result_1 and _result_1 then
		(icons:FindFirstChild("Admin")).Visible = true
	end
	if player.UserId == game.CreatorId then
		(icons:FindFirstChild("Developer")).Visible = true
	end
	icons.Visible = true
	local _condition = player:GetAttribute(PlayerAttributes.HasModifiers)
	if not (_condition ~= 0 and _condition == _condition and _condition ~= "" and _condition) then
		local _condition_1 = cube:GetAttribute("scale")
		if _condition_1 == nil then
			_condition_1 = 1
		end
		_condition = _condition_1 ~= 1
	end
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		cube:SetAttribute("used_modifiers", true)
	end
	player:SetAttribute(PlayerAttributes.TotalTime, nil)
	cube:SetAttribute("start_time", getTime())
	task.spawn(function()
		while not { cube:CanSetNetworkOwnership() } do
			task.wait()
		end
		cube:SetNetworkOwner(player)
		head:SetNetworkOwner(player)
	end)
	cube.Touched:Connect(function(otherPart)
		if otherPart == trappedArea then
			giveBadge(player, 2146259996)
		end
	end)
	if not firstTime then
		player:SetAttribute(PlayerAttributes.CompletedGame, false)
	end
	while true do
		local _value = player:GetAttribute(PlayerAttributes.HasDataLoaded)
		if not not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
			break
		end
		task.wait()
	end
	local cubeColor = player:GetAttribute(PlayerAttributes.CubeColor)
	if typeof(cubeColor) == "Color3" then
		cube.Color = cubeColor
	end
	Events.LoadPlayerAccessories:Fire(player, cube)
	task.delay(1, function()
		if cube.Parent ~= Workspace then
			return nil
		end
		reloadAccessories(cube, player)
		cube:GetPropertyChangedSignal("Color"):Connect(function()
			return reloadAccessories(cube, player)
		end)
	end)
end
local function characterAdded(character)
	local rootPart = character:WaitForChild("HumanoidRootPart")
	rootPart.Anchored = true
end
local function playerAdded(player)
	task.spawn(function()
		if not BadgeService:UserHasBadgeAsync(player.UserId, 1967915839777317) then
			giveBadge(player, 1967915839777317)
			player:SetAttribute(PlayerAttributes.IsNew, true)
		end
		giveBadge(player, 4410861265533965)
	end)
	createCube(player, true)
	if player.Character then
		characterAdded(player.Character)
	end
	player.CharacterAdded:Connect(characterAdded)
end
local function resetPlayer(player, fullReset)
	local _condition = not player
	if not _condition then
		local _fullReset = fullReset
		_condition = not (type(_fullReset) == "boolean")
	end
	if _condition then
		return nil
	end
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	if fullReset and cube then
		cube:Destroy()
		cube = nil
	end
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	if _result then
		cube:SetAttribute("extra_time", nil)
		cube:SetAttribute("finishTotalTime", nil)
		cube:SetAttribute("destroyed_counter", 0)
		player:SetAttribute(PlayerAttributes.CompletedGame, nil)
		local _value = player:GetAttribute(PlayerAttributes.HasModifiers)
		if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
			cube:SetAttribute("used_modifiers", nil)
		end
		cube:SetAttribute("start_time", getTime())
	else
		createCube(player, false)
	end
	local _fn = player
	local _exp = PlayerAttributes.TotalRestarts
	local _condition_1 = player:GetAttribute(PlayerAttributes.TotalRestarts)
	if _condition_1 == nil then
		_condition_1 = 0
	end
	_fn:SetAttribute(_exp, _condition_1 + 1)
end
Events.SetModifiersSetting.OnServerEvent:Connect(function(player, isEnabled)
	local _isEnabled = isEnabled
	if not (type(_isEnabled) == "boolean") then
		return nil
	end
	player:SetAttribute(PlayerAttributes.HasModifiers, isEnabled)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	if cube then
		cube:SetAttribute("used_modifiers", true)
	end
end)
Events.SetDeviceType.OnServerEvent:Connect(function(player, device)
	local _device = device
	if not (type(_device) == "number") then
		return nil
	end
	if device == 0 or device == 1 then
		player:SetAttribute(PlayerAttributes.Device, device)
		local cube = Workspace:FindFirstChild(`cube\{player.UserId\}`)
		if cube then
			local overheadGui = cube:FindFirstChild("OverheadGUI")
			local icons = overheadGui:FindFirstChild("Icons")
			local desktop = icons:FindFirstChild("Desktop")
			local mobile = icons:FindFirstChild("Mobile")
			desktop.Visible = false
			mobile.Visible = false
			if device == 0 then
				desktop.Visible = true
			elseif device == 1 then
				mobile.Visible = true
			end
		end
	end
end)
Events.AddRagdollCount.OnServerEvent:Connect(function(player)
	local _fn = player
	local _exp = PlayerAttributes.TotalRagdolls
	local _condition = player:GetAttribute(PlayerAttributes.TotalRagdolls)
	if _condition == nil then
		_condition = 0
	end
	_fn:SetAttribute(_exp, _condition + 1)
end)
Events.GroundImpact.OnServerEvent:Connect(function(player, velocity, position)
	local _velocity = velocity
	local _condition = not (typeof(_velocity) == "Vector3")
	if not _condition then
		local _position = position
		_condition = not (typeof(_position) == "Vector3")
	end
	if _condition then
		return nil
	end
	local _condition_1 = player:GetAttribute(PlayerAttributes.Impacts)
	if _condition_1 == nil then
		_condition_1 = 0
	end
	local newImpacts = _condition_1 + 1
	player:SetAttribute(PlayerAttributes.Impacts, newImpacts)
	local _condition_2 = newImpacts >= 15
	if _condition_2 then
		local _value = player:GetAttribute(PlayerAttributes.HasExplosiveBadge)
		_condition_2 = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
	end
	if _condition_2 then
		player:SetAttribute(PlayerAttributes.HasExplosiveBadge, true)
		giveBadge(player, 2146508969)
	end
	if velocity.Y > 892.857 then
		giveBadge(player, 4279006041653694)
	elseif velocity.Y > 357.142 then
		local _value = player:GetAttribute("didShatter")
		if _value ~= 0 and _value == _value and _value ~= "" and _value then
			giveBadge(player, 2512066188170235)
		else
			local params = OverlapParams.new()
			params.FilterDescendantsInstances = { targetCenter }
			params.FilterType = Enum.RaycastFilterType.Include
			if #Workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(4, 4, 4), params) > 0 then
				giveBadge(player, 2479031288528448)
			end
		end
	else
		giveBadge(player, 2146180612)
	end
end)
Events.CompleteGame.OnServerEvent:Connect(function(player, givenTime)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = not _result
	if not _condition then
		local _givenTime = givenTime
		_condition = not (type(_givenTime) == "number")
	end
	if _condition then
		return nil
	end
	local totalTime = math.min(givenTime, 3599.999)
	cube:SetAttribute("finishTotalTime", totalTime)
	player:SetAttribute("finished", true)
	local hours, minutes, seconds, milliseconds = getTimeUnits(totalTime * 1000)
	local formattedTime = string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
	local _value = cube:GetAttribute("used_modifiers")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		Events.SaySystemMessage:FireClient(player, `nice! you completed a modded run in: {formattedTime}`)
		Events.UpdatePlayerTime:Fire(player.UserId, totalTime, 1)
		local _fn = player
		local _exp = PlayerAttributes.TotalModdedWins
		local _condition_1 = player:GetAttribute(PlayerAttributes.TotalModdedWins)
		if _condition_1 == nil then
			_condition_1 = 0
		end
		_fn:SetAttribute(_exp, _condition_1 + 1)
		return nil
	else
		Events.UpdatePlayerTime:Fire(player.UserId, totalTime, 0)
		local _fn = player
		local _exp = PlayerAttributes.TotalWins
		local _condition_1 = player:GetAttribute(PlayerAttributes.TotalWins)
		if _condition_1 == nil then
			_condition_1 = 0
		end
		_fn:SetAttribute(_exp, _condition_1 + 1)
	end
	giveBadge(player, 2146411244)
	if cube:GetAttribute("destroyed_counter") == 0 then
		Events.SaySystemMessage:FireClient(player, `nice! you completed a pacifist run in: {formattedTime}`)
		giveBadge(player, 2146295992)
	else
		Events.SaySystemMessage:FireClient(player, `nice! you completed a normal run in: {formattedTime}`)
	end
	cube:SetAttribute("start_time", getTime() - totalTime)
	if totalTime < 210 then
		giveBadge(player, 2146538368)
	end
end)
Events.DestroyedPart.OnServerEvent:Connect(function(player, otherPart)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _condition = not cube
	if not _condition then
		local _otherPart = otherPart
		_condition = not (typeof(_otherPart) == "Instance")
		if not _condition then
			_condition = not otherPart:IsA("BasePart")
		end
	end
	if _condition then
		return nil
	end
	local _value = otherPart:GetAttribute("CAN_SHATTER")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		player:SetAttribute("didShatter", true)
		task.delay(10, function()
			if player.Parent == Players then
				player:SetAttribute("didShatter", nil)
			end
		end)
	end
	local _condition_1 = cube:GetAttribute("destroyed_counter")
	if _condition_1 == nil then
		_condition_1 = 0
	end
	local count = _condition_1 + 1
	cube:SetAttribute("destroyed_counter", count)
	if otherPart.Name == `part{player.UserId}` and getHammerTexture(player) == Accessories.HammerTexture.BuilderHammer then
		otherPart:SetAttribute("timer", 0)
	end
end)
Events.SayMessageRequest.OnServerEvent:Connect(function(player, message, channel)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _bubbleAttachment = cube
	if _bubbleAttachment ~= nil then
		_bubbleAttachment = _bubbleAttachment:FindFirstChild("BubbleOrigin")
	end
	local bubbleAttachment = _bubbleAttachment
	local _result = cube
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = not _result
	if not _condition then
		local _result_1 = bubbleAttachment
		if _result_1 ~= nil then
			_result_1 = _result_1:IsA("BasePart")
		end
		_condition = not _result_1
		if not _condition then
			local _message = message
			_condition = not (type(_message) == "string")
			if not _condition then
				local _channel = channel
				_condition = not (type(_channel) == "string")
			end
		end
	end
	if _condition then
		return nil
	end
	if startsWith(message, "/w ") or channel ~= "All" then
		return nil
	end
	for _, otherPlayer in Players:GetPlayers() do
		local filteredMessage = Chat:FilterStringAsync(message, player, otherPlayer)
		Events.ShowChatBubble:FireClient(otherPlayer, bubbleAttachment, filteredMessage)
	end
end)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end
Players.PlayerAdded:Connect(playerAdded)
Events.Reset.OnServerEvent:Connect(resetPlayer)
Events.ForceReset.Event:Connect(resetPlayer)
gravityFlipper.TouchEnded:Connect(function(otherPart)
	for _, player in Players:GetPlayers() do
		if otherPart.Name == `cube{player.UserId}` then
			local _value = player:GetAttribute("gravityFlipDebounce")
			if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
				player:SetAttribute(PlayerAttributes.GravityFlipDebounce, true)
				Events.FlipGravity:FireClient(player, true)
				task.delay(2, function()
					Events.FlipGravity:FireClient(player, false)
					player:SetAttribute(PlayerAttributes.GravityFlipDebounce, nil)
				end)
			end
			break
		end
	end
end)
RunService.Stepped:Connect(function()
	for _, player in Players:GetPlayers() do
		local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
		if cube then
			local _binding = convertStudsToMeters(cube.Position.Y - 1.9)
			local altitude = _binding[1]
			if altitude > 800 then
				if player:GetAttribute(PlayerAttributes.HasGravityBadge) == nil then
					player:SetAttribute(PlayerAttributes.HasGravityBadge, true)
					giveBadge(player, 1719451122385638)
					continue
				end
			elseif player:GetAttribute(PlayerAttributes.HasGravityBadge) ~= nil then
				player:SetAttribute(PlayerAttributes.HasGravityBadge, nil)
			end
			local _binding_1 = convertStudsToMeters(math.abs(cube.AssemblyLinearVelocity.X))
			local speed = _binding_1[1]
			if speed > 70 then
				if player:GetAttribute(PlayerAttributes.HasSpeedBadge) == nil then
					player:SetAttribute(PlayerAttributes.HasSpeedBadge, true)
					giveBadge(player, 2146687990)
				end
			else
				local _value = player:GetAttribute(PlayerAttributes.HasSpeedBadge)
				if _value ~= 0 and _value == _value and _value ~= "" and _value then
					player:SetAttribute(PlayerAttributes.HasSpeedBadge, nil)
				end
			end
		end
	end
end)
