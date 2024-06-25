import {
    ReplicatedStorage,
    GeometryService,
} from '@rbxts/services';

const random = new Random();

for (const i of $range(1, 300)) {
    task.spawn(() => {
        const vectorA = random.NextUnitVector();
        const vectorB = random.NextUnitVector();
        
        const debris = new Instance('Part');
        debris.CFrame = CFrame.fromOrientation(vectorA.X * math.pi, vectorA.Y * math.pi, vectorA.Z * math.pi);
        
        const intersect = debris.Clone();
        intersect.CFrame = CFrame.fromOrientation(vectorB.X * math.pi, vectorB.Y * math.pi, vectorB.Z * math.pi);
        
        const unions = GeometryService.IntersectAsync(debris, [ intersect ]) as PartOperation[];
        for (const union of unions) {
            union.UsePartColor = true;
            union.CollisionGroup = 'debris';
            union.TopSurface = Enum.SurfaceType.Smooth;
            union.BottomSurface = Enum.SurfaceType.Smooth;
            union.Parent = ReplicatedStorage.FindFirstChild('DebrisTypes');
        }
        
        debris.Destroy();
        intersect.Destroy();
    });
}