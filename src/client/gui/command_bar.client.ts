import { $warn } from 'rbxts-transform-debug';
$warn('Command bar is not enabled yet');

// import {
//     ReplicatedStorage,
//     UserInputService,
//     TweenService,
//     TextService,
//     Players,
// } from '@rbxts/services';

// import { endsWith, startsWith } from '@rbxts/string-utils';

// import { getPlayerRank } from 'shared/utils';

// const Events = {
//     'RunCommand': ReplicatedStorage.WaitForChild('RunCommand') as RemoteEvent,
// };

// const commands = {
//     cmds: 0,
//     rejoin: 0,
//     equip: 0,
//     flip: 1,
//     fequip: 1,
//     goto: 1,
//     alist: 1,
//     bring: 1,
//     scale: 2,
//     error: 2,
// };

// const player = Players.LocalPlayer;

// const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
// const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
// const commandBarCanvas = screenGui.WaitForChild('CommandBar') as CanvasGroup;
// const container = commandBarCanvas.WaitForChild('Container') as Frame;
// const inputBox = container.WaitForChild('Input') as TextBox;
// const textDisplay = container.WaitForChild('TextDisplay') as TextLabel;
// const cursor = textDisplay.WaitForChild('Cursor') as Frame;

// const playerRank = getPlayerRank(player);

// let currentAutoFillText = undefined as (string | undefined);

// function updateCursor() {
//     const cursorPosition = inputBox.CursorPosition;
//     const selectionStart = inputBox.SelectionStart;
//     if (cursorPosition === -1) {
//         cursor.Visible = false;
//         return;
//     }
    
//     task.wait();
    
//     const text = inputBox.ContentText;
    
//     const startIndex = math.min(selectionStart, cursorPosition);
//     const endIndex = math.max(selectionStart, cursorPosition);
    
//     const params = new Instance('GetTextBoundsParams');
//     params.Font = inputBox.FontFace;
//     params.Size = inputBox.TextSize;
//     params.Width = inputBox.AbsoluteSize.X;
    
//     params.Text = 'A';
//     const textSize = TextService.GetTextBoundsAsync(params);
    
//     if (startIndex !== -1) {
//         params.Text = text.sub(1, startIndex - 1);
//         const position = TextService.GetTextBoundsAsync(params);
        
//         cursor.Size = UDim2.fromOffset((endIndex - startIndex) * textSize.X, inputBox.AbsoluteSize.Y);
//         cursor.Position = new UDim2(0, position.X, 1, 0);
//         cursor.Transparency = 0.5;
//     } else {
//         params.Text = text.sub(1, endIndex - 1);
//         const position = TextService.GetTextBoundsAsync(params);
        
//         cursor.Size = UDim2.fromOffset(textSize.X, 3);
//         cursor.Position = new UDim2(0, position.X, 1, 0);
//         cursor.Transparency = 0;
//     }
    
//     cursor.Visible = true;
// }

// UserInputService.InputBegan.Connect((input, processed) => {
//     if (input.KeyCode === Enum.KeyCode.Tab && inputBox.IsFocused() && inputBox.CursorPosition > inputBox.ContentText.size()) {
//         const tabCharacter = '	';
//         while (!endsWith(inputBox.Text, tabCharacter)) inputBox.GetPropertyChangedSignal('ContentText').Wait();
        
//         const text = inputBox.Text.sub(1, inputBox.Text.size() - 1);
//         inputBox.Text = text;
        
//         if (currentAutoFillText) {
//             inputBox.Text = currentAutoFillText;
//             inputBox.CursorPosition = currentAutoFillText.size() + 1;
            
//             currentAutoFillText = undefined;
//         }
//     }
// });

// UserInputService.InputEnded.Connect((input, processed) => {
//     if (processed) return;
    
//     if (input.KeyCode === Enum.KeyCode.Semicolon) {
//         commandBarCanvas.GroupTransparency = 1;
//         TweenService.Create(commandBarCanvas, new TweenInfo(0.25, Enum.EasingStyle.Linear), { GroupTransparency: 0 }).Play();
//         commandBarCanvas.Visible = true;
        
//         inputBox.CaptureFocus();
//     }
// });

// inputBox.FocusLost.Connect((enterPressed) => {
//     if (enterPressed) Events.RunCommand.FireServer(inputBox.ContentText);
    
//     inputBox.Text = '';
    
//     commandBarCanvas.GroupTransparency = 0;
//     TweenService.Create(commandBarCanvas, new TweenInfo(0.5, Enum.EasingStyle.Linear), { GroupTransparency: 1 }).Play();
//     task.delay(0.6, () => {
//         if (commandBarCanvas.GroupTransparency === 1) commandBarCanvas.Visible = false;
//     });
// });

// inputBox.GetPropertyChangedSignal('ContentText').Connect(() => {
//     const text = inputBox.ContentText;
//     textDisplay.Text = inputBox.ContentText;
    
//     task.wait();
    
//     if (text.size() > 0) {
//         const wordsList = [  ] as string[];
        
//         if (wordsList.size() === 1) {
//             let currentWord = '';
            
//             for (const i of $range(1, text.size())) {
//                 const character = text.sub(i, i);
//                 if ((character === ' ' || i === text.size() || i === inputBox.CursorPosition) && currentWord.size() > 0) {
//                     wordsList.push(currentWord);
//                     currentWord = '';
//                     if (i === inputBox.CursorPosition) break;
//                 } else currentWord += character;
//             }
            
//             const autoCompletions = [  ];
//             for (const [ commandName, rank ] of pairs(commands)) {
//                 if (playerRank >= rank && startsWith(commandName, text)) autoCompletions.push(commandName);
//             }
            
//             if (autoCompletions.size() > 0) {
//                 const sortedAutoCompletions = autoCompletions.sort();
//                 currentAutoFillText = sortedAutoCompletions[0];
                
//                 const completionText = currentAutoFillText.sub(text.size() + 1);
//                 textDisplay.Text += `<font color="#aaa">${completionText}</font>`;
//             }
//         }
//     }
// });

// inputBox.GetPropertyChangedSignal('CursorPosition').Connect(updateCursor);
// inputBox.GetPropertyChangedSignal('SelectionStart').Connect(updateCursor);