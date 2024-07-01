import {
    ReplicatedStorage,
    Players,
} from '@rbxts/services';
import { isTestingServer } from 'shared/utils';

const player = Players.LocalPlayer;

const guiTemplates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const itemTemplate = guiTemplates.WaitForChild('ChangelogItem') as TextLabel;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const screenGui = GUI.WaitForChild('ScreenGui');
const changelogs = screenGui.WaitForChild('Changelogs') as Frame;
const items = changelogs.WaitForChild('Items') as ScrollingFrame;
const content = items.WaitForChild('Content') as TextLabel;

let text = content.Text;
if (isTestingServer()) text = 'nuh uh!!';

for (const [ i, line ] of pairs(text.split('\n'))) {
    let result = '';
    let word = '';
    for (const [ j, char ] of pairs(line.split(''))) {
        if (char === ' ' || j === line.size()) {
            if (char !== ' ') {
                word = word + char;
            } if (word === '-') {
                result += '•';
            } else if (word.sub(1, 1) === '*' && word.reverse().sub(1, 1) === '*') {
                if (word.sub(2, 2) === '*' && word.reverse().sub(2, 2) === '*') result += `<b>${word.sub(3, word.size() - 2)}</b>`
                else result += `<i>${word.sub(2, word.size() - 1)}</i>`
            } else {
                result += word;
            }
            
            word = '';
            result += ' ';
        } else word += char;
    }
    
    const item = itemTemplate.Clone();
    item.Text = `<stroke thickness="1">${result.sub(1, result.size() - 1)}</stroke>`;
    item.LayoutOrder = i;
    item.Parent = items;
}

content.Destroy();