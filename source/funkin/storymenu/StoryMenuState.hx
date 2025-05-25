package funkin.storymenu;

import funkin.input.Controls;
import funkin.storymenu.preview.LevelPreview;
import flixel.group.FlxContainer.FlxTypedContainer;
import funkin.music.MusicPlayback;
import funkin.util.MenuList.TypedMenuList;
import flixel.addons.transition.FlxTransitionableState;

class StoryMenuState extends FlxTransitionableState {
	private var _items:TypedMenuList<StoryMenuItem>;

	private var _preview:LevelPreview;

	override function create() {
		persistentUpdate = true;
		super.create();

		_items = new TypedMenuList<StoryMenuItem>(VERTICAL);
		_items.selectionChanged.add(_onSelectionChanged);
		add(_items);

		for (i => level in Level.list()) {
			final item = new StoryMenuItem().setItem(level, () -> _selectLevel(level));
			item.y = item.targetY = ((item.height + 20) * i);
			_items.add(item);
		}

		_preview = new LevelPreview();
		add(_preview);

		_items.changeSelection(0);

		MusicPlayback.current.conductor.beatHit.add(_beatHit);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.instance.justPressed.BACK) {
			_items.enabled = false;
			FlxG.switchState(() -> new funkin.mainmenu.MainMenuState());
		}
	}

	override function destroy() {
		MusicPlayback.current.conductor.beatHit.remove(_beatHit);
		super.destroy();
	}

	private function _beatHit(beat:Int) {
		_preview.playPropsDance(beat);
	}

	private function _onSelectionChanged(selected:StoryMenuItem) {
		selected.alpha = selected.unlocked ? 1 : 0.6;

		for (i => item in _items.members)
			item.targetY = (i - _items.selectedIndex) * 125 + 480;

		_preview.setLevel(selected.level, selected.name, 'normal');
	}

	private function _selectLevel(level:String) {
		_preview.playPropsConfirm();
		FlxG.log.notice('TODO: select level');
	}
}
