package funkin.animation;

import flixel.math.FlxPoint;

class AnimationData {
	public var name:String;
	public var prefix:String;
	@:alias('indices') @:optional public var frameIndices:Null<Array<Int>>;
	@:alias('fps') public var framesPerSecond:Float;
	@:alias('loop') public var shouldLoop:Bool;

	public function new(name:String, prefix:String, fps:Float = 24, loop:Bool = false) {
		this.name = name;
		this.prefix = prefix;
		framesPerSecond = fps;
		shouldLoop = loop;
	}

	public function addTo(sprite:FunkinSprite) {
		sprite.addAnimation(name, prefix, frameIndices, framesPerSecond, shouldLoop);
	}
}

class OffsetAnimationData extends AnimationData {
	@:jcustomparse(funkin.util.DataUtil.parseJsonPointOptional)
	@:jcustomparse(funkin.util.DataUtil.writeJsonPoint)
	@:optional public var offsets:Null<FlxPoint>;

	public function new(name:String, prefix:String, fps:Float = 24, loop:Bool = false, ?offsets:FlxPoint) {
		super(name, prefix, fps, loop);
		this.offsets = offsets;
	}

	override function addTo(sprite:FunkinSprite) {
		sprite.addAnimation(name, prefix, frameIndices, framesPerSecond, shouldLoop, offsets);
	}
}
