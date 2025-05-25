package funkin;

import thx.semver.Version;

class Constants {
	public static final ENGINE_VERSION:Version = CompileTime.readFile('gitVersion.txt') ?? '0.0.0';

	public static inline var DEFAULT_FONT:String = 'VCR OSD Mono RUS+VHS icons';

	public static inline var TRANSITION_IN_DURATION:Float = 1;
	public static inline var TRANSITION_OUT_DURATION:Float = 0.7;

	public static inline var DEFAULT_VARIATION:String = 'default';

	public static inline var MAX_BINDINGS:Int = 2;
}
