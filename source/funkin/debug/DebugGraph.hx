package funkin.debug;

import flixel.system.debug.DebuggerUtil;
import openfl.display.Shape;
import flixel.math.FlxMath;
import openfl.text.TextField;
import flixel.util.FlxColor;
import openfl.display.Sprite;

/** literally copied from flixel because I'm lazy **/
final class DebugGraph extends Sprite {
	static inline var AXIS_COLOR:FlxColor = 0xffffff;
	static inline var AXIS_ALPHA:Float = 0.5;
	static inline var HISTORY_MAX:Int = 30;

	public var minLabel:TextField;
	public var curLabel:TextField;
	public var maxLabel:TextField;
	public var avgLabel:TextField;

	public var minValue:Float = FlxMath.MAX_VALUE_FLOAT;
	public var maxValue:Float = FlxMath.MIN_VALUE_FLOAT;

	public var graphColor:FlxColor;

	public var history:Array<Float> = [];

	var _axis:Shape;
	var _width:Float;
	var _height:Float;
	var _unit:String;
	var _labelWidth:Int;
	var _label:String;

	public function new(X:Float, Y:Float, Width:Float, Height:Float, GraphColor:FlxColor, Unit:String, LabelWidth:Int = 45, ?Label:String) {
		super();
		x = X;
		y = Y;
		_width = Width - LabelWidth;
		_height = Height;
		graphColor = GraphColor;
		_unit = Unit;
		_labelWidth = LabelWidth;
		_label = (Label == null) ? "" : Label;

		_axis = new Shape();
		_axis.x = _labelWidth + 10;

		final labelColor = 0xaaffffff;
		final textSize = 11;

		maxLabel = DebuggerUtil.createTextField(0, 0, labelColor, textSize);
		curLabel = DebuggerUtil.createTextField(0, (_height / 2) - (textSize / 2), graphColor, textSize);
		minLabel = DebuggerUtil.createTextField(0, _height - textSize, labelColor, textSize);

		avgLabel = DebuggerUtil.createTextField(_labelWidth + 20, (_height / 2) - (textSize / 2) - 10, labelColor, textSize);
		avgLabel.width = _width;
		avgLabel.defaultTextFormat.align = CENTER;
		avgLabel.alpha = 0.5;

		addChild(_axis);
		addChild(maxLabel);
		addChild(curLabel);
		addChild(minLabel);
		addChild(avgLabel);

		drawAxes();
	}

	/**
	 * Redraws the axes of the graph.
	 */
	function drawAxes():Void {
		var gfx = _axis.graphics;
		gfx.clear();
		gfx.lineStyle(1, AXIS_COLOR, AXIS_ALPHA);

		// y-Axis
		gfx.moveTo(0, 0);
		gfx.lineTo(0, _height);

		// x-Axis
		gfx.moveTo(0, _height);
		gfx.lineTo(_width, _height);
	}

	/**
	 * Redraws the graph based on the values stored in the history.
	 */
	function drawGraph():Void {
		var gfx = graphics;
		gfx.clear();
		gfx.lineStyle(1, graphColor, 1);

		var inc:Float = _width / (HISTORY_MAX - 1);
		var range:Float = Math.max(maxValue - minValue, maxValue * 0.1);
		var graphX = _axis.x + 1;

		for (i in 0...history.length) {
			var value = (history[i] - minValue) / range;

			var pointY = (-value * _height - 1) + _height;
			if (i == 0)
				gfx.moveTo(graphX, _axis.y + pointY);
			gfx.lineTo(graphX + (i * inc), pointY);
		}
	}

	public function update(Value:Float):Void {
		history.unshift(Value);
		if (history.length > HISTORY_MAX)
			history.pop();

		// Update range
		maxValue = Math.max(maxValue, Value);
		minValue = Math.min(minValue, Value);

		minLabel.text = formatValue(minValue);
		curLabel.text = formatValue(Value);
		maxLabel.text = formatValue(maxValue);

		avgLabel.text = _label + "\nAvg: " + formatValue(average());

		drawGraph();
	}

	function formatValue(value:Float):String {
		return FlxMath.roundDecimal(value, 1) + " " + _unit;
	}

	public function average():Float {
		var sum:Float = 0;
		for (value in history)
			sum += value;
		return sum / history.length;
	}

	public function destroy():Void {
		_axis = FlxDestroyUtil.removeChild(this, _axis);
		minLabel = FlxDestroyUtil.removeChild(this, minLabel);
		curLabel = FlxDestroyUtil.removeChild(this, curLabel);
		maxLabel = FlxDestroyUtil.removeChild(this, maxLabel);
		avgLabel = FlxDestroyUtil.removeChild(this, avgLabel);
		history = null;
	}
}
