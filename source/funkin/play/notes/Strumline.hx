package funkin.play.notes;

import funkin.extensions.FlxSpriteParent;
import funkin.play.Song.SongStrumlineData;
import flixel.group.FlxContainer;

class Strumline extends FlxContainer {
	public var strums:FlxTypedSpriteParent<Strum>;

	public function new(data:SongStrumlineData) {
		super();

		strums = new FlxTypedSpriteParent<Strum>(FlxG.width * data.position.x, data.position.y);
		add(strums);

		for (i in 0...4) {
			final strum = new Strum(i, this);
			strums.add(strum);

			strum.x = i * 160 * 0.7;
		}
		strums.origin.x = -strums.width * 0.5;
		strums.x -= strums.width * 0.5;
	}
}
