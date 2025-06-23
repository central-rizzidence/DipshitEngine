package funkin.transition;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class CustomFadeTransition extends CustomTransition {
	public var gradient(default, null):FlxSprite;
	public var box(default, null):FlxSprite;

	override function create() {
		gradient = new FlxSprite(Paths.image('transitionSpr'));
		gradient.scale.x = FlxG.width;
		gradient.updateHitbox();
		add(gradient);

		box = new FlxSprite().makeGraphic(1, 1, 0xff000000);
		box.setGraphicSize(FlxG.width, FlxG.height);
		box.updateHitbox();
		add(box);

		if (!_isTransIn) {
			gradient.y = 2000;
			box.y = 2000;
		}

		if (_isTransIn) {
			gradient.angle = 180;
			FlxTween.num(0, FlxG.height + gradient.height, _duration, {onComplete: _ -> _callback()}, _tweenFunction);
		} else
			FlxTween.num(-FlxG.height - gradient.height, 0, _duration, {onComplete: _ -> _callback()}, _tweenFunction);
	}

	private function _tweenFunction(y:Float) {
		gradient.y = y + (_isTransIn ? -gradient.height : box.height);
		box.y = y;
	}
}
