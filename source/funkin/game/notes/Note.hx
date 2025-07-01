package funkin.game.notes;

import moonchart.formats.BasicFormat.BasicNote;
import flixel.FlxSprite;

class Note extends FlxSprite {
	public static inline var HIT_WINDOW_MS:Float = 160;
	public static inline var SPAWN_TIME:Float = 2000;

	public var strumTime(get, never):Float;
	public var noteType(get, never):String;
	public var noteLane(get, never):Int;
	public var sustainLength(get, never):Float;

	public var hitWindowScale:Float = 1;
	public var lowHitPriority:Bool = false;

	@:allow(funkin.game.notes.Strumline)
	public var sustain(default, null):Sustain;
	@:allow(funkin.game.notes.Strumline)
	public var parentStrumline(default, null):Null<Strumline>;

	@:allow(funkin.game.notes.Strumline)
	public var distance(default, null):Float = 0;

	@:allow(funkin.game.notes.Strumline)
	public var hasBeenHit(default, null):Bool = false;
	@:allow(funkin.game.notes.Strumline)
	public var handledMiss(default, null):Bool = false;

	private var _data:BasicNote;

	public function new(data:BasicNote) {
		super();
		_data = data;
	}

	public function canBeHit(songTime:Float):Bool {
		return Math.abs(strumTime - songTime) <= HIT_WINDOW_MS * hitWindowScale;
	}

	public function shouldBeSpawn(songTime:Float):Bool {
		return strumTime - songTime <= SPAWN_TIME / parentStrumline.scrollSpeed;
	}

	private function get_strumTime():Float {
		return _data.time;
	}

	private function get_noteType():String {
		return _data.type;
	}

	private function get_noteLane():Int {
		return _data.lane;
	}

	private function get_sustainLength():Float {
		return _data.length;
	}
}
