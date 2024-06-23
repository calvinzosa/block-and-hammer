-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService = _services.RunService
local Workspace = _services.Workspace
local Players = _services.Players
local player = Players.LocalPlayer
local mapFolder = Workspace:WaitForChild("Map")
local mudParts = mapFolder:WaitForChild("MudParts")
local propellers = mapFolder:WaitForChild("Propellers"):Clone()
local _result = mapFolder:FindFirstChild("Propellers")
if _result ~= nil then
	_result:Destroy()
end
propellers.Parent = mapFolder
local cachedPropellers = {}
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
		warn("[src/client/propellers.client.ts:25]", "An invalid propeller was created.")
		return nil
	end
	local _propeller = propeller
	table.insert(cachedPropellers, _propeller)
end
for _, propeller in propellers:GetChildren() do
	task.spawn(newPropeller, propeller)
end
propellers.ChildAdded:Connect(newPropeller)
RunService.Heartbeat:Connect(function(dt)
	local cube = Workspace:FindFirstChild(`cube{player.UserId}`)
	local _result_1 = cube
	if _result_1 ~= nil then
		_result_1 = _result_1:IsA("BasePart")
	end
	if not _result_1 then
		return nil
	end
	for i, propeller in pairs(cachedPropellers) do
		local blades = propeller:FindFirstChild("Blades")
		local _result_2 = blades
		if _result_2 ~= nil then
			_result_2 = _result_2:IsA("BasePart")
		end
		if not _result_2 then
			warn("[src/client/propellers.client.ts:42]", "A propeller has broke.")
			table.remove(cachedPropellers, i + 1)
			break
		end
		for _, descendant in propeller:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = (blades.AssemblyAngularVelocity.Magnitude >= 5)
			end
		end
	end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = cachedPropellers
	local usedPropellers = {}
	local totalCubeForce = Vector3.zero
	local totalHeadForce = Vector3.zero
	for i, part in pairs({ cube, cube:FindFirstChild("Head") }) do
		local _result_2 = part
		if _result_2 ~= nil then
			_result_2 = _result_2:IsA("BasePart")
		end
		if not _result_2 then
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
				local _result_3 = -1
				for _i, _v in usedPropellers do
					if _callback(_v, _i - 1, usedPropellers) == true then
						_result_3 = _i - 1
						break
					end
				end
				-- ▲ ReadonlyArray.findIndex ▲
				_condition = _result_3 >= 0
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
		local _result_2 = part
		if _result_2 ~= nil then
			_result_2 = _result_2:IsA("BasePart")
		end
		local _condition_1 = _result_2
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
	local _result_2 = propellerForce
	if _result_2 ~= nil then
		_result_2 = _result_2:IsA("VectorForce")
	end
	if _result_2 then
		local _exp = totalCubeForce * gravity
		local _arg0 = dt * 40 * cubeMultiplier
		propellerForce.Force = _exp * _arg0
	end
	local _headPropeller = cube:FindFirstChild("Head")
	if _headPropeller ~= nil then
		_headPropeller = _headPropeller:FindFirstChild("PropellerForce")
	end
	local headPropeller = _headPropeller
	local _result_3 = headPropeller
	if _result_3 ~= nil then
		_result_3 = _result_3:IsA("VectorForce")
	end
	if _result_3 then
		local _exp = totalHeadForce * gravity
		local _arg0 = dt * 10 * headMultiplier
		headPropeller.Force = _exp * _arg0
	end
end)
