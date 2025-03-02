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

export type GameDialogRoot = {
	icon: string;
	talkSound: string;
	talkDelay: number[];
	
	dialog: GameDialogChoices;
};

export type GameDialogChoices = {
	default: GameDialogChoice;
	special: GameSpecialDialogChoice[];
};

export type GameDialogChoice = {
	message: string;
	faceTo: '_player' | '_default' | Vector3;
	goodbyeEnabled: boolean;
	choices: Record<string, GameDialogChoice>;
	
	questName?: string;
	
	func?: (player: Player, npc: BasePart) => void;
	condition?: (player: Player, npc: BasePart) => boolean;
};

export type GameSpecialDialogChoice = {
	condition: (player: Player, npc: BasePart) => boolean;
} & GameDialogChoice;

export default {
	TestDialog: {
		icon: '',
		talkSound: '',
		talkDelay: [ 0.1, 0.1 ],
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
	bob: {
		icon: '',
		talkSound: 'rbxassetid://7772738671',
		talkDelay: [ 0.01, 0.015 ],
		dialog: {
			default: {
				message: 'hi',
				goodbyeEnabled: true,
				faceTo: '_player',
				choices: {
					'hello': {
						message: 'what you doing?',
						goodbyeEnabled: true,
						faceTo: '_player',
						choices: {
							'how to level 2': {
								message: 'i heard that if you reached the top of this wall beside me, you can get to level 2, but you didn\'t hear that from me',
								goodbyeEnabled: false,
								faceTo: new Vector3(1600, 10, 0),
								choices: {
									'...': {
										message: '... oh wait you did',
										goodbyeEnabled: true,
										faceTo: '_player',
										choices: {  }
									}
								}
							},
							'what that glowy thing beside you?': {
								message: 'idk',
								goodbyeEnabled: true,
								faceTo: '_player',
								choices: {  }
							},
							'why do you exist': {
								message: string.rep('.', 2500),
								goodbyeEnabled: true,
								faceTo: '_player',
								choices: {  }
							}
						}
					}
				}
			},
			special: [  ]
		}
	}
} as Record<string, GameDialogRoot>;
