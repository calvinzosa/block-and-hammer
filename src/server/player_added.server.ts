import {
    ReplicatedStorage,
    BadgeService,
    RunService,
    Workspace,
    Players,
} from '@rbxts/services';

import {
    Accessories,
    PlayerAttributes,
    computeNameColor,
	convertStudsToMeters,
	getTime,
	giveBadge
} from 'shared/utils';

import { reloadAccessories } from 'shared/accessory_loader';
import { Admins } from 'shared/admins';

const Events = {
    'SetModifiersSetting': ReplicatedStorage.FindFirstChild('SetModifiersSetting') as RemoteEvent,
    'AddRagdollCount': ReplicatedStorage.FindFirstChild('AddRagdollCount') as RemoteEvent,
    'SetDeviceType': ReplicatedStorage.FindFirstChild('SetDeviceType') as RemoteEvent,
    'FlipGravity': ReplicatedStorage.FindFirstChild('FlipGravity') as RemoteEvent,
	'Reset': ReplicatedStorage.FindFirstChild('Reset') as RemoteEvent,
	
	'LoadPlayerAccessories': ReplicatedStorage.FindFirstChild('LoadPlayerAccessories') as BindableEvent,
	'ForceReset': ReplicatedStorage.FindFirstChild('ForceReset') as BindableEvent,
};

const mapFolder = Workspace.FindFirstChild('Map') as Folder;
const trappedArea = mapFolder.FindFirstChild('trapped_area') as BasePart;

const cubeTemplate = ReplicatedStorage.FindFirstChild('Cube') as BasePart;

function createCube(player: Player, firstTime: boolean) {
    Workspace.FindFirstChild(`cube${player.Name}`)?.Destroy();
    
    if (player.UserId === -1) player.SetAttribute(PlayerAttributes.HammerTexture, Accessories.HammerTexture.GrapplingHammer);
    
    Events.FlipGravity.FireClient(player, false);
    
    const cube = cubeTemplate.Clone();
    cube.Name = `cube${player.UserId}`;
    cube.Color = computeNameColor(player.Name);
	
	const overheadGui = cube.FindFirstChild('OverheadGUI') as BillboardGui;
	const icons = overheadGui.FindFirstChild('Icons') as Frame;
	
    (overheadGui.FindFirstChild('Username') as TextLabel).Text = `${player.DisplayName} (@${player.Name})`;
    
    const device = player.GetAttribute('device');
    if (device === 0) (icons.FindFirstChild('Desktop') as ImageLabel).Visible = true;
    else if (device === 1) (icons.FindFirstChild('Mobile') as ImageLabel).Visible = true;
	
    if (player.MembershipType === Enum.MembershipType.Premium) (icons.FindFirstChild('Premium') as ImageLabel).Visible = true;
	if (player.IsFriendsWith(game.CreatorId)) (icons.FindFirstChild('Friend') as ImageLabel).Visible = true;
	if (Admins.find((userId) => userId === player.UserId)) (icons.FindFirstChild('Admin') as ImageLabel).Visible = true;
	if (player.UserId === game.CreatorId) (icons.FindFirstChild('Developer') as ImageLabel).Visible = true;
	
	icons.Visible = true;
	
	if (player.GetAttribute('modifiers')) cube.SetAttribute('used_modifiers', true);
	
	player.SetAttribute('total_time', undefined);
	cube.SetAttribute('start_time', getTime());
	cube.Parent = Workspace;
	
	const head = cube.FindFirstChild('Head') as BasePart;
	
	task.spawn(() => {
		while (!cube.CanSetNetworkOwnership()) task.wait();
		
		cube.SetNetworkOwner(player);
		head.SetNetworkOwner(player);
	});
	
	cube.Touched.Connect((otherPart) => {
		if (otherPart === trappedArea) giveBadge(player, 2146259996);
	});
	
	if (!firstTime) player.SetAttribute('finished', false);
	while (!player.GetAttribute('DATA_LOADED')) task.wait();
	
	const cubeColor = player.GetAttribute('CUBE_COLOR')
	if (typeIs(cubeColor, 'Color3')) cube.Color = cubeColor;
	
	Events.LoadPlayerAccessories.Fire(player, cube);
	
	task.delay(1, () => {
		if (cube.Parent !== Workspace) return;
		
		reloadAccessories(cube, player);
		cube.GetPropertyChangedSignal('Color').Connect(() => reloadAccessories(cube, player));
	});
}

