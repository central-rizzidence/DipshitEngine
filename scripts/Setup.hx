package scripts;

function main() {
	final args = Sys.args();

	var shouldRunNewrepo = true;
	while (args.length > 0) {
		switch args.shift().toLowerCase() {
			case '--global' | '-g':
				shouldRunNewrepo = false;
		}
	}

	if (shouldRunNewrepo)
		newrepo();

	git('hxcpp', 'https://github.com/HaxeFoundation/hxcpp.git', '8268ef2d518b1e7c8e8494114d0bdf6b5bc4147d');
	install('hxcpp-debug-server', '1.2.4');

	install('lime', '8.1.3');
	install('openfl', '9.4.1');

	install('flixel', '6.1.0');
	install('flixel-addons', '3.3.2');
	git('flixel-controls', 'https://github.com/Geokureli/FlxControls.git', '5fa97eab4ac29499a8f2a4abcd46f6f6cd1192b9');
	git('flxanimate', 'https://github.com/Redar13/flxanimate.git', '1f4a256eaa1b2ff90a4bbc88e5eff3e2db50aa4d');

	git('thx.core', 'https://github.com/fponticelli/thx.core.git', '76d87418fadd92eb8e1b61f004cff27d656e53dd');
	git('thx.semver', 'https://github.com/fponticelli/thx.semver.git', 'bdb191fe7cf745c02a980749906dbf22719e200b');

	install('hxjsonast', '1.1.0');
	install('json2object', '3.11.0');

	install('hxvlc', '2.2.1');

	install('compiletime', '2.8.0');

	install('actuate', '1.9.0');

	haxelib(['run', 'lime', 'setup']);
}

function newrepo() {
	haxelib(['newrepo']);
}

function install(name:String, version:String) {
	final args:Array<String> = ['--never', '--skip-dependencies', 'install', name, version];
	haxelib(args);
}

function git(name:String, url:String, ?ref:String) {
	final args:Array<String> = ['--never', '--skip-dependencies', 'git', name, url];
	if (ref != null)
		args.push(ref);
	haxelib(args);
}

inline function haxelib(args:Array<String>) {
	Sys.command('haxelib', args);
}
