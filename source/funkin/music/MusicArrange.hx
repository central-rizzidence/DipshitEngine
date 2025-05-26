package funkin.music;

import funkin.util.JsonUtil;
import json2object.ErrorUtils;
import funkin.util.Paths;
import json2object.JsonParser;

class MusicArrange {
	public var tracks:Array<MusicTrack>;
	public var shouldLoop:Bool = false;
	@:optional public var loopTime:Null<Float>;

	public function new() {
		tracks = [];
	}

	private static final _parser:JsonParser<MusicArrange> = new JsonParser<MusicArrange>();

	public static function get(id:String, directory:String = 'music'):MusicArrange {
		final path = Paths.file('$id/${Paths.cutLibrary(id)}-arrange', directory, 'json');

		_parser.fromJson(FlxG.assets.getText(path), path);

		JsonUtil.logErrors(_parser.errors);

		return _parser.value;
	}
}

class MusicTrack {
	@:alias('v') public var volume:Float;
	@:alias('t') public var playTime:Float;
	@:alias('s') @:optional public var startTime:Null<Float>;
	@:alias('e') @:optional public var endTime:Null<Float>;
	@:alias('a') public var asset:String;

	public function new(asset:String, volume:Float = 1, playTime:Float = 0) {
		this.asset = asset;
		this.volume = volume;
		this.playTime = playTime;
	}
}
