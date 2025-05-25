package funkin.storymenu.preview;

import funkin.scoring.Highscore;
import flixel.text.FlxText;
import flixel.group.FlxContainer;

class LevelPreview extends FlxContainer {
	private var _header:FunkinSprite;
	private var _scoreText:FlxText;
	private var _titleText:FlxText;

	private var _background:FunkinSprite;

	private var _props:Array<LevelPreviewProp> = [];
	private var _bopperProps:Array<LevelPreviewBopperProp> = [];

	public function new() {
		super();

		_header = new FunkinSprite();
		_header.makeGraphic(1, 1, 0xff000000);
		_header.setGraphicSize(FlxG.width, 56);
		_header.updateHitbox();
		add(_header);

		_scoreText = new FlxText(10, 10, 'LEVEL SCORE: 42069420');
		_scoreText.setFormat(Constants.DEFAULT_FONT, 32);
		add(_scoreText);

		_titleText = new FlxText(10, 10, FlxG.width - 20, 'LEVEL 1');
		_titleText.setFormat(Constants.DEFAULT_FONT, 32, 0xffffffff, RIGHT);
		_titleText.alpha = 0.7;
		add(_titleText);

		_background = new FunkinSprite(0, 56);
		_background.makeGraphic(1, 1);
		_background.setGraphicSize(FlxG.width, 400);
		_background.updateHitbox();
		add(_background);
	}

	public function setLevel(level:Level, id:String, difficulty:String, variation:String = Constants.DEFAULT_VARIATION) {
		_scoreText.text = 'LEVEL SCORE: ${Highscore.getWeek(id, difficulty, variation)?.score ?? 0}';
		_titleText.text = level.title;

		for (prop in _props)
			remove(prop, true);
		for (bopperProp in _bopperProps)
			remove(bopperProp, true);

		final propsCount = level.preview.props.filter(prop -> prop.bopper == null).length;
		final bopperPropsCount = level.preview.props.filter(prop -> prop.bopper != null).length;

		while (propsCount > _props.length)
			_props.push(new LevelPreviewProp());
		while (bopperPropsCount > _bopperProps.length)
			_bopperProps.push(new LevelPreviewBopperProp());

		if (level.preview == null) {
			_background.color = 0xffffffff;
		} else {
			_background.color = level.preview.background;

			var addedProps = 0;
			var addedBopperProps = 0;
			for (prop in level.preview.props) {
				if (prop.bopper != null)
					add(_bopperProps[addedBopperProps++].setData(prop));
				else
					add(_props[addedProps++].setData(prop));
			}
		}
	}

	public function playPropsDance(beat:Int) {
		for (bopperProp in _bopperProps)
			bopperProp.playDance(beat);
	}

	public function playPropsConfirm() {
		for (prop in _props) {
			if (prop.hasAnimation('confirm'))
				prop.playAnimation('confirm');
		}

		for (bopperProp in _bopperProps) {
			if (bopperProp.hasAnimation('confirm'))
				bopperProp.playAnimation('confirm');
		}
	}
}
