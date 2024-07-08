local rs = game:GetService("RunService")

local umbrella = workspace.umbrella
local center = umbrella.center.Position
for _, wedge in umbrella:GetChildren() do
	if wedge:IsA("WedgePart") then
		wedge:Destroy()
	end
	task.wait()
end

local wedge = Instance.new("WedgePart")
wedge.Anchored = true
wedge.TopSurface = Enum.SurfaceType.Smooth
wedge.BottomSurface = Enum.SurfaceType.Smooth

local alternate = false

local function makeUmbrella(diameter, angle, fidelity)
    local function triangle(a, b, c)
		local edges = {
			{longest = (c - a), other = (b - a), origin = a},
			{longest = (a - b), other = (c - b), origin = b},
			{longest = (b - c), other = (a - c), origin = c}
		}
		
		local edge = edges[1]
		for i = 2, #edges do
			if (edges[i].longest.magnitude > edge.longest.magnitude) then
				edge = edges[i]
			end
		end
		
		local theta = math.acos(edge.longest.unit:Dot(edge.other.unit))
		local w1 = math.cos(theta) * edge.other.magnitude
		local w2 = edge.longest.magnitude - w1
		local h = math.sin(theta) * edge.other.magnitude
		
		local p1 = edge.origin + edge.other * 0.5
		local p2 = edge.origin + edge.longest + (edge.other - edge.longest) * 0.5
		
		local right = edge.longest:Cross(edge.other).unit
		local up = right:Cross(edge.longest).unit
		local back = edge.longest.unit
		
		local cf1 = CFrame.new(
			p1.x, p1.y, p1.z,
			-right.x, up.x, back.x,
			-right.y, up.y, back.y,
			-right.z, up.z, back.z
		)
	 
		local cf2 = CFrame.new(
			p2.x, p2.y, p2.z,
			right.x, up.x, -back.x,
			right.y, up.y, -back.y,
			right.z, up.z, -back.z
		)
		
		alternate = not alternate
		wedge.Color = if alternate then Color3.new(1, 1, 1) else Color3.new(0, 0, 1)
		
		local wedge1 = wedge:Clone()
		wedge1.Size = Vector3.new(0.05, h, w1)
		wedge1.CFrame = cf1 + center
		wedge1.Parent = umbrella
		
		local wedge2 = wedge:Clone()
		wedge2.Size = Vector3.new(0.05, h, w2)
		wedge2.CFrame = cf2 + center
		wedge2.Parent = umbrella
		
		rs.Heartbeat:Wait()
    end
	
    local function createUmbrella(diameter, angle, fidelity)
        local points = {}
        local angleIncrement = 360 / fidelity
        local radius = diameter / 2
        local height = radius * math.tan(math.rad(angle))
		
        for i = 0, fidelity - 1 do
            local currentAngle = math.rad(i * angleIncrement)
            local nextAngle = math.rad((i + 1) * angleIncrement)
			
            local p1 = Vector3.new(0, height, 0)
            local p2 = Vector3.new(radius * math.cos(currentAngle), 0, radius * math.sin(currentAngle))
            local p3 = Vector3.new(radius * math.cos(nextAngle), 0, radius * math.sin(nextAngle))
			
            triangle(p1, p2, p3)
        end
    end
	
    createUmbrella(diameter, angle, fidelity)
end

local fidelity = 18
makeUmbrella(15, 25, fidelity)
wedge:Destroy()

local rs = game:GetService("RunService")

local umbrella = workspace.umbrella
umbrella.PrimaryPart = umbrella.center
local center = umbrella.center.Position

for i = 0, 1, 0.005 do
	local alpha = game.TweenService:GetValue(i, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	umbrella:PivotTo(CFrame.fromOrientation(0, math.pi * 2 * alpha, 0) + center)
	rs.Heartbeat:Wait()
end

umbrella:PivotTo(CFrame.new(center))