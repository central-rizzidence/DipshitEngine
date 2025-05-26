package funkin.util;

import flixel.math.FlxPoint;
import hxjsonast.Json;
import flixel.util.FlxColor;

using hxjsonast.Tools;

final class DataUtil {
	public static function parseJsonColor(json:Json, name:String):FlxColor {
		switch json.value {
			case JString(s):
				final color = FlxColor.fromString(s);
				if (color == null) {
					FlxG.log.warn('Json property $name expected to be a valid color string');
					return 0xffffffff;
				}
				return color;

			case _:
				FlxG.log.warn('Json property $name expected to be a valid color string');
				return 0xffffffff;
		}
	}

	public static inline function writeJsonColor(color:FlxColor):String {
		return '"${color.toWebString()}"';
	}

	public static inline function parseJsonPoint(json:Json, name:String):FlxPoint {
		return parseJsonPointOptional(json, name) ?? FlxPoint.get();
	}

	public static function parseJsonPointOptional(json:Json, name:String):Null<FlxPoint> {
		switch json.value {
			case JArray(values):
				// var realValues = values.map(value -> hxjsonast.Tools.getValue);
				if (Lambda.exists(values, value -> !value.value.match(JNumber(_)))) {
					FlxG.log.warn('Json property $name expected to be an array of two numbers');
					return null;
				}

				return FlxPoint.get(values[0].getValue(), values[1].getValue());

			case _:
				FlxG.log.warn('Json property $name expected to be an array of two numbers');
				return null;
		}
	}

	public static function writeJsonPoint(point:FlxPoint):String {
		return '[${point.x}, ${point.y}]';
	}
}
