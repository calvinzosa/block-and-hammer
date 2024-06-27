import {
    ReplicatedStorage,
    DataStoreService,
    BadgeService,
    HttpService,
    RunService,
    Players,
} from '@rbxts/services';

import {
	computeNameColor,
	getHammerTexture,
	PlayerAttributes,
    Accessories,
} from 'shared/utils';

import {
    accessoryList
} from 'shared/accessory_loader';
import { $dbg } from 'rbxts-transform-debug';

const Events = {
    EquipAccessory: ReplicatedStorage.WaitForChild('EquipAccessory') as RemoteFunction,
};

const player = Players.LocalPlayer;
const GUI = player.WaitForChild('PlayerGui') as PlayerGui;

const flippedGravity = ReplicatedStorage.WaitForChild('flipped_gravity') as BoolValue;
const templates = ReplicatedStorage.WaitForChild('GUI') as Folder;
const accessoryTemplate = templates.WaitForChild('AccessoryTemplate') as ImageButton;
const screenGui = GUI.WaitForChild('ScreenGui') as ScreenGui;
const accessoriesGui = screenGui.WaitForChild('AccessoriesGUI') as Frame;
const items = accessoriesGui.WaitForChild('Items') as ScrollingFrame;
const info = accessoriesGui.WaitForChild('Info') as Frame;
const title = info.WaitForChild('Title') as TextLabel;
const description = info.WaitForChild('Description') as TextLabel;
const equipButton = info.WaitForChild('Equip') as TextButton;

let selectedAccessory = undefined as (ImageButton | undefined);

const accessoryOrder: Accessories.Type[] = [ 'hammer_Texture', 'cube_Hat', 'cube_Face', 'cube_Aura' ];

function updateGui() {
	title.Text = 'select an accessory!';
	description.Text = '';
	equipButton.Visible = false;
	selectedAccessory = undefined;
	
	for (const button of items.GetChildren()) {
		if (button.IsA('ImageButton')) button.Destroy();
	}
	
    for (const [ name, accessory ] of pairs(accessoryList)) {
        if (accessory.never) continue;
        
		task.spawn(() => {
			const accessoryButton = accessoryTemplate.Clone();
			accessoryButton.Image = accessory.icon;
			accessoryButton.Name = name;
			accessoryButton.LayoutOrder = accessoryOrder.findIndex((accessoryType) => accessoryType === accessory.acc_type);
            
            const labelName = accessoryButton.FindFirstChild('LabelName') as TextLabel;
			labelName.Text = name;
            
			accessoryButton.Parent = items;
			
			const outline = accessoryButton.FindFirstChild('UIStroke') as UIStroke;
			const shadow = accessoryButton.FindFirstChild('Shadow') as TextLabel;
			const typeIndicator = accessoryButton.FindFirstChild('Type') as Frame;
			
			if (player.GetAttribute(accessory.acc_type) === name) {
				accessoryButton.LayoutOrder -= 100;
				outline.Enabled = true;
            }
			
			if (accessory.copy_cube_color) accessoryButton.ImageColor3 = player.GetAttribute('CUBE_COLOR') as (Color3 | undefined) ?? computeNameColor(player.Name);
			
			let canEquipIt = false;
			
			accessoryButton.Visible = true
			if (accessory.badge_id !== 0) {
				accessoryButton.Visible = false;
				task.spawn(() => {
					let hasBadge = false;
					while (true) {
						const [ success, result ] = pcall(() => BadgeService.UserHasBadgeAsync(player.UserId, accessory.badge_id));
						if (success) {
							hasBadge = result;
							break;
						} else task.wait(0.5);
					}
					
					accessoryButton.Visible = true;
					if (hasBadge) {
						canEquipIt = true;
						shadow.Visible = false;
					} else {
						shadow.Visible = true;
						shadow.Text = accessory.badge_name;
						if (!accessory.always_show) accessoryButton.Visible = false;
					}
				});
			} else {
				canEquipIt = true
				shadow.Visible = false
			}
			
			if (accessory.acc_type === PlayerAttributes.CubeHat) typeIndicator.BackgroundColor3 = Color3.fromRGB(255, 26, 26);
			else if (accessory.acc_type === PlayerAttributes.CubeFace) typeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 51);
			else if (accessory.acc_type === PlayerAttributes.HammerTexture) typeIndicator.BackgroundColor3 = Color3.fromRGB(51, 255, 128);
			else if (accessory.acc_type === PlayerAttributes.CubeAura) typeIndicator.BackgroundColor3 = Color3.fromRGB(51, 102, 255);
			else typeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			
			if (!accessoryButton.GetAttribute('connected')) {
				accessoryButton.SetAttribute('connected', true);
				
				accessoryButton.MouseButton1Click.Connect(() => {
					title.Text = name;
					description.Text = accessory.description ?? '[ No Description Found ]';
					
					equipButton.Text = 'equip';
					if (canEquipIt && !outline.Enabled) {
						equipButton.TextColor3 = Color3.fromRGB(255, 255, 255);
						equipButton.BackgroundTransparency = 0.6;
						equipButton.AutoButtonColor = true;
						selectedAccessory = accessoryButton;
					} else {
						equipButton.TextColor3 = Color3.fromRGB(175, 175, 175);
						equipButton.BackgroundTransparency = 0.5;
						equipButton.AutoButtonColor = false;
						if (outline.Enabled) equipButton.Text = 'already equipped';
					}
					
					equipButton.Visible = true;
				});
			}
        });
    }
}

