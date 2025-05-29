package funkin.sound;

import flixel.sound.FlxSound;

class FlxSoundTools {
	@:access(flixel.sound.FlxSound._channel)
	public static inline function getAccurateTime(sound:FlxSound):Float {
		return sound._channel?.position ?? sound.time;
	}
}
