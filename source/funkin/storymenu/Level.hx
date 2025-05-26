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
import funkin.util.Registry;

class Level implements IRegistryEntry<LevelData> {
	public final id:String;

	private var _data:Null<LevelData>;

	private static final _parser:JsonParser<LevelData> = new JsonParser<LevelData>();

	public function new(id:String) {
		this.id = id;

		final path = Paths.asDirectory(LevelRegistry.ASSETS_DIRECTORY) + id + Paths.asExtension(LevelRegistry.ASSETS_EXTENSION);
		final json = FlxG.assets.getText(path);

		_parser.fromJson(json, path);
		JsonUtil.logErrors(_parser.errors);
		_data = _parser.value;
	}

	public inline function hasValidData():Bool {
		return _data != null;
	}

	public inline function getTitle():String {
		return _data.title;
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

	public function destroy() {
		_data = null;
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

class LevelRegistry extends TypedAssetRegistry<Level, LevelData> {
	public static final ASSETS_DIRECTORY = Paths.file('levels', 'data');
	public static inline var ASSETS_EXTENSION = 'json';

	public static final instance:LevelRegistry = new LevelRegistry('levels');

	public function new(id:String) {
		super(id, ASSETS_DIRECTORY, ASSETS_EXTENSION, Level.new);
	}

	override function reloadEntries():LevelRegistry {
		destroyEntries();

		// TODO: scripted entries

		for (entryId in scanEntryIds()) {
			final entry = _entryFactory(entryId);
			if (entry.hasValidData())
				registerEntry(entry);
			else
				entry.destroy();
		}

		return this;
	}
}
