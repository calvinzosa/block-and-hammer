export type GameQuest = {
	name: string,
	description: string
};

export default {
	LostSteelHammer: {
		name: 'Lost steel hammer',
		description: 'Help Orange find his steel hammer in the swamp!',
	},
} as Record<string, GameQuest>;