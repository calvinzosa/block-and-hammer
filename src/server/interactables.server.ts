import {
	Workspace,
} from '@rbxts/services';

import {
	giveBadge,
	Badge,
	PlayerAttributes,
} from 'shared/utils';

const interactablesFolder = Workspace.FindFirstChild('Interactables') as Folder;
const steelHammer = interactablesFolder.FindFirstChild('SteelHammer') as Model;
const glowPart = interactablesFolder.FindFirstChild('Glow') as Model;

(steelHammer.FindFirstChild('Interacted') as RemoteEvent).OnServerEvent.Connect((player) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart')) return;
	
	if (player.GetAttribute('activeQuest') === 'LostSteelHammer') player.SetAttribute(PlayerAttributes.HasSteelHammer, true);
});

(glowPart.FindFirstChild('Interacted') as RemoteEvent).OnServerEvent.Connect((player) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart')) return;
	
	if (player.GetAttribute(PlayerAttributes.GlowDebounce)) return;
	
	player.SetAttribute(PlayerAttributes.GlowDebounce, true);
	task.delay(20, () => player.SetAttribute(PlayerAttributes.GlowDebounce, undefined));
	
	const currentPhase = ((player.GetAttribute('glowPhase') as number | undefined) ?? 0) + 1;
	player.SetAttribute(PlayerAttributes.GlowDebounce, currentPhase);

	if (currentPhase === 5) {
		player.SetAttribute(PlayerAttributes.GlowDebounce, undefined);
		giveBadge(player, Badge.Glowing);
	}
});
