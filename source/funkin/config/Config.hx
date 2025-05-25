package funkin.config;

import flixel.FlxSprite;

class Config {
	/** Whether jagged lines should be smoothed **/
	public static var antialiasing(get, set):Bool;

	@:noCompletion
	private static inline function get_antialiasing():Bool {
		return FlxG.save.data.config.antialiasing ?? true;
	}

	@:noCompletion
	private static inline function set_antialiasing(value:Bool):Bool {
		FlxSprite.defaultAntialiasing = value;
		return FlxG.save.data.config.antialasing = value;
	}

	/** Number of updates and draws per second **/
	public static var framerate(get, set):Int;

	@:noCompletion
	private static inline function get_framerate():Int {
		return FlxG.save.data.config.framerate ?? 60;
	}

	@:noCompletion
	private static inline function set_framerate(value:Int):Int {
		if (value > FlxG.drawFramerate)
			FlxG.drawFramerate = FlxG.updateFramerate = value;
		else
			FlxG.updateFramerate = FlxG.drawFramerate = value;

		return FlxG.save.data.config.framerate = value;
	}

	/** Whether to upload images to gpu memory **/
	public static var gpuBitmaps(get, set):Bool;

	@:noCompletion
	private static inline function get_gpuBitmaps():Bool {
		return FlxG.save.data.config.framerate ?? true;
	}

	@:noCompletion
	private static inline function set_gpuBitmaps(value:Bool):Bool {
		return FlxG.save.data.config.framerate = value;
	}

	/** Create missing data in the save file to prevent further errors **/
	public static inline function createMissingData() {
		FlxG.save.data.config = {}
	}

	/** Apply all settings **/
	public static inline function applyAll() {
		framerate = framerate;
		antialiasing = antialiasing;
	}
}
