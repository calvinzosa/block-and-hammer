import React, { useEffect, useState } from '@rbxts/react';

import { GradientStyleData, parseGradientColor } from 'client/stylesParser';

interface GradientProps {
	styles: GradientStyleData;
}

const Gradient: React.FC<GradientProps> = ({ styles: gradient }) => {
	const [colorSequence, setColorSequence] = useState<ColorSequence | undefined>(undefined);
	const [transparencySequence, setTransparencySequence] = useState<NumberSequence | undefined>(undefined);
	
	useEffect(() => {
		const [colorSequence, transparencySequence] = parseGradientColor(gradient);
		
		setColorSequence(colorSequence);
		setTransparencySequence(transparencySequence);
	}, [gradient.colors, gradient.transparency]);
	
	return (
		<uigradient
			Color={colorSequence}
			Transparency={transparencySequence}
			Rotation={gradient.rotation}
		/>
	);
};

export default Gradient;

