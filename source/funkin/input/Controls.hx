package funkin.input;

import flixel.math.FlxMath;
import flixel.addons.input.FlxControlInputType;
import flixel.addons.input.FlxControls;

final class Controls extends FlxControls<Action> {
	public static var instance:Controls;

	public function getDefaultMappings():ActionMap<Action> {
		final result = new ActionMap<Action>();
		for (action in Action.createAll()) {
			result[action] = [];

			final keyboardBindings = Bindings.keyboard.get(action);
			if (keyboardBindings != null) {
				for (i in 0...FlxMath.minInt(keyboardBindings.length, Constants.MAX_BINDINGS))
					result[action].push(FlxKeyInputType.Lone(keyboardBindings[i]));
			}

			final gamepadBindings = Bindings.gamepad.get(action);
			if (gamepadBindings != null) {
				for (i in 0...FlxMath.minInt(gamepadBindings.length, Constants.MAX_BINDINGS))
					result[action].push(FlxGamepadInputType.Lone(gamepadBindings[i]));
			}
		}
		return result;
	}
}
