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
	computeNameColor,
	getHammerTexture,
	PlayerAttributes,
	getCurrentArea,
	getTimeUnits,
	Accessories,
	giveBadge,
	getTime,
	Badge,
} from 'shared/utils';

import { reloadAccessories } from 'shared/accessory_loader';
import { startsWith } from '@rbxts/string-utils';
import admins from 'shared/admins';

const Events = {
	SayMessageRequest: ReplicatedStorage.WaitForChild('DefaultChatSystemChatEvents').WaitForChild('SayMessageRequest') as RemoteEvent,
	SetModifiersSetting: ReplicatedStorage.FindFirstChild('SetModifiersSetting') as RemoteEvent,
	SaySystemMessage: ReplicatedStorage.FindFirstChild('SaySystemMessage') as RemoteEvent,
	AddRagdollCount: ReplicatedStorage.FindFirstChild('AddRagdollCount') as RemoteEvent,
	ShowChatBubble: ReplicatedStorage.FindFirstChild('ShowChatBubble') as RemoteEvent,
	DestroyedPart: ReplicatedStorage.FindFirstChild('DestroyedPart') as RemoteEvent,
	SetDeviceType: ReplicatedStorage.FindFirstChild('SetDeviceType') as RemoteEvent,
	CompleteGame: ReplicatedStorage.FindFirstChild('CompleteGame') as RemoteEvent,
	GroundImpact: ReplicatedStorage.FindFirstChild('GroundImpact') as RemoteEvent,
	FlipGravity: ReplicatedStorage.FindFirstChild('FlipGravity') as RemoteEvent,
	SetColor: ReplicatedStorage.FindFirstChild('SetColor') as RemoteEvent,
	Reset: ReplicatedStorage.FindFirstChild('Reset') as RemoteEvent,

	LoadPlayerAccessories: ReplicatedStorage.FindFirstChild('LoadPlayerAccessories') as BindableEvent,
	UpdatePlayerTime: ReplicatedStorage.FindFirstChild('UpdatePlayerTime') as BindableEvent,
	ForceReset: ReplicatedStorage.FindFirstChild('ForceReset') as BindableEvent,
};

const cubeTemplate = ReplicatedStorage.FindFirstChild('Cube') as BasePart;
const targetCenter = Workspace.FindFirstChild('TargetCenter') as BasePart;
const areasFolder = Workspace.FindFirstChild('Areas') as Folder;
const mapFolder = Workspace.FindFirstChild('Map') as Folder;
const trappedArea = mapFolder.FindFirstChild('trapped_area') as BasePart;
const gravityFlipper = mapFolder.WaitForChild('gravity_flipper') as BasePart;

function createCube(player: Player, firstTime: boolean, prevArea = 'None') {
	Workspace.FindFirstChild(`cube${player.Name}`)?.Destroy();

	if (player.UserId === -1) player.SetAttribute(PlayerAttributes.HammerTexture, Accessories.HammerTexture.GrapplingHammer);
	
	Events.FlipGravity.FireClient(player, false);
	
	const cube = cubeTemplate.Clone();
	cube.Name = `cube${player.UserId}`;
	cube.Color = computeNameColor(player.Name);
	cube.Parent = Workspace;
	
	let position = new Vector3(0, 0, 0);
	if (prevArea === 'Level 2' || prevArea === 'Level 2: Cave 1') position = new Vector3(-5912, 0, 0);
	
	cube.SetAttribute('previousVelocity', Vector3.zero);
	cube.PivotTo(new CFrame(position.X, position.Y + 14, position.Z));
	
	const head = cube.FindFirstChild('Head') as BasePart;
	const overheadGui = cube.FindFirstChild('OverheadGUI') as BillboardGui;
	const icons = overheadGui.FindFirstChild('Icons') as Frame;
	
	(overheadGui.FindFirstChild('Username') as TextLabel).Text = `${player.DisplayName} (@${player.Name})`;
	
	const device = player.GetAttribute(PlayerAttributes.Device);
	if (device === 0) (icons.FindFirstChild('Desktop') as ImageLabel).Visible = true;
	else if (device === 1) (icons.FindFirstChild('Mobile') as ImageLabel).Visible = true;
	
	if (player.MembershipType === Enum.MembershipType.Premium) (icons.FindFirstChild('Premium') as ImageLabel).Visible = true;
	if (player.IsFriendsWith(game.CreatorId)) (icons.FindFirstChild('Friend') as ImageLabel).Visible = true;
	if (admins.find((userId) => userId === player.UserId)) (icons.FindFirstChild('Admin') as ImageLabel).Visible = true;
	if (player.UserId === game.CreatorId) (icons.FindFirstChild('Developer') as ImageLabel).Visible = true;
	
	icons.Visible = true;
	
	if (player.GetAttribute(PlayerAttributes.HasModifiers) || (cube.GetAttribute('scale') ?? 1) !== 1) cube.SetAttribute('used_modifiers', true);
	
	player.SetAttribute(PlayerAttributes.TotalTime, undefined);
	cube.SetAttribute('start_time', getTime());
	
	task.spawn(() => {
		let [ canSetNetworkOwner ] = cube.CanSetNetworkOwnership();
		while (!canSetNetworkOwner) {
			task.wait(0.1);
			[ canSetNetworkOwner ] = cube.CanSetNetworkOwnership();
		}
		
		cube.SetNetworkOwner(player);
		head.SetNetworkOwner(player);
	});
	
	cube.Touched.Connect((otherPart) => {
		if (otherPart === trappedArea) giveBadge(player, Badge.Trapped);
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
		if (!BadgeService.UserHasBadgeAsync(player.UserId, Badge.Welcome)) {
			giveBadge(player, Badge.Welcome);
			player.SetAttribute(PlayerAttributes.IsNew, true);
		}
		
		giveBadge(player, Badge.Visits35k);
		giveBadge(player, Badge.Visits1k);
	});

	createCube(player, true);

	if (player.Character) characterAdded(player.Character);
	player.CharacterAdded.Connect(characterAdded);
}

