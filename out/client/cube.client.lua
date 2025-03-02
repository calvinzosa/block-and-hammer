-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ContextActionService = _services.ContextActionService
local ReplicatedStorage = _services.ReplicatedStorage
local UserInputService = _services.UserInputService
local TextChatService = _services.TextChatService
local TweenService = _services.TweenService
local RunService = _services.RunService
local StarterGui = _services.StarterGui
local Workspace = _services.Workspace
local Players = _services.Players
local GuiService = _services.GuiService
local Debris = _services.Debris
local _utils = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils")
local roundDecimalPlaces = _utils.roundDecimalPlaces
local getHammerTexture = _utils.getHammerTexture
local PlayerAttributes = _utils.PlayerAttributes
local convertStudsToMeters = _utils.convertStudsToMeters
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
local randomDirection = _utils.randomDirection
local getCurrentArea = _utils.getCurrentArea
local _mobile_buttons = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "mobile_buttons")
local createMobileButton = _mobile_buttons.createMobileButton
local getMobileButtonsByCategory = _mobile_buttons.getMobileButtonsByCategory
local Events = {
	BuildingHammerPlace = ReplicatedStorage:WaitForChild("BuildingHammerPlace"),
	SaySystemMessage = ReplicatedStorage:WaitForChild("SaySystemMessage"),
	AddRagdollCount = ReplicatedStorage:WaitForChild("AddRagdollCount"),
	ShowChatBubble = ReplicatedStorage:WaitForChild("ShowChatBubble"),
	CompleteGame = ReplicatedStorage:WaitForChild("CompleteGame"),
	FlipGravity = ReplicatedStorage:WaitForChild("FlipGravity"),
	StartClientTutorial = ReplicatedStorage:WaitForChild("StartClientTutorial"),
	ClientCreateDebris = ReplicatedStorage:WaitForChild("ClientCreateDebris"),
	ClientForceReset = ReplicatedStorage:WaitForChild("ClientForceReset"),
	MakeReplayEvent = ReplicatedStorage:WaitForChild("MakeReplayEvent"),
	ClientMessage = ReplicatedStorage:WaitForChild("ClientMessage"),
	ClientRagdoll = ReplicatedStorage:WaitForChild("ClientRagdoll"),
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
}
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or (Workspace:WaitForChild("Camera"))
local GUI = player:WaitForChild("PlayerGui")
local valueInstances = GUI:WaitForChild("Values")
local shakeIntensity = valueInstances:WaitForChild("shake_intensity")
local isSpectating = valueInstances:WaitForChild("is_spectating")
local spectatePlayer = isSpectating:WaitForChild("player")
local canMove = valueInstances:WaitForChild("can_move")
local screenGui = GUI:WaitForChild("ScreenGui")
local mobileButtons = GUI:WaitForChild("MobileButtons")
local replayGui = GUI:WaitForChild("ReplayGui")
local spectatingGui = screenGui:WaitForChild("SpectatingGUI")
local spectateUsername = spectatingGui:WaitForChild("PlayerName")
local mouseIcon = screenGui:WaitForChild("MouseIcon")
local debugInfo = screenGui:WaitForChild("DebugInfo")
local newAreaLabel = screenGui:WaitForChild("NewArea")
local timerLabel = screenGui:WaitForChild("Timer")
local speedometerLabel = screenGui:WaitForChild("Speedometer")
local altitudeLabel = screenGui:WaitForChild("Altitude")
local travelGui = screenGui:WaitForChild("FastTravelGUI")
local nonBreakable = Workspace:WaitForChild("NonBreakable")
local resetParts = Workspace:WaitForChild("ResetParts")
local mapFolder = Workspace:WaitForChild("Map")
local electricalParts = mapFolder:WaitForChild("Electrical")
local platformsFolder = mapFolder:WaitForChild("Platforms")
local propellersFolder = mapFolder:WaitForChild("Propellers")
local mudParts = mapFolder:WaitForChild("MudParts")
local effectsFolder = Workspace:WaitForChild("Effects")
local winAreaLevel1 = mapFolder:WaitForChild("Level1WinArea")
local winAreaLevel2 = mapFolder:WaitForChild("Level2WinArea")
local wallPlane = Workspace:WaitForChild("Wall")
local flippedGravity = ReplicatedStorage:WaitForChild("flipped_gravity")
local mouseVisual = Workspace:WaitForChild("MouseVisual")
local modifierDisablers = Workspace:WaitForChild("ForceDisableModifiers")
local hitboxFolder = Workspace:WaitForChild("Hitboxes")
local prevObstructedParts = {}
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
local cachedParticles = {}
local cube = nil
local wasModifiersEnabled = false
local previousModifiersCheck = true
local stunDebounce = false
local isAnimating = false
local ragdollTime = 0
local intensity = 0
local function newPropeller(propeller)
	if not propeller:IsA("Model") then
		return nil
	end
	local hitbox = propeller:WaitForChild("Hitbox", 15)
	local _result = hitbox
	if _result ~= nil then
		_result = _result:IsA("BasePart")
	end
	local _condition = not _result
	if not _condition then
		local _arg0 = propeller:GetAttribute("windVelocity")
		_condition = not (type(_arg0) == "number")
	end
	if _condition then
		if propeller.Parent == propellersFolder then
			warn("[src/client/cube.client.ts:143]", "An invalid propeller was created.")
		end
		return nil
	end
	local _propeller = propeller
	table.insert(cachedPropellers, _propeller)
