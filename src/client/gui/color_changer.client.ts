import {
    ReplicatedStorage,
    UserInputService,
    RunService,
    Players,
    GuiService,
} from '@rbxts/services';

import {
    computeNameColor,
    PlayerAttributes,
} from 'shared/utils';

const Events = {
    SetColor: ReplicatedStorage.WaitForChild('SetColor') as RemoteEvent,
};

const player = Players.LocalPlayer;

const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const colorChanger = screenGui.WaitForChild('ColorChanger') as Frame;
const container = colorChanger.WaitForChild('Container') as Frame;
const colorInput = container.WaitForChild('ColorInput') as Frame;
const svMap = colorInput.WaitForChild('SVMap') as Frame;
const location = svMap.WaitForChild('Location') as Frame;
const saturationMap = svMap.WaitForChild('SaturationMap') as Frame;
const saturationGradient = saturationMap.WaitForChild('UIGradient') as UIGradient;
const hueSlider = colorInput.WaitForChild('HueSlider') as Frame;
const hueInput = hueSlider.WaitForChild('Input') as Frame;
const result = colorInput.WaitForChild('Result') as Frame;
const resultColor = result.WaitForChild('Color') as Frame;
const resultHex = result.WaitForChild('Hex') as TextBox;
const resetColor = container.WaitForChild('Reset') as TextButton;
const setColor = container.WaitForChild('Set') as TextButton;

const defaultColor = computeNameColor(player.Name);

let currentColor = defaultColor;
let isDraggingSV = false;
let isDraggingHue = false;
let currentHue = 0;
let currentSaturation = 1;
let currentValue = 1;

while (!player.GetAttribute(PlayerAttributes.HasDataLoaded)) player.AttributeChanged.Wait();

function updateResult() {
    currentColor = Color3.fromHSV(currentHue, currentSaturation, currentValue);
    
    location.Position = UDim2.fromScale(currentSaturation, 1 - currentValue);
    hueInput.Position = UDim2.fromScale(0, 1 - currentHue);
    
    saturationGradient.Color = new ColorSequence([
        new ColorSequenceKeypoint(0, new Color3(1, 1, 1)),
        new ColorSequenceKeypoint(1, Color3.fromHSV(currentHue, 1, 1))
    ]);
    
    resultColor.BackgroundColor3 = currentColor;
    resultHex.Text = currentColor.ToHex().upper();
}

const loadedColor = player.GetAttribute(PlayerAttributes.CubeColor);
if (typeIs(loadedColor, 'Color3')) currentColor = loadedColor;

resultHex.Text = currentColor.ToHex().upper();
resultHex.PlaceholderText = resultHex.Text;

resultHex.FocusLost.Connect(() => {
    let inputColor = undefined as (Color3 | undefined);
    try {
        inputColor = Color3.fromHex(resultHex.ContentText)
    } catch (err) {  }
    
    if (typeIs(inputColor, 'Color3')) {
        const [ hue, saturation, value ] = inputColor.ToHSV();
        location.Position = UDim2.fromScale(saturation, 1 - value);
        hueInput.Position = UDim2.fromScale(0, 1 - hue);
        
        currentHue = hue;
        currentSaturation = saturation;
        currentValue = value;
        
        updateResult();
    } else resultHex.Text = resultColor.BackgroundColor3.ToHex().upper();
});

RunService.RenderStepped.Connect(() => {
    const [ inset ] = GuiService.GetGuiInset();
    const mouseLocation = UserInputService.GetMouseLocation().sub(inset);
    
    if (svMap.GetAttribute('isDragging')) {
        const position = mouseLocation.sub(svMap.AbsolutePosition).Max(Vector2.zero).Min(svMap.AbsoluteSize).div(svMap.AbsoluteSize);
        
        currentSaturation = position.X;
        currentValue = 1 - position.Y;
        
        updateResult();
    } else if (hueSlider.GetAttribute('isDragging')) {
		const value = math.clamp(mouseLocation.Y - hueSlider.AbsolutePosition.Y, 0, hueSlider.AbsoluteSize.Y) / hueSlider.AbsoluteSize.Y;
		
		hueInput.Position = UDim2.fromScale(0, value);
		currentHue = 1 - value;
		
		updateResult();
    }
});

resetColor.MouseButton1Click.Connect(() => {
    [ currentHue, currentSaturation, currentValue ] = defaultColor.ToHSV();
    
    updateResult();
});

setColor.MouseButton1Click.Connect(() => {
    Events.SetColor.FireServer(currentColor);
});