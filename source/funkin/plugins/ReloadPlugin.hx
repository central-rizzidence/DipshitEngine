package funkin.plugins;

import flixel.FlxBasic;

class ReloadPlugin extends FlxBasic {
	public static var enabled:Bool = true;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (enabled && FlxG.keys.justPressed.F5)
			FlxG.resetState();
	}
}
