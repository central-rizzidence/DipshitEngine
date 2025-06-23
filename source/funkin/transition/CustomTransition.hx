package funkin.transition;

import flixel.FlxSubState;

class CustomTransition extends FlxSubState {
	private var _duration:Float;
	private var _isTransIn:Bool;
	private var _callback:() -> Void;

	public function new(duration:Float, transIn:Bool, callback:() -> Void) {
		super();
		_duration = duration;
		_isTransIn = transIn;
		_callback = callback;
	}
}
