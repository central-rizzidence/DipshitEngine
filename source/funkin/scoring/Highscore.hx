package funkin.scoring;

enum abstract Rank(Int) to Int {
	var NONE:Rank = -1;
	var LOSS:Rank = 0;
	var GOOD:Rank = 1;
	var GREAT:Rank = 2;
	var EXCELLENT:Rank = 3;
	var PERFECT:Rank = 4;
	var GOLD:Rank = 5;
}

typedef DifficultyScores = Map<String, Highscore>;
typedef VariationScores = Map<String, DifficultyScores>;
typedef SongOrWeekScores = Map<String, VariationScores>;

class Highscore {
	private static var _songScores:SongOrWeekScores = [];
	private static var _weekScores:SongOrWeekScores = [];

	public var score:Int;
	public var accuracy:Float;
	public var rank:Rank;

	public function new() {
		score = 0;
		accuracy = 0;
		rank = NONE;
	}

	public static inline function setSong(song:String, difficulty:String, variation:String = Constants.DEFAULT_VARIATION, highscore:Highscore) {
		_setTo(_songScores, song, difficulty, variation, highscore);
	}

	public static inline function setWeek(week:String, difficulty:String, variation:String = Constants.DEFAULT_VARIATION, highscore:Highscore) {
		_setTo(_weekScores, week, difficulty, variation, highscore);
	}

	public static inline function getSong(song:String, difficulty:String, variation:String = Constants.DEFAULT_VARIATION):Null<Highscore> {
		return _getFrom(_songScores, song, difficulty, variation);
	}

	public static inline function getWeek(week:String, difficulty:String, variation:String = Constants.DEFAULT_VARIATION):Null<Highscore> {
		return _getFrom(_weekScores, week, difficulty, variation);
	}

	private static function _setTo(map:SongOrWeekScores, songOrWeek:String, difficulty:String, variation:String, highscore:Highscore) {
		if (!map.exists(songOrWeek))
			map[songOrWeek] = new VariationScores();
		if (!map[songOrWeek].exists(variation))
			map[songOrWeek][variation] = new DifficultyScores();

		if (!map[songOrWeek][variation].exists(difficulty) || highscore.isGreaterThan(map[songOrWeek][variation][difficulty]))
			map[songOrWeek][variation][difficulty] = highscore;
	}

	private static function _getFrom(map:SongOrWeekScores, songOrWeek:String, difficulty:String, variation:String):Null<Highscore> {
		if (!map.exists(songOrWeek))
			return null;
		if (!map[songOrWeek].exists(variation))
			return null;

		return map[songOrWeek][variation].get(difficulty);
	}

	public function isGreaterThan(other:Highscore):Bool {
		if ((rank : Int) > (other.rank : Int))
			return true;
		if (accuracy > other.accuracy)
			return true;
		if (score > other.score)
			return true;

		return false;
	}
}
