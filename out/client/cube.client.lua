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
local convertStudsToMeters = _utils.convertStudsToMeters
local roundDecimalPlaces = _utils.roundDecimalPlaces
local getHammerTexture = _utils.getHammerTexture
local PlayerAttributes = _utils.PlayerAttributes
local getTimeUnits = _utils.getTimeUnits
local isClientCube = _utils.isClientCube
local GameSetting = _utils.GameSetting
local Accessories = _utils.Accessories
local randomFloat = _utils.randomFloat
local getCubeTime = _utils.getCubeTime
local getCubeHat = _utils.getCubeHat
local getSetting = _utils.getSetting
local tweenTypes = _utils.tweenTypes
local playSound = _utils.playSound
local waitUntil = _utils.waitUntil
local Settings = _utils.Settings
local numLerp = _utils.numLerp
local getTime = _utils.getTime
local Events = {
	BuildingHammerPlace = ReplicatedStorage:WaitForChild("BuildingHammerPlace"),
	AddRagdollCount = ReplicatedStorage:WaitForChild("AddRagdollCount"),
	CompleteGame = ReplicatedStorage:WaitForChild("CompleteGame"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
	ClientCreateDebris = ReplicatedStorage:WaitForChild("ClientCreateDebris"),
	MakeReplayEvent = ReplicatedStorage:WaitForChild("MakeReplayEvent"),
	ClientRagdoll = ReplicatedStorage:WaitForChild("ClientRagdoll"),
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
}
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local GUI = player:WaitForChild("PlayerGui")
local valueInstances = GUI:WaitForChild("Values")
local shakeIntensity = valueInstances:WaitForChild("shake_intensity")
local isSpectating = valueInstances:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local canMove = valueInstances:WaitForChild("can_move")
local screenGui = GUI:WaitForChild("ScreenGui")
local replayGui = GUI:WaitForChild("ReplayGui")
local timerLabel = screenGui:WaitForChild("Timer")
local speedometerLabel = screenGui:WaitForChild("Speedometer")
local altitudeLabel = screenGui:WaitForChild("Altitude")
local mapFolder = Workspace:WaitForChild("Map")
local propellersFolder = mapFolder:WaitForChild("Propellers")
local mudParts = mapFolder:WaitForChild("MudParts")
local effectsFolder = Workspace:WaitForChild("Effects")
local winArea = mapFolder:WaitForChild("WinArea")
local wallPlane = Workspace:WaitForChild("Wall")
local flippedGravity = ReplicatedStorage:WaitForChild("flipped_gravity")
local mouseVisual = Workspace:WaitForChild("MouseVisual")
local modifierDisablers = Workspace:WaitForChild("ForceDisableModifiers")
local AbilityCooldowns = {
	ExplosiveHammer = false,
	Shotgun = false,
	InverterHammer = false,
	BuildingHammer = false,
}
local ActionNames = {
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
local AbilityObjects = {
	GrapplingHammerRope = nil,
}
local AbilityVariables = {
	BuildingHammer = {
		BuildType = 0,
	},
}
local cachedPropellers = {}
local cube = nil
local wasModifiersEnabled = false
local previousModifiersCheck = true
local ragdollTime = 0
local intensity = 0
local function newPropeller(propeller)
	if not propeller:IsA("Model") then
		return nil
	end
	local hitbox = propeller:WaitForChild("Hitbox")
	local _condition = not hitbox
	if not _condition then
		local _arg0 = propeller:GetAttribute("windVelocity")
		_condition = not (type(_arg0) == "number")
	end
	if _condition then
		warn("[src/client/cube.client.ts:107]", "An invalid propeller was created.")
		return nil
	end
	local _propeller = propeller
	table.insert(cachedPropellers, _propeller)
end
local function updatePropellers(cube, dt)
	for i, propeller in pairs(cachedPropellers) do
		local blades = propeller:FindFirstChild("Blades")
		local _result = blades
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if not _result then
			warn("[src/client/cube.client.ts:118]", "A propeller has broke!")
			table.remove(cachedPropellers, i + 1)
			break
		end
		for _, descendant in propeller:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = (blades.AssemblyAngularVelocity.Magnitude >= 5)
			end
		end
	end
	local usedPropellers = {}
	local totalCubeForce = Vector3.zero
	local totalHeadForce = Vector3.zero
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = cachedPropellers
	for i, part in pairs({ cube, cube:FindFirstChild("Head") }) do
		local _result = part
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if not _result then
			return nil
		end
		for _, touching in Workspace:GetPartsInPart(part, params) do
			local propeller = touching:FindFirstAncestorWhichIsA("Model")
			local _condition = not propeller
			if not _condition then
				-- ▼ ReadonlyArray.findIndex ▼
				local _callback = function(otherPropeller)
					return otherPropeller == propeller
				end
				local _result_1 = -1
				for _i, _v in usedPropellers do
					if _callback(_v, _i - 1, usedPropellers) == true then
						_result_1 = _i - 1
						break
					end
				end
				-- ▲ ReadonlyArray.findIndex ▲
				_condition = _result_1 >= 0
				if not _condition then
					_condition = propeller:GetAttribute("jammed")
				end
			end
			if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
				continue
			end
			local _condition_1 = propeller:GetAttribute("noStack")
			if _condition_1 ~= 0 and _condition_1 == _condition_1 and _condition_1 ~= "" and _condition_1 then
				_condition_1 = #usedPropellers ~= 0
			end
			if _condition_1 ~= 0 and _condition_1 == _condition_1 and _condition_1 ~= "" and _condition_1 then
				continue
			end
			local hitbox = propeller:FindFirstChild("Hitbox")
			local blades = propeller:FindFirstChild("Blades")
			if blades.AssemblyAngularVelocity.Magnitude < 5 then
				propeller:SetAttribute("jammed", true)
				blades.Anchored = true
				task.delay(5, function()
					blades.Anchored = false
					task.delay(0.5, function()
						return propeller:SetAttribute("jammed", nil)
					end)
				end)
				continue
			end
			local velocity = propeller:GetAttribute("windVelocity")
			local result = hitbox.CFrame.RightVector * velocity
			if i == 1 then
				totalCubeForce = totalCubeForce - result
			elseif i == 2 then
				totalHeadForce = totalHeadForce - result
			end
			table.insert(usedPropellers, propeller)
		end
	end
	local _condition = Workspace:GetAttribute("default_gravity")
	if _condition == nil then
		_condition = 196.2
	end
	local gravity = _condition
	local cubeMultiplier = 1
	local headMultiplier = 1
	params.FilterDescendantsInstances = { mudParts }
	for i, part in pairs({ cube, cube:FindFirstChild("Head") }) do
		local _result = part
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition_1 = _result
		if _condition_1 then
			_condition_1 = #Workspace:GetPartsInPart(part, params) > 0
		end
		if _condition_1 then
			if i == 1 then
				cubeMultiplier = 2
			else
				headMultiplier = 2
			end
		end
	end
	local propellerForce = cube:FindFirstChild("PropellerForce")
	local _result = propellerForce
	if _result ~= nil then
		_result = _result:IsA("VectorForce")
	end
	if _result then
		local _exp = totalCubeForce * gravity
		local _arg0 = dt * 40 * cubeMultiplier
		propellerForce.Force = _exp * _arg0
	end
	local _headPropeller = cube:FindFirstChild("Head")
	if _headPropeller ~= nil then
		_headPropeller = _headPropeller:FindFirstChild("PropellerForce")
	end
	local headPropeller = _headPropeller
	local _result_1 = headPropeller
	if _result_1 ~= nil then
		_result_1 = _result_1:IsA("VectorForce")
	end
	if _result_1 then
		local _exp = totalHeadForce * gravity
		local _arg0 = dt * 10 * headMultiplier
		headPropeller.Force = _exp * _arg0
	end
end
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
	return _result, _result_1, _result_2 ~= wallPlane
end
local function getBuildPosition(headCFrame)
	local offset = Vector3.new(0, 0, 0)
	local buildType = AbilityVariables.BuildingHammer.BuildType
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
local function getBuildSize()
	local size = Vector3.zero
	local buildType = AbilityVariables.BuildingHammer.BuildType
	if buildType == 0 then
		size = Vector3.new(7, 1, 7)
	elseif buildType == 1 then
		size = Vector3.new(1, 7, 7)
	end
	return size
end
local function updateModifiers()
	for hammer, actions in pairs(ActionNames) do
		for abilityName, actionName in pairs(actions) do
			ContextActionService:UnbindAction(actionName)
		end
	end
	if AbilityObjects.GrapplingHammerRope ~= nil then
		AbilityObjects.GrapplingHammerRope:Destroy()
		AbilityObjects.GrapplingHammerRope = nil
	end
	local currentHammer = getHammerTexture()
	if getSetting(GameSetting.Modifiers) then
		if currentHammer == Accessories.HammerTexture.BuilderHammer then
			local function place(action, state, input)
				if not cube then
					return nil
				end
				if action == ActionNames.BuildingHammer.Place then
					if state == Enum.UserInputState.Begin and not AbilityCooldowns.BuildingHammer then
						local head = cube:FindFirstChild("Head")
						local _result = head
						if _result ~= nil then
							_result = _result:IsA("BasePart")
						end
						if not _result then
							return nil
						end
						head.AssemblyAngularVelocity = Vector3.zero
						Events.BuildingHammerPlace:FireServer(getBuildPosition(head.CFrame), AbilityVariables.BuildingHammer.BuildType)
						AbilityCooldowns.BuildingHammer = true
						task.delay(0.4, function()
							AbilityCooldowns.BuildingHammer = false
							return AbilityCooldowns.BuildingHammer
						end)
					end
				end
			end
			local function switchType(action, state, input)
				if not cube then
					return nil
				end
				if action == ActionNames.BuildingHammer.Switch then
					if state == Enum.UserInputState.Begin then
						local newType = AbilityVariables.BuildingHammer.BuildType + 1
						if newType > 1 then
							newType = 0
						end
						AbilityVariables.BuildingHammer.BuildType = newType
					end
				end
			end
			ContextActionService:BindAction(ActionNames.BuildingHammer.Place, place, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(ActionNames.BuildingHammer.Place, "Place")
			ContextActionService:BindAction(ActionNames.BuildingHammer.Switch, switchType, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(ActionNames.BuildingHammer.Switch, "switch")
		elseif currentHammer == Accessories.HammerTexture.GrapplingHammer then
			local function activate(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if AbilityObjects.GrapplingHammerRope then
					AbilityObjects.GrapplingHammerRope:Destroy()
					AbilityObjects.GrapplingHammerRope = nil
				end
				if action == ActionNames.GrapplingHammer.Activate then
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
						AbilityObjects.GrapplingHammerRope = rope
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
				if action == ActionNames.GrapplingHammer.Scroll then
					if state == Enum.UserInputState.Change then
						local head = cube:FindFirstChild("Head")
						local rope = AbilityObjects.GrapplingHammerRope
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
			ContextActionService:BindAction(ActionNames.GrapplingHammer.Activate, activate, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(ActionNames.GrapplingHammer.Activate, "Grapple")
			ContextActionService:BindAction(ActionNames.GrapplingHammer.Activate, scroll, false, Enum.UserInputType.MouseWheel)
		elseif currentHammer == Accessories.HammerTexture.Shotgun then
			local function fire(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if action == ActionNames.Shotgun.Fire and not AbilityCooldowns.Shotgun then
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
						AbilityCooldowns.Shotgun = true
						task.delay(1.5, function()
							AbilityCooldowns.Shotgun = false
							return AbilityCooldowns.Shotgun
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
			ContextActionService:BindAction(ActionNames.Shotgun.Fire, fire, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(ActionNames.Shotgun.Fire, "Fire")
		elseif currentHammer == Accessories.HammerTexture.ExplosiveHammer then
			local function explode(name, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if name == ActionNames.ExplosiveHammer.Explode and not AbilityCooldowns.ExplosiveHammer then
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
						AbilityCooldowns.ExplosiveHammer = true
						task.delay(2, function()
							if not didSet then
								didSet = true
								AbilityCooldowns.ExplosiveHammer = false
							end
						end)
						task.spawn(function()
							waitUntil(function()
								return not AbilityCooldowns.ExplosiveHammer
							end)
							if not didSet then
								TweenService:Create(head, TweenInfo.new(0), {
									Color = Color3.fromRGB(255, 0, 0),
								}):Play()
							end
							didSet = true
						end)
						head.Color = Color3.fromRGB(255, 175, 0)
						TweenService:Create(head, TweenInfo.new(2, Enum.EasingStyle.Linear), {
							Color = Color3.fromRGB(255, 0, 0),
						}):Play()
						local velocity = cube.AssemblyLinearVelocity
						local _position = cube.Position
						local _position_1 = head.Position
						local force = (_position - _position_1).Unit * 600
						cube.AssemblyLinearVelocity = velocity + force
						local explosion = Instance.new("Explosion")
						explosion.Position = head.Position
						explosion.BlastRadius = 0
						explosion.BlastPressure = 0
						explosion.Parent = effectsFolder
						for i = 1, 15 do
							playSound("explosion", {
								PlaybackSpeed = randomFloat(0.9, 1),
								Volume = head.AssemblyAngularVelocity.Magnitude / 50,
							})
						end
					end
				end
			end
			ContextActionService:BindAction(ActionNames.ExplosiveHammer.Explode, explode, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(ActionNames.ExplosiveHammer.Explode, "💥")
		elseif currentHammer == Accessories.HammerTexture.InverterHammer then
			local function invert(action, state, input)
				if not cube or not isClientCube(cube) then
					return nil
				end
				if action == ActionNames.InverterHammer.Invert and not AbilityCooldowns.InverterHammer then
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
						AbilityCooldowns.InverterHammer = true
						task.delay(0.5, function()
							AbilityCooldowns.InverterHammer = false
							return AbilityCooldowns.InverterHammer
						end)
						arm.Color = Color3.fromRGB(0, 0, 0)
						TweenService:Create(arm, tweenTypes.linear.short, {
							Color = Color3.fromRGB(7, 114, 172),
						}):Play()
						flippedGravity.Value = not flippedGravity.Value
						ContextActionService:SetTitle(ActionNames.InverterHammer.Invert, if flippedGravity.Value then "⬇️" else "⬆️")
						playSound("invert")
					end
				end
			end
			ContextActionService:BindAction(ActionNames.InverterHammer.Invert, invert, true, Enum.KeyCode.E)
			ContextActionService:SetTitle(ActionNames.InverterHammer.Invert, "⬆️")
		end
	end
end
task.spawn(updateModifiers)
for _, propeller in propellersFolder:GetChildren() do
	task.spawn(newPropeller, propeller)
end
propellersFolder.ChildAdded:Connect(newPropeller)
player.AttributeChanged:Connect(function(attr)
	if attr == PlayerAttributes.HammerTexture or attr == PlayerAttributes.Client.SettingsJSON then
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
RunService.Heartbeat:Connect(function(dt)
	local _value = player:GetAttribute(PlayerAttributes.Client.InMainMenu)
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return nil
	end
	for _, otherPlayer in Players:GetPlayers() do
		local _altitudeValue = otherPlayer:FindFirstChild("leaderstats")
		if _altitudeValue ~= nil then
			_altitudeValue = _altitudeValue:FindFirstChild("Altitude")
		end
		local altitudeValue = _altitudeValue
		local _result = altitudeValue
		if _result ~= nil then
			_result = _result:IsA("StringValue")
		end
		if _result then
			local otherCube = Workspace:FindFirstChild(`cube{otherPlayer.UserId}`)
			local value = "--"
			local _result_1 = otherCube
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			if _result_1 then
				local _binding = convertStudsToMeters(otherCube.Position.Y - 1.9)
				local altitude = _binding[1]
				local altitudeString = _binding[2]
				value = altitudeString
			end
			local _value_1 = player:GetAttribute(PlayerAttributes.InErrorLand)
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				value = "--"
			end
			altitudeValue.Value = value
		end
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
			local _value_1 = currentHammer == Accessories.HammerTexture.Hammer404 or player:GetAttribute(PlayerAttributes.InErrorLand)
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
	if not cube or cube.Parent ~= Workspace then
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
	if spectatingCube or cube then
		local targetPlayer = otherPlayer or player
		local targetCube = spectatingCube or cube
		local _binding = convertStudsToMeters(targetCube.Position.Y - 1.9)
		local altitude = _binding[1]
		local altitudeString = _binding[2]
		local _binding_1 = convertStudsToMeters(targetCube.AssemblyLinearVelocity.Magnitude)
		local speed = _binding_1[1]
		local speedString = _binding_1[2]
		local cubeTime = getCubeTime(targetCube)
		local hours, minutes, seconds, milliseconds = getTimeUnits(math.round(cubeTime * 1000))
		timerLabel.Text = string.format("%02d:%02d.%d", minutes, seconds, math.floor(milliseconds / 100))
		altitudeLabel.Text = altitudeString
		speedometerLabel.Text = speedString
		timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		local _value_1 = targetCube:GetAttribute("used_modifiers")
		if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
			timerLabel.TextColor3 = Color3.fromRGB(179, 77, 77)
			local _value_2 = targetPlayer:GetAttribute(PlayerAttributes.CompletedGame)
			if _value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2 then
				timerLabel.TextColor3 = Color3.fromRGB(255, 128, 128)
			end
		else
			local _value_2 = targetPlayer:GetAttribute(PlayerAttributes.CompletedGame)
			if _value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2 then
				timerLabel.TextColor3 = Color3.fromRGB(255, 255, 128)
			else
				local _timeValue = targetPlayer:FindFirstChild("leaderstats")
				if _timeValue ~= nil then
					_timeValue = _timeValue:FindFirstChild("Time")
				end
				local timeValue = _timeValue
				local _result = timeValue
				if _result ~= nil then
					_result = _result:IsA("StringValue")
				end
				local _condition_2 = _result
				if _condition_2 then
					_condition_2 = timeValue.Value == "--"
				end
				if _condition_2 then
					timerLabel.TextColor3 = Color3.fromRGB(179, 179, 179)
				end
			end
		end
	else
		timerLabel.Text = "--:--.-"
		altitudeLabel.Text = "--"
		speedometerLabel.Text = "--"
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
		local range = cube:FindFirstChild("Range")
		local _result_3 = range
		if _result_3 ~= nil then
			_result_3 = _result_3:IsA("BasePart")
		end
		if _result_3 then
			range.Transparency = if getSetting(GameSetting.ShowRange) then 0.75 else 1
		end
		local windForce = cube:FindFirstChild("WindForce")
		local _result_4 = windForce
		if _result_4 ~= nil then
			_result_4 = _result_4:IsA("VectorForce")
		end
		if _result_4 then
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
		intensity = shakeIntensity.Value
		if isSpectating.Value and otherPlayer then
			intensity = 0
			local _result_5 = screenGui:FindFirstChild("SpectatingGUI")
			if _result_5 ~= nil then
				_result_5 = _result_5:FindFirstChild("PlayerName")
			end
			local label = _result_5
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
			local _result_5 = cube:FindFirstChild("upsidedown_gravity")
			if _result_5 ~= nil then
				_result_5:Destroy()
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
		if not getSetting(GameSetting.ScreenShake) then
			intensity = 0
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
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { mapFolder }
		for _, obstructingPart in Workspace:GetPartBoundsInBox(CFrame.new(start.X, start.Y, distance / -2), Vector3.new(10, 10, distance), params) do
			local _value_1 = obstructingPart:GetAttribute("CAMERA_TRANSPARENT")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				local _condition_7 = obstructingPart:GetAttribute("CAMERA_TRANSPARENCY")
				if _condition_7 == nil then
					_condition_7 = 0.9
				end
				local transparency = _condition_7
				obstructingPart.LocalTransparencyModifier = numLerp(obstructingPart.LocalTransparencyModifier, transparency, dt * 5)
				TweenService:Create(obstructingPart, tweenTypes.linear.short, {
					LocalTransparencyModifier = 0,
				}):Play()
			end
		end
		if not replayGui.Enabled then
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
		shakeIntensity.Value = math.max(intensity - dt * 3, 0)
		wallPlane.Position = cubePosition
		updatePropellers(cube, dt)
		local position, nonFiltered, hitPart = mouseRaycast()
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
				if AbilityCooldowns.BuildingHammer then
					head.Color = Color3.fromRGB(255, 128, 128)
				else
					head.Color = Color3.fromRGB(26, 26, 26)
				end
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Position = getBuildPosition(head.CFrame)
				part.Size = getBuildSize()
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
		local _value_1 = player:GetAttribute(PlayerAttributes.InErrorLand)
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
			local _condition_7 = (cube:GetAttribute("destroyed_counter"))
			if _condition_7 == nil then
				_condition_7 = 0
			end
			(left:FindFirstChild("DestroyedCounter")).Text = _fn_1.format("Destroyed Counter: %d", _condition_7)
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
winArea.Touched:Connect(function(otherPart)
	local _condition = otherPart:GetAttribute("isCube")
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		_condition = isClientCube(otherPart)
		if _condition then
			local _value = player:GetAttribute(PlayerAttributes.CompletedGame)
			_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
		end
	end
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		player:SetAttribute(PlayerAttributes.CompletedGame, true)
		local totalTime = getCubeTime(otherPart)
		print("[src/client/cube.client.ts:929]", `Completed game in {totalTime} seconds`)
		Events.CompleteGame:FireServer(totalTime)
		Events.MakeReplayEvent:Fire(string.format("win,%d", totalTime * 1000))
	end
end)
Events.ClientReset.Event:Connect(function()
	player:SetAttribute(PlayerAttributes.CompletedGame, nil)
	for key in pairs(AbilityCooldowns) do
		AbilityCooldowns[key] = false
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
	local _value = not cube or player:GetAttribute(PlayerAttributes.InErrorLand)
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		return nil
	end
	local slowdownFactor = math.clamp(1 - (step * 30), 0.01, 1)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { mudParts }
	for _, part in { cube, cube:FindFirstChild("Head") } do
		local _result = part
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = _result
		if _condition then
			_condition = #Workspace:GetPartsInPart(part, params) > 0
		end
		if _condition then
			part.AssemblyLinearVelocity = part.AssemblyLinearVelocity * slowdownFactor
		end
	end
end)
