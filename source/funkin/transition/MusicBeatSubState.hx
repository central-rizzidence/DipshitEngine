package funkin.transition;

import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState {
	public var conductor(default, null):Null<Conductor>;

	public function new(?conductor:Conductor) {
		super();

		if (conductor != null)
			this.conductor = conductor;
	}
}
