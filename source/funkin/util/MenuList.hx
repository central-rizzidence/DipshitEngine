package funkin.util;

import funkin.input.Controls;
import flixel.math.FlxMath;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.FlxBasic;

class TypedMenuList<T:FlxBasic & IMenuItem> extends FlxTypedContainer<T> {
	public var selectedIndex(default, null):Int = 0;
	public var selectedItem(get, never):T;

	public var selectionChanged(default, null):FlxTypedSignal<(T) -> Void>;
	public var acceptPressed(default, null):FlxTypedSignal<(T) -> Void>;

	public var navigationControls:MenuNavigationControls;
	public var wrapMode:MenuWrapMode = BOTH;

	public var enabled:Bool = true;

	public function new(navigationControls:MenuNavigationControls, ?wrapMode:MenuWrapMode) {
		super();

		selectionChanged = new FlxTypedSignal<(T) -> Void>();
		acceptPressed = new FlxTypedSignal<(T) -> Void>();

		this.navigationControls = navigationControls;
		this.wrapMode = wrapMode ?? switch navigationControls {
			case HORIZONTAL: HORIZONTAL;
			case VERTICAL: VERTICAL;
			case _: BOTH;
		}
	}

	public function resetItem(oldName:String, newName:String, ?callback:() -> Void):T {
		final item = Lambda.find(members, member -> member.name == oldName);
		if (item == null) {
			FlxG.log.warn('No item named $oldName');
			return null;
		}

		item.setItem(newName, callback ?? item._callback);
		return item;
	}

	override function update(elapsed:Float) {
		if (enabled)
			updateControls();

		super.update(elapsed);
	}

	public function updateControls() {
		if (length == 0)
			return;

		final wrapX = wrapMode.match(HORIZONTAL | BOTH);
		final wrapY = wrapMode.match(VERTICAL | BOTH);

		final waitAndRepeat = Controls.instance.waitAndRepeat();
		final mouse = FlxG.mouse.wheel == 0 ? 0 : FlxMath.signOf(FlxG.mouse.wheel);

		final newIndex = switch navigationControls {
			case HORIZONTAL: _navigateList(waitAndRepeat.UI_LEFT || mouse > 0, waitAndRepeat.UI_RIGHT || mouse < 0, wrapX);
			case VERTICAL: _navigateList(waitAndRepeat.UI_UP || mouse > 0, waitAndRepeat.UI_DOWN || mouse < 0, wrapY);
			case BOTH: _navigateList(waitAndRepeat.UI_LEFT || waitAndRepeat.UI_UP || mouse > 0, waitAndRepeat.UI_RIGHT || waitAndRepeat.UI_DOWN || mouse < 0,
					!wrapMode.match(NONE));
			case COLUMNS(num): _navigateGrid(num, waitAndRepeat.UI_LEFT, waitAndRepeat.UI_RIGHT, wrapX, waitAndRepeat.UI_UP || mouse > 0, waitAndRepeat.UI_DOWN
					|| mouse < 0, wrapY);
			case ROWS(num): _navigateGrid(num, waitAndRepeat.UI_UP, waitAndRepeat.UI_DOWN,
					wrapY, waitAndRepeat.UI_LEFT || mouse > 0, waitAndRepeat.UI_RIGHT || mouse < 0, wrapX);
		}

		if (newIndex != selectedIndex)
			changeSelection(newIndex);

		if (Controls.instance.justPressed.ACCEPT)
			pressAccept();
	}

	private function _navigateAxis(index:Int, size:Int, previous:Bool, next:Bool, allowWrap:Bool):Int {
		if (previous == next)
			return index;

		var delta = previous ? -1 : 1;
		var result = allowWrap ? FlxMath.wrap(index + delta, 0, size - 1) : index + delta;
		while (members[result] == null)
			result = allowWrap ? FlxMath.wrap(result + delta, 0, size - 1) : result + delta;

		return result;
	}

	private function _navigateList(previous:Bool, next:Bool, allowWrap:Bool):Int {
		return _navigateAxis(selectedIndex, length, previous, next, allowWrap);
	}

	private function _navigateGrid(lateralSize:Int, lateralPrevious:Bool, lateralNext:Bool, allowLateralWrap:Bool, previous:Bool, next:Bool,
			allowWrap:Bool):Int {
		final size = Math.ceil(length / lateralSize);
		var index = Math.floor(selectedIndex / lateralSize);
		var lateralIndex = selectedIndex % lateralSize;

		lateralIndex = _navigateAxis(lateralIndex, lateralSize, lateralPrevious, lateralNext, allowLateralWrap);
		index = _navigateAxis(index, size, previous, next, allowWrap);

		return Math.floor(Math.min(length - 1, index * lateralSize + lateralIndex));
	}

	public function pressAccept() {
		acceptPressed.dispatch(selectedItem);
		selectedItem._callback();
	}

	public function changeSelection(index:Int) {
		selectedItem._idle();

		selectedIndex = index;

		selectedItem._select();
		selectionChanged.dispatch(selectedItem);
	}

	public function hasItem(name:String):Bool {
		return Lambda.exists(members, member -> member.name == name);
	}

	public function getItem(name:String):Null<T> {
		return Lambda.find(members, member -> member.name == name);
	}

	override function destroy() {
		selectionChanged?.destroy();
		acceptPressed?.destroy();
		selectionChanged = acceptPressed = null;

		super.destroy();
	}

	@:noCompletion
	private inline function get_selectedItem():T {
		return members[selectedIndex];
	}
}

@:allow(funkin.util.TypedMenuList)
interface IMenuItem {
	public var name(default, null):String;

	private var _callback:() -> Void;

	public function setItem(name:String, callback:() -> Void):IMenuItem;

	private function _idle():Void;
	private function _select():Void;
}

enum MenuNavigationControls {
	HORIZONTAL;
	VERTICAL;
	BOTH;
	COLUMNS(num:Int);
	ROWS(num:Int);
}

enum MenuWrapMode {
	HORIZONTAL;
	VERTICAL;
	BOTH;
	NONE;
}