function resetPlayer(player: Player, fullReset: any) {
	if (!player || !typeIs(fullReset, 'boolean')) return;
	
	let cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	
	const prevArea = getCurrentArea(cube);
	
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
	} else createCube(player, false, prevArea);
	
	player.SetAttribute(PlayerAttributes.TotalRestarts, ((player.GetAttribute(PlayerAttributes.TotalRestarts) as number) ?? 0) + 1);
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

		const cube = Workspace.FindFirstChild(`cube{player.UserId}`);
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
	player.SetAttribute(PlayerAttributes.TotalRagdolls, ((player.GetAttribute(PlayerAttributes.TotalRagdolls) as number | undefined) ?? 0) + 1);
});

Events.GroundImpact.OnServerEvent.Connect((player, velocity, position) => {
	if (!typeIs(velocity, 'Vector3') || !typeIs(position, 'Vector3')) return;
	
	const newImpacts = ((player.GetAttribute(PlayerAttributes.Impacts) as number | undefined) ?? 0) + 1;
	player.SetAttribute(PlayerAttributes.Impacts, newImpacts);
	
	if (newImpacts >= 15 && !player.GetAttribute(PlayerAttributes.HasExplosiveBadge)) {
		player.SetAttribute(PlayerAttributes.HasExplosiveBadge, true);
		task.delay(30, () => {
			if (player.Parent === Players) player.SetAttribute(PlayerAttributes.HasExplosiveBadge, undefined);
		});
		
		giveBadge(player, Badge.Explosive);
	}
	
	if (velocity.Y > 892.857) giveBadge(player, Badge.METEOR);
	else if (velocity.Y > 357.142) {
		if (player.GetAttribute('didShatter')) giveBadge(player, Badge.FreezingMisfortune);
		else {
			const params = new OverlapParams();
			params.FilterDescendantsInstances = [ targetCenter ];
			params.FilterType = Enum.RaycastFilterType.Include;

			if (Workspace.GetPartBoundsInBox(new CFrame(position), new Vector3(4, 4, 4), params).size() > 0) giveBadge(player, Badge.LongShot);
		}
	} else giveBadge(player, Badge.CrashLanding);
});

