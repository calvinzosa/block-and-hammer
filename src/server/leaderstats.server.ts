import { Players } from '@rbxts/services';

const defaultLeaderstats: Record<string, keyof CreatableInstances> = {
	Time: 'StringValue',
	Altitude: 'StringValue',
};

function playerAdded(player: Player) {
	const folder = new Instance('Folder');
	folder.Name = 'leaderstats';
	folder.Parent = player;

	for (const [name, className] of pairs(defaultLeaderstats)) {
		const value = new Instance(className);
		value.Name = name;
		value.Parent = folder;
	}
}

for (const player of Players.GetPlayers()) playerAdded(player);
Players.PlayerAdded.Connect(playerAdded);
