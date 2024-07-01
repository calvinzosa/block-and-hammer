import {
	ReplicatedStorage,
	GeometryService,
	HttpService,
	RunService,
	Workspace,
} from '@rbxts/services';

import { startsWith } from '@rbxts/string-utils';
import { $warn } from 'rbxts-transform-debug';

import {
	Badge,
	giveBadge,
	randomDirection,
} from 'shared/utils';

const Events = {
	PlaySound: ReplicatedStorage.FindFirstChild('PlaySound') as RemoteEvent,
};

const mapFolder = Workspace.FindFirstChild('Map') as Folder;
const serverTimeLabel = ((mapFolder.FindFirstChild('ServerAgeSign') as BasePart).FindFirstChild('SurfaceGui') as SurfaceGui).FindFirstChild('TextLabel') as TextLabel;
const interactablesFolder = Workspace.FindFirstChild('Interactables') as Folder;
const duck = interactablesFolder.FindFirstChild('Duck') as BasePart;

const untaggedParts = [  ] as BasePart[];

for (const part of mapFolder.GetDescendants()) {
	if (!part.IsA('BasePart')) continue;
	
	if (!part.GetTags().find((tag) => startsWith(tag, 'mapPart-'))) {
		part.AddTag(`mapPart-${HttpService.GenerateGUID()}`);
		untaggedParts.push(part);
	}
}

/*
local b,c=true,0;for _,p in workspace.Map:GetDescendants() do if p:IsA('BasePart') then b=true for _, t in p:GetTags() do if t:find('mapPart-')==1 then b=false break end end
if b then p:AddTag('mapPart-'..game.HttpService:GenerateGUID(false)) c+=1 end end end
print(c)
*/

if (untaggedParts.size() > 0) {
	$warn(`Found ${untaggedParts.size()} untagged part(s):`);
	for (const part of untaggedParts) $warn(part, part.GetFullName());
}

for (const i of $range(1, 300)) {
	task.spawn(() => {
		const vectorA = randomDirection();
		const vectorB = randomDirection();
		
		const debris = new Instance('Part');
		debris.CFrame = CFrame.fromOrientation(vectorA.X * math.pi, vectorA.Y * math.pi, vectorA.Z * math.pi);
		
		const intersect = debris.Clone();
		intersect.CFrame = CFrame.fromOrientation(vectorB.X * math.pi, vectorB.Y * math.pi, vectorB.Z * math.pi);
		
		const unions = GeometryService.IntersectAsync(debris, [intersect]) as PartOperation[];
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

(duck.FindFirstChild('Interacted') as RemoteEvent).OnServerEvent.Connect((player) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart') || cube.Position.sub(duck.Position).Magnitude > 50) return;

	Events.PlaySound.FireClient(player, 'quack');
	giveBadge(player, Badge.TheDuck);
});

RunService.Stepped.Connect((currentTime) => {
	const seconds = math.floor(currentTime % 60);
	const minutes = math.floor(currentTime / 60) % 60;
	const hours = math.floor(currentTime / 3600);
	
	if (hours > 0) serverTimeLabel.Text = string.format('this server has been running for %sh, %sm, %ss', hours, minutes, seconds);
	else if (minutes > 0) serverTimeLabel.Text = string.format('this server has been running for %sm, %ss', minutes, seconds);
	else serverTimeLabel.Text = string.format('this server has been running for %ss', seconds);
});
