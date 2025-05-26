package funkin.plugins;

import funkin.input.Controls;
import flixel.FlxBasic;

final class ReloadAssetsPlugin extends FlxBasic {
	public static var enabled:Bool = true;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (enabled && Controls.instance.justPressed.RELOAD_ASSETS)
			FlxG.resetState();
	}
}
