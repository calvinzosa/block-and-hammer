-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local TweenService = _services.TweenService
local RunService = _services.RunService
local StarterGui = _services.StarterGui
local Workspace = _services.Workspace
local Players = _services.Players
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local numLerp = _utils.numLerp
local getSetting = _utils.getSetting
local GameSetting = _utils.GameSetting
local getHammerTexture = _utils.getHammerTexture
local Accessories = _utils.Accessories
local isClientCube = _utils.isClientCube
local playSound = _utils.playSound
local randomFloat = _utils.randomFloat
local waitUntil = _utils.waitUntil
local tweenTypes = _utils.tweenTypes
local getCubeHat = _utils.getCubeHat
local convertStudsToMeters = _utils.convertStudsToMeters
local getTime = _utils.getTime
local Settings = _utils.Settings
local roundDecimalPlaces = _utils.roundDecimalPlaces
local getCubeTime = _utils.getCubeTime
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local screenGui = GUI:WaitForChild("ScreenGui")
local isSpectating = GUI:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local canMove = GUI:WaitForChild("can_move")
local mapFolder = Workspace:WaitForChild("Map")
local mudParts = mapFolder:WaitForChild("MudParts")
local effectsFolder = Workspace:WaitForChild("Effects")
local goalPart = mapFolder:WaitForChild("end_area")
local wallPlane = Workspace:WaitForChild("Wall")
local flippedGravity = ReplicatedStorage:WaitForChild("flipped_gravity")
local mouseVisual = Workspace:WaitForChild("MouseVisual")
local modifierDisablers = Workspace:WaitForChild("ForceDisableModifiers")
local cube = nil
local Events = {
	BuildingHammerPlace = ReplicatedStorage:WaitForChild("BuildingHammerPlace"),
	AddRagdollCount = ReplicatedStorage:WaitForChild("AddRagdollCount"),
	CompleteGame = ReplicatedStorage:WaitForChild("CompleteGame"),
	MakeReplayEvent = ReplicatedStorage:WaitForChild("MakeReplayEvent"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
	ClientRagdoll = ReplicatedStorage:WaitForChild("ClientRagdoll"),
	ClientCreateDebris = ReplicatedStorage:WaitForChild("ClientCreateDebris"),
}
local cooldowns = {
	explosiveHammer = false,
	shotgun = false,
	inverterHammer = false,
}
local actionNames = {
	BuildingHammer = {
		Place = "building_hammer-place",
		Switch = "building_hammer-switch",
	},
	GrapplingHammer = {
		Activate = "grappling_hammer-activate",
		Scroll = "grappling_hammer-scroll",
	},
	ExplosiveHammer = {
		Explode = "explosive_hammer-explode",
	},
	Shotgun = {
		Fire = "shotgun-fire",
	},
	InverterHammer = {
		Invert = "inverter_hammer-invert",
	},
}
local abilityObjects = {
	grapplingHammerRope = nil,
}
local wasModifiersEnabled = false
local previousModifiersCheck = true
local ragdollTime = 0
local intensity = 0
local function formatDebugWorldNumber(num)
	local integer, decimal = math.modf(math.abs(num))
	return string.format("%s%05d%s", if integer >= 0 then "+" else "-", integer, string.sub(string.format("%.3f", decimal), 2))
end
local function mouseRaycast()
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { wallPlane }
	local resultA = Workspace:Raycast(ray.Origin, ray.Direction.Unit * 512, params)
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { mouseVisual, modifierDisablers, effectsFolder }
	local resultB = Workspace:Raycast(ray.Origin, ray.Direction.Unit * 512, params)
	local _result = resultA
	if _result ~= nil then
		_result = _result.Position
	end
	local _result_1 = resultB
	if _result_1 ~= nil then
		_result_1 = _result_1.Position
	end
	local _result_2 = resultB
	if _result_2 ~= nil then
		_result_2 = _result_2.Instance
	end
	return { _result, _result_1, _result_2 ~= wallPlane }
end
local function getBuildPosition(headCFrame)
	local offset = Vector3.new(0, 0, 0)
	local _condition = player:GetAttribute("build_type")
	if _condition == nil then
		_condition = 0
	end
	local buildType = _condition
	if buildType == 0 then
		local _lookVector = headCFrame.LookVector
		local _vector3 = Vector3.new(1, 2, 1)
		offset = _lookVector * _vector3
	elseif buildType == 1 then
		local _lookVector = headCFrame.LookVector
		local _vector3 = Vector3.new(2, 1, 1)
		offset = _lookVector * _vector3
	end
	local _position = headCFrame.Position
	local _offset = offset
	return _position + _offset
end
local function getBuildSize(buildType)
	local size = Vector3.zero
	if buildType == 0 then
		size = Vector3.new(7, 1, 7)
	elseif buildType == 1 then
		size = Vector3.new(1, 7, 7)
	end
	return size
end
local function updateModifiers()
	for hammer, actions in pairs(actionNames) do
		for abilityName, actionName in pairs(actions) do
			ContextActionService:UnbindAction(actionName)
		end
	end
	if abilityObjects.grapplingHammerRope ~= nil then
		abilityObjects.grapplingHammerRope:Destroy()
		abilityObjects.grapplingHammerRope = nil
	end
	local currentHammer = getHammerTexture()
	if getSetting(GameSetting.Modifiers) then
		if currentHammer == Accessories.HammerTexture.BuilderHammer then
			local function place(action, state, input)
				if not cube then
					return nil
				end
				if action == actionNames.BuildingHammer.Place then
					local _condition = state == Enum.UserInputState.Begin
					if _condition then
						local _value = player:GetAttribute("place_cooldown")
						_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
					end
					if _condition then
						local head = cube:FindFirstChild("Head")
						local _result = head
						if _result ~= nil then
							_result = _result:IsA("BasePart")
						end
						if not _result then
							return nil
						end
						head.AssemblyAngularVelocity = Vector3.zero
						local _fn = Events.BuildingHammerPlace
						local _exp = getBuildPosition(head.CFrame)
						local _condition_1 = player:GetAttribute("build_type")
						if _condition_1 == nil then
							_condition_1 = 0
						end
						_fn:FireServer(_exp, _condition_1)
						player:SetAttribute("place_cooldown", true)
						task.delay(0.4, function()
							return player:SetAttribute("place_cooldown", nil)
						end)
					end
				end
			end
			local function switchType(action, state, input)
				if not cube then
					return nil
				end
				if action == actionNames.BuildingHammer.Switch then
					if state == Enum.UserInputState.Begin then
						local _condition = (player:GetAttribute("build_type"))
						if _condition == nil then
							_condition = 0
						end
						local newType = _condition + 1
						if newType > 1 then
							newType = 0
						end
						player:SetAttribute("build_type", newType)
					end
				end
			end
			ContextActionService:BindAction(actionNames.BuildingHammer.Place, place, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(actionNames.BuildingHammer.Place, "Place")
			ContextActionService:BindAction(actionNames.BuildingHammer.Switch, switchType, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(actionNames.BuildingHammer.Switch, "switch")
		elseif currentHammer == Accessories.HammerTexture.GrapplingHammer then
			local function activate(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if abilityObjects.grapplingHammerRope then
					abilityObjects.grapplingHammerRope:Destroy()
					abilityObjects.grapplingHammerRope = nil
				end
				if action == actionNames.GrapplingHammer.Activate then
					local head = cube:FindFirstChild("Head")
					local axisLock = Workspace:FindFirstChild("AxisLock")
					local _rightAttachment = head
					if _rightAttachment ~= nil then
						_rightAttachment = _rightAttachment:FindFirstChild("RightAttachment")
					end
					local rightAttachment = _rightAttachment
					local _result = head
					if _result ~= nil then
						_result = _result:IsA("BasePart")
					end
					local _condition = not _result
					if not _condition then
						local _result_1 = axisLock
						if _result_1 ~= nil then
							_result_1 = _result_1:IsA("BasePart")
						end
						_condition = not _result_1
						if not _condition then
							local _result_2 = rightAttachment
							if _result_2 ~= nil then
								_result_2 = _result_2:IsA("Attachment")
							end
							_condition = not _result_2
						end
					end
					if _condition then
						return nil
					end
					if state == Enum.UserInputState.Begin then
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						local filter = {}
						for _, object in Workspace:GetChildren() do
							if object ~= Workspace:FindFirstChild("Map") and object ~= Workspace:FindFirstChild("NonBreakable") then
								table.insert(filter, object)
							end
						end
						local propellers = Workspace:FindFirstChild("Propellers")
						if propellers then
							for _, propeller in propellers:GetChildren() do
								local hitbox = propeller:FindFirstChild("Hitbox")
								if hitbox then
									table.insert(filter, hitbox)
								end
							end
						end
						params.FilterDescendantsInstances = filter
						local result = Workspace:Raycast(head.Position, head.CFrame.LookVector * 6144, params)
						if not result then
							return nil
						end
						local target = Instance.new("Attachment")
						target.WorldCFrame = CFrame.new(result.Position)
						target.Parent = axisLock
						local rope = Instance.new("RopeConstraint")
						rope.Visible = true
						rope.Length = math.max(result.Distance, 1)
						rope.Attachment0 = rightAttachment
						rope.Attachment1 = target
						rope.Parent = head
						abilityObjects.grapplingHammerRope = rope
						head.Massless = false
						playSound("grapple", {
							PlaybackSpeed = randomFloat(0.9, 1.1),
						})
					elseif state == Enum.UserInputState.End then
						head.Massless = true
					end
				end
			end
			local function scroll(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if action == actionNames.GrapplingHammer.Scroll then
					if state == Enum.UserInputState.Change then
						local head = cube:FindFirstChild("Head")
						local rope = abilityObjects.grapplingHammerRope
						if not head or not head:IsA("BasePart") or not rope or not rope:IsA("RopeConstraint") then
							return nil
						end
						local delta = math.sign(input.Position.Z)
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
							delta *= 10
						end
						local newLength = math.clamp(rope.Length + delta * 10, 1, 6144)
						TweenService:Create(rope, tweenTypes.linear.short, {
							Length = newLength,
						}):Play()
					end
				end
			end
			ContextActionService:BindAction(actionNames.GrapplingHammer.Activate, activate, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(actionNames.GrapplingHammer.Activate, "Grapple")
			ContextActionService:BindAction(actionNames.GrapplingHammer.Activate, scroll, false, Enum.UserInputType.MouseWheel)
		elseif currentHammer == Accessories.HammerTexture.Shotgun then
			local function fire(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if action == actionNames.Shotgun.Fire and not cooldowns.shotgun then
					if state == Enum.UserInputState.Begin then
						local arm = cube:FindFirstChild("Arm")
						local shotgun = cube:FindFirstChild("Shotgun")
						local _result = arm
						if _result ~= nil then
							_result = _result:IsA("BasePart")
						end
						local _condition = not _result
						if not _condition then
							local _result_1 = shotgun
							if _result_1 ~= nil then
								_result_1 = _result_1:IsA("Model")
							end
							_condition = not _result_1
						end
						if _condition then
							return nil
						end
						cooldowns.shotgun = true
						task.delay(1.5, function()
							cooldowns.shotgun = false
							return cooldowns.shotgun
						end)
						local velocity = cube.AssemblyAngularVelocity
						local _rightVector = arm.CFrame.RightVector
						local _arg0 = Workspace.Gravity * -0.7
						local force = _rightVector * _arg0
						cube.AssemblyAngularVelocity = velocity + force
						playSound("shotgun_fire")
						local params = RaycastParams.new()
						params.FilterDescendantsInstances = { cube }
						local _fn = Workspace
						local _position = arm.Position
						local _arg0_1 = arm.CFrame.RightVector * 4
						local result = _fn:Raycast(_position + _arg0_1, arm.CFrame.RightVector * 512, params)
						if result then
							local part = result.Instance
							Events.ClientCreateDebris:Fire(result.Normal * 30, result.Position, part, 1, true)
							local _value = part:GetAttribute("CAN_BREAK")
							if _value ~= 0 and _value == _value and _value ~= "" and _value then
								part:SetAttribute("FORCE_BREAK", true)
							else
								local _value_1 = part:GetAttribute("CAN_SHATTER")
								if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
									part:SetAttribute("FORCE_SHATTER", true)
								end
							end
							local bulletTrail = Instance.new("Part")
							bulletTrail.Anchored = true
							bulletTrail.CanCollide = false
							bulletTrail.CFrame = CFrame.lookAt(arm.Position:Lerp(result.Position, 0.5), result.Position)
							local _position_1 = arm.Position
							local _position_2 = result.Position
							bulletTrail.Size = Vector3.new(0.1, 0.1, (_position_1 - _position_2).Magnitude)
							bulletTrail.Color = Color3.fromRGB(255, 255, 0)
							bulletTrail.Material = Enum.Material.Neon
							bulletTrail.Parent = effectsFolder
							task.delay(0.1, function()
								return bulletTrail:Destroy()
							end)
						end
						local _image1 = shotgun:FindFirstChild("Flash1")
						if _image1 ~= nil then
							_image1 = _image1:FindFirstChild("BillboardGui")
							if _image1 ~= nil then
								_image1 = _image1:FindFirstChild("ImageLabel")
							end
						end
						local image1 = _image1
						local _image2 = shotgun:FindFirstChild("Flash2")
						if _image2 ~= nil then
							_image2 = _image2:FindFirstChild("BillboardGui")
							if _image2 ~= nil then
								_image2 = _image2:FindFirstChild("ImageLabel")
							end
						end
						local image2 = _image2
						local _result_1 = image1
						if _result_1 ~= nil then
							_result_1 = _result_1:IsA("ImageLabel")
						end
						local _condition_1 = not _result_1
						if not _condition_1 then
							local _result_2 = image2
							if _result_2 ~= nil then
								_result_2 = _result_2:IsA("ImageLabel")
							end
							_condition_1 = not _result_2
						end
						if _condition_1 then
							return nil
						end
						image1.Visible = true
						image2.Visible = true
						task.delay(0.1, function()
							image1.Visible = false
							image2.Visible = false
						end)
					end
				end
			end
			ContextActionService:BindAction(actionNames.Shotgun.Fire, fire, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(actionNames.Shotgun.Fire, "Fire")
		elseif currentHammer == Accessories.HammerTexture.ExplosiveHammer then
			local function explode(name, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if name == actionNames.ExplosiveHammer.Explode and not cooldowns.explosiveHammer then
					if state == Enum.UserInputState.Begin then
						local head = cube:FindFirstChild("Head")
						local _result = head
						if _result ~= nil then
							_result = _result:IsA("BasePart")
						end
						if not _result then
							return nil
						end
						local didSet = false
						cooldowns.explosiveHammer = true
						task.delay(2, function()
							if not didSet then
								didSet = true
								cooldowns.explosiveHammer = false
							end
						end)
						task.spawn(function()
							waitUntil(function()
								return not cooldowns.explosiveHammer
							end)
							if not didSet then
								TweenService:Create(head, TweenInfo.new(0), {
									Color = Color3.fromRGB(255, 0, 0),
								})
							end
							didSet = true
						end)
						local velocity = cube.AssemblyAngularVelocity
						local _position = cube.Position
						local _position_1 = head.Position
						local force = (_position - _position_1).Unit * 600
						cube.AssemblyAngularVelocity = velocity + force
						local explosion = Instance.new("Explosion")
						explosion.Position = head.Position
						explosion.BlastRadius = 0
						explosion.BlastPressure = 0
						explosion.Parent = Workspace:FindFirstChild("Effects")
						do
							local i = 0
							local _shouldIncrement = false
							while true do
								if _shouldIncrement then
									i += 1
								else
									_shouldIncrement = true
								end
								if not (i < 15) then
									break
								end
								playSound("explosion", {
									PlaybackSpeed = randomFloat(0.9, 1),
									Volume = head.AssemblyAngularVelocity.Magnitude / 50,
								})
							end
						end
					end
				end
			end
			ContextActionService:BindAction(actionNames.ExplosiveHammer.Explode, explode, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(actionNames.ExplosiveHammer.Explode, "💥")
		elseif currentHammer == Accessories.HammerTexture.InverterHammer then
			local function invert(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if action == actionNames.InverterHammer.Invert and not cooldowns.inverterHammer then
					if state == Enum.UserInputState.Begin then
						local head = cube:FindFirstChild("Head")
						local arm = cube:FindFirstChild("Arm")
						local _result = head
						if _result ~= nil then
							_result = _result:IsA("BasePart")
						end
						local _condition = not _result
						if not _condition then
							local _result_1 = arm
							if _result_1 ~= nil then
								_result_1 = _result_1:IsA("BasePart")
							end
							_condition = not _result_1
						end
						if _condition then
							return nil
						end
						cooldowns.inverterHammer = true
						task.delay(0.5, function()
							cooldowns.inverterHammer = false
							return cooldowns.inverterHammer
						end)
						arm.Color = Color3.fromRGB(0, 0, 0)
						TweenService:Create(arm, tweenTypes.linear.short, {
							Color = Color3.fromRGB(7, 114, 172),
						}):Play()
						flippedGravity.Value = not flippedGravity.Value
						ContextActionService:SetTitle(actionNames.InverterHammer.Invert, if flippedGravity.Value then "⬇️" else "⬆️")
						playSound("invert")
					end
				end
			end
			ContextActionService:BindAction(actionNames.InverterHammer.Invert, invert, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(actionNames.InverterHammer.Invert, "⬆️")
		end
	end
end
task.spawn(updateModifiers)
player.AttributeChanged:Connect(function(attr)
	if attr == "hammer_Texture" or attr == "client_settings_json" then
		updateModifiers()
	end
end)
Events.ClientRagdoll.Event:Connect(function(seconds)
	local previousRagdollTime = ragdollTime
	ragdollTime = seconds
	local currentHat = getCubeHat()
	if currentHat ~= Accessories.CubeHat.InstantGyro and previousRagdollTime == 0 then
		Events.AddRagdollCount:FireServer()
	end
end)
RunService.RenderStepped:Connect(function(dt)
	local _value = player:GetAttribute("in_main_menu")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return nil
	end
	local currentHammer = getHammerTexture()
	local cubeHat = getCubeHat()
	local _condition = (Workspace:GetAttribute("default_gravity"))
	if _condition == nil then
		_condition = 0
	end
	Workspace.Gravity = _condition
	if getSetting(GameSetting.Modifiers) then
		if cubeHat == Accessories.CubeHat.AstronautHelmet then
			Workspace.Gravity = 5
		else
			local _value_1 = currentHammer == Accessories.HammerTexture.Hammer404 or player:GetAttribute("ERROR_LAND")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				Workspace.Gravity /= 2
			end
		end
	end
	local spectatingCube = nil
	local otherPlayer = Players:FindFirstChild(spectatePlayer.Value)
	local _condition_1 = isSpectating.Value
	if _condition_1 then
		local _result = otherPlayer
		if _result ~= nil then
			_result = _result:IsA("Player")
		end
		_condition_1 = _result
	end
	if _condition_1 then
		local otherCube = Workspace:FindFirstChild(`cube{otherPlayer.UserId}`)
		local _result = otherCube
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if _result then
			spectatingCube = otherCube
		end
	end
	if not cube then
		local localCube = Workspace:FindFirstChild(`cube{player.UserId}`)
		local _result = localCube
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if not _result then
			return nil
		end
		cube = localCube
	end
	if cube then
		local head = cube:FindFirstChild("Head")
		local arm = cube:FindFirstChild("Arm")
		local centerAttachment = cube:FindFirstChild("CenterAttachment")
		local alignOrientation = cube:FindFirstChild("AlignOrientation")
		local _armAlignPosition = arm
		if _armAlignPosition ~= nil then
			_armAlignPosition = _armAlignPosition:FindFirstChild("AlignPosition")
		end
		local armAlignPosition = _armAlignPosition
		local _armAlignOrientation = arm
		if _armAlignOrientation ~= nil then
			_armAlignOrientation = _armAlignOrientation:FindFirstChild("AlignOrientation")
		end
		local armAlignOrientation = _armAlignOrientation
		local startTime = cube:GetAttribute("start_time")
		local armCFrame = cube:FindFirstChild("ArmCFrame")
		local armRotation = cube:FindFirstChild("ArmRotation")
		local _result = head
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition_2 = not _result
		if not _condition_2 then
			local _result_1 = arm
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition_2 = not _result_1
			if not _condition_2 then
				local _result_2 = centerAttachment
				if _result_2 ~= nil then
					_result_2 = _result_2:IsA("Attachment")
				end
				_condition_2 = not _result_2
			end
		end
		if _condition_2 then
			return nil
		end
		local _result_1 = alignOrientation
		if _result_1 ~= nil then
			_result_1 = _result_1:IsA("AlignOrientation")
		end
		local _condition_3 = not _result_1
		if not _condition_3 then
			local _result_2 = armAlignPosition
			if _result_2 ~= nil then
				_result_2 = _result_2:IsA("AlignPosition")
			end
			_condition_3 = not _result_2
			if not _condition_3 then
				local _result_3 = armAlignOrientation
				if _result_3 ~= nil then
					_result_3 = _result_3:IsA("AlignOrientation")
				end
				_condition_3 = not _result_3
			end
		end
		if _condition_3 then
			return nil
		end
		local _result_2 = armCFrame
		if _result_2 ~= nil then
			_result_2 = _result_2:IsA("Attachment")
		end
		local _condition_4 = not _result_2
		if not _condition_4 then
			local _result_3 = armRotation
			if _result_3 ~= nil then
				_result_3 = _result_3:IsA("Attachment")
			end
			_condition_4 = not _result_3
		end
		if _condition_4 then
			return nil
		end
		if not (type(startTime) == "number") then
			return nil
		end
		local _binding = convertStudsToMeters(cube.Position.Y - 1.9)
		local altitude = _binding[1]
		local windForce = cube:FindFirstChild("WindForce")
		local _result_3 = windForce
		if _result_3 ~= nil then
			_result_3 = _result_3:IsA("VectorForce")
		end
		if _result_3 then
			if altitude > 400 and altitude < 500 then
				windForce.Force = Vector3.new(750, 0, 0)
			else
				windForce.Force = Vector3.zero
			end
		end
		if not getSetting(GameSetting.Modifiers) and flippedGravity.Value then
			flippedGravity.Value = false
		end
		if getTime() - startTime < 0.1 then
			ragdollTime = 0
		end
		head.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.6, 0, 100, 1)
		if getSetting(GameSetting.Modifiers) then
			if currentHammer == Accessories.HammerTexture.IcyHammer then
				head.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0, 0, 100, 1)
			end
		end
		cube.CollisionGroup = "clientCube"
		for _, descendant in cube:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.CollisionGroup == "cubes" then
				descendant.CollisionGroup = "clientCube"
			end
		end
		if ragdollTime > 0 and (not getSetting(GameSetting.Modifiers) or cubeHat ~= Accessories.CubeHat.InstantGyro) then
			alignOrientation.Enabled = false
			arm.CanCollide = true
			arm.Massless = false
			armAlignPosition.Enabled = false
			armAlignOrientation.Enabled = false
		else
			alignOrientation.Enabled = true
			arm.CanCollide = false
			arm.Massless = true
			armAlignPosition.Enabled = true
			armAlignOrientation.Enabled = true
		end
		ragdollTime = math.max(ragdollTime - dt, 0)
		cube:SetAttribute("ragdollTime", ragdollTime)
		local _condition_5 = (cube:GetAttribute("transparency"))
		if _condition_5 == nil then
			_condition_5 = 0
		end
		local cubeTransparency = _condition_5
		local _condition_6 = (cube:GetAttribute("hammerTransparency"))
		if _condition_6 == nil then
			_condition_6 = 0
		end
		local hammerTransparency = _condition_6
		cube.Transparency = numLerp(cube.Transparency, cubeTransparency, dt * 15)
		for _, part in { head, arm } do
			local alpha = dt * 15
			local _value_1 = cube:GetAttribute("instantHammerTransparency")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				alpha = 1
				cube:SetAttribute("instantHammerTransparent", nil)
			end
			part.Transparency = numLerp(part.Transparency, hammerTransparency, alpha)
			for _1, descendant in part:GetDescendants() do
				if descendant:IsA("Decal") or descendant:IsA("Texture") then
					descendant.Transparency = part.Transparency
				end
			end
		end
		local _condition_7 = (player:GetAttribute("client_shake_intensity"))
		if _condition_7 == nil then
			_condition_7 = 0
		end
		intensity = _condition_7
		if isSpectating.Value and otherPlayer then
			intensity = 0
			local _result_4 = screenGui:FindFirstChild("SpectatingGUI")
			if _result_4 ~= nil then
				_result_4 = _result_4:FindFirstChild("PlayerName")
			end
			local label = _result_4
			if label then
				label.Text = otherPlayer.DisplayName
			end
		end
		if flippedGravity.Value then
			alignOrientation.CFrame = CFrame.fromOrientation(0, 0, math.pi)
			if not cube:FindFirstChild("upsidedown_gravity") then
				local force = Instance.new("VectorForce")
				force.RelativeTo = Enum.ActuatorRelativeTo.World
				force.Attachment0 = centerAttachment
				force.Name = "upsidedown_gravity"
				force.Parent = cube
			end
			local force = cube:FindFirstChild("upsidedown_gravity")
			force.Force = Vector3.new(0, Workspace.Gravity * cube.AssemblyMass * 2, 0)
		else
			alignOrientation.CFrame = CFrame.fromOrientation(0, 0, 0)
			local _result_4 = cube:FindFirstChild("upsidedown_gravity")
			if _result_4 ~= nil then
				_result_4:Destroy()
			end
		end
		if time() > 1 then
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Include
			params.FilterDescendantsInstances = { modifierDisablers }
			if not wasModifiersEnabled and previousModifiersCheck then
				updateModifiers()
				previousModifiersCheck = false
			elseif wasModifiersEnabled and not previousModifiersCheck then
				updateModifiers()
				previousModifiersCheck = true
			end
			wasModifiersEnabled = Settings.modifiers
			if #Workspace:GetPartsInPart(cube, params) > 0 then
				wasModifiersEnabled = false
			end
		end
		local cubePosition = cube.Position
		local cubeVelocity = cube.AssemblyAngularVelocity
		if spectatingCube then
			cubePosition = spectatingCube.Position
			cubeVelocity = spectatingCube.AssemblyAngularVelocity
		end
		local _cubePosition = cubePosition
		local _vector3 = Vector3.new((if math.random() < 0.5 then 1 else -1) * intensity, (if math.random() < 0.5 then 1 else -1) * intensity, 0)
		local cameraPosition = _cubePosition + _vector3
		local velocity = math.clamp(cubeVelocity.Magnitude - 50, 0, 100) / 15
		local up = if flippedGravity.Value then Vector3.yAxis * (-1) else Vector3.yAxis
		local zoom = 37.5
		if getSetting(GameSetting.Modifiers) then
			if currentHammer == Accessories.HammerTexture.LongHammer then
				zoom = 70
			elseif currentHammer == Accessories.HammerTexture.GrapplingHammer then
				zoom = 50
			elseif currentHammer == Accessories.HammerTexture.ExplosiveHammer then
				zoom = 65
			end
		end
		local _fn = CFrame
		local _vector3_1 = Vector3.new(0, 0, zoom + velocity)
		local cameraCFrame = _fn.lookAt(cameraPosition - _vector3_1, cameraPosition, up)
		local start = cube.Position
		local goal = cameraCFrame.Position
		local distance = (start - goal).Magnitude
		-- let part = Workspace.FindFirstChild('ray_part') as BasePart | undefined;
		-- if (!part) {
		-- 	part = new Instance('Part');
		-- 	part.CanCollide = false;
		-- 	part.Anchored = true;
		-- 	part.Transparency = 1;
		-- 	part.Name = 'ray_part';
		-- 	part.Parent = Workspace;
		-- }
		-- part.Position = new Vector3(start.X, start.Y, distance / -2);
		-- part.Size = new Vector3(10, 10, distance);
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { mapFolder }
		for _, obstructingPart in Workspace:GetPartBoundsInBox(CFrame.new(start.X, start.Y, distance / -2), Vector3.new(10, 10, distance), params) do
			local _value_1 = obstructingPart:GetAttribute("CAMERA_TRANSPARENT")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				obstructingPart.LocalTransparencyModifier = numLerp(obstructingPart.LocalTransparencyModifier, 0.9, dt * 5)
				TweenService:Create(obstructingPart, tweenTypes.linear.short, {
					LocalTransparencyModifier = 0,
				}):Play()
			end
		end
		local replayGui = GUI:FindFirstChild("ReplayGui")
		local _result_4 = replayGui
		if _result_4 ~= nil then
			_result_4 = _result_4:IsA("ScreenGui")
		end
		local _condition_8 = not _result_4
		if not _condition_8 then
			_condition_8 = not replayGui.Enabled
		end
		if _condition_8 then
			local _position = camera.CFrame.Position
			local _position_1 = cameraCFrame.Position
			if (_position - _position_1).Magnitude > 50 then
				camera.CFrame = camera.CFrame:Lerp(cameraCFrame, 0.5)
			else
				camera.CFrame = camera.CFrame:Lerp(cameraCFrame, math.clamp(dt * 15, 0, 1))
			end
		end
		if camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
		end
		if isSpectating.Value then
			return nil
		end
		player:SetAttribute("client_shake_intensity", math.max(intensity - dt * 3, 0))
		wallPlane.Position = cubePosition
		local _binding_1 = mouseRaycast()
		local position = _binding_1[1]
		local nonFiltered = _binding_1[2]
		local hitPart = _binding_1[3]
		if not (typeof(position) == "Vector3") or not (typeof(nonFiltered) == "Vector3") then
			return nil
		end
		if screenGui.Enabled then
			mouseVisual.Position = nonFiltered
			local highlight = mouseVisual:FindFirstChild("Highlight")
			if highlight then
				highlight.FillTransparency = if hitPart then 0 else 1
			end
		end
		local hammerAngle = math.atan2(position.Y - cube.Position.Y, position.X - cube.Position.X)
		local hammerDistance = (cube.Position - position).Magnitude
		armAlignPosition.MaxForce = 12500
		armAlignPosition.Responsiveness = 80
		armAlignOrientation.Responsiveness = 200
		local maxRange = 13
		if getSetting(GameSetting.Modifiers) then
			if currentHammer == Accessories.HammerTexture.LongHammer then
				armAlignPosition.MaxForce = 25000
				maxRange = 40
			elseif currentHammer == Accessories.HammerTexture.Hammer404 then
				armAlignPosition.MaxForce = 6250
				armAlignPosition.Responsiveness = 40
				armAlignOrientation.Responsiveness = 100
				for _, effect in effectsFolder:GetDescendants() do
					if effect:IsA("ParticleEmitter") then
						effect.TimeScale *= 0.5
					end
				end
			elseif currentHammer == Accessories.HammerTexture.Mallet then
				armAlignPosition.MaxForce = 18750
				maxRange = 8.5
			elseif currentHammer == Accessories.HammerTexture.BuilderHammer then
				maxRange = 15
				local _value_1 = player:GetAttribute("place_cooldown")
				if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
					head.Color = Color3.fromRGB(255, 128, 128)
				else
					head.Color = Color3.fromRGB(26, 26, 26)
				end
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Position = getBuildPosition(head.CFrame)
				local _condition_9 = (player:GetAttribute("build_type"))
				if _condition_9 == nil then
					_condition_9 = 0
				end
				part.Size = getBuildSize(_condition_9)
				part.Transparency = 0.7
				part.Color = Color3.fromRGB(0, 0, 0)
				part.TopSurface = Enum.SurfaceType.Smooth
				part.BottomSurface = Enum.SurfaceType.Smooth
				part.Parent = Workspace
				task.spawn(function()
					RunService.RenderStepped:Wait()
					part:Destroy()
				end)
			elseif currentHammer == Accessories.HammerTexture.GodsHammer then
				armAlignPosition.MaxForce = math.huge
				armAlignPosition.Responsiveness = math.huge
			elseif currentHammer == Accessories.HammerTexture.RealGoldenHammer then
				armAlignPosition.MaxForce = 560
			elseif currentHammer == Accessories.HammerTexture.Platform then
				head.CollisionGroup = "cubes"
				maxRange = 18
			end
		end
		local _value_1 = player:GetAttribute("ERROR_LAND")
		if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
			armAlignPosition.MaxForce = 6250
			armAlignPosition.Responsiveness = 40
			armAlignOrientation.Responsiveness = 100
			for _, effect in effectsFolder:GetDescendants() do
				if effect:IsA("ParticleEmitter") then
					effect.TimeScale *= 0.5
				end
			end
		end
		local rangeDispaly = cube:FindFirstChild("Range")
		local _result_5 = rangeDispaly
		if _result_5 ~= nil then
			_result_5 = _result_5:IsA("BasePart")
		end
		if _result_5 then
			rangeDispaly.Size = Vector3.new(0.001, maxRange * 2, maxRange * 2)
		end
		local distanceLimit = cube:FindFirstChild("DistanceLimit")
		local _result_6 = distanceLimit
		if _result_6 ~= nil then
			_result_6 = _result_6:IsA("RopeConstraint")
		end
		if _result_6 then
			distanceLimit.Length = maxRange
		end
		local actualHammerDistance = math.min(hammerDistance, maxRange)
		local _position = cube.Position
		local _vector3_2 = Vector3.new(math.cos(hammerAngle) * actualHammerDistance, math.sin(hammerAngle) * actualHammerDistance)
		local hammerPosition = _position + _vector3_2
		local plane = Vector3.new(1, 1, 0)
		if canMove.Value then
			local rotationOffset = CFrame.fromOrientation(math.pi / 2, math.pi / 2, 0)
			local mouse = UserInputService:GetMouseLocation()
			for _, gui in StarterGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y) do
				if gui.Name == "ContextButtonFrame" then
					return nil
				end
			end
			armCFrame.WorldCFrame = CFrame.lookAt(hammerPosition * plane, cube.Position * plane, Vector3.zAxis)
			if currentHammer == Accessories.HammerTexture.Platform then
				armRotation.WorldCFrame = CFrame.fromOrientation(0, 0, math.pi / 2)
			else
				armRotation.WorldCFrame = CFrame.lookAt(cube.Position * plane, head.Position * plane, Vector3.zAxis) * rotationOffset
			end
		end
		local debugInfo = screenGui:FindFirstChild("DebugInfo")
		if debugInfo and debugInfo.Visible then
			local left = debugInfo:FindFirstChild("Left")
			local right = debugInfo:FindFirstChild("Right");
			(left:FindFirstChild("FPS")).Text = string.format("FPS: %.3f", 1 / dt);
			(left:FindFirstChild("CPosition")).Text = string.format("Position: X%s Y%s Z%s", formatDebugWorldNumber(roundDecimalPlaces(cube.Position.X)), formatDebugWorldNumber(roundDecimalPlaces(cube.Position.Y)), formatDebugWorldNumber(roundDecimalPlaces(cube.Position.Z)));
			(left:FindFirstChild("CVelocity")).Text = string.format("Velocity: X%s Y%s Z%s", formatDebugWorldNumber(roundDecimalPlaces(cube.AssemblyLinearVelocity.X)), formatDebugWorldNumber(roundDecimalPlaces(cube.AssemblyLinearVelocity.Y)), formatDebugWorldNumber(roundDecimalPlaces(cube.AssemblyLinearVelocity.Z)));
			(left:FindFirstChild("RagdollTime")).Text = string.format("RagdollTime: %.3fs", ragdollTime);
			(left:FindFirstChild("CameraShake")).Text = string.format("CameraShake: %.3fs studs", intensity)
			local totalSounds = 0
			for _, sound in Workspace:GetChildren() do
				if sound:IsA("Sound") and sound.Volume > 0 and sound.IsPlaying then
					totalSounds += 1
				end
			end
			(left:FindFirstChild("TotalSounds")).Text = string.format("Total Sounds Playing: %d", totalSounds)
			local _fn_1 = string
			local _condition_9 = (cube:GetAttribute("destroyed_counter"))
			if _condition_9 == nil then
				_condition_9 = 0
			end
			(left:FindFirstChild("DestroyedCounter")).Text = _fn_1.format("Destroyed Counter: %d", _condition_9)
			local unanchoredParts = 0
			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("BasePart") and not descendant:IsA("Terrain") and not descendant.Anchored then
					unanchoredParts += 1
				end
			end
			(left:FindFirstChild("UnanchoredParts")).Text = string.format("Unanchored Parts: %d", unanchoredParts)
			if cube.AssemblyAngularVelocity.Magnitude > 0 then
				(right:FindFirstChild("VelocityDisplay")).Rotation = 180 + math.deg(math.atan2(cube.AssemblyLinearVelocity.Y, cube.AssemblyAngularVelocity.X));
				(right:FindFirstChild("VelocityDisplay")).Visible = true
			else
				(right:FindFirstChild("VelocityDisplay")).Visible = false
			end
			(right:FindFirstChild("HammerDisplay")).Rotation = math.deg(math.atan2(cube.Position.Y - head.Position.Y, cube.Position.X - head.Position.X))
		end
	end
end)
goalPart.Touched:Connect(function(otherPart)
	local _condition = otherPart:GetAttribute("isCube")
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		_condition = isClientCube(otherPart)
		if _condition then
			local _value = player:GetAttribute("finished")
			_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
		end
	end
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		player:SetAttribute("finished", true)
		local _binding = getCubeTime(otherPart)
		local totalTime = _binding[1]
		print(`Completed game in {totalTime} seconds`)
		Events.CompleteGame:FireServer(totalTime)
		Events.MakeReplayEvent:Fire(string.format("win,%d", totalTime * 1000))
	end
end)
Events.ClientReset.Event:Connect(function()
	player:SetAttribute("finished", nil)
	for key in pairs(cooldowns) do
		cooldowns[key] = false
	end
	ragdollTime = 0
end)
Events.StartClientTutorial.Event:Connect(function()
	task.delay(0.1, updateModifiers)
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.KeyCode == Enum.KeyCode.I and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local debugInfo = screenGui:FindFirstChild("DebugInfo")
		if debugInfo then
			debugInfo.Visible = not debugInfo.Visible
		end
	end
end)
RunService.Heartbeat:Connect(function(step)
	local _value = not cube or player:GetAttribute("ERROR_LAND")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return nil
	end
	local slowdownFactor = math.clamp(1 - (step * 40), 0.01, 1)
	local touching = { cube, cube:FindFirstChild("Head") }
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { mudParts }
	for _, part in touching do
		local _result = part
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if not _result then
			return nil
		end
		if #Workspace:GetPartsInPart(part, params) > 0 then
			part.AssemblyLinearVelocity = part.AssemblyLinearVelocity * slowdownFactor
		end
	end
end)
