package funkin.storymenu.preview;

import flixel.text.FlxText;
import flixel.group.FlxContainer;

class LevelPreview extends FlxContainer {
	public var titleText:FlxText;

	public var background(default, null):FunkinSprite;

	public var cachedProps:Array<LevelPreviewProp> = [];
	public var cachedBopperProps:Array<LevelPreviewBopperProp> = [];

	public var songsText(default, null):FlxText;

	public function new() {
		super();

		final header = new FunkinSprite();
		header.makeGraphic(1, 1, 0xff000000);
		header.setGraphicSize(FlxG.width, 56);
		header.updateHitbox();
		add(header);

		titleText = new FlxText(10, 10, FlxG.width - 20, 'LEVEL 1');
		titleText.setFormat(Constants.DEFAULT_FONT, 32, 0xffffffff, RIGHT);
		titleText.alpha = 0.7;
		add(titleText);

		background = new FunkinSprite(0, header.y + header.height);
		background.makeGraphic(1, 1);
		background.setGraphicSize(FlxG.width, 400);
		background.updateHitbox();
		add(background);

		songsText = new FlxText(FlxG.width * 0.05, background.y + background.height + 44, 0, 'Tracks', 32);
		songsText.setFormat(Constants.DEFAULT_FONT, 32, 0xffe55777, CENTER);
		add(songsText);
	}

	public function playPropsDance(beat:Int) {
		for (bopperProp in cachedBopperProps) {
			if (bopperProp.getCurrentAnimationName() != 'confirm')
				bopperProp.playDance(beat);
		}
	}

	public function playPropsConfirm() {
		for (prop in cachedProps) {
			if (prop.hasAnimation('confirm'))
				prop.playAnimation('confirm');
		}

		for (bopperProp in cachedBopperProps) {
			if (bopperProp.hasAnimation('confirm'))
				bopperProp.playAnimation('confirm');
		}
	}
}
