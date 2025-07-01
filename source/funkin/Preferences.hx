package funkin;

import funkin.input.Action;
import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;

final class Preferences {
	public static var keyBinds:Map<Action, Array<FlxKey>> = [
		NOTE_LEFT => [A, LEFT],
		NOTE_DOWN => [S, DOWN],
		NOTE_UP => [W, UP],
		NOTE_RIGHT => [D, RIGHT],
		DEBUG_SKIP => [THREE]
	];

	public static var globalAntialiasing(default, set):Bool = true;

	@:noCompletion
	private static inline function set_globalAntialiasing(v:Bool):Bool {
		return FlxSprite.defaultAntialiasing = FlxSprite.canUseAntialiasing = globalAntialiasing = v;
	}

	public static var frameRate(default, set):Int = 60;

	@:noCompletion
	private static inline function set_frameRate(v:Int):Int {
		if (v > FlxG.drawFramerate)
			FlxG.drawFramerate = FlxG.updateFramerate = v;
		else
			FlxG.updateFramerate = FlxG.drawFramerate = v;

		return frameRate = v;
	}

	public static var flashingLights:Bool = true;

	public static var receptorsOverlap:Bool = false;
}
