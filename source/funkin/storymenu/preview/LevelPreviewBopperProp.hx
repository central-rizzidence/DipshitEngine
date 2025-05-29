package funkin.storymenu.preview;

import funkin.util.Paths;
import funkin.storymenu.preview.LevelPreviewData;

class LevelPreviewBopperProp extends BopperSprite {
	public function setData(data:LevelPreviewPropData):LevelPreviewBopperProp {
		if (data.bopper == null) {
			FlxG.log.error('Data must have bopper parameters');
			return this;
		}

		setPosition(data.position.x, data.position.y);

		if (data.animations?.length > 0) {
			frames = Paths.getFrames(data.sprite);
			active = true;

			danceSequence = data.bopper.danceSequence;
			danceEvery = data.bopper.danceEvery;

			for (animation in data.animations)
				animation.addTo(this);

			if (data.startingAnimation != null)
				playAnimation(data.startingAnimation);
			else
				playDance(0);
		} else {
			loadGraphic(Paths.image(data.sprite));
			active = false;
		}
		scale.set(data.scale, data.scale);
		updateHitbox();

		return this;
	}
}
