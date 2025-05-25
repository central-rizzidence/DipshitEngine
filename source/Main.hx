import funkin.config.Config;
import flixel.FlxGame;
import funkin.util.Paths;
import flixel.FlxG;
import funkin.external.ALSoftConfig;
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

	private function _init(?event:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, _init);

		FlxG.save.bind(Paths.buildSaveName(), Paths.buildSavePath());

		addChild(new FlxGame(1280, 720, funkin.InitState, Config.framerate, Config.framerate, true, false));
	}
}
