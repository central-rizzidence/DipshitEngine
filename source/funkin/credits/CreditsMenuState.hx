package funkin.credits;

import funkin.util.Paths;
import flixel.addons.transition.FlxTransitionableState;

class CreditsMenuState extends FlxTransitionableState {
	override function create() {
		super.create();

		var spr = new FunkinSprite();
		spr.loadGraphic(Paths.image('storymenu/lock'));
		spr.setGraphicSize(FlxG.width, FlxG.height);
		spr.updateHitbox();
		add(spr);
	}
}
