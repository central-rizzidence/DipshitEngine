package funkin;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;

class Paths {
	public static inline function data(key:String):String {
		return 'assets/data/$key';
	}

	public static inline function font(key:String):String {
		return FlxG.assets.exists('assets/fonts/$key.otf', FONT) ? 'assets/fonts/$key.otf' : 'assets/fonts/$key.ttf';
	}

	public static inline function image(key:String):String {
		return 'assets/images/$key.png';
	}

	public static inline function getSparrowAtlas(key:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(image(key), 'assets/images/$key.xml');
	}

	public static inline function music(key:String):String {
		return 'assets/music/$key';
	}

	public static inline function sound(key:String):String {
		return 'assets/sounds/$key';
	}

	public static inline function video(key:String):String {
		return 'assets/videos/$key.mp4';
	}

	public static function firstExisting(paths:Array<String>, ?type:FlxAssetType):String {
		for (path in paths) {
			if (FlxG.assets.exists(path, type))
				return path;
		}
		return paths[paths.length - 1];
	}

	private static final _SLASHES_REG = ~/[\\\/]+/g;
	private static final _INVALID_CHARS_REG:EReg = ~/[<>:'|?*]/g;
	private static final _RESERVED_NAMES = ['CON', 'PRN', 'AUX', 'NUL'].concat([for (i in 1...10) 'COM$i']).concat([for (i in 1...10) 'LPT$i']);

	public static function format(s:String):String {
		if (s?.length < 1)
			return '';

		var parts = _SLASHES_REG.split(s);
		var result:Array<String> = [];
		var depth = 0;
		for (part in parts) {
			var processed = _processPart(part);
			if (processed.length == 0)
				continue;

			if (processed == '..') {
				if (depth > 0) {
					result.pop();
					depth--;
				} else if (result.length == 0 || result[0] == '..')
					result.push(processed);
			} else if (processed != '.') {
				result.push(processed);
				depth++;
			}
		}
		return result.join('/');
	}

	private static function _processPart(part:String):String {
		if (part == '.' || part == '..')
			return part;

		var clean = _INVALID_CHARS_REG.replace(part, '_');
		clean = _rtrimSpecial(clean).ltrim();
		return _RESERVED_NAMES.contains(clean) ? '${clean}_' : clean;
	}

	private static function _rtrimSpecial(s:String):String {
		var i = s.length - 1;
		while (i >= 0) {
			final char = s.fastCodeAt(i);
			if (char != '.'.code && char != ' '.code)
				break;
			i--;
		}
		return s.substring(0, i + 1);
	}
}
