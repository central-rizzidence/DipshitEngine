package funkin.display;

import flixel.util.FlxSignal;
import openfl.Assets;
import flixel.graphics.FlxGraphic;
import hxvlc.flixel.FlxInternalVideo;
import flixel.FlxSprite;

class VideoSprite extends FlxSprite {
	public var started(default, null):FlxSignal;
	public var paused(default, null):FlxSignal;
	public var resumed(default, null):FlxSignal;
	public var completed(default, null):FlxSignal;

	#if hxvlc
	private var _video:FlxInternalVideo;
	#end

	public function new() {
		super();

		makeGraphic(1, 1, 0x00000000);

		started = new FlxSignal();
		paused = new FlxSignal();
		resumed = new FlxSignal();
		completed = new FlxSignal();

		_video = new FlxInternalVideo(antialiasing);
		_video.forceRendering = true;
		_video.onFormatSetup.add(() -> {
			if (_video.bitmapData != null)
				loadGraphic(FlxGraphic.fromBitmapData(_video.bitmapData, false, false));
			_video.visible = false;
			FlxG.stage.addChild(_video);
		});
		_video.onEndReached.add(() -> completed?.dispatch());
	}

	#if FLX_CUSTOM_ASSETS_DIRECTORY
	@:access(flixel.system.frontEnds.AssetFrontEnd.getPath)
	#end
	public function loadVideo(id:String, onLoaded:(sprite:VideoSprite) -> Void):VideoSprite {
		#if sys
		final path = #if FLX_CUSTOM_ASSETS_DIRECTORY FlxG.assets.getPath(id) #else Assets.getPath(id) ?? id #end;
		if (sys.FileSystem.exists(path) && !sys.FileSystem.isDirectory(path))
			_video.load(path);
		else
		#end
		_video.load(FlxG.assets.getBytes(id));

		function onFormatSetup() {
			onLoaded(this);
			_video.onFormatSetup.remove(onFormatSetup);
		}
		_video.onFormatSetup.add(onFormatSetup);

		return this;
	}

	public function start() {
		if (_video == null)
			return;

		_video.play();
		started.dispatch();
	}

	public function pause() {
		if (_video == null)
			return;

		_video.pause();
		paused.dispatch();
	}

	public function resume() {
		if (_video == null)
			return;

		_video.resume();
		resumed.dispatch();
	}

	override function destroy() {
		started?.destroy();
		paused?.destroy();
		resumed?.destroy();
		completed?.destroy();
		started = paused = resumed = completed = null;

		if (_video != null) {
			FlxG.stage.removeChild(_video);
			_video.stop();
		}

		super.destroy();
	}

	public function fitScreen() {
		if (_video?.bitmapData == null)
			return;

		final videoWidth = _video.bitmapData.width;
		final videoHeight = _video.bitmapData.height;

		final scale = Math.min(FlxG.width / videoWidth, FlxG.height / videoHeight);

		this.scale.x = this.scale.y = scale;
		updateHitbox();
		screenCenter();
	}
}