function characterAdded(character: Model) {
	const rootPart = character.WaitForChild('HumanoidRootPart') as BasePart;
	rootPart.Anchored = true;
}

function playerAdded(player: Player) {
	task.spawn(() => {
		if (!BadgeService.UserHasBadgeAsync(player.UserId, 1967915839777317)) {
			giveBadge(player, 1967915839777317);
			player.SetAttribute('isNew', true);
		}
		
		giveBadge(player, 4410861265533965);
	});
	
	createCube(player, true);
	
	if (player.Character) characterAdded(player.Character);
	player.CharacterAdded.Connect(characterAdded);
}

function resetPlayer(player: Player, fullReset: any) {
	if (!player || !typeIs(fullReset, 'boolean')) return;
	
	let cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (fullReset && cube) {
		cube.Destroy();
		cube = undefined;
	}
	
	if (cube?.IsA('BasePart')) {
		cube.SetAttribute('extra_time', undefined);
		cube.SetAttribute('finishTotalTime', undefined);
		cube.SetAttribute('destroyed_counter', 0);
		
		player.SetAttribute('finished', undefined);
		if (!player.GetAttribute('modifiers')) cube.SetAttribute('used_modifiers', undefined);
		
		cube.SetAttribute('start_time', getTime());
	} else createCube(player, false);
	
	player.SetAttribute('totalRestarts', (player.GetAttribute('totalRestarts') as number ?? 0) + 1);
}

Events.SetModifiersSetting.OnServerEvent.Connect((player, isEnabled) => {
	if (!typeIs(isEnabled, 'boolean')) return;
	
	player.SetAttribute('modifiers', isEnabled);
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (cube) cube.SetAttribute('used_modifiers', true);
});

Events.SetDeviceType.OnServerEvent.Connect((player, device) => {
	if (!typeIs(device, 'number')) return;
	
	if (device === 0 || device === 1) {
		player.SetAttribute('device', device)
		
		const cube = Workspace.FindFirstChild(`cube{player.UserId}`)
		if (cube) {
			const overheadGui = cube.FindFirstChild('OverheadGUI') as BillboardGui;
			const icons = overheadGui.FindFirstChild('Icons') as Frame;
			const desktop = icons.FindFirstChild('Desktop') as ImageLabel;
			const mobile = icons.FindFirstChild('Mobile') as ImageLabel;
			
			desktop.Visible = false;
			mobile.Visible = false;
			
			if (device === 0) desktop.Visible = true;
			else if (device === 1) mobile.Visible = true;
		}
	}
});

Events.AddRagdollCount.OnServerEvent.Connect((player) => {
	player.SetAttribute('totalRagdolls', (player.GetAttribute('totalRagdolls') as number ?? 0) + 1);
});

Players.PlayerAdded.Connect(playerAdded);

Events.Reset.OnServerEvent.Connect(resetPlayer);
Events.ForceReset.Event.Connect(resetPlayer);

RunService.Stepped.Connect(() => {
	for (const player of Players.GetPlayers()) {
		const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as (BasePart | undefined);
		if (cube) {
			const [ altitude ] = convertStudsToMeters(cube.Position.Y - 1.9);
			if (altitude > 800) {
				if (player.GetAttribute('gravityBadge') === undefined) {
					player.SetAttribute('gravityBadge', true);
					giveBadge(player, 1719451122385638);
					continue;
				}
			} else if (player.GetAttribute('gravityBadge') !== undefined) player.SetAttribute('gravityBadge', undefined);
			
			const [ speed ] = convertStudsToMeters(math.abs(cube.AssemblyLinearVelocity.X));
			if (speed > 70) {
				if (player.GetAttribute('speedBadge') === undefined) {
					player.SetAttribute('speedBadge', true);
					giveBadge(player, 2146687990);
				}
			} else if (player.GetAttribute('speedBadge')) player.SetAttribute('speedBadge', undefined);
		}
	}
});