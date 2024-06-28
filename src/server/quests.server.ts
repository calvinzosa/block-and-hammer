import { ReplicatedStorage } from '@rbxts/services';

import { PlayerAttributes, giveBadge } from 'shared/utils';

import questData from 'shared/quest_data';

const Events = {
	CancelQuest: ReplicatedStorage.FindFirstChild('CancelQuest') as RemoteEvent,
	FinishQuest: ReplicatedStorage.FindFirstChild('FinishQuest') as RemoteEvent,
	StartQuest: ReplicatedStorage.FindFirstChild('StartQuest') as RemoteEvent,
};

Events.StartQuest.OnServerEvent.Connect((player, questName) => {
	if (!typeIs(questName, 'string')) return;

	if (questName in questData) player.SetAttribute(PlayerAttributes.ActiveQuest, questName);
});

Events.CancelQuest.OnServerEvent.Connect((player) => {
	player.SetAttribute(PlayerAttributes.ActiveQuest, undefined);
});

Events.FinishQuest.OnServerEvent.Connect(function (player) {
	const questName = player.GetAttribute(PlayerAttributes.ActiveQuest);

	if (questName === 'LostSteelHammer') {
		if (player.GetAttribute(PlayerAttributes.HasSteelHammer)) giveBadge(player, 4010328408057079);
	}

	player.SetAttribute(PlayerAttributes.ActiveQuest, undefined);
});
