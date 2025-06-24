package funkin.game.notes;

import flixel.util.FlxSort;
import flixel.math.FlxMath;
import funkin.input.Action;
import funkin.input.Controls;
import haxe.ds.Vector;
import flixel.FlxCamera;
import moonchart.formats.BasicFormat.BasicNote;
import flixel.group.FlxGroup.FlxTypedGroup;

class Strumline extends FlxTypedGroup<Strum> {
	public static inline var PIXELS_PER_MS:Float = 0.45;
	public static inline var KEY_COUNT:Int = 4;

	public var strumFactory:(lane:Int) -> Strum = defaultStrumFactory;
	public var noteFactory:(data:BasicNote) -> Note = defaultNoteFactory;
	public var sustainFactory:(note:Note) -> Sustain = defaultSustainFactory;

	public var sustains:FlxTypedGroup<Sustain>;
	public var notes:NoteGroup;

	public var cpuControlled:Bool = false;

	public var conductor:Conductor;

	private var _heldKeys:Vector<Bool> = new Vector<Bool>(KEY_COUNT, false);

	public function new(conductor:Conductor) {
		super(KEY_COUNT);

		sustains = new FlxTypedGroup<Sustain>();
		notes = new NoteGroup();

		this.conductor = conductor;

		Controls.pressed.add(_onPressed);
		Controls.released.add(_onReleased);
	}

	public function createStrums(x:Float, y:Float, scale:Float = 1, alpha:Float = 1) {
		for (lane in 0...KEY_COUNT) {
			final strum = strumFactory(lane);
			strum.setPosition(x + Strum.STRUM_SIZE * (lane - 2), y - Strum.STRUM_SIZE * 0.5);
			strum.scale.scale(scale);
			strum.updateHitbox();
			strum.alpha *= alpha;
			strum.playStatic();
			add(strum);
		}
	}

