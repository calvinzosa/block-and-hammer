import {
	ReplicatedStorage,
	Players,
} from '@rbxts/services';

import quests from 'shared/quests';
import { PlayerAttributes } from 'shared/utils';

const Events = {
	CancelQuest: ReplicatedStorage.FindFirstChild('CancelQuest') as RemoteEvent,
	FinishQuest: ReplicatedStorage.FindFirstChild('FinishQuest') as RemoteEvent,
	StartQuest: ReplicatedStorage.FindFirstChild('StartQuest') as RemoteEvent,
	
	ClientStartQuest: ReplicatedStorage.FindFirstChild('ClientStartQuest') as BindableEvent,
};

const player = Players.LocalPlayer;

const GUI = player.WaitForChild('PlayerGui');
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const questGui = screenGui.WaitForChild('QuestGUI') as Frame;
const questCancelConfirmation = screenGui.WaitForChild('QuestCancelConfirmation') as Frame;
const questAlreadyStarted = screenGui.WaitForChild('QuestAlreadyStarted') as Frame;
const questStartConfirmation = screenGui.WaitForChild('QuestStartConfirmation') as Frame;
const activeQuest = questGui.WaitForChild('ActiveQuest') as Frame;
const activeQuestInfo = activeQuest.WaitForChild('Info') as Frame;
const infoTitle = activeQuestInfo.WaitForChild('Title') as TextLabel;
const infoDescription = activeQuestInfo.WaitForChild('Description') as TextLabel;
const infoNone = activeQuest.WaitForChild('None') as TextLabel;

(activeQuestInfo.WaitForChild('Cancel') as TextButton).MouseButton1Click.Connect(() => {
	questGui.Visible = false;
	questCancelConfirmation.Visible = true;
});

(questAlreadyStarted.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
	questAlreadyStarted.Visible = false;
	questGui.Visible = true;
});

(questCancelConfirmation.WaitForChild('No') as TextButton).MouseButton1Click.Connect(() => {
	questCancelConfirmation.Visible = false;
	questGui.Visible = true;
});

(questCancelConfirmation.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
	questCancelConfirmation.Visible = false;
	questGui.Visible = true;
	
	Events.CancelQuest.FireServer();
});

(questStartConfirmation.WaitForChild('No') as TextButton).MouseButton1Click.Connect(() => {
	questStartConfirmation.Visible = false;
	questGui.Visible = true;
});

(questStartConfirmation.WaitForChild('Yes') as TextButton).MouseButton1Click.Connect(() => {
	questStartConfirmation.Visible = false;
	questGui.Visible = true;
	
	Events.StartQuest.FireServer(questStartConfirmation.GetAttribute('questName'));
});

questGui.GetPropertyChangedSignal('Visible').Connect(() => {
	const questName = player.GetAttribute(PlayerAttributes.ActiveQuest);
	if (typeIs(questName, 'string') && questName in quests) {
		const data = quests[questName];
		
		infoTitle.Text = data.name;
		infoTitle.Visible = true;
		infoDescription.Text = data.description;
		activeQuestInfo.Visible = true;
		
		infoNone.Visible = false;
	} else {
		activeQuestInfo.Visible = false;
		infoNone.Visible = true;
	}
});

Events.ClientStartQuest.Event.Connect((questName: string) => {
	const currentQuest = player.GetAttribute('quest');
	if (!currentQuest) Events.StartQuest.FireServer(questName);
	else if (currentQuest === questName) questAlreadyStarted.Visible = true;
	else {
		questAlreadyStarted.SetAttribute('questName', questName);
		questAlreadyStarted.Visible = true;
	}
});