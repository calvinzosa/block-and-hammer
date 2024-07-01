-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Workspace = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Workspace
local unstableParts = Instance.new("Folder")
unstableParts.Name = "UnstableParts"
local nonBreakable = Workspace:WaitForChild("NonBreakable")
local unstablePartsFolder = nonBreakable:WaitForChild("UnstableParts")
task.wait(5)
for _, part in unstablePartsFolder:GetChildren() do
	if not part:IsA("BasePart") then
		continue
	end
	local clone = part:Clone()
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
end
unstablePartsFolder:Destroy()
unstableParts.Parent = nonBreakable
