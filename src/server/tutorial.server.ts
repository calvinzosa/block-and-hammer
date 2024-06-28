import { ReplicatedStorage, Workspace } from '@rbxts/services';

import { PlayerAttributes, giveBadge } from 'shared/utils';

const Events = {
	PlayTutorial: ReplicatedStorage.WaitForChild('PlayTutorial') as RemoteEvent,
	EndTutorial: ReplicatedStorage.WaitForChild('EndTutorial') as RemoteEvent,

	ForceReset: ReplicatedStorage.WaitForChild('ForceReset') as BindableEvent,
};

Events.PlayTutorial.OnServerEvent.Connect((player) => {
	player.SetAttribute(PlayerAttributes.InTutorial, true);

	Workspace.FindFirstChild(`cube${player.UserId}`)?.Destroy();
});

Events.EndTutorial.OnServerEvent.Connect((player, reachedEnd) => {
	player.SetAttribute(PlayerAttributes.InTutorial, undefined);

	Events.ForceReset.Fire(player, true);
	if (reachedEnd) giveBadge(player, 2146706248);
});
