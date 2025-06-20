import React from '@rbxts/react';

import Speedometer from './Speedometer';
import Altitude from './Altitude';
import MoveHint from './MoveHint';

const HUD: React.FC = () => {
	return (
		<screengui
			ResetOnSpawn={false}
		>
			<frame
				BackgroundTransparency={1}
				AnchorPoint={new Vector2(0, 1)}
				Position={new UDim2(0, 0, 1, 0)}
				Size={new UDim2(1, 0, 0, 0)}
				AutomaticSize={Enum.AutomaticSize.Y}
			>
				<uipadding
					PaddingBottom={new UDim(0, 8)}
				/>
				<uilistlayout
					FillDirection={Enum.FillDirection.Vertical}
					Padding={new UDim(0, 0)}
				/>
				<MoveHint />
				<Speedometer />
				<Altitude />
			</frame>
		</screengui>
	);
};

export default HUD;
