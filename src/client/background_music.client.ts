import {
	ReplicatedStorage,
	RunService,
	Workspace,
	Players,
} from '@rbxts/services';
import { $print } from 'rbxts-transform-debug';

import {
	convertStudsToMeters,
	getHammerTexture,
	PlayerAttributes,
	getCurrentArea,
	GameSetting,
	Accessories,
	getSetting,
	numLerp,
} from 'shared/utils';

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const valueInstances = GUI.WaitForChild('Values') as ScreenGui;
const isSpectating = valueInstances.WaitForChild('is_spectating') as BoolValue;
const spectatePlayer = isSpectating.WaitForChild('player') as StringValue;
const musicFolder = ReplicatedStorage.WaitForChild('Music') as Folder;

const Music = {
	Jamming: musicFolder.WaitForChild('Jamming').Clone() as Sound,
	StartingOff: musicFolder.WaitForChild('Starting Off').Clone() as Sound,
	SolitaryIsle: musicFolder.WaitForChild('Solitary Isle').Clone() as Sound,
	CrystalCave: musicFolder.WaitForChild('Crystal Cave').Clone() as Sound,
	Mountain: musicFolder.WaitForChild('Mountain').Clone() as Sound,
	Garden: musicFolder.WaitForChild('Garden').Clone() as Sound,
	TheLake: musicFolder.WaitForChild('The Lake').Clone() as Sound,
	HauntedField: musicFolder.WaitForChild('Haunted Field').Clone() as Sound,
	ForestOfFall: musicFolder.WaitForChild('Forest Of Fall').Clone() as Sound,
	CrystallizedAbyss: musicFolder.WaitForChild('Crystallized Abyss').Clone() as Sound,
};

for (const [ , sound ] of pairs(Music)) {
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
	
	let activeMusic = undefined as (Sound | undefined);
	
	if (player.GetAttribute(PlayerAttributes.Client.InMainMenu)) activeMusic = Music.Jamming;
	else if (targetCube?.IsA('BasePart')) {
		const area = getCurrentArea(targetCube);
		
		const [ altitude ] = convertStudsToMeters(targetCube.Position.Y, true);
		if (area === 'Tutorial') {
			activeMusic = Music.CrystalCave;
		} else if (area === 'Level 1') {
			if (altitude < 100) activeMusic = Music.StartingOff;
			else if (altitude < 200) activeMusic = Music.SolitaryIsle;
			else if (altitude < 300) activeMusic = Music.TheLake;
			else if (altitude < 400) activeMusic = Music.Mountain;
			else if (altitude < 500) activeMusic = Music.HauntedField;
			else if (altitude < 700) activeMusic = Music.Mountain;
			else activeMusic = Music.Garden;
		} else if (area === 'Level 2: Entrance') {
			activeMusic = Music.ForestOfFall;
		} else if (area === 'Level 2: Cave 1') {
			activeMusic = Music.CrystallizedAbyss;
		} else if (area === 'Level 2') {
			
		}
	}
	
	for (const [ , sound ] of pairs(Music)) {
		let targetVolume = sound === activeMusic ? (sound.GetAttribute('originalVolume') as number) : 0;
		
		sound.Volume = numLerp(sound.Volume, targetVolume, dt * 5);
		sound.PlaybackSpeed = currentHammer === Accessories.HammerTexture.Hammer404 && targetPlayer.GetAttribute(PlayerAttributes.HasModifiers) ? 0.5 : 1;
	}
});