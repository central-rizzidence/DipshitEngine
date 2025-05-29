package funkin.storymenu;

import flixel.FlxSprite;
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

	public var sprite:FlxSprite;
	public var lock:FlxSprite;

	public var isFlashing:Bool = false;

	private var _callback:() -> Void;

	public function new() {
		super();

		sprite = new FlxSprite();
		add(sprite);

		lock = new FlxSprite(Paths.image('storymenu/lock'));
		add(lock);
	}

	public function setItem(name:String, callback:() -> Void):StoryMenuItem {
		this.name = name;
		_callback = callback;

		level = Level.load(name);
		level.configureItem(this);
		lock.x = sprite.x + sprite.width + LOCK_PADDING;

		unlocked = true;
		screenCenter(X);

		// TODO: lock levels

		return this;
	}

	private var _flashTimer:Float = 0;
	final flashFramerate:Float = 20;

	override function update(elapsed:Float) {
		y = FlxMath.lerp(y, targetY, FlxMath.getElapsedLerp(0.17, elapsed));

		// TODO: поправить
		if (isFlashing) {
			_flashTimer += elapsed;
			if (_flashTimer >= 1 / flashFramerate) {
				_flashTimer %= 1 / flashFramerate;
				sprite.color = (sprite.color == 0xffffffff) ? 0xff33ffff : 0xffffffff;
			}
		}

		super.update(elapsed);
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
