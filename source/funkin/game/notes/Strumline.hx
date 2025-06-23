package funkin.game.notes;

import moonchart.formats.BasicFormat.BasicNote;
import flixel.group.FlxGroup.FlxTypedGroup;

class Strumline extends FlxTypedGroup<Strum> {
	public static inline var KEY_COUNT:Int = 4;

	public var strumFactory:(lane:Int) -> Strum = defaultStrumFactory;
	public var noteFactory:(data:BasicNote) -> Note = defaultNoteFactory;

	public var noteSpeed:Float = 1;

	public function new() {
		super(KEY_COUNT);

		trace('source/funkin/game/notes/Strumline.hx@createStrums');
	}

	public function createStrums(x:Float, y:Float, scale:Float = 1, alpha:Float = 1) {
		for (lane in 0...KEY_COUNT) {
			final strum = strumFactory(lane);
			strum.setPosition(x + Strum.STRUM_SIZE * (lane - 2.15), y - Strum.STRUM_SIZE * 0.5);
			strum.scale.scale(scale);
			strum.setSize(strum.frameWidth * strum.scale.x, strum.frameHeight * strum.scale.y);
			strum.alpha *= alpha;
			add(strum);
		}
	}

	public function createNotes(datas:Array<BasicNote>) {
		for (data in datas) {
			final note = noteFactory(data);
		}
	}

	public static function defaultStrumFactory(lane:Int):Strum {
		final strum = new Strum();
		strum.frames = Paths.getSparrowAtlas('game/noteSkins/default/NOTE_assets');

		final staticAnim = ['arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT'][lane];
		strum.animation.addByPrefix('static', staticAnim, 24);

		final pressAnim = ['left press', 'down press', 'up press', 'right press'][lane];
		strum.animation.addByPrefix('pressed', pressAnim, 24, false);

		final confirmAnim = ['left confirm', 'down confirm', 'up confirm', 'right confirm'][lane];
		strum.animation.addByPrefix('confirm', confirmAnim, 24, false);

		strum.scale.scale(0.7);

		strum.playStatic();

		return strum;
	}

	public static function defaultNoteFactory(data:BasicNote):Note {
		final note = new Note(data);
		note.frames = Paths.getSparrowAtlas('game/noteSkins/default/NOTE_assets');

		final scrollAnim = ['purple0', 'blue0', 'green0', 'red0'][data.lane];
		note.animation.addByPrefix('scroll', scrollAnim, 24);

		note.scale.scale(0.7);
		note.updateHitbox();

		note.animation.play('scroll');
		return note;
	}
}
