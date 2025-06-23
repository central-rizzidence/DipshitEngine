package funkin.game;

import funkin.game.notes.SustainTrail;
import flixel.FlxSprite;
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
		// super(currentSong != null ? new Conductor(currentSong.getBPMChanges()) : null);
		super();
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

		final sounds = [instrumental].concat(vocals);
		for (sound in sounds)
			sound.play();

		var spr = new FlxSprite(0, FlxG.height * 0.1).makeGraphic(FlxG.width, 500, 0xff78ffa5);
		add(spr);

		var note = new SustainTrail();
		note.x = 200;
		note.y = FlxG.height * 0.1;
		note.alpha = 0.6;
		// note.angle = -35;
		note.updateClipping(0, 1);
		add(note);
	}

	public function createStrumline(player:Int) {
		final strumline = new Strumline();
		strumline.createStrums(FlxG.width * (0.25 + 0.5 * player), 106);
		strumlines.insert(player, strumline);
	}

	override function destroy() {
		currentSong = null;

		super.destroy();
	}
}
