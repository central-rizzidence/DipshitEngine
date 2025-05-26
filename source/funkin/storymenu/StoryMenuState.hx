package funkin.storymenu;

import funkin.storymenu.Level.LevelRegistry;
import funkin.scoring.Highscore;
import flixel.text.FlxText;
import funkin.util.Paths;
import funkin.input.Controls;
import funkin.storymenu.preview.LevelPreview;
import funkin.music.MusicPlayback;
import funkin.util.MenuList.TypedMenuList;
import flixel.addons.transition.FlxTransitionableState;

class StoryMenuState extends FlxTransitionableState {
	public var items:TypedMenuList<StoryMenuItem>;

	public var preview:LevelPreview;
	public var scoreText:FlxText;
	public var difficultySelector:DifficultySelector;

	public var currentVariation:String = Constants.DEFAULT_VARIATION;

	override function create() {
		persistentUpdate = true;
		super.create();

		items = new TypedMenuList<StoryMenuItem>(VERTICAL);
		items.selectionChanged.add(_onSelectionChanged);
		add(items);

		for (i => level in LevelRegistry.instance.listEntryIds()) {
			final item = new StoryMenuItem().setItem(level, () -> _selectLevel(level));
			item.y = item.targetY = ((item.height + 20) * i);
			items.add(item);
		}

		preview = new LevelPreview();
		add(preview);

		scoreText = new FlxText(10, 10, 'LEVEL SCORE: 42069420');
		scoreText.setFormat(Constants.DEFAULT_FONT, 32);
		add(scoreText);

		difficultySelector = new DifficultySelector(870, 480);
		add(difficultySelector);

		items.changeSelection(0);

		MusicPlayback.current.conductor.beatHit.add(_beatHit);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.instance.justPressed.BACK) {
			items.enabled = false;
			FlxG.sound.play(Paths.sound('menu/cancel'), 0.7);
			FlxG.switchState(() -> new funkin.mainmenu.MainMenuState());
		}
	}

	override function destroy() {
		MusicPlayback.current.conductor.beatHit.remove(_beatHit);
		super.destroy();
	}

	private function _beatHit(beat:Int) {
		preview.playPropsDance(beat);
	}

	private function _onSelectionChanged(selected:StoryMenuItem) {
		selected.alpha = selected.unlocked ? 1 : 0.6;

		for (i => item in items.members)
			item.targetY = (i - items.selectedIndex) * 125 + 480;

		selected.level.configurePreview(preview, currentVariation);
		scoreText.text = 'LEVEL SCORE: ${Highscore.getWeek(selected.name, 'normal', currentVariation)?.score ?? 0}';

		difficultySelector.setDifficulties(selected.level.getDifficulties(currentVariation));
	}

	private function _selectLevel(level:String) {
		preview.playPropsConfirm();
		FlxG.log.notice('TODO: select level');
	}
}
