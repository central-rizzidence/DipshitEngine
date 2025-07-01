package funkin.game.notes;

import flixel.FlxSprite;

class Strum extends FlxSprite {
	public static inline var STRUM_SIZE:Float = 112;

	public var forceActive:Bool = false;

	public var confirmTimer:Float = 0;

	override function update(elapsed:Float) {
		if (confirmTimer > 0) {
			confirmTimer -= elapsed;
			if (confirmTimer <= 0)
				playStatic();
		}

		super.update(elapsed);
	}

	public function playAnimation(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		animation.play(name);
		adjustOffsets();
		centerOrigin();
	}

	public function adjustOffsets() {
		centerOffsets();
		offset.add(25, 25);
	}

	public function playStatic() {
		active = forceActive || isAnimationDynamic('static');
		playAnimation('static');
	}

	public function playPress() {
		active = forceActive || isAnimationDynamic('pressed');
		playAnimation('pressed', true);
	}

	public function playConfirm() {
		active = forceActive || isAnimationDynamic('confirm');
		playAnimation('confirm', true);
	}

	public function holdConfirm() {
		active = forceActive || isAnimationDynamic('confirm-hold');
		playAnimation('confirm-hold');
	}

	public function isAnimationDynamic(name:String):Bool {
		return animation.exists(name) && animation.getByName(name).numFrames > 1 && animation.getByName(name).frameRate > 0;
	}
}