end
local function updatePropellers(cube, head, dt)
	for i, propeller in pairs(cachedPropellers) do
		local blades = propeller:FindFirstChild("Blades")
		local _result = blades
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if not _result then
			warn("[src/client/cube.client.ts:154]", "A propeller has broke!")
			table.remove(cachedPropellers, i + 1)
			break
		end
		for _, descendant in propeller:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = blades.AssemblyAngularVelocity.Magnitude >= 5
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
	local _condition = (Workspace:GetAttribute("default_gravity"))
	if _condition == nil then
		_condition = 196.2
	end
	local gravity = _condition
	local cubeMultiplier = 0.1
	local headMultiplier = 0.1
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
				cubeMultiplier = 0.2
			else
				headMultiplier = 0.2
			end
		end
	end
	local _assemblyLinearVelocity = cube.AssemblyLinearVelocity
	local _exp = totalCubeForce * gravity
	local _arg0 = dt * cubeMultiplier
	cube.AssemblyLinearVelocity = _assemblyLinearVelocity + (_exp * _arg0)
	local _assemblyLinearVelocity_1 = head.AssemblyLinearVelocity
	local _exp_1 = totalHeadForce * gravity
	local _arg0_1 = dt * headMultiplier
	head.AssemblyLinearVelocity = _assemblyLinearVelocity_1 + (_exp_1 * _arg0_1)
end
local function updatePlatforms(cube, head)
	for _, platform in platformsFolder:GetChildren() do
		if not platform:IsA("BasePart") then
			continue
		end
		local cubeCollision = (platform:FindFirstChild("CubeCollision")) or Instance.new("NoCollisionConstraint")
		cubeCollision.Name = "CubeCollision"
		cubeCollision.Part0 = platform
		cubeCollision.Part1 = cube
		cubeCollision.Enabled = platform.Position.Y + platform.Size.Y / 2 > cube.Position.Y - cube.Size.Y / 2 + 0.25
		cubeCollision.Parent = platform
		local headCollision = (platform:FindFirstChild("HeadCollision")) or Instance.new("NoCollisionConstraint")
		headCollision.Name = "HeadCollision"
		headCollision.Part0 = platform
		headCollision.Part1 = head
		headCollision.Enabled = platform.Position.Y + platform.Size.Y / 2 > head.Position.Y
		headCollision.Parent = platform
		platform:SetAttribute("notCollidable", headCollision.Enabled)
	end
end
local function updateMud(cube, head, dt)
	local slowdownFactor = math.clamp(1 - dt * 15, 0.01, 1)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { mudParts }
	for _, part in { cube, head } do
		if #Workspace:GetPartsInPart(part, params) > 0 then
			part.AssemblyLinearVelocity = part.AssemblyLinearVelocity * slowdownFactor
		end
	end
end
local function newElectricalPart(part)
	if not part:IsA("BasePart") then
		return nil
	end
	local zapParticles = part:WaitForChild("Zap")
	part.Touched:Connect(function(otherPart)
		local _head = cube
		if _head ~= nil then
			_head = _head:FindFirstChild("Head")
		end
		local head = _head
		local _condition = not cube
		if not _condition then
			local _result = head
			if _result ~= nil then
				_result = _result:IsA("BasePart")
			end
			_condition = not _result
		end
		if _condition then
			return nil
		end
		if otherPart == cube or otherPart == cube:FindFirstChild("Head") then
			if ragdollTime > 0 or stunDebounce then
				return nil
			end
			stunDebounce = true
			task.delay(4, function()
				stunDebounce = false
				return stunDebounce
			end)
			ragdollTime = 3
			local stunParticles = ReplicatedStorage:WaitForChild("Particles"):WaitForChild("Stunned")
			local cubeParticles = stunParticles:Clone()
			cubeParticles.Parent = cube
			local headParticles = stunParticles:Clone()
			headParticles.Parent = cube
			Debris:AddItem(cubeParticles, 3)
			Debris:AddItem(headParticles, 3)
			local _position = cube.Position
			local _arg0 = part:GetClosestPointOnSurface(cube.Position)
			local cubeVelocity = _position - _arg0
			local _position_1 = head.Position
			local _arg0_1 = part:GetClosestPointOnSurface(head.Position)
			local headVelocity = _position_1 - _arg0_1
			if cubeVelocity.Magnitude > 0 and headVelocity.Magnitude > 0 then
				local _unit = cubeVelocity.Unit
				local _arg0_2 = if otherPart == cube then 100 else 45
				cube.AssemblyLinearVelocity = _unit * _arg0_2
				local _unit_1 = headVelocity.Unit
				local _arg0_3 = if otherPart == head then 100 else 45
				head.AssemblyLinearVelocity = _unit_1 * _arg0_3
			end
			playSound("zap", {
				PlaybackSpeed = randomFloat(0.9, 1.1),
				Volume = 1.5,
			})
			task.delay(2.5, function()
				cubeParticles.Enabled = false
				headParticles.Enabled = false
			end)
			zapParticles:Emit(50)
		end
	end)
