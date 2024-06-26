-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local UserInputService = _services.UserInputService
local TweenService = _services.TweenService
local Workspace = _services.Workspace
local Players = _services.Players
local playSound = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").playSound
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local mouseIcon = screenGui:WaitForChild("MouseIcon")
local interactablesFolder = Workspace:WaitForChild("Interactables")
local wasInteracting = false
local function getMouseInteractable()
	if not screenGui.Enabled then
		return nil
	end
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { interactablesFolder }
	local result = Workspace:Raycast(ray.Origin, ray.Direction.Unit * 1024, params)
	return result
end
UserInputService.InputChanged:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local interactable = getMouseInteractable()
		if interactable then
			if not wasInteracting then
				wasInteracting = true
				mouseIcon.Image = "rbxassetid://13414586756"
				mouseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				mouseIcon.Size = UDim2.fromScale(0.044, 1)
				mouseIcon.Visible = true
			end
		else
			if wasInteracting then
				wasInteracting = false
				mouseIcon.Visible = false
			end
		end
	end
end)
UserInputService.InputEnded:Connect(function(input, processed)
	if processed then
		return nil
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local interactable = getMouseInteractable()
		local _part = interactable
		if _part ~= nil then
			_part = _part.Instance
		end
		local part = _part
		if not part or not part:IsDescendantOf(interactablesFolder) then
			return nil
		end
		while part.Parent ~= interactablesFolder do
			local _result = part
			if _result ~= nil then
				_result = _result.Parent
			end
			part = _result
		end
		local _interactedEvent = part
		if _interactedEvent ~= nil then
			_interactedEvent = _interactedEvent:FindFirstChild("Interacted")
		end
		local interactedEvent = _interactedEvent
		local _result = interactedEvent
		if _result ~= nil then
			_result = _result:IsA("RemoteEvent")
		end
		if _result then
			interactedEvent:FireServer()
		end
	end
end)
player.AttributeChanged:Connect(function(attr)
	if attr == "hasSteelHammer" then
		local hasSteelHammer = player:GetAttribute(attr)
		local steelHammer = interactablesFolder:FindFirstChild("SteelHammer")
		local _arm = steelHammer
		if _arm ~= nil then
			_arm = _arm:FindFirstChild("Arm")
		end
		local arm = _arm
		local _head = steelHammer
		if _head ~= nil then
			_head = _head:FindFirstChild("Head")
		end
		local head = _head
		local _result = arm
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		local _condition = not _result
		if not _condition then
			local _result_1 = head
			if _result_1 ~= nil then
				_result_1 = _result_1:IsA("BasePart")
			end
			_condition = not _result_1
		end
		if _condition then
			return nil
		end
		local transparency = if hasSteelHammer then 1 else 0
		arm.Transparency = transparency
		head.Transparency = transparency
	elseif attr == "glowPhase" then
		local phase = player:GetAttribute(attr)
		local glowPart = interactablesFolder:FindFirstChild("Glow")
		local _result = glowPart
		if _result ~= nil then
			_result = _result:IsA("BasePart")
		end
		if not _result then
			return nil
		end
		playSound("magic", {
			Volume = 2,
		})
		local targetPosition = Vector3.new(1598, 5, 5)
		if phase == 1 then
			targetPosition = Vector3.new(335, 115, 5)
		elseif phase == 2 then
			targetPosition = Vector3.new(960, 605, 5)
		elseif phase == 3 then
			targetPosition = Vector3.new(495, 1060, 5)
		elseif phase == 4 then
			targetPosition = Vector3.new(442, 1515, 5)
		end
		TweenService:Create(glowPart, TweenInfo.new(20, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = targetPosition,
		}):Play()
	end
end)
