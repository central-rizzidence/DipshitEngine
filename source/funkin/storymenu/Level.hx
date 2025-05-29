package funkin.storymenu;

import funkin.storymenu.preview.LevelPreviewBopperProp;
import funkin.storymenu.preview.LevelPreviewProp;
import funkin.storymenu.preview.LevelPreviewData;
import funkin.storymenu.preview.LevelPreview;
import funkin.scoring.Highscore;
import flixel.math.FlxPoint;
import funkin.util.JsonUtil;
import json2object.JsonParser;
import funkin.util.Paths;

class Level {
	private static var _levelCount:Int = 0;

	public var id(default, null):String;

	public var title(get, set):String;

	private var _data:Null<LevelData>;

	private static final _parser:JsonParser<LevelData> = new JsonParser<LevelData>();

	public static function list():Array<String> {
		final prefix = Paths.asDirectory(Paths.file('levels', 'data'));
		final suffix = Paths.asExtension('json');

		return FlxG.assets.list(TEXT)
			.filter(asset -> asset.startsWith(prefix) && asset.endsWith(suffix))
			.map(asset -> asset.substring(prefix.length, asset.length - suffix.length));
	}

	public static function load(id:String):Null<Level> {
		final path = Paths.file('levels/$id', 'data', 'json');
		if (!FlxG.assets.exists(path, TEXT)) {
			FlxG.log.warn('There is no level $id');
			return null;
		}

		final json = FlxG.assets.getText(path);

		_parser.fromJson(json, path);
		JsonUtil.logErrors(_parser.errors);

		if (_parser.value != null) {
			final level = new Level(_parser.value);
			level.id = id;
			return level;
		}
		return null;
	}

	public function new(data:LevelData) {
		this.id = 'runtime[${_levelCount++}]';
		_data = data;
	}

	public inline function configureItem(item:StoryMenuItem):StoryMenuItem {
		item.sprite.loadGraphic(Paths.image(_data.sprite));
		if (_data.offsets != null)
			item.sprite.offset.copyFrom(_data.offsets);
		else
			item.sprite.offset.set();
		return item;
	}

	public inline function getSongs(variation:String):Null<Array<String>> {
		return _data.songs.get(variation);
	}

	public inline function getDifficulties(variation:String):Null<Array<String>> {
		return _data.difficulties.get(variation);
	}

	public inline function isUnlocked(difficulty:String, variation:String):Bool {
		return _data.unlocksAfter.length == 0 || Highscore.getWeek(_data.unlocksAfter, difficulty, variation) != null;
	}

	public inline function configurePreview(preview:LevelPreview, variation:String):LevelPreview {
		preview.titleText.text = _data.title;

		for (prop in preview.cachedProps)
			preview.remove(prop, true);
		for (bopperProp in preview.cachedBopperProps)
			preview.remove(bopperProp, true);

		final propsCount = _data.preview.props.filter(prop -> prop.bopper == null).length;
		final bopperPropsCount = _data.preview.props.filter(prop -> prop.bopper != null).length;

		while (propsCount > preview.cachedProps.length)
			preview.cachedProps.push(new LevelPreviewProp());
		while (bopperPropsCount > preview.cachedBopperProps.length)
			preview.cachedBopperProps.push(new LevelPreviewBopperProp());

		if (_data.preview == null) {
			preview.background.color = 0xffffffff;
		} else {
			preview.background.color = _data.preview.background;

			var addedProps = 0;
			var addedBopperProps = 0;
			for (prop in _data.preview.props) {
				if (prop.bopper != null)
					preview.add(preview.cachedBopperProps[addedBopperProps++].setData(prop));
				else
					preview.add(preview.cachedProps[addedProps++].setData(prop));
			}
		}

		preview.songsText.text = 'TRACKS\n\n';
		if (_data.songs.exists(variation))
			preview.songsText.text += getSongs(variation).join('\n');
		else {
			FlxG.log.warn('Level $id has no variation $variation');
			preview.songsText.text += '-';
		}
		preview.songsText.screenCenter(X);
		preview.songsText.x -= FlxG.width * 0.35;

		return preview;
	}

	@:noCompletion
	private inline function get_title():String {
		return _data.title;
	}

	@:noCompletion
	private function set_title(value:String):String {
		return _data.title = value;
	}
}

@:structInit
class LevelData {
	public var title:String;
	public var sprite:String;
	public var songs:Map<String, Array<String>>;
	public var difficulties:Map<String, Array<String>>;
	public var unlocksAfter:String;
	public var preview:LevelPreviewData;

	@:jcustomparse(funkin.util.DataUtil.parseJsonPointOptional)
	@:jcustomparse(funkin.util.DataUtil.writeJsonPoint)
	@:optional public var offsets:Null<FlxPoint>;
}
