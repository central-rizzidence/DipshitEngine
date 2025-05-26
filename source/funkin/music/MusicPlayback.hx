package funkin.music;

import flixel.util.FlxSignal;
import funkin.util.Paths;
import funkin.music.MusicArrange.MusicTrack;
import flixel.sound.FlxSound;

typedef MusicTrackContainer = {sound:FlxSound, data:MusicTrack, started:Bool, completed:Bool};

// TODO: loop
class MusicPlayback implements IFlxDestroyable {
	public static var current:Null<MusicPlayback>;

	public var conductor:Conductor;

	public var shouldLoop:Bool = false;
	public var loopTime:Float = 0;

	public var volume(default, set):Float = 1;
	public var rate(default, set):Float = 1;

	public var started(default, null):FlxSignal;
	public var paused(default, null):FlxSignal;
	public var resumed(default, null):FlxSignal;
	public var completed(default, null):FlxSignal;
	public var looped(default, null):FlxSignal;

	public var isStarted(default, null):Bool = false;
	public var isPaused(default, null):Bool = false;
	public var isCompleted(default, null):Bool = false;

	public var numTracks(get, never):Int;

	private var _tracks:Array<MusicTrackContainer>;
	private var _manualTime:Float = 0;

	public function new(id:String, ?metadata:MusicMetadata, ?arrange:MusicArrange, directory:String = 'music') {
		if (metadata == null)
			metadata = MusicMetadata.get(id, directory);

		if (arrange == null)
			arrange = MusicArrange.get(id, directory);
		if (arrange == null) {
			arrange = new MusicArrange();
			arrange.tracks.push(new MusicTrack(id));
		}

		conductor = new Conductor(metadata.timeChanges);
		shouldLoop = arrange.shouldLoop;
		loopTime = arrange.loopTime;

		started = new FlxSignal();
		paused = new FlxSignal();
		resumed = new FlxSignal();
		completed = new FlxSignal();
		looped = new FlxSignal();

		_tracks = [];

		for (track in arrange?.tracks) {
			final path = Paths.file('$id/${Paths.cutLibrary(track.asset)}', 'music', Paths.SOUND_EXTENSION);
			final sound = FlxG.sound.load(path, FlxG.sound.defaultMusicGroup);
			sound.persist = true;

			_tracks.push({
				sound: sound,
				data: track,
				started: false,
				completed: false
			});
		}

		FlxG.signals.preUpdate.add(_update);
	}

	public function destroy() {
		conductor = FlxDestroyUtil?.destroy(conductor);

		started?.destroy();
		paused?.destroy();
		resumed?.destroy();
		completed?.destroy();
		looped?.destroy();
		started = paused = resumed = completed = looped = null;

		for (track in _tracks)
			track.sound.destroy();
		_tracks = [];

		FlxG.signals.preUpdate.remove(_update);
	}

	public function start() {
		if (isStarted)
			return;

		_startReachedTracks(0);
		isStarted = true;
		started.dispatch();
	}

	public function pause() {
		for (track in _tracks)
			track.sound.pause();

		isPaused = true;
		paused.dispatch();
	}

	public function resume() {
		for (track in _tracks)
			track.sound.resume();

		isPaused = false;
		resumed.dispatch();
	}

	@:access(flixel.sound.FlxSound._channel)
	public function getTime():Float {
		if (!isStarted)
			return 0;

		var firstPlayedTrack:Null<MusicTrackContainer> = null;
		for (track in _tracks) {
			if (!track.sound.playing)
				continue;

			if (firstPlayedTrack == null || track.data.playTime < firstPlayedTrack.data.playTime)
				firstPlayedTrack = track;
		}

		if (firstPlayedTrack != null)
			return (firstPlayedTrack.sound._channel?.position ?? firstPlayedTrack.sound.time)
				+ firstPlayedTrack.data.playTime
				- firstPlayedTrack.data.startTime;
		else
			return _manualTime;
	}

	public function setTime(time:Float) {
		_manualTime = time;

		if (!isStarted)
			return;

		for (track in _tracks) {
			if (track.data.playTime > time) {
				track.sound.stop();
				track.started = false;
				track.completed = false;
				continue;
			} else if (!track.started)
				_startTrack(track);

			track.sound.time = time - track.data.playTime + track.data.startTime;
		}
	}

	public function getLength():Float {
		var result = 0.0;

		for (track in _tracks) {
			final trackLength = (track.data.endTime ?? track.sound.length) - track.data.startTime + track.data.playTime;
			if (trackLength < result)
				result = trackLength;
		}

		return result;
	}

	public function resync() {
		final time = getTime();
		for (track in _tracks) {
			if (track.sound.playing)
				track.sound.time = time - track.data.playTime + track.data.startTime;
		}
	}

	private function _update() {
		if (!isStarted)
			return;

		_manualTime += FlxG.elapsed * 1000;

		final time = getTime();
		conductor.updateTime(time);

		if (_startReachedTracks(time))
			resync();
	}

	private function _startReachedTracks(time:Float) {
		var hasStartedTracks = false;
		for (track in _tracks) {
			if (track.started)
				continue;

			if (track.data.playTime <= time) {
				_startTrack(track);
				track.sound.time += time - track.data.playTime;
				hasStartedTracks = true;
			}
		}
		return hasStartedTracks;
	}

	private function _startTrack(track:MusicTrackContainer) {
		track.sound.volume = track.data.volume * volume;
		track.sound.onComplete = () -> _onTrackComplete(track);
		track.sound.play(track.data.startTime, track.data.endTime ?? track.sound.length);
		track.started = true;
		track.completed = false;
	}

	private function _onTrackComplete(track:MusicTrackContainer) {
		track.completed = true;

		if (Lambda.exists(_tracks, track -> !track.started || !track.completed))
			return;

		if (shouldLoop) {
			_loop();
		} else {
			isCompleted = true;
			completed.dispatch();
		}
	}

	private function _loop() {
		isCompleted = false;
		for (track in _tracks) {
			track.sound.stop();
			track.started = false;
			track.completed = false;
		}
		_manualTime = 0;

		_startReachedTracks(0);
		looped.dispatch();
	}

	@:noCompletion
	private function set_volume(value:Float):Float {
		for (track in _tracks)
			track.sound.volume = track.data.volume * value;

		return volume = value;
	}

	@:noCompletion
	private function set_rate(value:Float):Float {
		for (track in _tracks)
			track.sound.pitch = value;

		return rate = value;
	}

	@:noCompletion
	private inline function get_numTracks():Int {
		return _tracks.length;
	}
}
