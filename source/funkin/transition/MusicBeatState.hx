package funkin.transition;

import flixel.FlxSubState;
import flixel.FlxState;

class MusicBeatState extends FlxState {
	public var conductor(default, null):Null<Conductor>;

	public function new(?conductor:Conductor) {
		super();

		if (conductor != null)
			this.conductor = conductor;
	}

	override function create() {
		Conductor.setCurrent(conductor);
		openSubState(new CustomFadeTransition(0.6, true, closeSubState));
	}

	override function startOutro(onOutroComplete:() -> Void) {
		openSubState(new CustomFadeTransition(0.6, false, onOutroComplete));
	}

	override function openSubState(subState:FlxSubState) {
		final mbSubState = Std.downcast(subState, MusicBeatSubState);
		if (mbSubState != null)
			Conductor.setCurrent(mbSubState.conductor);

		super.openSubState(subState);
	}

	override function closeSubState() {
		Conductor.setCurrent(conductor);
		super.closeSubState();
	}
}
