package funkin.credits;

import flixel.text.FlxText;
import funkin.util.MenuList.IMenuItem;
import flixel.group.FlxSpriteContainer;

class CreditsMenuItem extends FlxSpriteContainer implements IMenuItem {
	public var name(default, null):String;

	public var icon(default, null):FunkinSprite;
	public var text(default, null):FlxText; // TODO: change to alphabet

	private var _callback:() -> Void;

	public function setItem(name:String, callback:() -> Void):CreditsMenuItem {
		return this;
	}

	private function _idle() {}

	private function _select() {}
}
