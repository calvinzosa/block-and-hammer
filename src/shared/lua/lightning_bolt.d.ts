declare class LightningBolt {
	constructor(attachment0: Attachment, attachment1: Attachment, duration: number);
	
	public Destroy(): void;
	
	public CurveSize0: number;
	public CurveSize1: number;
	public MinRadius: number;
	public MaxRadius: number;
	public Frequency: number;
	public AnimationSpeed: number;
	public Thickness: number;
	public MinThicknessMultiplier: number;
	public MaxThicknessMultiplier: number;
	
	public MinTransparency: number;
	public MaxTransparency: number;
	public PulseSpeed: number;
	public PulseLength: number;
	public FadeLength: number;
	public ContractFrom: number;
	
	public Color: Color3 | ColorSequence;
	public ColorOffsetSpeed: number;
}

export = LightningBolt;