	public function createNotes(datas:Array<BasicNote>) {
		notes.prealloc(datas.length);
		sustains.clear();

		final sortedDatas = datas.copy();
		sortedDatas.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));

		for (i => data in sortedDatas) {
			final note = noteFactory(data);
			note.parentStrumline = this;
			notes.members[i] = note;

			if (data.length > 0) {
				note.sustain = sustainFactory(note);
				sustains.add(note.sustain);
			}
		}
	}

	public function updateNotes() {
		if (cpuControlled)
			_updateCPUControl();

		notes.forEach(note -> if (note.alive || note.sustain?.alive) updateNote(note));
		sustains.forEachAlive(sustain -> updateSustain(sustain));
	}

	public function updateNote(note:Note) {
		final noteStrum = members[note.noteLane % KEY_COUNT];

		note.distance = -PIXELS_PER_MS * (conductor.currentTime - note.strumTime) * noteStrum.noteSpeed;

		note.x = noteStrum.x + note.distance * noteStrum._noteCosDirection;
		note.y = noteStrum.y + note.distance * noteStrum._noteSinDirection;
	}

	public function updateSustain(sustain:Sustain) {
		sustain.updateHeight();

		if (sustain.parentNote.hasBeenHit) {
			if ((cpuControlled || _heldKeys[sustain.parentNote.noteLane % KEY_COUNT])
				&& FlxMath.inBounds(sustain.parentNote.strumTime, conductor.currentTime, conductor.currentTime + sustain.parentNote.sustainLength)) {
				_holdSustain(sustain);
			} else
				_releaseSustain(sustain);

			if (!sustain.handledRelease && sustain.parentNote.strumTime <= conductor.currentTime)
				sustain.updateClipping(conductor.currentTime);
		}

		if (sustain.clipHeight == 0)
			sustain.kill();

		sustain.x = sustain.parentNote.x + (sustain.parentNote.width - sustain.width) * 0.5;
		sustain.y = sustain.parentNote.y + sustain.parentNote.height * 0.5;
	}

	override function update(elapsed:Float) {
		if (Preferences.receptorsOverlap)
			sustains.update(elapsed);

		super.update(elapsed);

		if (!Preferences.receptorsOverlap)
			sustains.update(elapsed);

		notes.update(elapsed);
	}

	private function _updateCPUControl() {
		notes.forEachAlive(note -> {
			if (note.strumTime <= conductor.currentTime)
				_hitNote(note);
		});
	}

	private function _hitNote(note:Note) {
		final noteStrum = members[note.noteLane % KEY_COUNT];
		if (noteStrum != null) {
			noteStrum.playConfirm();
			if (cpuControlled)
				noteStrum.confirmTimer = 0.15;
		}

		note.kill();
		note.hasBeenHit = true;
	}

	private function _holdSustain(sustain:Sustain) {
		final noteStrum = members[sustain.parentNote.noteLane % KEY_COUNT];
		if (noteStrum != null) {
			noteStrum.holdConfirm();
			if (cpuControlled)
				noteStrum.confirmTimer = 0.15;
		}
	}

	private function _missNote(note:Note) {
		note.kill();
		note.handledMiss = true;
	}

	private function _releaseSustain(sustain:Sustain) {
		sustain.handledRelease = true;
	}

	@:access(flixel.FlxCamera._defaultCameras)
	override function draw() {
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
			FlxCamera._defaultCameras = _cameras;

		if (Preferences.receptorsOverlap)
			sustains.draw();

		for (basic in members) {
			if (basic != null && basic.exists && basic.visible)
				basic.draw();
		}

		if (!Preferences.receptorsOverlap)
			sustains.draw();

		notes.draw();

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	private function _onPressed(actions:Array<Action>) {
		if (cpuControlled)
			return;

		for (lane => action in [NOTE_LEFT, NOTE_DOWN, NOTE_UP, NOTE_RIGHT]) {
			if (!actions.contains(action))
				continue;

			final notesToHit = notes.members.filter(note -> !note.hasBeenHit
				&& !note.handledMiss
				&& note.noteLane % KEY_COUNT == lane
				&& note.canBeHit(Conductor.current.currentTime));

			if (notesToHit.length > 0) {
				notesToHit.sort(_sortHitNotes);
				var firstNote = notesToHit[0];

				if (notesToHit.length > 1) {
					final secondNote = notesToHit[1];
					if (Math.abs(secondNote.strumTime - firstNote.strumTime) < 1)
						secondNote.kill();
					else if (secondNote.strumTime < firstNote.strumTime)
						firstNote = secondNote;
				}
				_hitNote(firstNote);
			}

			_heldKeys[lane] = true;

			if (members[lane].animation.name != 'confirm')
				members[lane].playPress();
		}
	}

	private static function _sortHitNotes(a:Note, b:Note):Int {
		if (a.lowHitPriority && !b.lowHitPriority)
			return 1;
		else if (!a.lowHitPriority && b.lowHitPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function _onReleased(actions:Array<Action>) {
		if (cpuControlled)
			return;

		for (lane => action in [NOTE_LEFT, NOTE_DOWN, NOTE_UP, NOTE_RIGHT]) {
			if (!actions.contains(action))
				continue;

			_heldKeys[lane] = false;

			members[lane].playStatic();
		}
	}

	public static function defaultStrumFactory(lane:Int):Strum {
		final strum = new Strum();
		strum.frames = Paths.getSparrowAtlas('game/noteSkins/default/noteStrumline');

		final suffix = ['Left', 'Down', 'Up', 'Right'][lane % KEY_COUNT];
		strum.animation.addByPrefix('static', 'static$suffix', 24);
		strum.animation.addByPrefix('pressed', 'press$suffix', 24, false);
		strum.animation.addByPrefix('confirm', 'confirm$suffix', 24, false);
		strum.animation.addByPrefix('confirm-hold', 'confirmHold$suffix', 24, false);

		strum.scale.scale(0.7);
		strum.updateHitbox();

		return strum;
	}

	public static function defaultNoteFactory(data:BasicNote):Note {
		final note = new Note(data);
		note.frames = Paths.getSparrowAtlas('game/noteSkins/default/notes');

		final suffix = ['Left', 'Down', 'Up', 'Right'][data.lane % KEY_COUNT];
		note.animation.addByPrefix('note', 'note$suffix', 24);

		note.scale.scale(0.7);
		note.updateHitbox();

		note.animation.play('note');
		return note;
	}

	public static function defaultSustainFactory(note:Note):Sustain {
		final sustain = new Sustain(note);

		sustain.loadGraphic(Paths.image('game/noteSkins/default/NOTE_hold_assets'), true, 52, 87);
		sustain.scale.scale(0.7);
		sustain.updateHitbox();
		sustain.alpha = 0.6;

		return sustain;
	}
}
