package funkin;

import thx.semver.Version;

final class Constants {
	public static var ENGINE_VERSION(get, never):Version;

	public static inline var DEFAULT_FONT:String = 'VCR OSD Mono RUS+VHS icons';

	public static inline var TRANSITION_IN_DURATION:Float = 1;
	public static inline var TRANSITION_OUT_DURATION:Float = 0.7;

	public static inline var DEFAULT_DIFFICULTY:String = 'normal';
	public static inline var DEFAULT_VARIATION:String = 'default';

	public static inline var MAX_BINDINGS:Int = 2;

	@:noCompletion
	private static inline function get_ENGINE_VERSION():Version {
		return try Version.stringToVersion(FlxG.stage.application.meta['version']) catch (_) Version.arrayToVersion([0, 0, 1]);
	}
}
