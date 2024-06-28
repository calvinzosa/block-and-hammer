import { ReplicatedStorage } from '@rbxts/services';

import { isTestingServer } from 'shared/utils';

const placeVersion = ReplicatedStorage.FindFirstChild('PlaceVersion') as IntValue;

if (isTestingServer()) placeVersion.Value = -2;
else placeVersion.Value = game.PlaceVersion;
