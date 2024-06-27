import {
    ReplicatedStorage,
    BadgeService,
    RunService,
    Workspace,
    Players,
	Chat,
} from '@rbxts/services';

import {
	convertStudsToMeters,
    PlayerAttributes,
    computeNameColor,
    Accessories,
	giveBadge,
	getTime,
	getTimeUnits,
	getHammerTexture,
} from 'shared/utils';

import { reloadAccessories } from 'shared/accessory_loader';
import { startsWith } from '@rbxts/string-utils';
import { Admins } from 'shared/admins';

const Events = {
	'SayMessageRequest': ReplicatedStorage.WaitForChild('DefaultChatSystemChatEvents').WaitForChild('SayMessageRequest') as RemoteEvent,
    'SetModifiersSetting': ReplicatedStorage.FindFirstChild('SetModifiersSetting') as RemoteEvent,
	'SaySystemMessage': ReplicatedStorage.FindFirstChild('SaySystemMessage') as RemoteEvent,
    'AddRagdollCount': ReplicatedStorage.FindFirstChild('AddRagdollCount') as RemoteEvent,
	'ShowChatBubble': ReplicatedStorage.FindFirstChild('ShowChatBubble') as RemoteEvent,
    'DestroyedPart': ReplicatedStorage.FindFirstChild('DestroyedPart') as RemoteEvent,
    'SetDeviceType': ReplicatedStorage.FindFirstChild('SetDeviceType') as RemoteEvent,
	'CompleteGame': ReplicatedStorage.FindFirstChild('CompleteGame') as RemoteEvent,
	'GroundImpact': ReplicatedStorage.FindFirstChild('GroundImpact') as RemoteEvent,
    'FlipGravity': ReplicatedStorage.FindFirstChild('FlipGravity') as RemoteEvent,
	'Reset': ReplicatedStorage.FindFirstChild('Reset') as RemoteEvent,
	
	'LoadPlayerAccessories': ReplicatedStorage.FindFirstChild('LoadPlayerAccessories') as BindableEvent,
	'UpdatePlayerTime': ReplicatedStorage.FindFirstChild('UpdatePlayerTime') as BindableEvent,
	'ForceReset': ReplicatedStorage.FindFirstChild('ForceReset') as BindableEvent,
};

const cubeTemplate = ReplicatedStorage.FindFirstChild('Cube') as BasePart;
const targetCenter = Workspace.FindFirstChild('TargetCenter') as BasePart;
const mapFolder = Workspace.FindFirstChild('Map') as Folder;
const trappedArea = mapFolder.FindFirstChild('trapped_area') as BasePart;
const gravityFlipper = mapFolder.WaitForChild('gravity_flipper') as BasePart;

function createCube(player: Player, firstTime: boolean) {
    Workspace.FindFirstChild(`cube${player.Name}`)?.Destroy();
    
    if (player.UserId === -1) player.SetAttribute(PlayerAttributes.HammerTexture, Accessories.HammerTexture.GrapplingHammer);
    
    Events.FlipGravity.FireClient(player, false);
    
    const cube = cubeTemplate.Clone();
    cube.Name = `cube${player.UserId}`;
    cube.Color = computeNameColor(player.Name);
	cube.Parent = Workspace;
	
	const head = cube.FindFirstChild('Head') as BasePart;
	const overheadGui = cube.FindFirstChild('OverheadGUI') as BillboardGui;
	const icons = overheadGui.FindFirstChild('Icons') as Frame;
	
    (overheadGui.FindFirstChild('Username') as TextLabel).Text = `${player.DisplayName} (@${player.Name})`;
    
    const device = player.GetAttribute(PlayerAttributes.Device);
    if (device === 0) (icons.FindFirstChild('Desktop') as ImageLabel).Visible = true;
    else if (device === 1) (icons.FindFirstChild('Mobile') as ImageLabel).Visible = true;
	
    if (player.MembershipType === Enum.MembershipType.Premium) (icons.FindFirstChild('Premium') as ImageLabel).Visible = true;
	if (player.IsFriendsWith(game.CreatorId)) (icons.FindFirstChild('Friend') as ImageLabel).Visible = true;
	if (Admins.find((userId) => userId === player.UserId)) (icons.FindFirstChild('Admin') as ImageLabel).Visible = true;
	if (player.UserId === game.CreatorId) (icons.FindFirstChild('Developer') as ImageLabel).Visible = true;
	
	icons.Visible = true;
	
	if (player.GetAttribute(PlayerAttributes.HasModifiers) || (cube.GetAttribute('scale') ?? 1) !== 1) cube.SetAttribute('used_modifiers', true);
	
	player.SetAttribute(PlayerAttributes.TotalTime, undefined);
	cube.SetAttribute('start_time', getTime());
	
	task.spawn(() => {
		while (!cube.CanSetNetworkOwnership()) task.wait();
		
		cube.SetNetworkOwner(player);
		head.SetNetworkOwner(player);
	});
	
	cube.Touched.Connect((otherPart) => {
		if (otherPart === trappedArea) giveBadge(player, 2146259996);
	});
	
	if (!firstTime) player.SetAttribute(PlayerAttributes.CompletedGame, false);
	while (!player.GetAttribute(PlayerAttributes.HasDataLoaded)) task.wait();
	
	const cubeColor = player.GetAttribute(PlayerAttributes.CubeColor);
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
			player.SetAttribute(PlayerAttributes.IsNew, true);
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
		
		player.SetAttribute(PlayerAttributes.CompletedGame, undefined);
		if (!player.GetAttribute(PlayerAttributes.HasModifiers)) cube.SetAttribute('used_modifiers', undefined);
		
		cube.SetAttribute('start_time', getTime());
	} else createCube(player, false);
	
	player.SetAttribute(PlayerAttributes.TotalRestarts, (player.GetAttribute(PlayerAttributes.TotalRestarts) as number ?? 0) + 1);
}

