import {
    ReplicatedStorage,
    BadgeService,
    RunService,
	Workspace,
    Players,
	TweenService,
	Debris,
} from '@rbxts/services';

import {
	Accessories,
	PlayerAttributes
} from 'shared/utils';

import { reloadAccessories, loadAccessories } from 'shared/accessory_loader';

const Events = {
    'BuildingHammerPlace': ReplicatedStorage.FindFirstChild('BuildingHammerPlace') as RemoteEvent,
	
    'LoadPlayerAccessories': ReplicatedStorage.FindFirstChild('LoadPlayerAccessories') as BindableEvent,
}

const mapFolder = Workspace.FindFirstChild('Map') as Folder;

const removeFunctions: Record<number, () => void | undefined> = {  };

Events.LoadPlayerAccessories.Event.Connect((player, cube) => {
    if (!typeIs(player, 'Instance') || !player.IsA('Player') || !typeIs(cube, 'Instance') || !cube.IsA('BasePart')) return;
    
	while (!player.GetAttribute(PlayerAttributes.HasDataLoaded)) task.wait();
	
    if (cube.Parent !== Workspace) return;
	
	const hasRemoveFunction = (player.UserId in removeFunctions);
	
	const hammerRemoveFunction = loadAccessories(
		cube,
		{
			face: player.GetAttribute(PlayerAttributes.CubeFace) as (string | undefined),
			hammer: player.GetAttribute(PlayerAttributes.HammerTexture) as (string | undefined),
			hat: player.GetAttribute(PlayerAttributes.CubeHat) as (string | undefined),
			aura: player.GetAttribute(PlayerAttributes.CubeAura) as (string | undefined)
		},
		player,
		hasRemoveFunction ? removeFunctions[player.UserId] : undefined
	);
	
	if (player.UserId in removeFunctions) delete removeFunctions[player.UserId];
	if (typeIs(hammerRemoveFunction, 'function')) removeFunctions[player.UserId] = hammerRemoveFunction;
	
	reloadAccessories(cube, player);
});

Events.BuildingHammerPlace.OnServerEvent.Connect((player, position, buildType) => {
	if (player.GetAttribute(PlayerAttributes.HammerTexture) !== Accessories.HammerTexture.BuilderHammer || !typeIs(position, 'Vector3') || !typeIs(buildType, 'number')) return;
	
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	const head = cube?.FindFirstChild('Head')
	if (!cube?.IsA('BasePart') || !head?.IsA('BasePart')) return;
	
	const part = new Instance('Part');
	part.Name = `part${player.UserId}`;
	part.Anchored = true;
	part.Position = position;
	part.BrickColor = BrickColor.random();
	part.TopSurface = Enum.SurfaceType.Smooth;
	part.BottomSurface = Enum.SurfaceType.Smooth;
	part.Parent = mapFolder;
	
	if (buildType === 0) part.Size = new Vector3(7, 1, 7);
	else if (buildType === 1) part.Size = new Vector3(1, 7, 7);
	
	const billboardGui = new Instance('BillboardGui');
	billboardGui.Size = UDim2.fromScale(1.5, 1.5);
	billboardGui.AlwaysOnTop = true;
	
	const label = new Instance('TextLabel');
	label.Text = '20.0s';
	label.TextSize = 20;
	label.Size = UDim2.fromScale(1, 1);
	label.Font = Enum.Font.BuilderSansBold;
	label.TextColor3 = new Color3(1, 1, 1);
	label.TextStrokeTransparency = 0;
	label.BackgroundTransparency = 1;
	label.Parent = billboardGui;
	
	billboardGui.Parent = part;
	
	TweenService.Create(part, new TweenInfo(0.5, Enum.EasingStyle.Linear), { Transparency: 0 }).Play();
	TweenService.Create(label, new TweenInfo(0.5, Enum.EasingStyle.Linear), { TextTransparency: 0, TextStrokeTransparency: 0 }).Play();
	
	let timer = 25;
	part.SetAttribute('timer', timer);
	while (timer > 0) {
		const dt = task.wait();
		timer -= dt;
		
		part.SetAttribute('timer', timer);
		label.Text = string.format('%.1fs', timer);
	}
	
	label.Text = '0.0s';
	
	TweenService.Create(part, new TweenInfo(1, Enum.EasingStyle.Linear), { Transparency: 1 }).Play();
	TweenService.Create(label, new TweenInfo(1, Enum.EasingStyle.Linear), { TextTransparency: 1, TextStrokeTransparency: 1 }).Play();
	
	Debris.AddItem(part, 1);
});

Players.PlayerRemoving.Connect((player) => {
	delete removeFunctions[player.UserId];
});