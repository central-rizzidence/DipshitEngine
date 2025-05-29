package funkin.debug;

import funkin.input.Bindings;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxBasic;
import flixel.system.debug.DebuggerUtil;
import openfl.text.TextField;
import funkin.util.MemoryUtil;
import motion.Actuate;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.display.Sprite;

final class DebugInfo extends Sprite {
	public static inline var SHOW_HIDE_DURATION:Float = 1;

	public static inline var HEIGHT:Float = 100;
	public static inline var PADDING:Float = 10;

	public static inline var MEASURE_COOLDOWN:Float = 0.2;
	public static inline var BYTES_TO_MB:Float = 1 / 1024 / 1024;

	public var hidden(default, null):Bool = true;

	private var _frameTimeGraph:DebugGraph;
	private var _memoryGraph:DebugGraph;

	private var _flixelInfo:TextField;
	private var _polymodInfo:TextField;

	private var _measureTimer:Float = 0;

	public function new() {
		super();

		if (stage != null)
			_init();
		else
			addEventListener(Event.ADDED_TO_STAGE, _init);
	}

	private function _init(?event:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, _init);

		final graphWidth = 400;
		final graphHeight = HEIGHT - PADDING * 2;

		_frameTimeGraph = new DebugGraph(PADDING, PADDING, graphWidth, graphHeight, 0xff89ffd2, 'ms', 'Frame time');
		addChild(_frameTimeGraph);

		_memoryGraph = new DebugGraph(_frameTimeGraph.x + _frameTimeGraph.width + PADDING, PADDING, graphWidth, graphHeight, 0xff339dff, 'MB', 'Memory usage');
		addChild(_memoryGraph);

		_flixelInfo = DebuggerUtil.createTextField(_memoryGraph.x + _memoryGraph.width + PADDING, PADDING);
		addChild(_flixelInfo);

		_polymodInfo = DebuggerUtil.createTextField(0, PADDING);
		addChild(_polymodInfo);

		updateInfos();
		x = (stage.stageWidth - width) * 0.5;

		_drawBackground();

		hide(true);

		stage.addEventListener(Event.RESIZE, _onResize);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
	}

	private function _onResize(event:Event) {
		graphics.clear();

		x = (stage.stageWidth - width) * 0.5;

		_drawBackground();
	}

	private function _onKeyDown(event:KeyboardEvent) {
		if (!Bindings.keyboard.get(TOGGLE_DEBUGGER)?.contains(event.keyCode))
			return;

		if (hidden)
			show();
		else
			hide();
	}

	@:noCompletion
	override function __enterFrame(deltaTime:Int) {
		_frameTimeGraph.update(deltaTime);

		if (_measureTimer == 0) {
			_memoryGraph.maxValue = MemoryUtil.getAllocated() * BYTES_TO_MB;
			_memoryGraph.update(MemoryUtil.getUsed() * BYTES_TO_MB);
			updateInfos();
		}

		_measureTimer += deltaTime * 0.001;
		if (_measureTimer >= MEASURE_COOLDOWN)
			_measureTimer = 0;
	}

	public function show(instantly:Bool = false) {
		hidden = false;

		Actuate.stop(this);
		Actuate.tween(this, instantly ? 0 : SHOW_HIDE_DURATION, {y: 0, alpha: 1});
	}

	public function hide(instantly:Bool = false) {
		hidden = true;

		Actuate.stop(this);
		Actuate.tween(this, instantly ? 0 : SHOW_HIDE_DURATION, {y: -HEIGHT, alpha: 0});
	}

	private function _drawBackground() {
		graphics.clear();
		graphics.beginFill(0xff000000, 0.4);
		graphics.drawRect(-x, 0, stage.stageWidth, HEIGHT);
		graphics.endFill();
	}

	@:access(flixel.FlxBasic)
	@:access(flixel.tweens.FlxTweenManager._tweens)
	@:access(flixel.util.FlxTimerManager._timers)
	public function updateInfos() {
		_flixelInfo.text = 'Updates: Not implemented';
		_flixelInfo.text += '\nDraws: Not implemented';
		_flixelInfo.text += '\nTweens: ${FlxTween.globalManager._tweens.length}';
		_flixelInfo.text += '\nTimers: ${FlxTimer.globalManager._timers.length}';
		_flixelInfo.text += '\nState: ${Type.getClassName(Type.getClass(FlxG.state))}';

		_polymodInfo.x = _flixelInfo.x + _flixelInfo.width + PADDING;
		_polymodInfo.text = 'Loaded mods: Not implemented';
	}
}