Events.SetModifiersSetting.OnServerEvent.Connect((player, isEnabled) => {
	if (!typeIs(isEnabled, 'boolean')) return;
	
	player.SetAttribute(PlayerAttributes.HasModifiers, isEnabled);
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (cube) cube.SetAttribute('used_modifiers', true);
});

Events.SetDeviceType.OnServerEvent.Connect((player, device) => {
	if (!typeIs(device, 'number')) return;
	
	if (device === 0 || device === 1) {
		player.SetAttribute(PlayerAttributes.Device, device);
		
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
	player.SetAttribute(PlayerAttributes.TotalRagdolls, (player.GetAttribute(PlayerAttributes.TotalRagdolls) as (number | undefined) ?? 0) + 1);
});

Events.GroundImpact.OnServerEvent.Connect((player, velocity, position) => {
	if (!typeIs(velocity, 'Vector3') || !typeIs(position, 'Vector3')) return;
	
	const newImpacts = (player.GetAttribute(PlayerAttributes.Impacts) as (number | undefined) ?? 0) + 1;
	player.SetAttribute(PlayerAttributes.Impacts, newImpacts);
	
	if (newImpacts >= 15 && !player.GetAttribute(PlayerAttributes.HasExplosiveBadge)) {
		player.SetAttribute(PlayerAttributes.HasExplosiveBadge, true);
		giveBadge(player, 2146508969);
	}
	
	if (velocity.Y > 892.857) giveBadge(player, 4279006041653694);
	else if (velocity.Y > 357.142) {
		if (player.GetAttribute('didShatter')) giveBadge(player, 2512066188170235);
		else {
			const params = new OverlapParams();
			params.FilterDescendantsInstances = [ targetCenter ];
			params.FilterType = Enum.RaycastFilterType.Include;
			
			if (Workspace.GetPartBoundsInBox(new CFrame(position), new Vector3(4, 4, 4), params).size() > 0) giveBadge(player, 2479031288528448);
		}
	} else giveBadge(player, 2146180612);
});

Events.CompleteGame.OnServerEvent.Connect((player, givenTime) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart') || !typeIs(givenTime, 'number')) return;
	
	const totalTime = math.min(givenTime, 3599.999);
	
	cube.SetAttribute('finishTotalTime', totalTime);
	player.SetAttribute('finished', true);
	
	const [ hours, minutes, seconds, milliseconds ] = getTimeUnits(totalTime * 1000);
	const formattedTime = string.format('%02d:%02d.%03d', minutes, seconds, milliseconds);
	
	if (cube.GetAttribute('used_modifiers')) {
		Events.SaySystemMessage.FireClient(player, `nice! you completed a modded run in: ${formattedTime}`);
		Events.UpdatePlayerTime.Fire(player.UserId, totalTime, 1);
		
		player.SetAttribute(PlayerAttributes.TotalModdedWins, (player.GetAttribute(PlayerAttributes.TotalModdedWins) as (number | undefined) ?? 0) + 1);
		return;
	} else {
		Events.UpdatePlayerTime.Fire(player.UserId, totalTime, 0);
		
		player.SetAttribute(PlayerAttributes.TotalWins, (player.GetAttribute(PlayerAttributes.TotalWins) as (number | undefined) ?? 0) + 1);
	}
	
	giveBadge(player, 2146411244);
	
	if (cube.GetAttribute('destroyed_counter') === 0) {
		Events.SaySystemMessage.FireClient(player, `nice! you completed a pacifist run in: ${formattedTime}`);
		giveBadge(player, 2146295992);
	} else Events.SaySystemMessage.FireClient(player, `nice! you completed a normal run in: ${formattedTime}`);
	
	cube.SetAttribute('start_time', getTime() - totalTime);
	
	if (totalTime < 210) giveBadge(player, 2146538368);
});

