package funkin.storymenu;

import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;
import funkin.input.Controls;
import funkin.util.Paths;
import flixel.group.FlxSpriteContainer;

class DifficultySelector extends FlxSpriteContainer {
	public var arrowLeft:FunkinSprite;
	public var arrowRight:FunkinSprite;

	public var difficultySprites:FlxTypedSpriteContainer<FunkinSprite>;

	public var selectedDifficulty:Int = 0;

	public var cachedDifficultySprites:Map<String, FunkinSprite> = [];

	private var _difficultyNames:Array<String> = [];

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);

		arrowLeft = new FunkinSprite();
		arrowLeft.loadFrames(Paths.file('storymenu/arrows', 'images'));
		arrowLeft.addAnimation('idle', 'leftIdle', true);
		arrowLeft.addAnimation('press', 'leftConfirm', true);
		arrowLeft.playAnimation('idle');
		add(arrowLeft);

		arrowRight = new FunkinSprite(375);
		arrowRight.loadFrames(Paths.file('storymenu/arrows', 'images'));
		arrowRight.addAnimation('idle', 'rightIdle', true);
		arrowRight.addAnimation('press', 'rightConfirm', true);
		arrowRight.playAnimation('idle');
		add(arrowRight);

		difficultySprites = new FlxTypedSpriteContainer<FunkinSprite>(arrowLeft.x - x + arrowLeft.width + 10);
		add(difficultySprites);
	}

	override function update(elapsed:Float) {
		var deltaDifficulty = 0;

		if (Controls.instance.justPressed.UI_LEFT) {
			arrowLeft.playAnimation('press');
			deltaDifficulty--;
		}
		if (Controls.instance.justReleased.UI_LEFT || !Controls.instance.pressed.UI_LEFT)
			arrowLeft.playAnimation('idle');

		if (Controls.instance.justPressed.UI_RIGHT) {
			arrowRight.playAnimation('press');
			deltaDifficulty++;
		}
		if (Controls.instance.justReleased.UI_RIGHT || !Controls.instance.pressed.UI_RIGHT)
			arrowRight.playAnimation('idle');

		if (deltaDifficulty != 0)
			changeSelection(FlxMath.wrap(selectedDifficulty + deltaDifficulty, 0, difficultySprites.length - 1));

		super.update(elapsed);
	}

	public function setDifficulties(difficulties:Array<String>) {
		if (FlxArrayUtil.equals(_difficultyNames, difficulties))
			return;

		_difficultyNames = difficulties;

		difficultySprites.clear();

		for (difficulty in difficulties) {
			if (!cachedDifficultySprites.exists(difficulty)) {
				final sprite = new FunkinSprite();
				sprite.loadGraphic(Paths.image('storymenu/difficulties/$difficulty'));
				sprite.alpha = 0;
				cachedDifficultySprites[difficulty] = sprite;
			}
			difficultySprites.add(cachedDifficultySprites[difficulty]);
		}

		difficultySprites.forEach(sprite -> sprite.x += (difficultySprites.width - sprite.width) * 0.5);

		changeSelection(Math.round(difficulties.length * 0.5) - 1);
	}

	public function changeSelection(newSelection:Int) {
		difficultySprites.forEach(sprite -> {
			FlxTween.cancelTweensOf(sprite);
			sprite.alpha = 0;
		});

		selectedDifficulty = newSelection;
		final sprite = difficultySprites.members[selectedDifficulty];
		var targetY = y - 5;
		targetY -= (sprite.height - height) * 0.5;
		sprite.y = y - 10;
		FlxTween.tween(sprite, {y: targetY, alpha: 1}, 0.07);
	}
}
