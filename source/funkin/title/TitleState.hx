package funkin.title;

import funkin.input.Controls;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import funkin.util.Paths;
#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#end
import funkin.music.MusicPlayback;
import flixel.addons.transition.FlxTransitionableState;

class TitleState extends FlxTransitionableState {
	public static inline var MENU_MUSIC:String = 'klaskiiLoop';
	public static inline var MENU_MUSIC_VOLUME:Float = 0.6;

	public static inline var LOGO_BUMP_WIDTH:Float = 718;

	public static var justStarted:Bool = true;

	public var canSkipIntro:Bool = false;

	public var isIntroSkipped(default, null):Bool = false;
	public var isEnterPressed(default, null):Bool = false;

	#if hxvlc
	private var _introVideo:FlxVideoSprite;
	private var _backgroundVideo:FlxVideoSprite;
	#end

	private var _gfDance:BopperSprite;

	private var _logoBump:FunkinSprite;
	private var _logoTimer:Float = 0;

	private var _titleText:FunkinSprite;
	private var _titleTimer:Float = 0;

	private var _introVideoLoaded:Bool = false;
	private var _backgroundVideoLoaded:Bool = false;

	override function create() {
		FlxTransitionableState.skipNextTransIn = true;
		persistentUpdate = true;
		super.create();

		MusicPlayback.current = FlxDestroyUtil.destroy(MusicPlayback.current);
		MusicPlayback.current = new MusicPlayback(MENU_MUSIC);
		MusicPlayback.current.volume = MENU_MUSIC_VOLUME;
		MusicPlayback.current.looped.add(() -> FlxG.log.notice('Playback should be looped!'));

		FlxG.assets.getSound(Paths.sound('menu/confirm'));

		if (justStarted)
			_createIntroVideo();
		_createBackgroundVideo();

		_createSprites();

		if (justStarted && _introVideoLoaded)
			FlxTimer.wait(0.001, () -> {
				#if hxvlc
				_introVideo.play();
				#end
				canSkipIntro = true;
			});
		else
			skipIntro();
	}

	private function _createIntroVideo() {
		#if hxvlc
		_introVideo = new FlxVideoSprite();
		_introVideo.bitmap.onFormatSetup.add(() -> {
			if (_introVideo.bitmap?.bitmapData == null)
				return;

			final videoWidth = _introVideo.bitmap.bitmapData.width;
			final videoHeight = _introVideo.bitmap.bitmapData.height;

			final scale = Math.min(FlxG.width / videoWidth, FlxG.height / videoHeight);

			_introVideo.scale.x = _introVideo.scale.y = scale;
			_introVideo.updateHitbox();
			_introVideo.screenCenter();
		});
		_introVideo.bitmap.onEndReached.add(skipIntro);
		_introVideo.bitmap.volumeAdjust = MENU_MUSIC_VOLUME;
		add(_introVideo);

		_introVideoLoaded = _introVideo.load(Paths.video('klaskiiTitle'));
		#end
	}

	private function _createBackgroundVideo() {
		#if hxvlc
		_backgroundVideo = new FlxVideoSprite();
		_backgroundVideo.bitmap.onFormatSetup.add(() -> {
			if (_backgroundVideo.bitmap?.bitmapData == null)
				return;

			final videoWidth = _backgroundVideo.bitmap.bitmapData.width;
			final videoHeight = _backgroundVideo.bitmap.bitmapData.height;

			final scale = Math.min(FlxG.width / videoWidth, FlxG.height / videoHeight);

			_backgroundVideo.scale.x = _backgroundVideo.scale.y = scale;
			_backgroundVideo.updateHitbox();
			_backgroundVideo.screenCenter();
		});
		_backgroundVideo.bitmap.onEndReached.add(() -> {
			// FlxTween.cancelTweensOf(_backgroundVideo);
			_backgroundVideo = FlxDestroyUtil.destroy(_backgroundVideo);
		});
		add(_backgroundVideo);

		_backgroundVideoLoaded = _backgroundVideo.load(Paths.video('titleKickBG'));
		#end
	}

