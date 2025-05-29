package funkin.play;

import funkin.music.MusicMetadata;
import funkin.util.JsonUtil;
import funkin.util.Paths;
import json2object.JsonParser;
import flixel.math.FlxPoint;

@:allow(funkin.play.SongDifficulty)
class Song {
	private static var _songCount:Int = 0;

	public var id(default, null):String;

	public var metadata:Map<String, MusicMetadata>;
	public var difficulties:Map<String, Map<String, SongDifficulty>>;

	private var _data:Null<SongData>;

	private static final _parser:JsonParser<SongData> = new JsonParser<SongData>();

	public static function list():Array<String> {
		final prefix = Paths.asDirectory(Paths.file('songs', 'data'));
		final suffix = Paths.asExtension('json');

		return FlxG.assets.list(TEXT)
			.filter(asset -> asset.startsWith(prefix) && asset.endsWith(suffix))
			.map(asset -> asset.substring(prefix.length, asset.length - suffix.length));
	}

	public static function load(id:String):Null<Song> {
		final path = Paths.file('songs/$id', 'data', 'json');
		if (!FlxG.assets.exists(path, TEXT)) {
			FlxG.log.warn('There is no song $id');
			return null;
		}

		final json = FlxG.assets.getText(path);

		_parser.fromJson(json, path);
		JsonUtil.logErrors(_parser.errors);

		if (_parser.value != null) {
			final song = new Song(_parser.value);
			song.id = id;
			return song;
		}
		return null;
	}

	public function new(data:SongData) {
		this.id = 'runtime[$_songCount]';
		_data = data;

		metadata = [];
		difficulties = [];

		for (variationKey => variationData in _data.variations) {
			metadata[variationKey] = MusicMetadata.get(variationData.music, 'songs');

			difficulties[variationKey] = new Map<String, SongDifficulty>();
			for (difficulty in variationData.playData.difficulties) {
				difficulties[variationKey][difficulty.id] = new SongDifficulty(this, difficulty.id, difficulty.chart, variationKey);
			}
		}
	}
}

class SongDifficulty {
	public final difficulty:String;
	public final variation:String;

	public var metadata:MusicMetadata;

	public var strumlines:Array<SongStrumlineData>;

	public var notes:Array<SongNoteData>;
	public var noteSpeed:Float;

	public var events:Array<SongEventData>;

	private var _song:Song;

	public function new(song:Song, difficultyId:String, difficultyChart:String, variation:String) {
		_song = song;
		difficulty = difficultyId;
		this.variation = variation;

		metadata = song.metadata[variation];

		strumlines = song._data.variations[variation].playData.strumlines;

		notes = song._data.variations[variation].charts[difficultyChart].notes;
		noteSpeed = song._data.variations[variation].charts[difficultyChart].noteSpeed;

		events = song._data.variations[variation].events;
	}
}

@:structInit
class SongData {
	public var variations:Map<String, SongVariationData>;
}

@:structInit
class SongVariationData {
	public var music:String;
	public var playData:SongPlayData;
	public var charts:Map<String, SongChartData>;
	public var events:Array<SongEventData>;
}

@:structInit
class SongPlayData {
	public var strumlines:Array<SongStrumlineData>;
	public var difficulties:Array<{id:String, chart:String}>;
}

@:structInit
class SongStrumlineData {
	@:jcustomparse(funkin.util.DataUtil.parseJsonPoint)
	@:jcustomparse(funkin.util.DataUtil.writeJsonPoint)
	public var position:FlxPoint;

	public var scale:Float;
	public var alpha:Float;
	public var characters:Array<{p:Int, c:String}>;
	public var cpuControlled:Bool;
	public var attachedTrack:Int;
	public var muteOnMiss:Bool;
}

@:structInit
class SongChartData {
	public var notes:Array<SongNoteData>;
	public var noteSpeed:Float;
}

@:structInit
class SongNoteData {
	@:alias('t') public var strumTime:Float;
	@:alias('s') public var sustainLength:Float;
	@:alias('l') public var lane:Int;
	@:alias('k') public var kind:String;

	@:alias('p') @:optional var params:Null<Array<String>>;
}

@:structInit
class SongEventData {
	@:alias('t') public var strumTime:Float;
	@:alias('e') public var event:String;
	@:alias('p') public var params:Array<String>;
	@:jignore public var executed:Bool = false;
}
