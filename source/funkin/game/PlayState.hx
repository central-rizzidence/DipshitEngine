package funkin.game;

import funkin.input.Action;
import funkin.input.Controls;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import funkin.game.notes.Strumline;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.Song;
import funkin.transition.MusicBeatState;

class PlayState extends MusicBeatState {
	public var currentSong(default, null):Song;

	public var strumlines(default, null):FlxTypedGroup<Strumline>;

	public var instrumental:FlxSound;
	public var vocals:Array<FlxSound>;

	public function new(song:Song) {
		currentSong = song;
		super(currentSong != null ? new Conductor(currentSong.getBPMChanges()) : null);
	}

	override function create() {
		super.create();

		strumlines = new FlxTypedGroup<Strumline>();
		add(strumlines);

		createStrumline(0);
		createStrumline(1);

		instrumental = currentSong.buildInstrumental();
		if (instrumental == null) {
			FlxG.log.error('Could not load instrumental');
			instrumental = new FlxSound();
		}
		vocals = currentSong.buildVocals();

		conductor.playingMusic = instrumental;

		final sounds = [instrumental].concat(vocals);
		for (sound in sounds)
			sound.play();

		Controls.pressed.add(_onPressed);
		Controls.released.add(_onReleased);
	}

	public function createStrumline(player:Int) {
		final strumline = new Strumline();
		strumline.createStrums(FlxG.width * (0.25 + 0.5 * player), 106);
		strumline.createNotes(currentSong.getNotes().filter(data -> FlxMath.inBounds(data.lane, player * 4, player * 4 + Strumline.KEY_COUNT - 1)));
		// strumline.scrollSpeed = currentSong.getScrollSpeed();
		strumline.cpuControlled = player != 1;
		strumlines.insert(player, strumline);
	}

	override function update(elapsed:Float) {
		if (instrumental.playing) {
			conductor.updateMusic();
			strumlines.forEach(strumline -> strumline.updateNotes());
		}

		super.update(elapsed);
	}

	override function destroy() {
		currentSong = null;

		super.destroy();
	}

	@:access(flixel.sound.FlxSound._channel)
	private function _onPressed(actions:Array<Action>) {
		if (actions.contains(DEBUG_SKIP)) {
			instrumental.pitch = 3;
			for (vocal in vocals) {
				vocal.pitch = instrumental.pitch;
				vocal.time = instrumental._channel?.position ?? instrumental.time;
			}
		}
	}

	@:access(flixel.sound.FlxSound._channel)
	private function _onReleased(actions:Array<Action>) {
		if (actions.contains(DEBUG_SKIP)) {
			instrumental.pitch = 1;
			for (vocal in vocals) {
				vocal.pitch = instrumental.pitch;
				vocal.time = instrumental._channel?.position ?? instrumental.time;
			}
		}
	}
}
