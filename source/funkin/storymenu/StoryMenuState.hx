package funkin.storymenu;

import funkin.title.TitleState;
import funkin.play.Song;
import funkin.play.PlayState;
import flixel.util.FlxTimer;
import funkin.scoring.Highscore;
import flixel.text.FlxText;
import funkin.util.Paths;
import funkin.input.Controls;
import funkin.storymenu.preview.LevelPreview;
import funkin.util.MenuList.TypedMenuList;
import flixel.addons.transition.FlxTransitionableState;

class StoryMenuState extends FlxTransitionableState {
	public var items:TypedMenuList<StoryMenuItem>;

	public var preview:LevelPreview;
	public var scoreText:FlxText;
	public var difficultySelector:DifficultySelector;

	public var selectedVariation:String = Constants.DEFAULT_VARIATION;

	override function create() {
		persistentUpdate = true;
		super.create();

		items = new TypedMenuList<StoryMenuItem>(VERTICAL);
		items.selectionChanged.add(_onSelectionChanged);
		add(items);

		for (i => level in Level.list()) {
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

		TitleState.menuMusicConductor.beatHit.add(_beatHit);

		FlxG.assets.getSound(Paths.sound('menu/cancel'));
		FlxG.assets.getSound(Paths.sound('menu/confirm'));
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
		TitleState.menuMusicConductor.beatHit.remove(_beatHit);
		super.destroy();
	}

	private function _beatHit(beat:Int) {
		preview.playPropsDance(beat);
	}

	private function _onSelectionChanged(selected:StoryMenuItem) {
		selected.alpha = selected.unlocked ? 1 : 0.6;

		for (i => item in items.members)
			item.targetY = (i - items.selectedIndex) * 125 + 480;

		selected.level.configurePreview(preview, selectedVariation);
		scoreText.text = 'LEVEL SCORE: ${Highscore.getWeek(selected.name, difficultySelector.getSelectedDifficultyId(), selectedVariation)?.score ?? 0}';

		difficultySelector.setDifficulties(selected.level.getDifficulties(selectedVariation));
	}

	private function _selectLevel(level:String) {
		items.selectedItem.isFlashing = true;
		FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);

		preview.playPropsConfirm();

		final playlist = items.selectedItem.level.getSongs(selectedVariation).map(Song.load);
		final playstateFactory = () -> new PlayState({
			playlist: playlist
		});

		FlxTimer.wait(1, () -> {
			FlxG.switchState(playstateFactory);
		});
	}
}
