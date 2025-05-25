package funkin.storymenu.preview;

import funkin.util.Paths;
import funkin.storymenu.preview.LevelPreviewData;

class LevelPreviewProp extends FunkinSprite {
	public function setData(data:LevelPreviewPropData):LevelPreviewProp {
		if (data.bopper != null)
			FlxG.log.warn('Data has bopper parameters, it is recommended to apply to LevelPreviewBopperProp');

		setPosition(data.position.x, data.position.y);

		if (data.animations?.length > 0) {
			loadFrames(Paths.file(data.sprite, 'images'));
			active = true;

			for (animation in data.animations)
				animation.addTo(this);

			if (data.startingAnimation != null)
				playAnimation(data.startingAnimation);
		} else {
			loadGraphic(Paths.image(data.sprite));
			active = false;
		}
		scale.set(data.scale, data.scale);
		updateHitbox();

		return this;
	}
}
