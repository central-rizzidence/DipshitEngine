package funkin;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flxanimate.FlxAnimate;

class FunkinSprite extends FlxAnimate {
	public var autoUpdateOffsets:Bool = false;

	@:allow(funkin.animation.OffsetAnimationData)
	private var _animationOffsets:Map<String, FlxPoint> = [];

	private var _lastOffsettedAnimation:Null<String>;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
	}

	public function loadFrames(id:String):FunkinSprite {
		if (FlxG.assets.exists('$id/Animation.json', TEXT))
			loadAtlas(id);
		else if (FlxG.assets.exists('$id.txt', TEXT))
			frames = FlxAtlasFrames.fromSpriteSheetPacker('$id.png', '$id.txt');
		else if (FlxG.assets.exists('$id.json', TEXT))
			frames = FlxAtlasFrames.fromTexturePackerJson('$id.png', '$id.json');
		else if (FlxG.assets.exists('$id.xml', TEXT))
			frames = FlxAtlasFrames.fromSparrow('$id.png', '$id.xml');
		else
			FlxG.log.error('Frames $id does not exist');

		return this;
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

	public function getCurrentAnimation():Null<String> {
		return useAtlas ? anim.curAnimName : animation.name;
	}

	override function update(elapsed:Float) {
		if (autoUpdateOffsets) {
			final animationName = useAtlas ? anim.curAnimName : animation.name;
			if (_lastOffsettedAnimation != animationName) {
				updateOffsets();
				_lastOffsettedAnimation = animationName;
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
