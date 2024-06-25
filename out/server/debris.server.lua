-- Compiled with roblox-ts v2.3.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local GeometryService = _services.GeometryService
local random = Random.new()
for i = 1, 300 do
	task.spawn(function()
		local vectorA = random:NextUnitVector()
		local vectorB = random:NextUnitVector()
		local debris = Instance.new("Part")
		debris.CFrame = CFrame.fromOrientation(vectorA.X * math.pi, vectorA.Y * math.pi, vectorA.Z * math.pi)
		local intersect = debris:Clone()
		intersect.CFrame = CFrame.fromOrientation(vectorB.X * math.pi, vectorB.Y * math.pi, vectorB.Z * math.pi)
		local unions = GeometryService:IntersectAsync(debris, { intersect })
		for _, union in unions do
			union.UsePartColor = true
			union.CollisionGroup = "debris"
			union.TopSurface = Enum.SurfaceType.Smooth
			union.BottomSurface = Enum.SurfaceType.Smooth
			union.Parent = ReplicatedStorage:FindFirstChild("DebrisTypes")
		end
		debris:Destroy()
		intersect:Destroy()
	end)
end
