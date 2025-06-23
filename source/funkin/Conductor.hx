package funkin;

import flixel.util.FlxSort;
import moonchart.formats.BasicFormat.BasicBPMChange;
import flixel.util.FlxSignal.FlxTypedSignal;

class Conductor implements IFlxDestroyable {
	public static var current(default, null):Null<Conductor>;

	public static function setCurrent(inst:Null<Conductor>) {
		if (inst != null)
			current = inst;
		FlxG.log.notice('New conductor assigned to current');
	}

	public var currentTime(default, null):Float = -1;
	public var currentStep(default, null):Float = -1;
	public var currentBeat(default, null):Float = -1;
	public var currentMeasure(default, null):Float = -1;

	public var stepHit(default, null):FlxTypedSignal<(step:Int) -> Void>;
	public var beatHit(default, null):FlxTypedSignal<(beat:Int) -> Void>;
	public var measureHit(default, null):FlxTypedSignal<(measure:Int) -> Void>;

	private var _bpmChanges:Array<BasicBPMChange>;

	public function new(?bpmChanges:Array<BasicBPMChange>) {
		stepHit = new FlxTypedSignal<(step:Int) -> Void>();
		beatHit = new FlxTypedSignal<(beat:Int) -> Void>();
		measureHit = new FlxTypedSignal<(measure:Int) -> Void>();

		if (bpmChanges != null)
			setBPMChanges(bpmChanges);
	}

	public function setBPMChanges(bpmChanges:Array<BasicBPMChange>) {
		_bpmChanges = bpmChanges.copy();
		_bpmChanges.sort(sortBPMChanges);
	}

	public static inline function sortBPMChanges(a:BasicBPMChange, b:BasicBPMChange):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
	}

	public function destroy() {
		stepHit?.destroy();
		beatHit?.destroy();
		measureHit?.destroy();
		stepHit = beatHit = measureHit = null;

		_bpmChanges = null;
	}

	public function updateTime(timeMs:Float) {
		currentTime = timeMs;

		var lastBPMChange:Null<BasicBPMChange> = null;

		final oldStep = Math.floor(currentStep);
		final oldBeat = Math.floor(currentBeat);
		final oldMeasure = Math.floor(currentMeasure);

		currentBeat = 0;

		for (bpmChange in _bpmChanges) {
			if (lastBPMChange != null)
				currentBeat += (bpmChange.time - lastBPMChange.time) / _getCrochet(lastBPMChange);
			currentBeat += (currentTime - bpmChange.time) / _getCrochet(bpmChange);

			lastBPMChange = bpmChange;
		}

		currentStep = currentBeat * lastBPMChange.stepsPerBeat;
		currentMeasure = currentBeat / lastBPMChange.beatsPerMeasure;

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

	private static function _getCrochet(bpmChange:BasicBPMChange):Float {
		return 60 / bpmChange.bpm * 1000;
	}
}
