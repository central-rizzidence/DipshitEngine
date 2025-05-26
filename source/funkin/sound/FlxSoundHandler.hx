package funkin.sound;

final class FlxSoundHandler {
	private static inline var _MIN_VOLUME = 0.001;
	private static final _STUPID_LOG = Math.log(_MIN_VOLUME);

	public static function setupCurve() {
		FlxG.sound.applySoundCurve = volume -> {
			// If linear volume is 0, return 0
			if (volume <= 0)
				return 0;

			// Ensure x is between 0 and 1
			volume = Math.min(1, volume);

			// Convert linear scale to logarithmic
			return Math.exp(_STUPID_LOG * (1 - volume));
		}

		FlxG.sound.reverseSoundCurve = volume -> {
			// If logarithmic volume is 0, return 0
			if (volume <= 0)
				return 0;

			// Ensure x is between minValue and 1
			volume = Math.min(1, volume);

			// Convert logarithmic scale to linear
			return 1 - (Math.log(Math.max(volume, _MIN_VOLUME)) / _STUPID_LOG);
		}
	}
}