end
local function newResetPart(part)
	if not part:IsA("BasePart") then
		return nil
	end
	part.LocalTransparencyModifier = 1
	part.Touched:Connect(function(otherPart)
		if otherPart == cube then
			Events.ClientForceReset:Fire(true)
		end
	end)
end
local function saySystemMessage(message, color, font, size)
	local _message = message
	if not (type(_message) == "string") then
		return nil
	end
	local _color = color
	if not (typeof(_color) == "Color3") then
		color = Color3.fromRGB(255, 255, 255)
	end
	local _font = font
	local _condition = not (typeof(_font) == "EnumItem")
	if not _condition then
		_condition = not font:IsA("Font")
	end
	if _condition then
		font = Enum.Font.BuilderSans
	end
	local _size = size
	if not (type(_size) == "number") then
		size = nil
	end
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = message,
		Color = color,
		Font = font,
		TextSize = size,
	})
end
local function doTeleportAnimation(towards, finish)
	if not cube then
		return nil
	end
	isAnimating = true
	canMove.Value = false
	task.delay(1.5, function()
		isAnimating = false
		canMove.Value = true
		if cube then
			cube.Anchored = false
			local _fn = CFrame
			local _position = cube.Position
			local _vector3 = Vector3.new(0, 0, 1)
			camera.CFrame = _fn.lookAt(_position - _vector3, cube.Position)
		end
	end)
	local effect = cube:Clone()
	effect.Anchored = true
	effect.Name = "TeleportTransition"
	effect.Parent = effectsFolder
	cube.Anchored = true
	cube.AssemblyAngularVelocity = Vector3.zero
	cube:PivotTo(CFrame.new(finish))
	for _, part in effect:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	local Info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local _fn = TweenService
	local _object = {}
	local _left = "CFrame"
	local _fn_1 = CFrame
	local _towards = towards
	local _vector3 = Vector3.new(0, 0, 37.5)
	_object[_left] = _fn_1.lookAt(_towards - _vector3, towards)
	_fn:Create(camera, Info, _object):Play()
	TweenService:Create(effect, Info, {
		CFrame = CFrame.lookAlong(towards, randomDirection()),
		Size = Vector3.zero,
		LocalTransparencyModifier = 1,
	}):Play()
	for _, part in effect:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			TweenService:Create(part, TweenInfo.new(randomFloat(0.5, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				CFrame = CFrame.lookAlong(towards, randomDirection()),
				Size = Vector3.zero,
				LocalTransparencyModifier = 1,
			}):Play()
		elseif part:IsA("ParticleEmitter") or part:IsA("BillboardGui") then
			part.Enabled = false
		end
	end
	task.wait(1)
	effect:Destroy()
	local _fn_2 = TweenService
	local _exp = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local _object_1 = {}
	local _left_1 = "CFrame"
	local _fn_3 = CFrame
	local _towards_1 = towards
	local _vector3_1 = Vector3.new(0, 0, 1)
	_object_1[_left_1] = _fn_3.lookAt(_towards_1 - _vector3_1, towards)
	_fn_2:Create(camera, _exp, _object_1):Play()
end
local function formatDebugWorldNumber(num)
	local integer, decimal = math.modf(math.abs(num))
	return string.format("%s%05d%s", if integer >= 0 then "+" else "-", integer, string.sub(string.format("%.3f", decimal), 2))
end
local function mouseRaycast(distance)
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { wallPlane }
	local _fn = Workspace
	local _exp = ray.Origin
	local _unit = ray.Direction.Unit
	local _distance = distance
	local resultA = _fn:Raycast(_exp, _unit * _distance, params)
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { mouseVisual, modifierDisablers, effectsFolder }
	local _fn_1 = Workspace
	local _exp_1 = ray.Origin
	local _unit_1 = ray.Direction.Unit
	local _distance_1 = distance
	local resultB = _fn_1:Raycast(_exp_1, _unit_1 * _distance_1, params)
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
	for _, hitbox in hitboxFolder:GetChildren() do
		if hitbox:IsA("SelectionBox") then
			local _result = hitbox.Adornee
			if _result ~= nil then
				_result:SetAttribute("hitboxOutline", nil)
			end
		end
	end
	hitboxFolder:ClearAllChildren()
	local modifierCategory = "ModifierAbilities"
	local _exp = getMobileButtonsByCategory(modifierCategory)
	-- ▼ ReadonlyArray.forEach ▼
	local _callback = function(button)
		return button:Destroy()
	end
	for _k, _v in _exp do
		_callback(_v, _k - 1, _exp)
	end
	-- ▲ ReadonlyArray.forEach ▲
	for _, actions in pairs(ActionNames) do
		for _1, actionName in pairs(actions) do
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
			ContextActionService:BindAction(ActionNames.BuildingHammer.Place, place, false, Enum.KeyCode.E)
			ContextActionService:BindAction(ActionNames.BuildingHammer.Switch, switchType, false, Enum.KeyCode.E)
			createMobileButton("🧱", modifierCategory, Vector2.zero, 1, ActionNames.BuildingHammer.Place, function(action, state, input)
				place(action, state, input)
			end)
			createMobileButton("➡️", modifierCategory, Vector2.yAxis * (-1), 0.5, ActionNames.BuildingHammer.Switch, function(action, state, input)
				switchType(action, state, input)
			end)
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
					local arm = cube:FindFirstChild("Arm")
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
						local _result_1 = arm
						if _result_1 ~= nil then
							_result_1 = _result_1:IsA("BasePart")
						end
						_condition = not _result_1
						if not _condition then
							local _result_2 = axisLock
							if _result_2 ~= nil then
								_result_2 = _result_2:IsA("BasePart")
							end
							_condition = not _result_2
							if not _condition then
								local _result_3 = rightAttachment
								if _result_3 ~= nil then
									_result_3 = _result_3:IsA("Attachment")
								end
								_condition = not _result_3
							end
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
							if object ~= mapFolder and object ~= nonBreakable then
								table.insert(filter, object)
							end
						end
						for _, propeller in propellersFolder:GetChildren() do
							local hitbox = propeller:FindFirstChild("Hitbox")
							local _result_1 = hitbox
							if _result_1 ~= nil then
								_result_1 = _result_1:IsA("BasePart")
							end
							if _result_1 then
								table.insert(filter, hitbox)
							end
						end
						params.FilterDescendantsInstances = filter
						local result = Workspace:Raycast(head.Position, arm.CFrame.RightVector * 6144, params)
						if not result then
							return nil
						end
						local target = Instance.new("Attachment")
						target.CFrame = CFrame.new(result.Position)
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
						TweenService:Create(rope, TweenInfo.new(0.2), {
							Length = newLength,
						}):Play()
					end
				end
			end
			ContextActionService:BindAction(ActionNames.GrapplingHammer.Activate, activate, false, Enum.KeyCode.E)
			ContextActionService:BindAction(ActionNames.GrapplingHammer.Scroll, scroll, false, Enum.UserInputType.MouseWheel)
			createMobileButton("🪢", modifierCategory, Vector2.zero, 1, ActionNames.GrapplingHammer.Activate, function(action, state, input)
				activate(action, state, input)
			end)
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
			ContextActionService:BindAction(ActionNames.Shotgun.Fire, fire, false, Enum.KeyCode.E)
			createMobileButton("🔫", modifierCategory, Vector2.zero, 1, ActionNames.Shotgun.Fire, function(action, state, input)
				fire(action, state, input)
			end)
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
						AbilityCooldowns.ExplosiveHammer = true
						local didSet = false
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
								head.Color = Color3.fromRGB(255, 0, 0)
							end
							didSet = true
						end)
						head.Color = Color3.fromRGB(255, 175, 0)
						TweenService:Create(head, TweenInfo.new(2, Enum.EasingStyle.Linear), {
							Color = Color3.fromRGB(255, 0, 0),
						}):Play()
						local _condition = (cube:GetAttribute("scale"))
						if _condition == nil then
							_condition = 1
						end
						local cubeScale = _condition
						local velocity = cube.AssemblyLinearVelocity
						local _position = cube.Position
						local _position_1 = head.Position
						local _unit = (_position - _position_1).Unit
						local _arg0 = 600 * cubeScale
						local force = _unit * _arg0
						if force.X == force.X and force.Y == force.Y and force.Z == force.Z then
							cube.AssemblyLinearVelocity = velocity + force
						end
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
			ContextActionService:BindAction(ActionNames.ExplosiveHammer.Explode, explode, false, Enum.KeyCode.E)
			createMobileButton("💥", modifierCategory, Vector2.zero, 1, ActionNames.Shotgun.Fire, function(action, state, input)
				explode(action, state, input)
			end)
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
						playSound("invert")
					end
				end
			end
			ContextActionService:BindAction(ActionNames.InverterHammer.Invert, invert, false, Enum.KeyCode.E)
			createMobileButton("⤴️", modifierCategory, Vector2.zero, 1, ActionNames.InverterHammer.Invert, function(action, state, input)
				invert(action, state, input)
			end)
		elseif currentHammer == Accessories.HammerTexture.HitboxHammer then
			local _array = {}
			local _length = #_array
			local _array_1 = mapFolder:GetDescendants()
			local _Length = #_array_1
			table.move(_array_1, 1, _Length, _length + 1, _array)
			_length += _Length
			local _array_2 = nonBreakable:GetDescendants()
			table.move(_array_2, 1, #_array_2, _length + 1, _array)
			for _, descendant in _array do
				local _condition = descendant:IsA("BasePart")
				if _condition then
					local _value = descendant:GetAttribute("hitboxOutline")
					_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
				end
				if _condition then
					descendant:SetAttribute("hitboxOutline", true)
					local outline = Instance.new("SelectionBox")
					outline.Adornee = descendant
					outline.Color3 = if descendant:IsA("Part") and descendant.Shape == Enum.PartType.Block then Color3.fromRGB(255, 0, 0) else Color3.fromRGB(0, 0, 255)
					outline.Transparency = math.min(descendant.Transparency, 0.5)
					outline.Parent = hitboxFolder
				end
			end
		end
	end
end
local function winTouched(otherPart)
	local _condition = otherPart:GetAttribute("isCube")
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		_condition = isClientCube(otherPart)
		if _condition then
			local _value = player:GetAttribute(PlayerAttributes.CompletedGame)
			_condition = not (_value ~= 0 and _value == _value and _value ~= "" and _value)
		end
	end
	if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
		local currentArea = getCurrentArea(otherPart, true)
		if currentArea ~= "Level 1" and currentArea ~= "Level 2" then
			return nil
		end
		player:SetAttribute(PlayerAttributes.CompletedGame, true)
		local totalTime = getCubeTime(otherPart)
		print("[src/client/cube.client.ts:736]", `Completed '{currentArea}' in {totalTime}s`)
		Events.CompleteGame:FireServer(totalTime)
		Events.MakeReplayEvent:Fire(string.format("win,%d", totalTime * 1000))
	end
end
task.spawn(updateModifiers)
player.AttributeChanged:Connect(function(attr)
	if attr == PlayerAttributes.HammerTexture or attr == PlayerAttributes.Client.SettingsJSON then
		updateModifiers()
	end
end)
Events.ClientRagdoll.Event:Connect(function(seconds)
	local previousRagdollTime = ragdollTime
	ragdollTime = math.max(ragdollTime, seconds)
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
		local leaderstats = otherPlayer:FindFirstChild("leaderstats")
		local _altitudeValue = leaderstats
		if _altitudeValue ~= nil then
			_altitudeValue = _altitudeValue:FindFirstChild("Altitude")
		end
		local altitudeValue = _altitudeValue
		local _timeValue = leaderstats
		if _timeValue ~= nil then
			_timeValue = _timeValue:FindFirstChild("Time")
		end
		local timeValue = _timeValue
		local _areaValue = leaderstats
		if _areaValue ~= nil then
			_areaValue = _areaValue:FindFirstChild("Area")
		end
		local areaValue = _areaValue
		local _result = altitudeValue
		if _result ~= nil then
			_result = _result:IsA("StringValue")
		end
		local _condition = _result
		if _condition then
			local _result_1 = timeValue
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("StringValue")
			end
			_condition = _result_1
			if _condition then
				local _result_2 = areaValue
				if _result_2 ~= nil then
					_result_2 = _result_2:IsA("StringValue")
				end
				_condition = _result_2
			end
		end
		if _condition then
			local otherCube = Workspace:FindFirstChild(`cube{otherPlayer.UserId}`)
			local newAltitudeValue = "--"
			local newTimeValue = "--"
			local _result_1 = otherCube
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			if _result_1 then
				local _binding = convertStudsToMeters(otherCube.Position.Y, true)
				local altitudeString = _binding[2]
				newAltitudeValue = altitudeString
				local cubeTime = getCubeTime(otherCube)
				local _1, minutes, seconds, milliseconds = getTimeUnits(cubeTime * 1000)
				newTimeValue = string.format("%02d:%02d.%d", minutes, seconds, math.floor(milliseconds / 100))
			end
			if getCurrentArea(cube) == "ErrorLand" or getCurrentArea(cube) == "ErrorLand" then
				newAltitudeValue = "--"
			end
			timeValue.Value = newTimeValue
			altitudeValue.Value = newAltitudeValue
			areaValue.Value = getCurrentArea(otherCube, true)
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
		elseif currentHammer == Accessories.HammerTexture.Hammer404 or getCurrentArea(cube) == "ErrorLand" then
			Workspace.Gravity /= 2
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
		spectateUsername.Text = spectatePlayer.Value
	else
		spectateUsername.Text = "None"
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
		local _condition_2 = targetCube:GetAttribute("_previousArea")
		if _condition_2 == nil then
			_condition_2 = "None"
		end
		local previousArea = _condition_2
		local currentArea = getCurrentArea(cube, true)
		if previousArea ~= currentArea then
			targetCube:SetAttribute("_previousArea", currentArea)
			if currentArea ~= "None" then
				local _value_1 = newAreaLabel:GetAttribute("animating")
				if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
					newAreaLabel:SetAttribute("stop", true)
					while true do
						local _value_2 = newAreaLabel:GetAttribute("animating")
						if not (_value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2) then
							break
						end
						RunService.Heartbeat:Wait()
					end
				end
				newAreaLabel:SetAttribute("animating", true)
				newAreaLabel.AnchorPoint = Vector2.new(0, 1)
				newAreaLabel.TextTransparency = 1
				newAreaLabel.Text = `<stroke thickness="1"><u>{currentArea}</u></stroke>`
				newAreaLabel.Visible = true
				local startTime = time()
				local totalTime = 2
				local currentTime = startTime
				while (currentTime - startTime) < totalTime do
					local _value_2 = newAreaLabel:GetAttribute("stop")
					if _value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2 then
						newAreaLabel:SetAttribute("stop", nil)
						break
					end
					local percent = (currentTime - startTime) / totalTime
					newAreaLabel.TextTransparency = math.abs(2 * percent - 1)
					newAreaLabel.AnchorPoint = Vector2.new(0, (1 - percent) / 2 + 0.5)
					newAreaLabel.Text = `<stroke thickness="1" transparency="{newAreaLabel.TextTransparency}"><u>{currentArea}</u></stroke>`
					RunService.Heartbeat:Wait()
					currentTime = time()
				end
				newAreaLabel.Visible = false
				newAreaLabel:SetAttribute("animating", nil)
				local _value_2 = newAreaLabel:GetAttribute("stop")
				if _value_2 ~= 0 and _value_2 == _value_2 and _value_2 ~= "" and _value_2 then
					newAreaLabel:SetAttribute("stop", nil)
				end
			end
		end
		local _binding = convertStudsToMeters(targetCube.Position.Y, true)
		local altitudeString = _binding[2]
		local _binding_1 = convertStudsToMeters(targetCube.AssemblyLinearVelocity.Magnitude)
		local speedString = _binding_1[2]
		local cubeTime = getCubeTime(targetCube)
		local _, minutes, seconds, milliseconds = getTimeUnits(math.round(cubeTime * 1000))
		timerLabel.Text = string.format("%02d:%02d.%d", minutes, seconds, math.floor(milliseconds / 100))
		altitudeLabel.Text = altitudeString
		speedometerLabel.Text = `{speedString}/s`
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
				local _condition_3 = _result
				if _condition_3 then
					_condition_3 = timeValue.Value == "--"
				end
				if _condition_3 then
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
		local _condition_5 = (cube:GetAttribute("scale"))
		if _condition_5 == nil then
			_condition_5 = 1
		end
		local cubeScale = _condition_5
		local _binding = convertStudsToMeters(cube.Position.Y, true)
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
		local previousRagdollTime = ragdollTime
		ragdollTime = math.max(ragdollTime - dt, 0)
		cube:SetAttribute("ragdollTime", ragdollTime)
		if getSetting(GameSetting.Modifiers) and cubeHat == Accessories.CubeHat.InstantGyro then
			ragdollTime = 0
			previousRagdollTime = 0
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
		if ragdollTime == 0 and previousRagdollTime > 0 then
			print("[src/client/cube.client.ts:959]", "Pivot hammer back to cube")
			local _cFrame = CFrame.new(cube.Position)
			local _arg0 = CFrame.fromOrientation(0, 0, math.pi / 2)
			arm.CFrame = _cFrame * _arg0
		end
		local _condition_6 = (cube:GetAttribute("transparency"))
		if _condition_6 == nil then
			_condition_6 = 0
		end
		local cubeTransparency = _condition_6
		local _condition_7 = (cube:GetAttribute("hammerTransparency"))
		if _condition_7 == nil then
			_condition_7 = 0
		end
		local hammerTransparency = _condition_7
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
				if flippedGravity.Value then
					flippedGravity.Value = false
				end
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
		local cameraPosition = cubePosition
		if intensity > 0 then
			local _cameraPosition = cameraPosition
			local _vector3 = Vector3.new((math.random(0, 1) * 2 - 1) * intensity, (math.random(0, 1) * 2 - 1) * intensity, 0)
			cameraPosition = _cameraPosition + _vector3
		end
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
		if cubeScale ~= 1 then
			zoom *= cubeScale
		end
		wallPlane.Transparency = 1
		if getSetting(GameSetting.OrthographicView) then
			wallPlane.Transparency = 0.75
			zoom *= 64
			for i, particle in pairs(cachedParticles) do
				if not particle:IsDescendantOf(Workspace) then
					local _arg0 = i - 1
					table.remove(cachedParticles, _arg0 + 1)
				end
				local _value_1 = not particle.Enabled or particle:GetAttribute("__emitDebounce")
				if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
					continue
				end
				if particle.Rate < math.huge then
					particle:SetAttribute("__emitDebounce", true)
					task.delay(1 / particle.Rate, function()
						return particle:SetAttribute("__emitDebounce", nil)
					end)
				end
				particle:Emit(1)
			end
		end
		local _fn = CFrame
		local _cameraPosition = cameraPosition
		local _vector3 = Vector3.new(0, 0, zoom + velocity)
		local cameraCFrame = _fn.lookAt(_cameraPosition - _vector3, cameraPosition, up)
		local start = cube.Position
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { mapFolder }
		local obstructingPartsList = Workspace:GetPartBoundsInBox(CFrame.new(start.X, start.Y, 0), Vector3.new(32, 32, 4096), params)
		for _, obstructingPart in obstructingPartsList do
			local _value_1 = obstructingPart:GetAttribute("CAMERA_TRANSPARENT")
			if _value_1 ~= 0 and _value_1 == _value_1 and _value_1 ~= "" and _value_1 then
				local _condition_8 = (obstructingPart:GetAttribute("CAMERA_TRANSPARENCY"))
				if _condition_8 == nil then
					_condition_8 = 0.9
				end
				local transparency = _condition_8
				obstructingPart.LocalTransparencyModifier = numLerp(obstructingPart.LocalTransparencyModifier, transparency, dt * 5)
				if not (table.find(prevObstructedParts, obstructingPart) ~= nil) then
					table.insert(prevObstructedParts, obstructingPart)
				end
			end
		end
		for i, obstructingPart in pairs(prevObstructedParts) do
			if not (table.find(obstructingPartsList, obstructingPart) ~= nil) then
				table.remove(prevObstructedParts, i + 1)
				TweenService:Create(obstructingPart, tweenTypes.linear.short, {
					LocalTransparencyModifier = 0,
				}):Play()
			end
		end
		if not replayGui.Enabled and not travelGui.Visible and not isAnimating then
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
		updatePropellers(cube, head, dt)
		updateMud(cube, head, dt)
		updatePlatforms(cube, head)
		local position, nonFiltered, hitPart = mouseRaycast(zoom + 512)
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
					RunService.Heartbeat:Wait()
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
		if cubeScale ~= 1 then
			maxRange *= cubeScale
		end
		local area = getCurrentArea(cube)
		if area == "ErrorLand" then
			armAlignPosition.MaxForce = 6250
			armAlignPosition.Responsiveness = 40
			armAlignOrientation.Responsiveness = 100
			for _, effect in effectsFolder:GetDescendants() do
				if effect:IsA("ParticleEmitter") then
					effect.TimeScale *= 0.5
				end
			end
		end
		local rangeDisplay = cube:FindFirstChild("Range")
		local _result_5 = rangeDisplay
		if _result_5 ~= nil then
			_result_5 = _result_5:IsA("BasePart")
		end
		if _result_5 then
			rangeDisplay.Size = Vector3.new(0, maxRange * 2, maxRange * 2)
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
		local rotationOffset = CFrame.fromOrientation(math.pi / 2, math.pi / 2, 0)
		local _position = cube.Position
		local _vector3_1 = Vector3.new(math.cos(hammerAngle) * actualHammerDistance, math.sin(hammerAngle) * actualHammerDistance)
		local hammerPosition = _position + _vector3_1
		local plane = Vector3.new(1, 1, 0)
		local mouse = UserInputService:GetMouseLocation()
		local trail = head:FindFirstChild("Trail")
		local _result_7 = trail
		if _result_7 ~= nil then
			_result_7 = _result_7:IsA("Trail")
		end
		if _result_7 then
			local isMouseIconVisible = mouseIcon.Visible
			if isMouseIconVisible then
				if trail.Enabled then
					local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
					TweenService:Create(arm, Info, {
						LocalTransparencyModifier = 0.75,
					}):Play()
					TweenService:Create(head, Info, {
						LocalTransparencyModifier = 0.75,
					}):Play()
					trail.Enabled = false
				end
				mouseIcon.Position = UDim2.fromOffset(mouse.X, mouse.Y)
			else
				if not trail.Enabled then
					local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
					TweenService:Create(arm, Info, {
						LocalTransparencyModifier = 0,
					}):Play()
					TweenService:Create(head, Info, {
						LocalTransparencyModifier = 0,
					}):Play()
					trail.Enabled = true
				end
			end
			local hideMouse = player:GetAttribute(PlayerAttributes.Client.HideMouse)
			if hideMouse == true then
				UserInputService.MouseIconEnabled = true
			else
				UserInputService.MouseIconEnabled = not isMouseIconVisible
			end
			mouseVisual.Transparency = if isMouseIconVisible then 1 else 0
		end
		if canMove.Value then
			local inset = GuiService:GetGuiInset()
			local canMove = true
			for _, gui in GUI:GetGuiObjectsAtPosition(mouse.X - inset.X, mouse.Y - inset.Y) do
				if gui:IsDescendantOf(mobileButtons) then
					canMove = false
					break
				end
			end
			if canMove then
				armCFrame.WorldCFrame = CFrame.lookAt(hammerPosition * plane, cube.Position * plane, Vector3.zAxis)
				if currentHammer == Accessories.HammerTexture.Platform then
					armRotation.WorldCFrame = CFrame.fromOrientation(0, 0, math.pi / 2)
				else
					armRotation.WorldCFrame = CFrame.lookAt(cube.Position * plane, head.Position * plane, Vector3.zAxis) * rotationOffset
				end
			end
		end
		if cubeScale ~= 1 then
			armAlignPosition.MaxForce *= (cubeScale - 1) ^ 3 + 1
			if cubeScale > 1 then
				armAlignPosition.Responsiveness *= (cubeScale - 1) ^ 2 + 1
				armAlignOrientation.Responsiveness *= (cubeScale - 1) ^ 2 + 1
			end
		end
		local densityMultiplier = 1 - math.log(math.min(cubeScale, 2))
		local cubeProperties = cube.CurrentPhysicalProperties
		local headProperties = head.CurrentPhysicalProperties
		local armProperties = arm.CurrentPhysicalProperties
		cube.CustomPhysicalProperties = PhysicalProperties.new(0.5 * densityMultiplier, cubeProperties.Friction, cubeProperties.Elasticity, cubeProperties.FrictionWeight, cubeProperties.ElasticityWeight)
		head.CustomPhysicalProperties = PhysicalProperties.new(0.7 * densityMultiplier, headProperties.Friction, headProperties.Elasticity, headProperties.FrictionWeight, headProperties.ElasticityWeight)
		arm.CustomPhysicalProperties = PhysicalProperties.new(0.7 * densityMultiplier, armProperties.Friction, armProperties.Elasticity, armProperties.FrictionWeight, armProperties.ElasticityWeight)
		-- Workspace.Gravity *= math.log(math.abs(cubeScale - 1) + 1) * -1 + 1;
		mouseVisual.Size = Vector3.new(0.5, 0.5, 0.5) * cubeScale
		if debugInfo.Visible then
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
			local _condition_8 = (cube:GetAttribute("destroyed_counter"))
			if _condition_8 == nil then
				_condition_8 = 0
			end
			(left:FindFirstChild("DestroyedCounter")).Text = _fn_1.format("Destroyed Counter: %d", _condition_8)
			local unanchoredParts = 0
			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("BasePart") and not descendant:IsA("Terrain") and not descendant.Anchored then
					unanchoredParts += 1
				end
			end
			(left:FindFirstChild("UnanchoredParts")).Text = string.format("Unanchored Parts: %d", unanchoredParts)
			if cube.AssemblyAngularVelocity.Magnitude > 0 then
				(right:FindFirstChild("VelocityDisplay")).Rotation = 180 + math.deg(math.atan2(cube.AssemblyLinearVelocity.Y, cube.AssemblyLinearVelocity.X));
				(right:FindFirstChild("VelocityDisplay")).Visible = true
			else
				(right:FindFirstChild("VelocityDisplay")).Visible = false
			end
			(right:FindFirstChild("HammerDisplay")).Rotation = math.deg(math.atan2(cube.Position.Y - head.Position.Y, cube.Position.X - head.Position.X))
		end
	end
end)
winAreaLevel1.Touched:Connect(winTouched)
winAreaLevel2.Touched:Connect(winTouched)
Events.ClientReset.Event:Connect(function(fullReset)
	player:SetAttribute(PlayerAttributes.CompletedGame, nil)
	for key in pairs(AbilityCooldowns) do
		AbilityCooldowns[key] = false
	end
	flippedGravity.Value = false
	shakeIntensity.Value = 0
	ragdollTime = 0
	if not fullReset then
		if getSetting(GameSetting.Modifiers) then
			updateModifiers()
		end
		if cube then
			cube:SetAttribute("_previousArea", nil)
		end
	end
end)
Events.StartClientTutorial.Event:Connect(function()
	task.delay(0.1, updateModifiers)
end)
Events.ShowChatBubble.OnClientEvent:Connect(function(bubbleAttachment, content)
	TextChatService:DisplayBubble(bubbleAttachment, content)
end)
Events.FlipGravity.OnClientEvent:Connect(function(isFlipped)
	local _isFlipped = isFlipped
	if type(_isFlipped) == "boolean" then
		flippedGravity.Value = isFlipped
	else
		flippedGravity.Value = not flippedGravity.Value
	end
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.KeyCode == Enum.KeyCode.I and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		debugInfo.Visible = not debugInfo.Visible
	end
end)
for _, descendant in Workspace:GetDescendants() do
	if descendant:IsA("ParticleEmitter") then
		table.insert(cachedParticles, descendant)
	end
end
Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("ParticleEmitter") then
		local _descendant = descendant
		table.insert(cachedParticles, _descendant)
	end
end)
for _, propeller in propellersFolder:GetChildren() do
	task.spawn(newPropeller, propeller)
