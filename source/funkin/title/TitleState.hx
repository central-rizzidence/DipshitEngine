package funkin.title;

import funkin.input.Controls;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import funkin.util.Paths;
#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#end
import funkin.music.Conductor;
import funkin.music.MusicMetadata;
import flixel.addons.transition.FlxTransitionableState;

using funkin.sound.FlxSoundTools;

class TitleState extends FlxTransitionableState {
	public static inline var MENU_MUSIC:String = 'klaskiiLoop';
	public static inline var MENU_MUSIC_VOLUME:Float = 0.6;

	public static var menuMusicConductor:Conductor;

	public static var justStarted:Bool = true;

	public var canSkipIntro:Bool = false;

	public var isIntroSkipped(default, null):Bool = false;
	public var isEnterPressed(default, null):Bool = false;

	public var gfDance(default, null):BopperSprite;
	public var logoBump(default, null):FunkinSprite;
	public var titleText(default, null):FunkinSprite;

	private var _logoTimer:Float = 0;
	private var _titleTimer:Float = 0;

	#if hxvlc
	private var _introVideo:FlxVideoSprite;
	private var _backgroundVideo:FlxVideoSprite;
	#end

	public var introVideoLoaded(default, null):Bool = false;
	public var backgroundVideoLoaded(default, null):Bool = false;

	override function create() {
		FlxTransitionableState.skipNextTransIn = true;
		persistentUpdate = true;
		super.create();

		FlxG.assets.getSound(Paths.music(MENU_MUSIC));
		FlxG.assets.getSound(Paths.sound('menu/confirm'));

		final menuMusicMetadata = MusicMetadata.get(MENU_MUSIC);
		menuMusicConductor = new Conductor(menuMusicMetadata.timeChanges);
		FlxG.signals.preUpdate.add(() -> {
			if (FlxG.sound.music?.playing)
				menuMusicConductor.updateTime(FlxG.sound.music.getAccurateTime());
		});

		if (justStarted)
			_createIntroVideo();
		_createBackgroundVideo();

		_createSprites();

		if (justStarted && introVideoLoaded)
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

		introVideoLoaded = _introVideo.load(Paths.video('klaskiiTitle'));
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

		backgroundVideoLoaded = _backgroundVideo.load(Paths.video('titleKickBG'));
		#end
	}

	private function _createSprites() {
		gfDance = new BopperSprite(512, 40);
		gfDance.frames = Paths.getFrames('title/gf');
		gfDance.addAnimation('danceLeft', 'gfDance', [30].concat([for (i in 0...15) i]));
		gfDance.addAnimation('danceRight', 'gfDance', [for (i in 15...30) i]);
		gfDance.danceSequence = ['danceRight', 'danceLeft'];
		gfDance.kill();
		add(gfDance);

		logoBump = new FunkinSprite(-13, 21);
		logoBump.loadGraphic(Paths.image('title/logo'));
		logoBump.kill();
		add(logoBump);

		titleText = new FunkinSprite(100, 576);
		titleText.frames = Paths.getFrames('title/titleEnter');
		titleText.addAnimation('idle', 'ENTER IDLE', true);
		titleText.addAnimation('pressed', 'ENTER PRESSED', true);
		titleText.playAnimation('idle');
		titleText.kill();
		add(titleText);

		menuMusicConductor.beatHit.add(_beatHit);
	}

	override function update(elapsed:Float) {
		if (Controls.instance.justPressed.ACCEPT) {
			if (canSkipIntro && !isIntroSkipped)
				skipIntro();
			else if (!isEnterPressed) {
				titleText.color = 0xffffffff;
				titleText.alpha = 1;
				titleText.playAnimation('pressed');

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
			titleText.color = FlxColor.interpolate(0xff33ffff, 0xff3333cc, factor);
			titleText.alpha = FlxMath.lerp(1, 0.64, factor);

			_logoTimer += elapsed;

			final frame = Math.floor(14 * _logoTimer * 1.6); // не спрашивайте что за 1.6, я не помню, но это что то с фпс
			logoBump.setGraphicSize( switch frame {
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

		FlxG.sound.playMusic(Paths.music(MENU_MUSIC), MENU_MUSIC_VOLUME);

		#if hxvlc
		_introVideo = FlxDestroyUtil.destroy(_introVideo);

		if (backgroundVideoLoaded)
			_backgroundVideo.play();
		#end

		FlxG.camera.flash(true);

		gfDance.revive();
		logoBump.revive();
		titleText.revive();

		_beatHit(0);

		isIntroSkipped = true;
	}

	override function destroy() {
		menuMusicConductor.beatHit.remove(_beatHit);
		super.destroy();
	}

	private function _beatHit(beat:Int) {
		if (gfDance.playDance(beat))
			_logoTimer = 0;
	}

	public static function playMenuMusic() {
		final menuMusicMetadata = MusicMetadata.get(MENU_MUSIC);
		menuMusicConductor.setTimeChanges(menuMusicMetadata.timeChanges);

		FlxG.sound.playMusic(Paths.music(MENU_MUSIC), MENU_MUSIC_VOLUME);
	}
}
