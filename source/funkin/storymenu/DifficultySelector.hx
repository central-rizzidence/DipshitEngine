package funkin.storymenu;

import flixel.FlxSprite;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;
import funkin.input.Controls;
import funkin.util.Paths;
import flixel.group.FlxSpriteContainer;

class DifficultySelector extends FlxSpriteContainer {
	public var arrowLeft(default, null):FunkinSprite;
	public var arrowRight(default, null):FunkinSprite;

	public var difficultySprites(default, null):FlxTypedSpriteContainer<FlxSprite>;

	public var selectedDifficulty(default, null):Int = 0;

	public var cachedDifficultySprites:Map<String, FlxSprite> = [];

	private var _difficultyIds:Array<String> = [];

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);

		arrowLeft = new FunkinSprite();
		arrowLeft.frames = Paths.getFrames('storymenu/arrows');
		arrowLeft.addAnimation('idle', 'leftIdle', true);
		arrowLeft.addAnimation('press', 'leftConfirm', true);
		arrowLeft.playAnimation('idle');
		add(arrowLeft);

		arrowRight = new FunkinSprite(375);
		arrowRight.frames = Paths.getFrames('storymenu/arrows');
		arrowRight.addAnimation('idle', 'rightIdle', true);
		arrowRight.addAnimation('press', 'rightConfirm', true);
		arrowRight.playAnimation('idle');
		add(arrowRight);

		difficultySprites = new FlxTypedSpriteContainer<FlxSprite>(arrowLeft.x - x + arrowLeft.width + 10);
		add(difficultySprites);
	}

	override function update(elapsed:Float) {
		var deltaDifficulty = 0;

		if (Controls.instance.justPressed.UI_LEFT) {
			arrowLeft.animation.play('press');
			deltaDifficulty--;
		}
		if (Controls.instance.justReleased.UI_LEFT || !Controls.instance.pressed.UI_LEFT)
			arrowLeft.animation.play('idle');

		if (Controls.instance.justPressed.UI_RIGHT) {
			arrowRight.animation.play('press');
			deltaDifficulty++;
		}
		if (Controls.instance.justReleased.UI_RIGHT || !Controls.instance.pressed.UI_RIGHT)
			arrowRight.animation.play('idle');

		if (deltaDifficulty != 0)
			changeDifficulty(FlxMath.wrap(selectedDifficulty + deltaDifficulty, 0, difficultySprites.length - 1));

		super.update(elapsed);
	}

	public function setDifficulties(difficulties:Array<String>) {
		if (FlxArrayUtil.equals(_difficultyIds, difficulties))
			return;

		_difficultyIds = difficulties;

		difficultySprites.clear();

		for (difficulty in difficulties) {
			if (!cachedDifficultySprites.exists(difficulty)) {
				final sprite = new FunkinSprite();
				if (Paths.hasFrames('storymenu/difficulties/$difficulty')) {
					sprite.frames = Paths.getFrames('storymenu/difficulties/$difficulty');
					sprite.addAnimation('idle', difficulty, true);
					sprite.playAnimation('idle');
				} else
					sprite.loadGraphic(Paths.image('storymenu/difficulties/$difficulty'));
				sprite.alpha = 0;
				cachedDifficultySprites[difficulty] = sprite;
			}
			difficultySprites.add(cachedDifficultySprites[difficulty]);
		}

		difficultySprites.forEach(sprite -> sprite.x += (difficultySprites.width - sprite.width) * 0.5);

		changeDifficulty(Math.round(difficulties.length * 0.5) - 1);
	}

	public function changeDifficulty(newDifficulty:Int) {
		difficultySprites.forEach(sprite -> {
			FlxTween.cancelTweensOf(sprite);
			sprite.alpha = 0;
		});

		selectedDifficulty = newDifficulty;
		final sprite = difficultySprites.members[selectedDifficulty];
		var targetY = y - 5;
		targetY -= (sprite.height - height) * 0.5;
		sprite.y = y - 10;
		FlxTween.tween(sprite, {y: targetY, alpha: 1}, 0.07);
	}

	public function getSelectedDifficultyId():String {
		return _difficultyIds[selectedDifficulty];
	}
}
