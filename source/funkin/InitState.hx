package funkin;

import funkin.util.Paths;
import funkin.logging.FlxLogHandler;
import funkin.plugins.ReloadPlugin;
import funkin.input.Bindings;
import funkin.input.Controls;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import funkin.assets.FlxAssetsHandler;
import flixel.FlxState;

class InitState extends FlxState {
	override function create() {
		FlxLogHandler.setupRetranslation();
		// FlxAssetsHandler.replaceFunctions();

		FlxG.assets.getBitmapDataUnsafe(Paths.image('meru'));

		Config.createMissingData();
		Config.applyAll();

		_setupTransitions();

		_initControls();

		FlxG.plugins.addIfUniqueType(new ReloadPlugin());

		FlxG.switchState(() -> new funkin.title.TitleState());
	}

	private function _setupTransitions() {
		// Diamond Transition
		final diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		// NOTE: tileData is ignored if TransitionData.type is FADE instead of TILES.
		final tileData = {asset: diamond, width: 32, height: 32};

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xff000000, Constants.TRANSITION_IN_DURATION, FlxPoint.get(0, -1), tileData,
			FlxRect.get(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xff000000, Constants.TRANSITION_OUT_DURATION, FlxPoint.get(0, 1), tileData,
			FlxRect.get(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		// Don't play transition in when entering the title state.
		FlxTransitionableState.skipNextTransIn = true;
	}

	private function _initControls() {
		Controls.instance = new Controls();
		FlxG.inputs.addInput(Controls.instance);
	}
}
