import {
    ReplicatedStorage,
    Players,
} from '@rbxts/services';

import {
    getTimeUnits,
    getTime,
} from 'shared/utils';

const player = Players.LocalPlayer;

const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const itemTemplate = guiTemplates.WaitForChild('StatItem') as TextLabel;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const statsGui = screenGui.WaitForChild('StatsGUI') as Frame;
const statsTitle = statsGui.WaitForChild('Title') as TextLabel;
const list = statsGui.WaitForChild('List') as ScrollingFrame;

function formatTime(totalSeconds: number) {
    const [ hours, minutes, seconds ] = getTimeUnits(totalSeconds * 1000);
    
    let result = [  ];
    
    if (hours > 0) result.push(`${hours} hour${hours === 1 ? '' : 's'}`);
    if (minutes > 0) result.push(`${minutes} minute${minutes === 1 ? '' : 's'}`);
    
    result.push(`${seconds} second${seconds === 1 ? '' : 's'}`);
    return result.join(', ');
}

statsGui.GetPropertyChangedSignal('Visible').Connect(() => {
    if (!statsGui.Visible) return;
    
    statsTitle.Text = `player stats for ${player.DisplayName} (@${player.Name})`;
    
    const currentTime = getTime();
    
    const data = [
        `total time played: ${formatTime(currentTime - (player.GetAttribute('serverJoinTime') as (number | undefined) ?? currentTime))}`,
        `total times joined: ${(player.GetAttribute('timesJoined') as (number | undefined) ?? 1)}`,
        `total wins: ${(player.GetAttribute('totalWins') as (number | undefined) ?? 0)}`,
        `total modded wins: ${(player.GetAttribute('totalModdedWins') as (number | undefined) ?? 0)}`,
        `total resets: ${(player.GetAttribute('totalRestarts') as (number | undefined) ?? 0)}`,
        `amount of times ragdolled: ${player.GetAttribute('totalRagdolls') as (number | undefined) ?? 0}`,
    ];
    
    for (const item of list.GetChildren()) {
        if (item.IsA('TextLabel')) item.Destroy();
    }
    
    for (const text of data) {
        let item = itemTemplate.Clone();
        item.Text = text;
        item.Parent = list;
    }
});