package funkin.game.notes;

import moonchart.formats.BasicFormat.BasicNote;
import flixel.FlxSprite;

class Note extends FlxSprite {
	public var strumTime(get, never):Float;
	public var noteType(get, never):String;
	public var noteLane(get, never):Int;
	public var sustainLength(get, never):Float;

	public var sustainTrail:SustainTrail;

	private var _data:BasicNote;

	public function new(data:BasicNote) {
		super();
		_data = data;
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
