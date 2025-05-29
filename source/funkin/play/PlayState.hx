package funkin.play;

import funkin.play.Song;
import flixel.math.FlxAngle;
import funkin.input.Controls;
import funkin.play.notes.Strumline;
import flixel.math.FlxPoint;
import funkin.play.Song.SongStrumlineData;
import flixel.addons.transition.FlxTransitionableState;

typedef PlayStateParams = {
	@:optional var song:Song;
	@:optional var songData:SongData;
	@:optional var songId:String;
	@:optional var playlist:Array<Song>;

	@:optional var difficulty:String;
	@:optional var variation:String;
}

class PlayState extends FlxTransitionableState {
	public var currentChart(default, null):SongDifficulty;

	public var playlist:Array<Song>;
	public var currentPlaylistPosition:Int = 0;

	var strumline:Strumline;

	public function new(params:PlayStateParams) {
		super();

		if (params.difficulty == null)
			params.difficulty = Constants.DEFAULT_DIFFICULTY;
		if (params.variation == null)
			params.variation = Constants.DEFAULT_VARIATION;

		if (params.song == null) {
			if (params.songData != null)
				params.song = new Song(params.songData);
			else if (params.songId != null)
				params.song = Song.load(params.songId);
		}

		if (params.song == null)
			FlxG.log.error('Null song received');
		else if (!params.song.difficulties.exists(params.variation))
			FlxG.log.error('Recieved song has no variation ${params.variation}');
		else if (!params.song.difficulties[params.variation].exists(params.difficulty))
			FlxG.log.error('Recieved song has no difficulty ${params.difficulty} in variation ${params.variation}');
		else
			currentChart = params.song.difficulties[params.variation][params.difficulty];

		playlist = params.playlist ?? [params.song] ?? [];
	}

	override function create() {
		super.create();

		var data:SongStrumlineData = {
			position: FlxPoint.get(0.5, (FlxG.height - 112) * 0.5),
			scale: 1,
			alpha: 1,
			characters: [],
			cpuControlled: true,
			attachedTrack: 0,
			muteOnMiss: false
		}

		strumline = new Strumline(data);
		add(strumline);
	}

	override function update(elapsed:Float) {
		if (Controls.instance.pressed.UI_LEFT)
			strumline.strums.angle -= FlxAngle.asDegrees(Math.PI * 2 * elapsed);
		if (Controls.instance.pressed.UI_RIGHT)
			strumline.strums.angle += FlxAngle.asDegrees(Math.PI * 2 * elapsed);

		if (Controls.instance.pressed.UI_UP)
			strumline.strums.scale.x = strumline.strums.scale.y += 0.1 * elapsed;
		if (Controls.instance.pressed.UI_DOWN)
			strumline.strums.scale.x = strumline.strums.scale.y -= 0.1 * elapsed;

		super.update(elapsed);
	}
}
