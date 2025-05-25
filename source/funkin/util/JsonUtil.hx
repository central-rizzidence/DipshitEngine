package funkin.util;

import json2object.Error;
import haxe.PosInfos;
import json2object.Position;

class JsonUtil {
	public static function convertPosition(position:Position):PosInfos {
		return {
			fileName: position.file,
			lineNumber: position.lines[0].number,
			className: 'JSON',
			methodName: 'schema'
		}
	}

	public static function stringifyError(error:Error):String {
		return switch error {
			case IncorrectType(variable, expected, pos):
				'Variable "$variable" should be of type $expected';
			case IncorrectEnumValue(value, expected, pos):
				'Identifier "$value" is not part of $expected';
			case InvalidEnumConstructor(value, expected, pos):
				'Enum argument "$value" should be of type $expected';
			case UnknownVariable(variable, pos):
				'Variable "$variable" is not part of the schema';
			case UninitializedVariable(variable, pos):
				'Variable "$variable" should be in the json';
			case ParserError(message, pos):
				'Parser error: $message';
			case CustomFunctionException(e, pos):
				'Custom function exception: $e';
		}
	}

	public static function logError(error:Error) {
		final position = switch error {
			case IncorrectType(_, _, pos) | IncorrectEnumValue(_, _, pos) | InvalidEnumConstructor(_, _, pos) | UninitializedVariable(_, pos) |
				UnknownVariable(_, pos) | ParserError(_, pos) | CustomFunctionException(_, pos): pos;
		}

		FlxG.log.error(stringifyError(error), convertPosition(position));
	}

	public static inline function logErrors(errors:Array<Error>) {
		if (errors.length < 1)
			return;

		for (error in errors)
			logError(error);
	}
}
