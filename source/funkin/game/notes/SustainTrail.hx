package funkin.game.notes;

import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flixel.FlxSprite;

class SustainTrail extends FlxSprite {
	public static inline var PIXELS_PER_MS:Float = 0.45;

	public static inline function getSustainHeight(sustainLength:Float, noteSpeed:Float):Float {
		return sustainLength * PIXELS_PER_MS * noteSpeed;
	}

	public var parentNote:Note;
	public var parentStrumline:Strumline;

	public var sustainHeight(default, null):Float = 0;
	public var clipHeight(default, null):Float = 0;

	private var _drawPoint:FlxPoint = FlxPoint.get();
	private var _drawMatrix:FlxMatrix = new FlxMatrix();

	public function new() {
		super();

		loadGraphic(Paths.image('game/noteSkins/default/NOTE_hold_assets'), true, 52, 87);
		scale.scale(0.7);
		updateHitbox();

		parentNote = new Note({
			time: 0,
			lane: 0,
			length: 500 / PIXELS_PER_MS,
			type: ''
		});
	}

	public function updateClipping(songTime:Float, noteSpeed:Float) {
		sustainHeight = getSustainHeight(parentNote.sustainLength, noteSpeed);
		clipHeight = Math.min(getSustainHeight(parentNote.sustainLength - (songTime - parentNote.strumTime), noteSpeed), sustainHeight);
	}

	@:noCompletion
	override function drawSimple(camera:FlxCamera) {
		if (clipHeight == 0)
			return;

		getScreenPosition(_point, camera).subtract(offset);
		if (isPixelPerfectRender(camera))
			_point.floor();

		final pieceFrame = getPieceFrame();
		var drawnHeight = sustainHeight - clipHeight;

		while (drawnHeight < clipHeight) {
			_drawPoint.copyFrom(_point);
			_drawPoint.y += drawnHeight;

			final pieceHeight = pieceFrame.frame.height;
			pieceFrame.frame.height = Math.min(clipHeight - drawnHeight, pieceHeight);

			_drawPoint.copyTo(_flashPoint);
			camera.copyPixels(pieceFrame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);

			drawnHeight += pieceFrame.frame.height;
			pieceFrame.frame.height = pieceHeight;
		}

		final endFrame = getEndFrame();
		_drawPoint.copyFrom(_point);
		_drawPoint.y += drawnHeight;
		camera.copyPixels(endFrame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera) {
		if (clipHeight == 0)
			return;

		frame.prepareMatrix(_matrix, 0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtract(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			_matrix.tx = Math.ffloor(_matrix.tx);
			_matrix.ty = Math.ffloor(_matrix.ty);
		}

		final pieceFrame = getPieceFrame();
		var drawnHeight = sustainHeight - clipHeight;

		while (drawnHeight < clipHeight) {
			_drawMatrix.copyFrom(_matrix);
			_drawMatrix.translate(drawnHeight * -_sinAngle, drawnHeight * _cosAngle);

			final pieceHeight = pieceFrame.frame.height;
			pieceFrame.frame.height = Math.min(clipHeight - drawnHeight, pieceHeight);

			camera.drawPixels(pieceFrame, framePixels, _drawMatrix, colorTransform, blend, antialiasing, shader);

			drawnHeight += pieceFrame.frame.height * scale.y;
			pieceFrame.frame.height = pieceHeight;
		}

		final endFrame = getEndFrame();
		_drawMatrix.copyFrom(_matrix);
		_drawMatrix.translate(drawnHeight * -_sinAngle, drawnHeight * _cosAngle);
		camera.drawPixels(endFrame, framePixels, _drawMatrix, colorTransform, blend, antialiasing, shader);
	}

	public inline function getPieceFrame():FlxFrame {
		return frames.frames[parentNote.noteLane * 2];
	}

	public inline function getEndFrame():FlxFrame {
		return frames.frames[parentNote.noteLane * 2 + 1];
	}
}
