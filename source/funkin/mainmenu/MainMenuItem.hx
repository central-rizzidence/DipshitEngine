package funkin.mainmenu;

import funkin.util.Paths;
import funkin.util.MenuList.IMenuItem;

class MainMenuItem extends FunkinSprite implements IMenuItem {
	public var name(default, null):String;

	private var _callback:() -> Void;

	public function setItem(name:String, callback:() -> Void):MainMenuItem {
		this.name = name;
		_callback = callback;

		var isSelected = getCurrentAnimation() == 'selected';

		loadFrames(Paths.file('mainmenu/$name', 'images'));
		addAnimation('idle', 'idle', true);
		addAnimation('selected', 'selected', true);

		if (isSelected)
			_select();
		else
			_idle();

		return this;
	}

	private function _idle() {
		playAnimation('idle');
		updateHitbox();
		screenCenter(X);
	}

	private function _select() {
		playAnimation('selected');
		centerOffsets();
		screenCenter(X);
	}
}
