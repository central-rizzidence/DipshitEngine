package funkin.storymenu.preview;

import flixel.math.FlxPoint;
import funkin.animation.AnimationData.OffsetAnimationData;
import flixel.util.FlxColor;

class LevelPreviewData {
	@:jcustomparse(funkin.util.DataUtil.parseJsonColor)
	@:jcustomparse(funkin.util.DataUtil.writeJsonColor)
	public var background:FlxColor;

	@:optional public var props:Null<Array<LevelPreviewPropData>>;

	public function new(background:FlxColor = 0xfff9cf51) {}
}

class LevelPreviewPropData {
	public var sprite:String;
	public var scale:Float;
	@:optional public var bopper:Null<LevelPreviewBopperData>;
	@:optional public var animations:Null<Array<OffsetAnimationData>>;
	@:optional public var startingAnimation:Null<String>;

	@:jcustomparse(funkin.util.DataUtil.parseJsonPointOptional)
	@:jcustomparse(funkin.util.DataUtil.writeJsonPoint)
	@:optional public var position:Null<FlxPoint>;

	public function new(sprite:String, scale:Float = 1) {
		this.sprite = sprite;
		this.scale = scale;
	}
}

class LevelPreviewBopperData {
	public var danceSequence:Array<String>;
	public var danceEvery:Int;

	public function new(?sequence:Array<String>, every:Int = 2) {
		danceSequence = sequence ?? ['idle'];
		danceEvery = every;
	}
}
