package funkin;

class BopperSprite extends FunkinSprite {
	public var danceSequence:Array<String> = ['idle'];
	public var danceEvery:Int = 2;

	private var _currentDance:Int = 0;

	public function playDance(beat:Int):Bool {
		if (beat % danceEvery != 0)
			return false;

		if (danceSequence.length == 0) {
			FlxG.log.warn('Dance sequence must have at least one animation');
			return true;
		}

		_currentDance = Math.floor(beat / danceEvery) % danceSequence.length;
		playAnimation(danceSequence[_currentDance], true);

		return true;
	}
}
