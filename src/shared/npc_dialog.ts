import {
	ReplicatedStorage,
} from '@rbxts/services';

import {
	PlayerAttributes,
} from './utils';

const Events = {
	'FinishQuest': ReplicatedStorage.WaitForChild('FinishQuest') as RemoteEvent,
	
	'ClientStartQuest': ReplicatedStorage.WaitForChild('ClientStartQuest') as BindableEvent,
};

export type DialogRoot = {
	icon: string;
	talkSound: string;
	talkDelay: number[];
	
	dialog: DialogChoices;
};

export type DialogChoices = {
	default: DialogChoice;
	special: SpecialDialogChoice[];
};

export type DialogChoice = {
	message: string;
	faceTo: '_player' | '_default' | Vector3;
	goodbyeEnabled: boolean;
	choices: Record<string, DialogChoice>;
	
	questName?: string;
	
	func?: (player: Player, npc: BasePart) => void;
	condition?: (player: Player, npc: BasePart) => boolean;
};

export type SpecialDialogChoice = {
	condition: (player: Player, npc: BasePart) => boolean;
} & DialogChoice;

export default {
	TestDialog: {
		icon: '',
		talkSound: '',
		talkDelay: [ 0.1 ],
		dialog: {
			default: {
				message: 'This is a test dialog.\n2nd line.',
				goodbyeEnabled: true,
				faceTo: '_player',
				choices: {
					'Ok.': {
						message: 'idk what top ut hereo wdkawskfw1w2qwrfs',
						goodbyeEnabled: false,
						faceTo: '_default',
						choices: {
							'no!': {
								message: 'ok bye',
								goodbyeEnabled: true,
								faceTo: '_player',
								choices: {  },
							},
						},
					},
				},
			},
			special: [  ],
		},
	},
	Orange: {
		icon: '',
		talkSound: 'rbxassetid://7772738671',
		talkDelay: [ 0.01, 0.015 ],
		dialog: {
			default: {
				message: 'Oh, hello!',
				goodbyeEnabled: true,
				faceTo: '_player',
				choices: {
					'Hello!': {
						message: 'This waterfall is nice, isn\'t it?',
						goodbyeEnabled: true,
						faceTo: '_default',
						choices: {
							'It sure is!': {
								message: 'Hey, if you get my steel hammer near the swamp, I\'ll let you have it!',
								goodbyeEnabled: false,
								faceTo: '_player',
								choices: {
									'Sure!': {
										message: 'Cool! I\'ll wait for you here.',
										goodbyeEnabled: true,
										faceTo: '_player',
										choices: {  },
										
										func: (player: Player, npc: BasePart) => Events.ClientStartQuest.Fire('LostSteelHammer'),
									},
									'Sorry, I can\'t do that right now.': {
										message: 'Okay, that\'s fine.',
										goodbyeEnabled: true,
										faceTo: '_player',
										choices: {  },
									},
								},
							},
						},
					},
				},
			},
			special: [
				{
					condition: (player) => player.GetAttribute(PlayerAttributes.ActiveQuest) === 'LostSteelHammer',
					
					message: 'I see you\'re back, have you found it yet?',
					goodbyeEnabled: false,
					faceTo: '_player',
					choices: {
						'I have found it!': {
							message: 'Thank you! Here, you can have it.',
							goodbyeEnabled: true,
							faceTo: '_player',
							func: () => Events.FinishQuest.FireServer(),
							condition: (player) => player.GetAttribute('hasSteelHammer') as (boolean | undefined) ?? false,
							choices: {  },
						},
						'Nope, not yet': {
							message: 'Oh, okay then.',
							goodbyeEnabled: true,
							faceTo: '_player',
							choices: {  },
						},
						'Where is it?': {
							message: 'I last remember it being in the swamp area.',
							goodbyeEnabled: true,
							faceTo: '_player',
							choices: {  },
						},
					},
				},
			],
		},
	},
} as Record<string, DialogRoot>;
