package funkin.music;

import funkin.music.MusicMetadata.MusicTimeChange;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import funkin.music.MusicMetadata.MusicTimeChange;

class Conductor implements IFlxDestroyable {
	public var currentTime(default, null):Float = 0;
	public var currentStep(default, null):Float = 0;
	public var currentBeat(default, null):Float = 0;
	public var currentMeasure(default, null):Float = 0;

	public var stepHit(default, null):FlxTypedSignal<(Int) -> Void>;
	public var beatHit(default, null):FlxTypedSignal<(Int) -> Void>;
	public var measureHit(default, null):FlxTypedSignal<(Int) -> Void>;

	private var _timeChanges:Array<MusicTimeChange>;

	public function new(timeChanges:Array<MusicTimeChange>) {
		stepHit = new FlxTypedSignal<(Int) -> Void>();
		beatHit = new FlxTypedSignal<(Int) -> Void>();
		measureHit = new FlxTypedSignal<(Int) -> Void>();

		setTimeChanges(timeChanges);
	}

	public function setTimeChanges(timeChanges:Array<MusicTimeChange>) {
		_timeChanges = timeChanges.copy();
		_timeChanges.sort(sortTimeChanges);
	}

	public static function sortTimeChanges(a:MusicTimeChange, b:MusicTimeChange):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, a.timestamp, b.timestamp);
	}

	public function destroy() {
		stepHit?.destroy();
		beatHit?.destroy();
		measureHit?.destroy();
		stepHit = beatHit = measureHit = null;

		_timeChanges = null;
	}

	public function updateTime(timeMs:Float) {
		currentTime = timeMs;

		var lastTimeChange:Null<MusicTimeChange> = null;

		final oldStep = Math.floor(currentStep);
		final oldBeat = Math.floor(currentBeat);
		final oldMeasure = Math.floor(currentMeasure);

		currentBeat = 0;

		for (timeChange in _timeChanges) {
			if (lastTimeChange != null)
				currentBeat += (timeChange.timestamp - lastTimeChange.timestamp) / lastTimeChange.getBeatLengthMs();
			currentBeat += (currentTime - timeChange.timestamp) / timeChange.getBeatLengthMs();

			lastTimeChange = timeChange;
		}

		currentStep = currentBeat * lastTimeChange.timeSignatureDen;
		currentMeasure = currentBeat / lastTimeChange.timeSignatureNum;

		final newStep = Math.floor(currentStep);
		final newBeat = Math.floor(currentBeat);
		final newMeasure = Math.floor(currentMeasure);

		if (newStep > oldStep)
			for (i in oldStep...newStep)
				stepHit.dispatch(i + 1);

		if (newBeat > oldBeat)
			for (i in oldBeat...newBeat)
				beatHit.dispatch(i + 1);

		if (newMeasure > oldMeasure)
			for (i in oldMeasure...newMeasure)
				measureHit.dispatch(i + 1);
	}
}
