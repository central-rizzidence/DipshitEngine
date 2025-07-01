package funkin.game;

import moonchart.Moonchart;
import moonchart.formats.fnf.legacy.FNFPsych;
import moonchart.formats.fnf.legacy.FNFLegacy.FNFLegacyMetaValues;
import moonchart.formats.BasicFormat;
import flixel.sound.FlxSound;
import moonchart.formats.fnf.FNFCodename;
import moonchart.backend.FormatDetector;
import moonchart.backend.FormatData.Format;

class Song {
	private static final _POSSIBLE_FORMATS:Array<Format> = [FNF_CODENAME, FNF_LEGACY_PSYCH];

	public final id:String;
	public final difficulty:String;
	public final path:String;

	private var _format:Null<Format>;
	private var _codename:FNFCodenameFormat;
	private var _psych:PsychJsonFormat;

	private var _chart:BasicChartData;
	private var _meta:BasicMetaData;

	public function new(id:String, difficulty:String) {
		this.id = id;
		this.difficulty = difficulty;

		path = Paths.format('assets/data/songs/${id.toLowerCase()}');

		_format = FlxG.assets.getText('$path/format.txt').trim(); // It can be null only if the file does not exist
		if (_format == null) {
			FlxG.log.warn('It is strongly recommended to manually specify the chart format, automatic detection is not accurate');
			try {
				_format = FormatDetector.findInFolder(path, id, difficulty, {
					checkContents: true,
					possibleFormats: _POSSIBLE_FORMATS
				}).format;
			}
			catch (_)
				return FlxG.log.notice('No format detected');

			FlxG.log.notice('Format $_format detected, if it is incorrect then install it manually');
		}

		switch _format {
			case FNF_CODENAME:
				_readCodename();
			case FNF_LEGACY_PSYCH:
				_readPsych();
			case fmt:
				_errorFormat(fmt);
		}
	}

	public function getBPMChanges():Array<BasicBPMChange> {
		return _meta.bpmChanges.copy();
	}

	public function buildInstrumental():Null<FlxSound> {
		return FlxG.sound.load('assets/songs/${id.toLowerCase()}/Inst', FlxG.sound.defaultMusicGroup);
	}

	public function buildVocals():Array<FlxSound> {
		if (_meta.extraData.get(FNFLegacyMetaValues.NEEDS_VOICES) == false)
			return [];

		switch _format {
			case FNF_CODENAME:
				final vocals:Array<FlxSound> = [];
				final pushedSuffixes:Array<String> = [];
				for (dat in _codename.strumLines) {
					final suffix = dat.vocalsSuffix ?? '';
					if (!pushedSuffixes.contains(suffix)) {
						vocals.push(FlxG.sound.load('assets/songs/${id.toLowerCase()}/Voices$suffix', FlxG.sound.defaultMusicGroup));
						pushedSuffixes.push(suffix);
					}
				}
				return vocals;

			case FNF_LEGACY_PSYCH:
				final opponentVocals = 'assets/songs/${id.toLowerCase()}/Voices-Opponent';
				final playerVocals = 'assets/songs/${id.toLowerCase()}/Voices-Player';
				final sharedVocals = 'assets/songs/${id.toLowerCase()}/Voices';

				if (FlxG.assets.exists(opponentVocals, SOUND) && FlxG.assets.exists(playerVocals, SOUND))
					return [
						FlxG.sound.load(opponentVocals, FlxG.sound.defaultMusicGroup),
						FlxG.sound.load(playerVocals, FlxG.sound.defaultMusicGroup)
					];
				else if (FlxG.assets.exists(sharedVocals, SOUND))
					return [FlxG.sound.load(sharedVocals, FlxG.sound.defaultMusicGroup)];
				else
					return [];

			case fmt:
				_errorFormat(fmt);
				return [];
		}
	}

	public function getOpponentCharacter():String {
		return _meta.extraData.get(FNFLegacyMetaValues.PLAYER_2);
	}

	public function getBoyfriendCharacter():String {
		return _meta.extraData.get(FNFLegacyMetaValues.PLAYER_1);
	}

	public function getGirlfriendCharacter():String {
		return _meta.extraData.get(FNFLegacyMetaValues.PLAYER_3);
	}

	public function getStage():String {
		return _meta.extraData.get(FNFLegacyMetaValues.STAGE);
	}

	public function getNotes():Array<BasicNote> {
		return _chart.diffs[Moonchart.DEFAULT_DIFF].copy();
	}

	public function getScrollSpeed():Float {
		return _meta.scrollSpeeds[Moonchart.DEFAULT_DIFF];
	}

	public function getEvents():Array<BasicEvent> {
		return _chart.events.copy();
	}

	private function _readCodename() {
		final dataPath = Paths.format('$path/charts/$difficulty.json');

		if (!FlxG.assets.exists(dataPath, TEXT))
			return FlxG.log.error('There is no chart for "$id" $difficulty');

		_codename = FlxG.assets.getJson(dataPath);

		if (_codename.meta == null) {
			final metaPath = Paths.firstExisting([Paths.format('$path/meta-$difficulty.json'), Paths.format('$path/meta.json')], TEXT);
			if (!FlxG.assets.exists(metaPath, TEXT))
				FlxG.log.warn('There is no meta for "$id" $difficulty');
			else
				_codename.meta = FlxG.assets.getJson(metaPath);
		}

		final eventsPath = Paths.firstExisting([Paths.format('$path/events-$difficulty.json'), Paths.format('$path/events.json')], TEXT);
		if (FlxG.assets.exists(eventsPath, TEXT)) {
			final events:Array<FNFCodenameEvent> = FlxG.assets.getJson(eventsPath)?.events;
			if (events?.length > 1) {
				if (_codename.events != null)
					_codename.events = _codename.events.concat(events);
				else
					_codename.events = events;
			}
		}

		final wrapper = new FNFCodename(_codename, _codename.meta);
		_chart = wrapper.getChartData();
		_meta = wrapper.getChartMeta();
	}

	private function _readPsych() {
		final diffSuffix = difficulty.toLowerCase() != Moonchart.DEFAULT_DIFF.toLowerCase() ? '-${difficulty.toLowerCase()}' : '';
		final dataPath = Paths.format('$path/${id.toLowerCase()}$diffSuffix.json');
		trace(dataPath);

		if (!FlxG.assets.exists(dataPath, TEXT))
			return FlxG.log.error('There is no chart for "$id" $difficulty');

		_psych = FlxG.assets.getJson(dataPath).song;

		final wrapper = new FNFPsych(_psych);
		_chart = wrapper.getChartData();
		_meta = wrapper.getChartMeta();
	}

	private static function _errorFormat(fmt:Format) {
		FlxG.log.error('Unsupported format $fmt');
	}
}
