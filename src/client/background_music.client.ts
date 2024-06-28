import { ReplicatedStorage, RunService, Workspace, Players } from '@rbxts/services';

import { convertStudsToMeters, getHammerTexture, GameSetting, Accessories, getSetting, numLerp, PlayerAttributes } from 'shared/utils';

enum Music {
	Jamming = 'Jamming',
	StartingOff = 'StartingOff',
	SolitaryIsle = 'SolitaryIsle',
	CrystalCave = 'CrystalCave',
	Mountain = 'Mountain',
	Garden = 'Garden',
	TheLake = 'TheLake',
	HauntedField = 'HauntedField',
}

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const isSpectating = valueInstances.WaitForChild('is_spectating') as BoolValue;
const spectatePlayer = isSpectating.WaitForChild('player') as StringValue;
const musicFolder = ReplicatedStorage.WaitForChild('Music') as Folder;

const sounds: Record<Music, Sound> = {
	Jamming: musicFolder.WaitForChild('Jamming').Clone() as Sound,
	StartingOff: musicFolder.WaitForChild('Starting Off').Clone() as Sound,
	SolitaryIsle: musicFolder.WaitForChild('Solitary Isle').Clone() as Sound,
	CrystalCave: musicFolder.WaitForChild('Crystal Cave').Clone() as Sound,
	Mountain: musicFolder.WaitForChild('Mountain').Clone() as Sound,
	Garden: musicFolder.WaitForChild('Garden').Clone() as Sound,
	TheLake: musicFolder.WaitForChild('The Lake').Clone() as Sound,
	HauntedField: musicFolder.WaitForChild('Haunted Field').Clone() as Sound,
};

for (const [_, sound] of pairs(sounds)) {
	sound.SetAttribute('originalVolume', sound.Volume);
	sound.Volume = 0;
	sound.Parent = Workspace;

	sound.Play();
}

RunService.RenderStepped.Connect((dt) => {
	let targetPlayer = player;
	if (isSpectating.Value) {
		const otherPlayer = Players.FindFirstChild(spectatePlayer.Name);
		if (otherPlayer?.IsA('Player')) targetPlayer = otherPlayer;
	}

	let targetCube = Workspace.FindFirstChild(`cube${targetPlayer.UserId}`);

	const replayView = Workspace.FindFirstChild('REPLAY_VIEW');
	if (replayView?.IsA('BasePart')) targetCube = replayView;

	const currentHammer = getHammerTexture(targetPlayer);

	let activeMusic = undefined as Music | undefined;
	if (player.GetAttribute(PlayerAttributes.Client.InMainMenu)) activeMusic = Music.Jamming;
	else if (player.GetAttribute(PlayerAttributes.InTutorial)) activeMusic = Music.CrystalCave;
	else if (targetCube?.IsA('BasePart')) {
		const [altitude] = convertStudsToMeters(targetCube.Position.Y - 1.9);
		if (altitude < 100) activeMusic = Music.StartingOff;
		else if (altitude < 200) activeMusic = Music.SolitaryIsle;
		else if (altitude < 300) activeMusic = Music.TheLake;
		else if (altitude < 400) activeMusic = Music.Mountain;
		else if (altitude < 500) activeMusic = Music.HauntedField;
		else if (altitude < 700) activeMusic = Music.Mountain;
		else activeMusic = Music.Garden;
	}

	const isMusicEnabled = getSetting(GameSetting.Music) && !targetPlayer.GetAttribute(PlayerAttributes.InErrorLand);
	for (const [name, sound] of pairs(sounds)) {
		let targetVolume = name === activeMusic && isMusicEnabled ? (sound.GetAttribute('originalVolume') as number) : 0;

		sound.Volume = numLerp(sound.Volume, targetVolume, dt * 5);
		sound.PlaybackSpeed = currentHammer === Accessories.HammerTexture.Hammer404 && targetPlayer.GetAttribute(PlayerAttributes.HasModifiers) ? 0.5 : 1;
	}
});
