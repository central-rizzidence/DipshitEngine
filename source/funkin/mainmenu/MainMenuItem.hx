package funkin.mainmenu;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.util.Paths;
import funkin.util.MenuList.IMenuItem;

class MainMenuItem extends FlxSprite implements IMenuItem {
	public var name(default, null):String;

	private var _callback:() -> Void;

	public function setItem(name:String, callback:() -> Void):MainMenuItem {
		this.name = name;
		_callback = callback;

		var isSelected = animation.name == 'selected';

		frames = Paths.getFrames('mainmenu/$name');
		animation.addByPrefix('idle', 'idle', 24);
		animation.addByPrefix('selected', 'selected', 24);

		if (isSelected)
			_select();
		else
			_idle();

		return this;
	}

	private function _idle() {
		animation.play('idle');
		updateHitbox();
		screenCenter(X);
	}

	private function _select() {
		animation.play('selected');
		centerOffsets();
	}
}
