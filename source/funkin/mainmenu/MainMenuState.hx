package funkin.mainmenu;

import funkin.input.Controls;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.typeLimit.NextState;
import funkin.util.MenuList.TypedMenuList;
import funkin.util.Paths;
import flixel.addons.transition.FlxTransitionableState;

class MainMenuState extends FlxTransitionableState {
	public var magenta:FunkinSprite;
	public var items:TypedMenuList<MainMenuItem>;

	public var camFollow:FlxObject;

	private var _camFollowPoint:FlxPoint = FlxPoint.get();

	override function create() {
		persistentUpdate = true;
		super.create();

		var bg = new FunkinSprite();
		bg.loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set();
		bg.setGraphicSize(bg.width * 1.175);
		bg.updateHitbox();
		bg.screenCenter();
		bg.active = false;
		add(bg);

		magenta = new FunkinSprite(bg.x, bg.y);
		magenta.loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.copyFrom(bg.scrollFactor);
		magenta.scale.copyFrom(bg.scale);
		magenta.updateHitbox();
		magenta.visible = false;
		magenta.color = 0xfffd719b;
		magenta.active;
		add(magenta);

		items = new TypedMenuList(BOTH);
		items.selectionChanged.add(_onSelectionChanged);
		add(items);

		_createMenuItem('storymode', () -> _startExitState(() -> new funkin.storymenu.StoryMenuState()));
		_createMenuItem('freeplay', () -> _startExitState(null));
		_createMenuItem('options', () -> _startExitState(null));
		_createMenuItem('credits', () -> _startExitState(null));

		bg.scrollFactor.y = magenta.scrollFactor.y = Math.max(0.25 - (0.05 * (items.length - 4)), 0.1);

		items.forEach(item -> {
			item.y += 108 - (Math.max(items.length, 4) - 4) * 80;
			item.scrollFactor.set(0, items.length < 6 ? 0 : (items.length - 4) * 0.135);
		});

		final textSize = 16;
		final textPadding = 2;
		final versionText = new FlxText(textPadding, FlxG.height - textSize - textPadding, FlxG.width, 'Soda Engine v${Constants.ENGINE_VERSION}');
		versionText.setFormat(Constants.DEFAULT_FONT, textSize, 0xffffffff, LEFT, OUTLINE, 0xff000000);
		versionText.scrollFactor.set();
		add(versionText);

		camFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		FlxG.camera.follow(camFollow, null, 0.06);
		FlxG.camera.snapToTarget();

		items.changeSelection(0);

		FlxG.assets.getSound(Paths.sound('menu/scroll'));
		FlxG.assets.getSound(Paths.sound('menu/confirm'));
	}

	private function _createMenuItem(name:String, callback:() -> Void) {
		final item = new MainMenuItem().setItem(name, callback);
		item.y = 140 * items.length;
		items.add(item);
	}

	private function _onSelectionChanged(selected:MainMenuItem) {
		selected.getGraphicMidpoint(_camFollowPoint);
		camFollow.setPosition(_camFollowPoint.x, _camFollowPoint.y);

		FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
	}

	private function _startExitState(nextState:NextState) {
		items.enabled = false;

		FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);

		FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		FlxFlicker.flicker(items.selectedItem, 1, 0.06, false, false, _ -> {
			FlxG.switchState(nextState);
		});

		for (i in 0...items.length) {
			if (i == items.selectedIndex)
				continue;

			FlxTween.tween(items.members[i], {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.instance.justPressed.BACK) {
			items.enabled = false;
			FlxG.sound.play(Paths.sound('menu/cancel'));
			FlxG.switchState(() -> new funkin.title.TitleState());
		}
	}
}
