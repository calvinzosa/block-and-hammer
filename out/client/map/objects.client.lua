-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Workspace = _services.Workspace
local Events = {
	ClientReset = ReplicatedStorage:WaitForChild("ClientReset"),
}
local mapFolder = Workspace:WaitForChild("Map")
local nonBreakable = Workspace:WaitForChild("NonBreakable")
local unstablePartsFolder = nonBreakable:WaitForChild("UnstableParts")
local unanchoredPartsFolder = mapFolder:WaitForChild("Unanchored")
local unstableParts = Instance.new("Folder")
local unanchoredParts = Instance.new("Folder")
unstablePartsFolder.Name = `server-{unstablePartsFolder.Name}`
unstableParts.Name = "UnstableParts"
unstableParts.Parent = nonBreakable
unanchoredPartsFolder.Name = `server-{unanchoredPartsFolder.Name}`
unanchoredParts.Name = "UnanchoredParts"
unanchoredParts.Parent = mapFolder
local function newPart(part)
	if part.Parent == unstablePartsFolder then
		if not part:IsA("BasePart") then
			return nil
		end
		local clone = part:Clone()
		clone.CollisionGroup = "objects"
		local attachment = Instance.new("Attachment", clone)
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Attachment0 = attachment
		alignOrientation.CFrame = part.CFrame.Rotation
		alignOrientation.RigidityEnabled = true
		alignOrientation.Parent = attachment
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.Position = part.Position
		alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		alignPosition.MaxAxesForce = Vector3.new(math.huge, 495000, math.huge)
		alignPosition.MaxVelocity = 300
		alignPosition.Responsiveness = 35
		alignPosition.Enabled = false
		alignPosition.Parent = attachment
		task.delay(0.5, function()
			clone.Position = part.Position
			clone.AssemblyLinearVelocity = Vector3.zero
			alignPosition.Enabled = true
		end)
		clone.Anchored = false
		clone.Parent = unstableParts
	elseif part.Parent == unanchoredPartsFolder then
		local clone = part:Clone()
		clone.Parent = unanchoredParts
		if clone:IsA("PVInstance") then
			clone:SetAttribute("_pivot", clone:GetPivot())
			if clone:IsA("BasePart") then
				clone.CollisionGroup = "objects"
				clone:SetAttribute("_linearvelocity", clone.AssemblyLinearVelocity)
				clone:SetAttribute("_angularvelocity", clone.AssemblyAngularVelocity)
			end
		end
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "objects"
				descendant:SetAttribute("_linearvelocity", descendant.AssemblyLinearVelocity)
				descendant:SetAttribute("_angularvelocity", descendant.AssemblyAngularVelocity)
			end
		end
	end
	part:Destroy()
end
Events.ClientReset.Event:Connect(function()
	for _, part in unanchoredPartsFolder:GetChildren() do
		if part:IsA("PVInstance") then
			local pivot = part:GetAttribute("_pivot")
			if typeof(pivot) == "CFrame" then
				part:PivotTo(pivot)
				if part:IsA("BasePart") then
					local linearVelocity = part:GetAttribute("_linearvelocity")
					if typeof(linearVelocity) == "Vector3" then
						part.AssemblyLinearVelocity = linearVelocity
					end
					local angularVelocity = part:GetAttribute("_angularvelocity")
					if typeof(angularVelocity) == "Vector3" then
						part.AssemblyAngularVelocity = angularVelocity
					end
				end
			end
		end
	end
end)
for _, part in unstablePartsFolder:GetChildren() do
	newPart(part)
end
for _, part in unanchoredPartsFolder:GetChildren() do
	newPart(part)
end
unstablePartsFolder.ChildAdded:Connect(newPart)
unanchoredPartsFolder.ChildAdded:Connect(newPart)
