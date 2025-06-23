package funkin;

import moonchart.Moonchart;
import funkin.input.Controls;
import flixel.system.FlxAssets;
import flixel.FlxSprite;
import flixel.FlxState;

class InitState extends FlxState {
	override function create() {
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;

		FlxSprite.defaultAntialiasing = Preferences.globalAntialiasing;
		FlxAssets.FONT_DEFAULT = Paths.font('vcr');

		Moonchart.DEFAULT_DIFF = 'normal';

		Controls.initSignals();

		final song = new funkin.game.Song('stalker-a-idol-miku-mix', 'normal');
		FlxG.switchState(() -> new funkin.game.PlayState(song));
	}
}
