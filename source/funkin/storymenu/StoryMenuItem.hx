package funkin.storymenu;

import funkin.storymenu.Level.LevelRegistry;
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

	public var sprite:FunkinSprite;
	public var lock:FunkinSprite;

	private var _callback:() -> Void;

	public function new() {
		super();

		sprite = new FunkinSprite();
		add(sprite);

		lock = new FunkinSprite();
		lock.loadGraphic(Paths.image('storymenu/lock'));
		add(lock);
	}

	public function setItem(name:String, callback:() -> Void):StoryMenuItem {
		this.name = name;
		_callback = callback;

		level = LevelRegistry.instance.findEntry(name);
		level.configureItem(this);
		lock.x = sprite.x + sprite.width + LOCK_PADDING;

		unlocked = true;
		screenCenter(X);

		// TODO: lock levels

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
			remove(lock);
		else
			add(lock);

		return unlocked = value;
	}
}
