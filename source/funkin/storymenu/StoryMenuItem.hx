package funkin.storymenu;

import flixel.math.FlxMath;
import funkin.util.Paths;
import funkin.util.MenuList.IMenuItem;
import flixel.group.FlxSpriteContainer;

class StoryMenuItem extends FlxSpriteContainer implements IMenuItem {
	public static inline var LOCK_PADDING:Float = 4;

	public var name(default, null):String;

	public var unlocked(default, set):Bool = false;

	public var targetY:Float = 0;
	public var level(default, null):Level;

	private var _item:FunkinSprite;
	private var _lock:FunkinSprite;

	private var _callback:() -> Void;

	public function new() {
		super();

		_item = new FunkinSprite();
		add(_item);

		_lock = new FunkinSprite();
		_lock.loadGraphic(Paths.image('storymenu/lock'));
		add(_lock);
	}

	public function setItem(name:String, callback:() -> Void):StoryMenuItem {
		this.name = name;
		_callback = callback;

		level = Level.get(name);

		_item.loadGraphic(Paths.image(level.sprite));
		_lock.x = _item.x + _item.width + LOCK_PADDING;

		unlocked = true;
		screenCenter(X);

		// TODO: lock levels
		unlocked = true;

		return this;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		y = FlxMath.lerp(y, targetY, FlxMath.getElapsedLerp(0.17, elapsed));
	}

	private function _idle() {
		alpha = 0.6;
	}

	private function _select() {
		alpha = unlocked ? 1 : 0.6;
	}

	@:noCompletion
	private function set_unlocked(value:Bool):Bool {
		if (value)
			remove(_lock);
		else
			add(_lock);

		return unlocked = value;
	}
}
