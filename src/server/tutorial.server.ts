import {
	ReplicatedStorage,
	Workspace,
} from '@rbxts/services';

import {
	PlayerAttributes,
	giveBadge,
	Badge,
} from 'shared/utils';

const Events = {
	PlayTutorial: ReplicatedStorage.WaitForChild('PlayTutorial') as RemoteEvent,
	EndTutorial: ReplicatedStorage.WaitForChild('EndTutorial') as RemoteEvent,

	ForceReset: ReplicatedStorage.WaitForChild('ForceReset') as BindableEvent,
};

const mapFolder = Workspace.FindFirstChild('Map') as Folder;
const tutorialFolder = mapFolder.FindFirstChild('Tutorial') as Folder;
const tutorialSpawn = tutorialFolder.FindFirstChild('SpawnLocation') as SpawnLocation;

Events.PlayTutorial.OnServerEvent.Connect((player) => {
	const cube = Workspace.FindFirstChild(`cube${player.UserId}`);
	if (cube?.IsA('BasePart')) {
		cube.Destroy();
		
		Events.ForceReset.Fire(player, true);
		
		const newCube = Workspace.WaitForChild(`cube${player.UserId}`);
		if (newCube.IsA('BasePart')) newCube.PivotTo(tutorialSpawn.CFrame.mul(new CFrame(0, 10, 0)));
	}
});

Events.EndTutorial.OnServerEvent.Connect((player, reachedEnd) => {
	Events.ForceReset.Fire(player, true);
	if (reachedEnd) giveBadge(player, Badge.Learner);
});
