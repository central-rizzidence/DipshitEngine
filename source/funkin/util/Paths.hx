package funkin.util;

import haxe.macro.Compiler;
import flixel.util.FlxSave;
import flixel.FlxG;
import haxe.io.Path;

class Paths {
	public static final SOUND_EXTENSION:String = Compiler.getDefine('FLX_DEFAULT_SOUND_EXT');
	public static inline var VIDEO_EXTENSION:String = 'mp4';

	@:access(flixel.util.FlxSave.validate)
	public static function buildSaveName():String {
		return FlxSave.validate(FlxG.stage.application.meta['file']);
	}

	@:access(flixel.util.FlxSave.validate)
	public static function buildSavePath():String {
		final company = FlxG.stage.application.meta['company'];
		final file = FlxG.stage.application.meta['file'];
		return FlxSave.validate(Path.join([company, file]));
	}

	public static function getLibrary(id:String):String {
		id = id.trim();
		final colon = id.indexOf(':');
		return colon > 0 ? id.substr(0, colon) : 'default';
	}

	public static function cutLibrary(id:String):String {
		id = id.trim();
		final colon = id.indexOf(':');
		return colon > 0 ? id.substr(colon + 1) : id;
	}

	public static function file(id:String, ?directory:String, ?extension:String):String {
		final library = getLibrary(id);

		final prefix = ![null, 'default'].contains(library) ? '$library:assets/$library' : 'assets';
		final suffix = extension != null ? '$id.$extension' : id;

		return directory != null ? '$prefix/$directory/$suffix' : '$prefix/$suffix';
	}

	public static inline function font(id:String, extension:String = 'ttf'):String {
		return file(id, 'fonts', extension);
	}

	public static inline function image(id:String):String {
		return file(id, 'images', 'png');
	}

	public static inline function sound(id:String):String {
		return file(id, 'sounds', SOUND_EXTENSION);
	}

	public static inline function video(id:String):String {
		return file(id, 'videos', VIDEO_EXTENSION);
	}
}
