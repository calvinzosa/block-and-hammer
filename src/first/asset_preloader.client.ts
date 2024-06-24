const ReplicatedFirst = game.GetService('ReplicatedFirst');
const ContentProvider = game.GetService('ContentProvider');
const Players = game.GetService('Players');

import { $print } from 'rbxts-transform-debug';

const AssetIds = {
	Audios: [
		// SFX
		'rbxassetid://9076854890', 'rbxassetid://5801257793', 'rbxassetid://9113131247', 'rbxassetid://3417831369', 'rbxassetid://6239232266',
		'rbxassetid://6746263591', 'rbxassetid://5134377245', 'rbxassetid://821439273', 'rbxassetid://4780469887', 'rbxassetid://130976109',
		'rbxassetid://9118159665', 'rbxassetid://134188543', 'rbxassetid://836142578', 'rbxassetid://2048662066','rbxassetid://9118614718',
		'rbxassetid://9116910432', 'rbxassetid://9113819607', 'rbxassetid://17778392816',
		
		// Music
		'rbxassetid://1844234702', 'rbxassetid://13616520700', 'rbxassetid://13639365943', 'rbxassetid://13639401235', 'rbxassetid://13651211094',
		'rbxassetid://17750941254'
    ]
};

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const mainMenuGui = ReplicatedFirst.WaitForChild('MainMenuGui') as ScreenGui;
const shadow = mainMenuGui.WaitForChild('Shadow') as Frame;
const shadowLoading = shadow.WaitForChild('Loading') as TextLabel;

shadow.Visible = true;
mainMenuGui.Parent = GUI;

player.SetAttribute('in_main_menu', true);

ReplicatedFirst.RemoveDefaultLoadingScreen();

$print('Created loading screen');

for (const audioId of AssetIds.Audios) {
    shadowLoading.Text = `attempting to preload asset ${audioId}`;
	ContentProvider.PreloadAsync([ audioId ], (_, status: Enum.AssetFetchStatus) => {
		if (status === Enum.AssetFetchStatus.Success) shadowLoading.Text = `preloaded asset ${audioId}`;
        else shadowLoading.Text = `asset ${audioId} failed to preload with status '${status.Name}'`;
    });
}

$print('Finished preloading assets');

mainMenuGui.SetAttribute('done', true);