end
propellersFolder.ChildAdded:Connect(newPropeller)
local _exp = electricalParts:GetChildren()
-- ▼ ReadonlyArray.map ▼
local _newValue = table.create(#_exp)
local _callback = function(part)
	return newElectricalPart(part)
end
for _k, _v in _exp do
	_newValue[_k] = _callback(_v, _k - 1, _exp)
end
-- ▲ ReadonlyArray.map ▲
electricalParts.ChildAdded:Connect(newElectricalPart)
local _exp_1 = resetParts:GetChildren()
-- ▼ ReadonlyArray.map ▼
local _newValue_1 = table.create(#_exp_1)
local _callback_1 = function(part)
	return newResetPart(part)
end
for _k, _v in _exp_1 do
	_newValue_1[_k] = _callback_1(_v, _k - 1, _exp_1)
end
-- ▲ ReadonlyArray.map ▲
resetParts.ChildAdded:Connect(newResetPart)
local level2Teleport = mapFolder:WaitForChild("Level2Teleport")
level2Teleport.Touched:Connect(function(otherPart)
	if not cube then
		return nil
	end
	if otherPart == cube or otherPart == cube:FindFirstChild("Head") or otherPart == cube:FindFirstChild("Arm") then
		doTeleportAnimation(level2Teleport.Position, Vector3.new(-5912, 14, 0))
	end
end)
Events.SaySystemMessage.OnClientEvent:Connect(saySystemMessage)
Events.ClientMessage.Event:Connect(saySystemMessage)
