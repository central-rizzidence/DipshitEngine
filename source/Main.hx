import funkin.debug.DebugInfo;
import flixel.FlxGame;
import funkin.util.Paths;
import flixel.FlxG;
import funkin.external.ALSoftConfig; // just to make sure it's included and it initializes
import openfl.events.Event;
import openfl.display.Sprite;

class Main extends Sprite {
	private function new() {
		super();

		if (stage != null)
			_init();
		else
			addEventListener(Event.ADDED_TO_STAGE, _init);
	}

	@:access(flixel.FlxGame._customSoundTray)
	private function _init(?event:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, _init);

		FlxG.save.bind(Paths.buildSaveName(), Paths.buildSavePath());

		final game = new FlxGame(1280, 720, funkin.InitState, 60, 60, true, false);
		game._customSoundTray = funkin.sound.FunkinSoundTray;
		addChild(game);

		addChild(new DebugInfo());
	}
}
