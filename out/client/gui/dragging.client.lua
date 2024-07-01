-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local UserInputService = _services.UserInputService
local Players = _services.Players
local MouseImageIcon = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "utils").MouseImageIcon
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local screenGui = GUI:WaitForChild("ScreenGui")
local mouseIcon = screenGui:WaitForChild("MouseIcon")
local draggableObjects = {}
local draggedObject = nil
local isHolding = false
local function newObject(object)
	if not object:IsA("GuiObject") then
		return nil
	end
	local _value = object:GetAttribute("draggable")
	if _value ~= 0 and _value == _value and _value ~= "" and _value then
		local _object = object
		table.insert(draggableObjects, _object)
	end
end
local function mouseMoved(position, isTouch)
	if mouseIcon.Visible and (mouseIcon.Image == MouseImageIcon.DragActive or mouseIcon.Image == MouseImageIcon.DragHover) then
		mouseIcon.Visible = false
		mouseIcon.Rotation = 0
	end
	local didFindHoveredObject = false
	for _, object in draggableObjects do
		local isVisible = true
		local parent = object
		while parent and parent ~= GUI do
			if parent:IsA("GuiObject") and not parent.Visible then
				isVisible = false
				break
			end
			parent = parent.Parent
		end
		if not isVisible then
			local _value = object:GetAttribute("isDragging")
			if _value ~= 0 and _value == _value and _value ~= "" and _value then
				object:SetAttribute("isDragging", nil)
			end
			break
		end
		local absolutePosition = object.AbsolutePosition
		local absoluteSize = object.AbsoluteSize
		if not didFindHoveredObject and (draggedObject == object or (not draggedObject and position:Max(absolutePosition):Min(absolutePosition + absoluteSize) == position)) then
			didFindHoveredObject = true
			if isHolding then
				draggedObject = object
				local _value = object:GetAttribute("isDragging")
				if not (_value ~= 0 and _value == _value and _value ~= "" and _value) then
					object:SetAttribute("isDragging", true)
				end
			else
				draggedObject = nil
				local _value = object:GetAttribute("isDragging")
				if _value ~= 0 and _value == _value and _value ~= "" and _value then
					object:SetAttribute("isDragging", nil)
				end
			end
			if not isTouch and not mouseIcon.Visible then
				mouseIcon.Visible = true
				mouseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				mouseIcon.Image = if isHolding then MouseImageIcon.DragActive else MouseImageIcon.DragHover
				mouseIcon.Rotation = -35
				mouseIcon.Size = UDim2.fromOffset(23, 25)
			end
		else
			local _value = object:GetAttribute("isDragging")
			if _value ~= 0 and _value == _value and _value ~= "" and _value then
				object:SetAttribute("isDragging", nil)
			end
		end
	end
end
for _, descendant in GUI:GetDescendants() do
	newObject(descendant)
end
GUI.DescendantAdded:Connect(newObject)
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isHolding = true
		mouseMoved(Vector2.new(input.Position.X, input.Position.Y), input.UserInputType == Enum.UserInputType.Touch)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isHolding = false
		draggedObject = nil
		mouseMoved(Vector2.new(input.Position.X, input.Position.Y), input.UserInputType == Enum.UserInputType.Touch)
	end
end)
UserInputService.TouchMoved:Connect(function(touch)
	mouseMoved(Vector2.new(touch.Position.X, touch.Position.Y), true)
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mouseMoved(Vector2.new(input.Position.X, input.Position.Y), false)
	end
end)