Events.DestroyedPart.OnServerEvent.Connect((player, otherPart) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`)
	if (!cube || !typeIs(otherPart, 'Instance') || !otherPart.IsA('BasePart')) return;
	
	if (otherPart.GetAttribute('CAN_SHATTER')) {
		player.SetAttribute('didShatter', true);
		task.delay(10, () => {
			if (player.Parent === Players) player.SetAttribute('didShatter', undefined);
		});
	}
	
	const count = (cube.GetAttribute('destroyed_counter') as (number | undefined) ?? 0) + 1;
	cube.SetAttribute('destroyed_counter', count);
	
	if (otherPart.Name === `part${player.UserId}` && getHammerTexture(player) === Accessories.HammerTexture.BuilderHammer) otherPart.SetAttribute('timer', 0);
});

Events.SayMessageRequest.OnServerEvent.Connect((player, message, channel) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	const bubbleAttachment = cube?.FindFirstChild('BubbleOrigin');
	if (!cube?.IsA('BasePart') || !bubbleAttachment?.IsA('BasePart') || !typeIs(message, 'string') || !typeIs(channel, 'string')) return;
	
	if (startsWith(message, '/w ') || channel !== 'All') return;
	
	for (const otherPlayer of Players.GetPlayers()) {
		const filteredMessage = Chat.FilterStringAsync(message, player, otherPlayer);
		Events.ShowChatBubble.FireClient(otherPlayer, bubbleAttachment, filteredMessage);
	}
});

for (const player of Players.GetPlayers()) playerAdded(player);
Players.PlayerAdded.Connect(playerAdded);

Events.Reset.OnServerEvent.Connect(resetPlayer);
Events.ForceReset.Event.Connect(resetPlayer);

gravityFlipper.TouchEnded.Connect((otherPart) => {
	for (const player of Players.GetPlayers()) {
		if (otherPart.Name === `cube${player.UserId}`) {
			if (!player.GetAttribute('gravityFlipDebounce')) {
				player.SetAttribute(PlayerAttributes.GravityFlipDebounce, true);
				
				Events.FlipGravity.FireClient(player, true);
				task.delay(2, () => {
					Events.FlipGravity.FireClient(player, false);
					
					player.SetAttribute(PlayerAttributes.GravityFlipDebounce, undefined)
				});
			}
			
			break;
		}
	}
});

RunService.Stepped.Connect(() => {
	for (const player of Players.GetPlayers()) {
		const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as (BasePart | undefined);
		if (cube) {
			const [ altitude ] = convertStudsToMeters(cube.Position.Y - 1.9);
			if (altitude > 800) {
				if (player.GetAttribute(PlayerAttributes.HasGravityBadge) === undefined) {
					player.SetAttribute(PlayerAttributes.HasGravityBadge, true);
					giveBadge(player, 1719451122385638);
					continue;
				}
			} else if (player.GetAttribute(PlayerAttributes.HasGravityBadge) !== undefined) player.SetAttribute(PlayerAttributes.HasGravityBadge, undefined);
			
			const [ speed ] = convertStudsToMeters(math.abs(cube.AssemblyLinearVelocity.X));
			if (speed > 70) {
				if (player.GetAttribute(PlayerAttributes.HasSpeedBadge) === undefined) {
					player.SetAttribute(PlayerAttributes.HasSpeedBadge, true);
					giveBadge(player, 2146687990);
				}
			} else if (player.GetAttribute(PlayerAttributes.HasSpeedBadge)) player.SetAttribute(PlayerAttributes.HasSpeedBadge, undefined);
		}
	}
});