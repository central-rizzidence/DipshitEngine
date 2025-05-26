package funkin.music;

import funkin.util.JsonUtil;
import funkin.util.Paths;
import json2object.JsonParser;

class MusicMetadata {
	public var title:String;
	public var artist:String;
	@:optional public var album:Null<String>;
	public var timeChanges:Array<MusicTimeChange>;

	public function new(title:String, artist:String, bpm:Float, num:Int, den:Int) {
		this.title = title;
		this.artist = artist;
		timeChanges = [new MusicTimeChange(0, bpm, num, den)];
	}

	private static final _parser:JsonParser<MusicMetadata> = new JsonParser<MusicMetadata>();

	public static function get(id:String, directory:String = 'music'):MusicMetadata {
		final path = Paths.file('$id/${Paths.cutLibrary(id)}-metadata', directory, 'json');

		_parser.fromJson(FlxG.assets.getText(path), path);

		JsonUtil.logErrors(_parser.errors);

		return _parser.value;
	}
}

class MusicTimeChange {
	@:alias('n') public var timeSignatureNum:Int;
	@:alias('d') public var timeSignatureDen:Int;
	@:alias('bpm') public var beatsPerMinute:Float;
	@:alias('t') public var timestamp:Float;

	public function new(timestamp:Float, bpm:Float, num:Int, den:Int) {
		this.timestamp = timestamp;
		beatsPerMinute = bpm;
		timeSignatureNum = num;
		timeSignatureDen = den;
	}

	public inline function getBeatLengthMs():Float {
		return 60 / beatsPerMinute * 1000;
	}
}
