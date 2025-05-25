package funkin.external;

import haxe.io.Path;

@:keep class ALSoftConfig {
	private static function __init__() {
		#if sys
		var filePath = Path.join([Sys.getCwd(), 'alsoftrc.ini']);
		Sys.putEnv('ALSOFT_CONF', filePath);
		#end
	}
}
