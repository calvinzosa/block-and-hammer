import {
    ReplicatedStorage,
    UserInputService,
    TweenService,
    RunService,
    Workspace,
    Players,
} from '@rbxts/services';

import {
    getTime,
    getHammerTexture,
    getPlayerRank,
    playSound,
    Accessories,
    tweenTypes,
    PlayerAttributes
} from 'shared/utils';

const player = Players.LocalPlayer;
const camera = Workspace.CurrentCamera ?? Workspace.WaitForChild('Camera') as Camera;

const GUI = player.WaitForChild('PlayerGui') as PlayerGui;
const canMove = GUI.WaitForChild('Values').WaitForChild('can_move') as BoolValue;
const menuGui = GUI.WaitForChild('MainMenuGui') as ScreenGui;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const tutorialGui = screenGui.WaitForChild('TutorialGUI') as Frame;
const playButton = menuGui.WaitForChild('Play') as TextButton;
const editButton = menuGui.WaitForChild('Edit') as TextButton;
const titleLabel = menuGui.WaitForChild('Title') as TextLabel;
const hintLabel = menuGui.WaitForChild('Hint') as TextLabel;
const shadow = menuGui.WaitForChild('Shadow') as Frame;
const shadowTitle = shadow.WaitForChild('Title') as TextLabel;
const shadowText = shadow.WaitForChild('Loading') as TextLabel;
const effectsFolder = Workspace.WaitForChild('Effects');

let didClickButton = false;

if (player.GetAttribute(PlayerAttributes.IsNew)) {
    tutorialGui.Visible = true;
    canMove.Value = false;
}

player.AttributeChanged.Connect((attr) => {
	if (attr === PlayerAttributes.IsNew && player.GetAttribute(attr)) {
		tutorialGui.Visible = true;
		canMove.Value = false;
    }
});

menuGui.Enabled = true;
screenGui.Enabled = false;

while (!menuGui.GetAttribute('done')) menuGui.AttributeChanged.Wait();

do {
	shadowText.Text = 'retrieving player data' + string.rep('.', math.round(getTime() * 5 % 3));
	task.wait();
} while (!player.GetAttribute(PlayerAttributes.HasDataLoaded));
shadowText.Text = 'done!';