	private function _createSprites() {
		_gfDance = new BopperSprite(512, 40);
		_gfDance.frames = FlxAtlasFrames.fromSparrow(Paths.image('title/gf'), Paths.file('title/gf', 'images', 'xml'));
		_gfDance.addAnimation('danceLeft', 'gfDance', [30].concat([for (i in 0...15) i]));
		_gfDance.addAnimation('danceRight', 'gfDance', [for (i in 15...30) i]);
		_gfDance.danceSequence = ['danceRight', 'danceLeft'];
		_gfDance.kill();
		add(_gfDance);

		_logoBump = new FunkinSprite(-13, 21);
		_logoBump.loadGraphic(Paths.image('title/logo'));
		_logoBump.kill();
		add(_logoBump);

		_titleText = new FunkinSprite(100, 576);
		_titleText.frames = FlxAtlasFrames.fromSparrow(Paths.image('title/titleEnter'), Paths.file('title/titleEnter', 'images', 'xml'));
		_titleText.addAnimation('idle', 'ENTER IDLE', true);
		_titleText.addAnimation('pressed', 'ENTER PRESSED', true);
		_titleText.playAnimation('idle');
		_titleText.kill();
		add(_titleText);

		MusicPlayback.current.conductor.beatHit.add(_beatHit);
	}

	override function update(elapsed:Float) {
		if (Controls.instance.justPressed.ACCEPT) {
			if (canSkipIntro && !isIntroSkipped)
				skipIntro();
			else if (!isEnterPressed) {
				_titleText.color = 0xffffffff;
				_titleText.alpha = 1;
				_titleText.playAnimation('pressed');

				FlxG.camera.flash(true);
				FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);

				new FlxTimer().start(1, _ -> {
					// _startExitState(() -> new funkin.mainmenu.MainMenuState());
					FlxG.switchState(() -> new funkin.mainmenu.MainMenuState());
					justStarted = false;
				});

				isEnterPressed = true;
			}
		}

		if (!isEnterPressed) {
			_titleTimer += elapsed;
			if (_titleTimer > 2)
				_titleTimer -= 2;

			final factor = FlxEase.quadInOut(_titleTimer >= 1 ? -_titleTimer + 2 : _titleTimer);
			_titleText.color = FlxColor.interpolate(0xff33ffff, 0xff3333cc, factor);
			_titleText.alpha = FlxMath.lerp(1, 0.64, factor);

			_logoTimer += elapsed;

			final frame = Math.floor(14 * _logoTimer * 1.6); // не спрашивайте что за 1.6, я не помню, но это что то с фпс
			_logoBump.setGraphicSize( switch frame {
				case 0: 683;
				case 1 | 2: 718;
				case 3 | 4: 696;
				case _: 691;
			});
		}

		super.update(elapsed);
	}

	public function skipIntro() {
		if (isIntroSkipped)
			return;

		#if hxvlc
		_introVideo = FlxDestroyUtil.destroy(_introVideo);
		#end

		MusicPlayback.current.start();
		#if hxvlc
		if (_backgroundVideoLoaded)
			_backgroundVideo.play();
		#end

		FlxG.camera.flash();

		_gfDance.revive();
		_logoBump.revive();
		_titleText.revive();

		_beatHit(0);

		isIntroSkipped = true;
	}

	override function destroy() {
		MusicPlayback.current.conductor.beatHit.remove(_beatHit);
		super.destroy();
	}

	private function _beatHit(beat:Int) {
		if (_gfDance.playDance(beat))
			_logoTimer = 0;
	}
	/*private function _startExitState(nextState:NextState) {
		if (_backgroundVideo != null)
			FlxTween.tween(_backgroundVideo, {alpha: 0}, 1);

		FlxTween.tween(_logoBump, {y: _logoBump.y + FlxG.height}, 1, {ease: FlxEase.expoIn});
		FlxTween.tween(_gfDance, {x: _gfDance.x + FlxG.width}, 1, {ease: FlxEase.backIn});

		FlxTransitionableState.skipNextTransOut = true;
		FlxTimer.wait(2, () -> FlxG.switchState(() -> new funkin.mainmenu.MainMenuState()));
	}*/
}