updateGui();
accessoriesGui.GetPropertyChangedSignal('Visible').Connect(() => {
    if (accessoriesGui.Visible) updateGui();
});

equipButton.MouseButton1Click.Connect(() => {
	const outline = selectedAccessory?.FindFirstChild('UIStroke');
    if (!selectedAccessory || !outline?.IsA('UIStroke')) return;
	
	const name = selectedAccessory.Name;
    if (!(name in accessoryList)) return;
    
	const accessory = accessoryList[name];
	
	const previousHammerAccessory = getHammerTexture(player);
	
	const didEquip = Events.EquipAccessory.InvokeServer(name);
    if (didEquip) {
		if (previousHammerAccessory === Accessories.HammerTexture.InverterHammer && accessory.acc_type === 'hammer_Texture') flippedGravity.Value = false;
		
        outline.Enabled = true;
        selectedAccessory.LayoutOrder = accessoryOrder.findIndex((accessoryType) => accessoryType === accessory.acc_type) - 100;
        
        for (const [ otherName, otherAccessory ] of pairs(accessoryList)) {
            if (otherName !== name && otherAccessory.acc_type === accessory.acc_type) {
                const button = items.FindFirstChild(otherName);
                const otherOutline = button?.FindFirstChild('UIStroke');
                if (button?.IsA('ImageButton') && otherOutline?.IsA('UIStroke')) {
                    otherOutline.Enabled = false;
                    button.LayoutOrder = accessoryOrder.findIndex((accessoryType) => accessoryType === otherAccessory.acc_type);
                }
            }
        }
        
        equipButton.TextColor3 = Color3.fromRGB(175, 175, 175);
        equipButton.BackgroundTransparency = 0.5;
        equipButton.AutoButtonColor = false;
        equipButton.Text = 'already equipped';
    }
});

RunService.RenderStepped.Connect(() => {
    if (!accessoriesGui.Visible) return;
	
	for (const button of items.GetChildren()) {
		if (!button.IsA('ImageButton') || button.GetAttribute('loopDebounce') || !(button.Name in accessoryList)) continue;
		
		const data = accessoryList[button.Name];
		if (data.spritesheet_data) {
			const tileWidth = data.spritesheet_data.tileWidth;
			const tileHeight = data.spritesheet_data.tileHeight;
			const maxRow = data.spritesheet_data.rows;
			const maxColumn = data.spritesheet_data.columns;
			const loopDelay = data.spritesheet_data.loopDelay;
			const fps = data.spritesheet_data.fps;
			
			const currentTime = time();
			const lastChange = button.GetAttribute('lastChange') as (number | undefined) ?? (currentTime - 1);
			if ((currentTime - lastChange) < (1 / fps)) continue;
			
			button.SetAttribute('lastChange', currentTime);
			
			let x = button.GetAttribute('spritesheetX') as (number | undefined) ?? -tileWidth;
			let y = button.GetAttribute('spritesheetY') as (number | undefined) ?? 0;
			
			x += tileWidth;
			if (x >= maxColumn * tileWidth) {
				y += tileHeight;
				x = 0;
				
				if (y >= maxRow * tileHeight) {
					y = 0;
					if (loopDelay > 0) {
						button.SetAttribute('loopDebounce', true);
						task.delay(loopDelay, () => button.SetAttribute('loopDebounce', undefined));
					}
				}
			}
			
			button.SetAttribute('spritesheetX', x);
			button.SetAttribute('spritesheetY', y);
			
			button.ImageRectSize = new Vector2(tileWidth, tileHeight);
			button.ImageRectOffset = new Vector2(x, y);
		}
	}
});