Events.CompleteGame.OnServerEvent.Connect((player, givenTime) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart') || !typeIs(givenTime, 'number')) return;
	
	const totalTime = math.min(givenTime, 3599.999);
	
	cube.SetAttribute('finishTotalTime', totalTime);
	player.SetAttribute(PlayerAttributes.CompletedGame, true);
	
	const currentArea = getCurrentArea(cube, true);
	if (currentArea === 'Level 1') giveBadge(player, Badge.ProfessionalClimberI);
	// else if (currentArea === 'Level 2') giveBadge(player, Badge.ProfessionalClimberII);
	
	if (currentArea === 'Level 2') {
		Events.SaySystemMessage.FireClient(player, 'level 2 is unfinished so i cant give you any badges just yet');
		return;
	}
	
	const [ , minutes, seconds, milliseconds ] = getTimeUnits(totalTime * 1000);
	const formattedTime = string.format('%02d:%02d.%03d', minutes, seconds, milliseconds);
	
	if (cube.GetAttribute('used_modifiers')) {
		Events.SaySystemMessage.FireClient(player, `nice! you completed a modded run in: ${formattedTime}`);
		Events.UpdatePlayerTime.Fire(player.UserId, totalTime, 1);
		
		player.SetAttribute(PlayerAttributes.TotalModdedWins, ((player.GetAttribute(PlayerAttributes.TotalModdedWins) as number | undefined) ?? 0) + 1);
		return;
	} else {
		Events.UpdatePlayerTime.Fire(player.UserId, totalTime, 0);

		player.SetAttribute(PlayerAttributes.TotalWins, ((player.GetAttribute(PlayerAttributes.TotalWins) as number | undefined) ?? 0) + 1);
	}
	
	if (cube.GetAttribute('destroyed_counter') === 0) {
		Events.SaySystemMessage.FireClient(player, `nice! you completed a pacifist run in: ${formattedTime}`);
		giveBadge(player, Badge.Pacifist);
	} else Events.SaySystemMessage.FireClient(player, `nice! you completed '${currentArea}' in: ${formattedTime}`);
	
	cube.SetAttribute('start_time', getTime() - totalTime);
	
	if (totalTime < 210) giveBadge(player, Badge.Speedrunner);
});

Events.DestroyedPart.OnServerEvent.Connect((player, otherPart) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube || !typeIs(otherPart, 'Instance') || !otherPart.IsA('BasePart')) return;
	
	if (otherPart.GetAttribute('CAN_SHATTER')) {
		player.SetAttribute(PlayerAttributes.DidShatterPart, true);
		task.delay(10, () => {
			if (player.Parent === Players) player.SetAttribute(PlayerAttributes.DidShatterPart, undefined);
		});
	}
	
	const count = ((cube.GetAttribute('destroyed_counter') as number | undefined) ?? 0) + 1;
	cube.SetAttribute('destroyed_counter', count);

	if (otherPart.Name === `part${player.UserId}` && getHammerTexture(player) === Accessories.HammerTexture.BuilderHammer) otherPart.SetAttribute('timer', 0);
});

Events.SetColor.OnServerEvent.Connect((player, color) => {
	if (!typeIs(color, 'Color3')) return;
	
	player.SetAttribute(PlayerAttributes.CubeColor, color);
	
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (cube?.IsA('BasePart')) cube.Color = color;
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

((areasFolder.FindFirstChild('Level 2: Cave 1') as Model).FindFirstChild('Main') as BasePart).Touched.Connect((otherPart) => {
	if (!otherPart.GetAttribute('isCube')) return;
	
	const userId = tonumber(otherPart.Name.sub(5)) ?? -1;
	const player = Players.GetPlayerByUserId(userId);
	if (player && !player.GetAttribute(PlayerAttributes.HasLevel2)) {
		player.SetAttribute(PlayerAttributes.HasLevel2, true);
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

					player.SetAttribute(PlayerAttributes.GravityFlipDebounce, undefined);
				});
			}

			break;
		}
	}
});

RunService.Stepped.Connect(() => {
	for (const player of Players.GetPlayers()) {
		const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as BasePart | undefined;
		if (cube) {
			const [ canSetNetworkOwner ] = cube.CanSetNetworkOwnership();
			if (canSetNetworkOwner) {
				if (cube.GetNetworkOwner() !== player && !cube.GetAttribute('networkOwnerDebounce')) {
					try {
						cube.SetNetworkOwner(player);
					} catch (err) {  }
					
					cube.SetAttribute('networkOwnerDebounce', true);
					task.delay(2, () => cube.SetAttribute('networkOwnerDebounce', undefined));
				}
			}
			
			const [ altitude ] = convertStudsToMeters(cube.Position.Y, true);
			if (altitude > 800) {
				if (player.GetAttribute(PlayerAttributes.HasGravityBadge) === undefined) {
					player.SetAttribute(PlayerAttributes.HasGravityBadge, true);
					giveBadge(player, Badge.FreeFloater);
					continue;
				}
			} else if (player.GetAttribute(PlayerAttributes.HasGravityBadge) !== undefined) player.SetAttribute(PlayerAttributes.HasGravityBadge, undefined);
			
			const [ speed ] = convertStudsToMeters(math.abs(cube.AssemblyLinearVelocity.X));
			if (speed > 70) {
				if (player.GetAttribute(PlayerAttributes.HasSpeedBadge) === undefined) {
					player.SetAttribute(PlayerAttributes.HasSpeedBadge, true);
					giveBadge(player, Badge.UltraSpeed);
				}
			} else if (player.GetAttribute(PlayerAttributes.HasSpeedBadge)) player.SetAttribute(PlayerAttributes.HasSpeedBadge, undefined);
		}
	}
});
