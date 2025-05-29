package funkin.storymenu.preview;

import flixel.math.FlxPoint;
import funkin.animation.AnimationData.OffsetAnimationData;
import flixel.util.FlxColor;

@:structInit
class LevelPreviewData {
	@:jcustomparse(funkin.util.DataUtil.parseJsonColor)
	@:jcustomparse(funkin.util.DataUtil.writeJsonColor)
	public var background:FlxColor;

	@:optional public var props:Null<Array<LevelPreviewPropData>>;
}

@:structInit
class LevelPreviewPropData {
	public var sprite:String;
	public var scale:Float;
	@:optional public var bopper:Null<LevelPreviewBopperData>;
	@:optional public var animations:Null<Array<OffsetAnimationData>>;
	@:optional public var startingAnimation:Null<String>;

	@:jcustomparse(funkin.util.DataUtil.parseJsonPointOptional)
	@:jcustomparse(funkin.util.DataUtil.writeJsonPoint)
	@:optional public var position:Null<FlxPoint>;
}

@:structInit
class LevelPreviewBopperData {
	public var danceSequence:Array<String>;
	public var danceEvery:Int;
}
