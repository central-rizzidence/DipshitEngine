package funkin.input;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

final class Bindings {
	public static var keyboard:Map<Action, Array<FlxKey>> = [
		UI_UP => [FlxKey.W, FlxKey.UP],
		UI_DOWN => [FlxKey.S, FlxKey.DOWN],
		UI_LEFT => [FlxKey.A, FlxKey.LEFT],
		UI_RIGHT => [FlxKey.D, FlxKey.RIGHT],
		BACK => [FlxKey.ESCAPE, FlxKey.BACKSPACE],
		ACCEPT => [FlxKey.SPACE, FlxKey.ENTER],
		RELOAD_ASSETS => [FlxKey.F5],
		TOGGLE_DEBUGGER => [FlxKey.F2]
	];

	public static var gamepad:Map<Action, Array<FlxGamepadInputID>> = buildNullGamepadBindings();

	public static function buildGamepadBindings(gamepad:FlxGamepad):Map<Action, Array<FlxGamepadInputID>> {
		if (gamepad == null) {
			FlxG.log.warn('Could not build bindings for null gamepad');
			return buildNullGamepadBindings();
		}

		FlxG.log.notice('Building bindings for ${getGamepadModelName(gamepad)}');

		switch gamepad.model {
			case LOGITECH | OUYA | XINPUT | MFI | PS4 | PSVITA:
				return [
					UI_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
					UI_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
					UI_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
					UI_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
					BACK => [B],
					ACCEPT => [A]
				];

			case SWITCH_PRO:
				return [
					UI_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
					UI_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
					UI_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
					UI_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
					BACK => [A],
					ACCEPT => [B]
				];

			case SWITCH_JOYCON_LEFT | SWITCH_JOYCON_RIGHT:
				return [
					UI_UP => [LEFT_STICK_DIGITAL_UP],
					UI_DOWN => [LEFT_STICK_DIGITAL_DOWN],
					UI_LEFT => [LEFT_STICK_DIGITAL_LEFT],
					UI_RIGHT => [LEFT_STICK_DIGITAL_RIGHT],
					BACK => [A],
					ACCEPT => [B]
				];

			case MAYFLASH_WII_REMOTE | WII_REMOTE:
				switch gamepad.attachment {
					case WII_CLASSIC_CONTROLLER:
						return [
							UI_UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
							UI_DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
							UI_LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
							UI_RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
							BACK => [A],
							ACCEPT => [B]
						];

					case WII_NUNCHUCK:
						FlxG.log.error('Could not build bindings for Wii Nunchuck');
						return buildNullGamepadBindings();

					case NONE:
						FlxG.log.error('Could not build bindings for Wii Remote with no attachment');
						return buildNullGamepadBindings();
				}

			case UNKNOWN:
				FlxG.log.error('Could not build bindings for unknown gamepad');
				return buildNullGamepadBindings();
		}
	}

	public static function getGamepadModelName(gamepad:FlxGamepad):String {
		return switch gamepad.model {
			case LOGITECH: 'Logitech';
			case OUYA: 'OUYA';
			case PS4: 'DualShock 4';
			case PSVITA: 'PS Vita';
			case XINPUT: 'XInput';
			case MAYFLASH_WII_REMOTE | WII_REMOTE:
				switch gamepad.attachment {
					case WII_NUNCHUCK: (gamepad.model.match(MAYFLASH_WII_REMOTE) ? 'MAYFLASH ' : '') + 'Wii Remote with Nunchuck';
					case WII_CLASSIC_CONTROLLER: (gamepad.model.match(MAYFLASH_WII_REMOTE) ? 'MAYFLASH ' : '') + 'Wii Remote with classic controller';
					case NONE: (gamepad.model.match(MAYFLASH_WII_REMOTE) ? 'MAYFLASH ' : '') + 'Wii Remote with no attachment';
				}
			case MFI: 'MFI';
			case SWITCH_PRO: 'Switch Pro';
			case SWITCH_JOYCON_LEFT: 'Switch Joycon (Left)';
			case SWITCH_JOYCON_RIGHT: 'Switch Joycon (Right)';
			case UNKNOWN: 'Unknown';
		}
	}

	public static inline function buildNullGamepadBindings():Map<Action, Array<FlxGamepadInputID>> {
		return [
			UI_UP => [],
			UI_DOWN => [],
			UI_LEFT => [],
			UI_RIGHT => [],
			BACK => [],
			ACCEPT => []
		];
	}
}
