package funkin.input;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSignal.FlxTypedSignal;

class Controls {
	public static var pressed(default, null):FlxTypedSignal<(actions:Array<Action>) -> Void>;
	public static var released(default, null):FlxTypedSignal<(actions:Array<Action>) -> Void>;
	public static var repeated(default, null):FlxTypedSignal<(actions:Array<Action>) -> Void>;
	public static var pressedOrRepeated(default, null):FlxTypedSignal<(actions:Array<Action>) -> Void>;

	private static var _pressedKeys:Map<FlxKey, Bool> = [];
	private static var _repeatCount:Int = 0;

	public static function initSignals() {
		pressed = new FlxTypedSignal<(actions:Array<Action>) -> Void>();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyPressed);

		released = new FlxTypedSignal<(actions:Array<Action>) -> Void>();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyReleased);

		repeated = new FlxTypedSignal<(actions:Array<Action>) -> Void>();

		pressedOrRepeated = new FlxTypedSignal<(actions:Array<Action>) -> Void>();
	}

	public static function getActionsByKey(key:FlxKey):Array<Action> {
		final actions:Array<Action> = [];
		for (action => keys in Preferences.keyBinds) {
			if (keys.contains(key))
				actions.push(action);
		}
		return actions;
	}

	private static function _onKeyPressed(event:KeyboardEvent) {
		if (FlxG.stage.focus == @:privateAccess FlxG.game.debugger.console.input)
			return;

		if (!_pressedKeys.get(event.keyCode)) { // Pressed
			_pressedKeys[event.keyCode] = true;

			final actions = getActionsByKey(event.keyCode);
			pressed.dispatch(actions);
			pressedOrRepeated.dispatch(actions);
		} else { // Rrepeated
			_repeatCount++;
			if ((_repeatCount <= 64 && _repeatCount % 4 == 0) || (_repeatCount > 64 && _repeatCount % 3 == 0)) {
				final actions = getActionsByKey(event.keyCode);
				repeated.dispatch(actions);
				pressedOrRepeated.dispatch(actions);
			}
		}
	}

	private static function _onKeyReleased(event:KeyboardEvent) {
		if (FlxG.stage.focus == @:privateAccess FlxG.game.debugger.console.input)
			return;

		_pressedKeys[event.keyCode] = false;

		final actions = getActionsByKey(event.keyCode);
		released.dispatch(actions);
	}
}
