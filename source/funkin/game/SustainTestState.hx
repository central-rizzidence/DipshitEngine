package funkin.game;

import funkin.game.notes.Sustain;
import funkin.game.notes.Strumline;
import funkin.game.notes.Note;
import flixel.FlxSprite;
import funkin.transition.MusicBeatState;

class SustainTestState extends MusicBeatState {
	var sus:Sustain;
	var tm:Float = 0;

	override function create() {
		super.create();

		var spr = new FlxSprite(0, FlxG.height * 0.1).makeGraphic(FlxG.width, 500, 0xffff0000);
		add(spr);

		var note = new Note({
			lane: 2,
			time: 0,
			length: 500 / Strumline.PIXELS_PER_MS,
			type: ''
		});

		sus = new Sustain(note);
		sus.y = FlxG.height * 0.1;
		sus.loadGraphic(Paths.image('game/noteSkins/default/NOTE_hold_assets'), true, 52, 87);
		sus.scale.scale(0.7);
		sus.updateHitbox();
		sus.alpha = 0.6;
		add(sus);
	}

	override function update(elapsed:Float) {
		if (FlxG.keys.pressed.UP)
			tm -= elapsed * 1000;
		if (FlxG.keys.pressed.DOWN)
			tm += elapsed * 1000;

		sus.updateClipping(tm);

		super.update(elapsed);
	}
}
