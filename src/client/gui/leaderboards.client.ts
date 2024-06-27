import {
    ReplicatedStorage,
    HttpService,
    Players,
} from '@rbxts/services';

import { $print, $warn } from 'rbxts-transform-debug';

import {
    getTimeUnits,
} from 'shared/utils';

const Events = {
    'UpdateLeaderboard': ReplicatedStorage.FindFirstChild('UpdateLeaderboard') as RemoteEvent,
    
    'UpdatePlayerTime': ReplicatedStorage.FindFirstChild('UpdatePlayerTime') as BindableEvent,
};

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const playerTemplate = guiTemplates.WaitForChild('Player') as Frame;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const leaderboardGui = screenGui.WaitForChild('LeaderboardGUI') as Frame;

let data: Record<string, Record<number, [ number, number ]>> = { GlobalLeaderboard: {  }, ModdedLeaderboard: {  } };

Events.UpdateLeaderboard.OnClientEvent.Connect((encodedData: string) => {
	data = HttpService.JSONDecode(encodedData) as Record<string, Record<number, [ number, number ]>>;
    $print('Recieved new leaderboard info');
});

leaderboardGui.GetPropertyChangedSignal('Visible').Connect(() => {
    for (const [ name, values ] of pairs(data)) {
		const frame = leaderboardGui.WaitForChild(name) as Frame;
        const list = frame.WaitForChild('List') as ScrollingFrame;
		
        for (const item of list.GetChildren()) {
            if (item.IsA('Frame')) item.Destroy();
        }
		
        for (const [ number, data ] of pairs(values)) {
            const userId = data[0];
            const totalTimeMilliseconds = data[1];
			
            let name = `[ ${userId} ]`;
            try {
                name = Players.GetNameFromUserIdAsync(userId);
            } catch (err) {
                $warn(err);
            }
			
			const [ , minutes, seconds, milliseconds ] = getTimeUnits(totalTimeMilliseconds);
			
			const item = playerTemplate.Clone();
			item.LayoutOrder = number;
			(item.FindFirstChild('Number') as TextLabel).Text = tostring(number);
			(item.FindFirstChild('Username') as TextLabel).Text = name;
			(item.FindFirstChild('Time') as TextLabel).Text = string.format('%02d:%02d.%03d', minutes, seconds, milliseconds);
			(item.FindFirstChild('Icon') as ImageLabel).Image = `https://www.roblox.com/bust-thumbnail/image?userId=${userId}&width=117&height=117&format=png`;
			item.Parent = list;
		}
	}
})