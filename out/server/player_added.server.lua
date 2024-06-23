-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local BadgeService = _services.BadgeService
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local convertStudsToMeters = _utils.convertStudsToMeters
local PlayerAttributes = _utils.PlayerAttributes
local computeNameColor = _utils.computeNameColor
local Accessories = _utils.Accessories
local giveBadge = _utils.giveBadge
local getTime = _utils.getTime
local reloadAccessories = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "accessory_loader").reloadAccessories
local Admins = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "admins").Admins
local Events = {
	SetModifiersSetting = ReplicatedStorage:FindFirstChild("SetModifiersSetting"),
	AddRagdollCount = ReplicatedStorage:FindFirstChild("AddRagdollCount"),
	SetDeviceType = ReplicatedStorage:FindFirstChild("SetDeviceType"),
	FlipGravity = ReplicatedStorage:FindFirstChild("FlipGravity"),
	Reset = ReplicatedStorage:FindFirstChild("Reset"),
	LoadPlayerAccessories = ReplicatedStorage:FindFirstChild("LoadPlayerAccessories"),
	ForceReset = ReplicatedStorage:FindFirstChild("ForceReset"),
}
local mapFolder = Workspace:FindFirstChild("Map")
local trappedArea = mapFolder:FindFirstChild("trapped_area")
local cubeTemplate = ReplicatedStorage:FindFirstChild("Cube")
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
	local overheadGui = cube:FindFirstChild("OverheadGUI")
	local icons = overheadGui:FindFirstChild("Icons");
	(overheadGui:FindFirstChild("Username")).Text = `{player.DisplayName} (@{player.Name})`
	local device = player:GetAttribute("device")
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
	local _value = player:GetAttribute("modifiers")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		cube:SetAttribute("used_modifiers", true)
	end
	player:SetAttribute("total_time", nil)
	cube:SetAttribute("start_time", getTime())
	cube.Parent = Workspace
	local head = cube:FindFirstChild("Head")
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
		player:SetAttribute("finished", false)
	end
	while true do
		local _value_1 = player:GetAttribute("DATA_LOADED")
		if not not (_value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1) then
			break
		end
		task.wait()
	end
	local cubeColor = player:GetAttribute("CUBE_COLOR")
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
			player:SetAttribute("isNew", true)
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
		player:SetAttribute("finished", nil)
		local _value = player:GetAttribute("modifiers")
		if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
			cube:SetAttribute("used_modifiers", nil)
		end
		cube:SetAttribute("start_time", getTime())
	else
		createCube(player, false)
	end
	local _fn = player
	local _condition_1 = player:GetAttribute("totalRestarts")
	if _condition_1 == nil then
		_condition_1 = 0
	end
	_fn:SetAttribute("totalRestarts", _condition_1 + 1)
end
Events.SetModifiersSetting.OnServerEvent:Connect(function(player, isEnabled)
	local _isEnabled = isEnabled
	if not (type(_isEnabled) == "boolean") then
		return nil
	end
	player:SetAttribute("modifiers", isEnabled)
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
		player:SetAttribute("device", device)
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
	local _condition = player:GetAttribute("totalRagdolls")
	if _condition == nil then
		_condition = 0
	end
	_fn:SetAttribute("totalRagdolls", _condition + 1)
end)
Players.PlayerAdded:Connect(playerAdded)
Events.Reset.OnServerEvent:Connect(resetPlayer)
Events.ForceReset.Event:Connect(resetPlayer)
RunService.Stepped:Connect(function()
	for _, player in Players:GetPlayers() do
		local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
		if cube then
			local _binding = convertStudsToMeters(cube.Position.Y - 1.9)
			local altitude = _binding[1]
			if altitude > 800 then
				if player:GetAttribute("gravityBadge") == nil then
					player:SetAttribute("gravityBadge", true)
					giveBadge(player, 1719451122385638)
					continue
				end
			elseif player:GetAttribute("gravityBadge") ~= nil then
				player:SetAttribute("gravityBadge", nil)
			end
			local _binding_1 = convertStudsToMeters(math.abs(cube.AssemblyLinearVelocity.X))
			local speed = _binding_1[1]
			if speed > 70 then
				if player:GetAttribute("speedBadge") == nil then
					player:SetAttribute("speedBadge", true)
					giveBadge(player, 2146687990)
				end
			else
				local _value = player:GetAttribute("speedBadge")
				if _value ~= 0 and _value == _value and _value ~= "" and _value then
					player:SetAttribute("speedBadge", nil)
				end
			end
		end
	end
end)
