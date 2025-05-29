package funkin;

import flixel.math.FlxPoint;
import flxanimate.FlxAnimate;

class FunkinSprite extends FlxAnimate {
	public var autoUpdateOffsets:Bool = false;

	public var animationChain:Map<String, String> = [];

	@:allow(funkin.animation.OffsetAnimationData)
	private var _animationOffsets:Map<String, FlxPoint> = [];

	private var _lastOffsettedAnimation:Null<String>;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
	}

	public function addAnimation(name:String, prefix:String, ?frameIndices:Array<Int>, framesPerSecond:Float = 24, shouldLoop:Bool = false, ?offsets:FlxPoint) {
		if (useAtlas) {
			if (frameIndices != null)
				anim.addBySymbolIndices(name, prefix, frameIndices, framesPerSecond, shouldLoop);
			else
				anim.addBySymbol(name, prefix, framesPerSecond, shouldLoop);
		} else {
			if (frameIndices != null)
				animation.addByIndices(name, prefix, frameIndices, '', framesPerSecond, shouldLoop);
			else
				animation.addByPrefix(name, prefix, framesPerSecond, shouldLoop);
		}
		_animationOffsets[name] = offsets?.clone() ?? FlxPoint.get();
	}

	public function playAnimation(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		if (useAtlas)
			anim.play(name, force, reversed, frame);
		else
			animation.play(name, force, reversed, frame);
	}

	public function hasAnimation(name:String):Bool {
		return useAtlas ? anim.existsByName(name) : animation.exists(name);
	}

	public function getCurrentAnimationName():Null<String> {
		return useAtlas ? anim.curAnimName : animation.name;
	}

	public function isAnimationCompleted():Bool {
		return useAtlas ? anim.finished : animation.finished;
	}

	override function update(elapsed:Float) {
		if (autoUpdateOffsets) {
			final animationName = getCurrentAnimationName();
			if (_lastOffsettedAnimation != animationName) {
				updateOffsets();
				_lastOffsettedAnimation = animationName;
			}
		}

		// TODO: оно не работает
		if (isAnimationCompleted()) {
			final animationName = getCurrentAnimationName();
			if (animationName != null && animationChain.exists(animationName)) {
				if (hasAnimation(animationChain[animationName]))
					playAnimation(animationChain[animationName]);
			}
		}
		super.update(elapsed);
	}

	override function updateHitbox() {
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		updateOffsets();
		centerOrigin();
		super.updateHitbox();
	}

	public function updateOffsets() {
		final animationName = useAtlas ? anim.curAnimName : animation.name;
		if (_animationOffsets.exists(animationName))
			offset.copyFrom(_animationOffsets[animationName]);
		else {
			offset.set(width - frameWidth, height - frameHeight);
			offset.scale(-0.5);
		}
	}
}
