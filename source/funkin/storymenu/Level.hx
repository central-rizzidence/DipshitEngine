package funkin.storymenu;

import funkin.util.JsonUtil;
import funkin.storymenu.preview.LevelPreviewData;
import json2object.ErrorUtils;
import json2object.JsonParser;
import funkin.util.Paths;
import flixel.util.FlxColor;

class Level {
	public var title:String;
	public var sprite:String;
	public var songs:Array<String>;
	public var difficulties:Array<String>;
	public var unlocksAfter:String;
	public var preview:LevelPreviewData;

	public function new(title:String, sprite:String, ?difficulties:Array<String>, background:FlxColor = 0xfff9cf51) {
		this.title = title;
		this.sprite = sprite;
		songs = [];
		this.difficulties = difficulties ?? ['easy', 'normal', 'hard'];
		unlocksAfter = '';
		preview = new LevelPreviewData(background);
	}

	private static final _parser:JsonParser<Level> = new JsonParser<Level>();

	public static function get(id:String):Null<Level> {
		final path = Paths.file('levels/$id', 'data', 'json');

		_parser.fromJson(FlxG.assets.getText(path), path);

		JsonUtil.logErrors(_parser.errors);

		return _parser.value;
	}

	public static function list():Array<String> {
		final prefix = 'assets/data/levels/';
		final suffix = '.json';

		return FlxG.assets.list(TEXT)
			.filter(asset -> asset.startsWith(prefix) && asset.endsWith(suffix))
			.map(asset -> asset.substring(prefix.length, asset.length - suffix.length));
	}
}
