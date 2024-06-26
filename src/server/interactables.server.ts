import {
	Workspace,
} from '@rbxts/services';

import {
	giveBadge
} from 'shared/utils';

const interactablesFolder = Workspace.FindFirstChild('Interactables') as Folder;
const steelHammer = interactablesFolder.FindFirstChild('SteelHammer') as Model;
const glowPart = interactablesFolder.FindFirstChild('Glow') as Model;

(steelHammer.FindFirstChild('Interacted') as RemoteEvent).OnServerEvent.Connect((player) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart')) return;
	
	if (player.GetAttribute('activeQuest') === 'LostSteelHammer') player.SetAttribute('hasSteelHammer', true);
});

(glowPart.FindFirstChild('Interacted') as RemoteEvent).OnServerEvent.Connect((player) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (!cube?.IsA('BasePart')) return;
	
	if (player.GetAttribute('glowDebounce')) return;
	
	player.SetAttribute('glowDebounce', true);
	task.delay(20, () => player.SetAttribute('glowDebounce', undefined));
	
	const currentPhase = (player.GetAttribute('glowPhase') as (number | undefined) ?? 0) + 1;
	player.SetAttribute('glowPhase', currentPhase);
	
	if (currentPhase === 5) {
		player.SetAttribute('glowPhase', undefined);
		giveBadge(player, 254003402602004);
	}
});