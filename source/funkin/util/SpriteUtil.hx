package funkin.util;

class SpriteUtil {
	public static function loadFrames(sprite:FunkinSprite, imageId:String):FunkinSprite {
		sprite.frames = Paths.getFrames(imageId);
	}
}
