package funkin;

import funkin.input.Action;
import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;

final class Preferences {
	public static var keyBinds:Map<Action, Array<FlxKey>> = [];

	public static var globalAntialiasing(default, set):Bool = true;

	@:noCompletion
	private static inline function set_globalAntialiasing(v:Bool):Bool {
		return FlxSprite.canUseAntialiasing = globalAntialiasing = v;
	}

	public static var flashingLights:Bool = true;
}