shadow.TweenSize(UDim2.fromScale(0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.5);

const menuAssets = Workspace.WaitForChild('MainMenuAssets');
const hammer = menuAssets.WaitForChild('Hammer') as Model;

UserInputService.InputBegan.Once(() => {
	const currentHammer = getHammerTexture();
	
    const arm = hammer.WaitForChild('Arm') as BasePart;
    const head = hammer.WaitForChild('Head') as BasePart;
    
	if (currentHammer === Accessories.HammerTexture.Hammer404) {
        for (const part of [ head, arm ]) {
            for (const face of Enum.NormalId.GetEnumItems()) {
                const texture = new Instance('Texture');
                texture.Face = face;
                texture.Texture = 'rbxassetid://9994130132';
                texture.Name = 'ERROR_TEXTURE';
                texture.Parent = part;
            }
        }
    } else if (currentHammer === Accessories.HammerTexture.ExplosiveHammer) {
        arm.BrickColor = new BrickColor('Medium stone grey');
        arm.Material = Enum.Material.DiamondPlate;
        
        head.BrickColor = new BrickColor('Really red');
        head.Material = Enum.Material.Neon;
    }
	
	const start = hammer.GetPivot();
    const goal = (menuAssets.WaitForChild('EndAnim') as BasePart).CFrame;
    for (const i of $range(0, 1, 0.1)) {
        hammer.PivotTo(start.Lerp(goal, i));
        task.wait();
    }
    
	hammer.PivotTo(goal);
	
	playButton.Visible = true;
	// menuGui.Edit.Visible = true
    titleLabel.Visible = true;
	
	TweenService.Create(hintLabel, tweenTypes.linear.short, { TextTransparency: 1, TextStrokeTransparency: 1 }).Play();
	TweenService.Create(playButton, tweenTypes.linear.short, { TextTransparency: 0, BackgroundTransparency: 0.6 }).Play();
	TweenService.Create(titleLabel, tweenTypes.linear.short, { TextTransparency: 0, TextStrokeTransparency: 0 }).Play();
	
    if (getPlayerRank(player) >= 1) {
        TweenService.Create(editButton, tweenTypes.linear.short, { TextTransparency: 0, BackgroundTransparency: 0.6 }).Play();
    } else {
        editButton.SetAttribute('disabled', true);
        TweenService.Create(editButton, tweenTypes.linear.short, { TextTransparency: 0.4, BackgroundTransparency: 0.4 }).Play();
    }
	
	const spark = ReplicatedStorage.WaitForChild('Particles').WaitForChild('spark').Clone() as BasePart;
	spark.CFrame = CFrame.lookAt((menuAssets.WaitForChild('SparkPosition') as BasePart).Position, head.Position);
	(spark.FindFirstChild('ParticleEmitter') as ParticleEmitter).Rate = math.huge;
	spark.Parent = effectsFolder;
    
    task.delay(0.15, () => (spark.FindFirstChild('ParticleEmitter') as ParticleEmitter).Enabled = false);
	
	playSound('hit1', { PlaybackSpeed: 0.8, Volume: 0.5 });
	
    if (currentHammer === Accessories.HammerTexture.Hammer404) {
        playSound('error2', { PlaybackSpeed: 1, Volume: 1.5 });
        playSound('hit2', { PlaybackSpeed: 0.8, Volume: 1.5 });
    } else if (currentHammer === Accessories.HammerTexture.ExplosiveHammer) {
        playSound('explosion', { Volume: 1.5 });
        playSound('hit2', { Volume: 1.5 });
        new Instance('Explosion', Workspace).Position = head.Position;
    }
});

let connection: RBXScriptConnection | undefined = undefined;
connection = RunService.RenderStepped.Connect(() => {
    const cube = Workspace.FindFirstChild(`cube${player.UserId}`) as BasePart | undefined;
    if (cube) cube.Anchored = true;
    
    if (!player.GetAttribute(PlayerAttributes.Client.InMainMenu) && connection) {
        connection.Disconnect();
        screenGui.Enabled = true;
        menuGui.Enabled = false;
        if (cube) cube.Anchored = false;
        
        return;
    }
    
    camera.FieldOfView = 70;
    camera.CFrame = (menuAssets.FindFirstChild('CameraCFrame') as BasePart).CFrame;
});

playButton.MouseButton1Click.Once(() => {
    if (didClickButton) return;
    didClickButton = true;
    
    shadow.Size = UDim2.fromScale(1, 1);
    shadow.BackgroundTransparency = 1;
    shadowTitle.Visible = false;
    shadowText.Visible = false;
    
    TweenService.Create(shadow, new TweenInfo(0.6, Enum.EasingStyle.Linear), { BackgroundTransparency: 0 }).Play();
    task.wait(0.6);
    
    TweenService.Create(shadow, tweenTypes.linear.short, { Size: UDim2.fromScale(0, 0) }).Play();
    task.delay(1, () => menuGui.Enabled = false);
    
    player.SetAttribute(PlayerAttributes.Client.InMainMenu, undefined);
});

editButton.MouseButton1Click.Once(() => {
    if (editButton.GetAttribute('disabled')) return;
    
    if (!didClickButton) return;
    didClickButton = true;
    
    shadow.Size = UDim2.fromScale(1, 1);
    shadow.BackgroundTransparency = 1;
    titleLabel.Visible = false;
    shadowText.Visible = false;
    
    TweenService.Create(shadow, tweenTypes.linear.short, { BackgroundTransparency: 0 }).Play();
    task.wait(1);
    
    (ReplicatedStorage.FindFirstChild('JoinEdit') as RemoteEvent).FireServer();
});