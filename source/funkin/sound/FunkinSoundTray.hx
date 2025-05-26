package funkin.sound;

import motion.Actuate;
import flixel.system.FlxAssets.FlxSoundAsset;
import funkin.util.Paths;
import openfl.display.Bitmap;
import flixel.system.ui.FlxSoundTray;

class FunkinSoundTray extends FlxSoundTray {
	public var volumeMaxSound:Null<String>;

	private var _yTarget:Float = 0;
	private var _alphaTarget:Float = 0;

	private var _graphicScale:Float = 0.3;

	public function new() {
		super();
		removeChildren();

		final bg = new Bitmap(FlxG.assets.getBitmapData(Paths.image('soundtray/volumebox')));
		bg.scaleX = bg.scaleY = _graphicScale;
		bg.smoothing = true;
		addChild(bg);

		y = -height;
		alpha = 0;

		final backingBar = new Bitmap(FlxG.assets.getBitmapData(Paths.image('soundtray/bars_10')));
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.scaleX = backingBar.scaleY = _graphicScale;
		backingBar.smoothing = true;
		backingBar.alpha = 0.4;
		addChild(backingBar);

		_bars = [];

		for (i in 1...11) {
			final bar = new Bitmap(FlxG.assets.getBitmapData(Paths.image('soundtray/bars_$i')));
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = bar.scaleY = _graphicScale;
			bar.smoothing = true;
			addChild(bar);
			_bars.push(bar);
		}

		screenCenter();

		volumeUpSound = Paths.sound('soundtray/Volup');
		volumeDownSound = Paths.sound('soundtray/Voldown');
		volumeMaxSound = Paths.sound('soundtray/VolMAX');
	}

	override function showIncrement() {
		final volume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
		showAnim(volume, silent ? null : Math.round(FlxG.sound.reverseSoundCurve(volume) * 10) == 10 ? volumeMaxSound : volumeUpSound);
	}

	override function showAnim(volume:Float, ?sound:FlxSoundAsset, duration:Float = 1, label:String = 'VOLUME') {
		_timer = 1;

		Actuate.stop(this);
		Actuate.tween(this, 1, {y: 10, alpha: 1});
		Actuate.tween(this, 1, {_timer: 0}).onComplete(() -> {
			Actuate.stop(this);
			Actuate.tween(this, 0.7, {y: -height, alpha: 0});
		});

		for (i => bar in _bars)
			bar.visible = i == Math.round(FlxG.sound.reverseSoundCurve(volume) * 10) - 1;

		FlxG.sound.play(sound, 0.7);
		saveVolumePreferences();
	}

	public function saveVolumePreferences() {
		#if FLX_SAVE
		// Save sound preferences
		if (FlxG.save.isBound) {
			FlxG.save.data.mute = FlxG.sound.muted;
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		}
		#end
	}
}
