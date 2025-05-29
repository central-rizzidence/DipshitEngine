package funkin.play.notes;

import funkin.extensions.FlxSpriteChild;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import funkin.util.Paths;
import flixel.FlxSprite;

class Strum extends FlxSpriteChild {
	public var confirmTimer:Float;

	public final lane:Int;
	public var strumline(default, null):Strumline;

	public function new(lane:Int, strumline:Strumline) {
		super();
		this.lane = lane;
		this.strumline = strumline;

		frames = Paths.getFrames('game/notes/default/noteStrumline');

		final suffix = ['Left', 'Down', 'Up', 'Right'][lane % 4];
		animation.addByPrefix('static', 'static$suffix', 24);
		animation.addByPrefix('press', 'press$suffix', 24, false);
		animation.addByPrefix('confirm', 'confirm$suffix', 24, false);

		playStatic();

		// scale.set(0.7, 0.7);
		// updateHitbox();
	}

	public function playStatic() {
		animation.play('static');
	}

	public function playPress() {
		animation.play('press', true);
	}

	public function playConfirm(timer:Float) {
		animation.play('confirm', true);
		confirmTimer = timer;
	}

	override function update(elapsed:Float) {
		if (confirmTimer > 0) {
			confirmTimer -= elapsed;
			if (confirmTimer <= 0)
				playStatic();
		}

		super.update(elapsed);
	}
}
