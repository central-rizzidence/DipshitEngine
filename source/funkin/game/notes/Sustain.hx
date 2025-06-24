package funkin.game.notes;

import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flixel.FlxSprite;

class Sustain extends FlxSprite {
	public var parentNote(default, null):Note;

	public var sustainHeight(default, null):Float = 0;
	public var clipHeight(default, null):Float = 0;

	@:allow(funkin.game.notes.Strumline)
	public var handledRelease(default, null):Bool = false;

	private var _clipLength:Null<Float>;

	private var _drawPoint:FlxPoint = FlxPoint.get();
	private var _drawMatrix:FlxMatrix = new FlxMatrix();

	public function new(note:Note) {
		super();
		parentNote = note;
		updateHeight();
		updateClipping(Conductor.current?.currentTime ?? 0);
	}

	public static inline function getSustainHeight(sustainLength:Float, noteSpeed:Float):Float {
		return sustainLength * Strumline.PIXELS_PER_MS * noteSpeed;
	}

	public function updateHeight() {
		final parentStrum = parentNote.parentStrumline != null ? parentNote.parentStrumline.members[parentNote.noteLane % Strumline.KEY_COUNT] : null;
		sustainHeight = getSustainHeight(parentNote.sustainLength, parentStrum?.noteSpeed ?? 1);
		if (_clipLength == null)
			_clipLength = parentNote.sustainLength;
		clipHeight = Math.min(getSustainHeight(_clipLength, parentStrum?.noteSpeed ?? 1), sustainHeight);
	}

	public function updateClipping(songTime:Float) {
		final parentStrum = parentNote.parentStrumline != null ? parentNote.parentStrumline.members[parentNote.noteLane % Strumline.KEY_COUNT] : null;
		_clipLength = parentNote.sustainLength - (songTime - parentNote.strumTime);
		clipHeight = Math.min(getSustainHeight(_clipLength, parentStrum?.noteSpeed ?? 1), sustainHeight);
	}

	@:noCompletion
	override function drawSimple(camera:FlxCamera) {
		// TODO
	}

	#if INVERTED_SUSTAIN_DRAW
	@:noCompletion
	override function drawComplex(camera:FlxCamera) {
		if (clipHeight <= 0)
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
		var drawnHeight = 0.0;

		final shouldUseAntialiasing = antialiasing && (FlxSprite.canUseAntialiasing || forceAntialiasing);

		while (drawnHeight < clipHeight) {
			final pieceHeight = pieceFrame.frame.height;
			pieceFrame.frame.height = Math.min(clipHeight - drawnHeight, pieceHeight);
			pieceFrame.frame.y = pieceHeight - pieceFrame.frame.height;

			_drawMatrix.copyFrom(_matrix);
			_drawMatrix.tx += (sustainHeight - pieceFrame.frame.height * scale.y - drawnHeight) * -_sinAngle;
			_drawMatrix.ty += (sustainHeight - pieceFrame.frame.height * scale.y - drawnHeight) * _cosAngle;

			camera.drawPixels(pieceFrame, framePixels, _drawMatrix, colorTransform, blend, shouldUseAntialiasing, shader);

			drawnHeight += pieceFrame.frame.height * scale.y;
			pieceFrame.frame.height = pieceHeight;
		}

		final endFrame = getEndFrame();
		_drawMatrix.copyFrom(_matrix);
		_drawMatrix.tx += sustainHeight * -_sinAngle;
		_drawMatrix.ty += sustainHeight * _cosAngle;
		camera.drawPixels(endFrame, framePixels, _drawMatrix, colorTransform, blend, shouldUseAntialiasing, shader);
	}
	#else
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
	#end

	public inline function getPieceFrame():FlxFrame {
		return frames.frames[(parentNote.noteLane % Strumline.KEY_COUNT) * 2];
	}

	public inline function getEndFrame():FlxFrame {
		return frames.frames[(parentNote.noteLane % Strumline.KEY_COUNT) * 2 + 1];
	}
}
