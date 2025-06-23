package funkin.game.notes;

import flixel.FlxSprite;

class Strum extends FlxSprite {
	public static inline var STRUM_SIZE:Float = 112;

	public var forceActive:Bool = false;

	public function playStatic() {
		active = forceActive || isAnimationDynamic('static');
		animation.play('static');
	}

	public function playPress() {
		active = forceActive || isAnimationDynamic('pressed');
		animation.play('pressed', true);
	}

	public function playConfirm() {
		active = forceActive || isAnimationDynamic('confirm');
		animation.play('confirm', true);
	}

	public function isAnimationDynamic(name:String):Bool {
		return animation.exists(name) && animation.getByName(name).numFrames > 1 && animation.getByName(name).frameRate > 0;
	}
}
