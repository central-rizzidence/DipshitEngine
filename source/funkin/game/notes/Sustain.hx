package funkin.game.notes;

import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flixel.FlxSprite;

using flixel.util.FlxColorTransformUtil;

class Sustain extends FlxSprite {
	public var parentNote(default, null):Note;

	public var sustainHeight(default, null):Float = 0;
	public var clipHeight(default, null):Float = 0;

	@:allow(funkin.game.notes.Strumline)
	public var handledRelease(default, null):Bool = false;

	private var _clipLength:Null<Float>;

	private var _drawPoint:FlxPoint = new FlxPoint();
	private var _drawMatrix:FlxMatrix = new FlxMatrix();

	public function new(note:Note, initialSpeed:Float = 1) {
		super();
		parentNote = note;
		updateHeight(initialSpeed);
		updateClipping(Conductor.current?.currentTime ?? 0);
	}

	public static inline function getSustainHeight(sustainLength:Float, scrollSpeed:Float):Float {
		return sustainLength * Strumline.PIXELS_PER_MS * scrollSpeed;
	}

	public function updateHeight(scrollSpeed:Float = 1) {
		final old = sustainHeight;
		sustainHeight = getSustainHeight(parentNote.sustainLength, scrollSpeed);

		final ratio = sustainHeight / old;
		_clipLength *= ratio;
		clipHeight *= ratio;
	}

	public function updateClipping(songTime:Float, scrollSpeed:Float = 1) {
		_clipLength = parentNote.sustainLength - (songTime - parentNote.strumTime);
		clipHeight = Math.min(getSustainHeight(_clipLength, scrollSpeed), sustainHeight);
	}

	@:noCompletion
	override function drawSimple(camera:FlxCamera) {
		FlxG.log.notice('Simple render not supported for sustains');
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera) {
		if (!dirty || clipHeight <= 0)
			return;

		frame.prepareMatrix(_matrix, 0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtract(offset).add(origin);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			_matrix.tx = Math.ffloor(_matrix.tx);
			_matrix.ty = Math.ffloor(_matrix.ty);
		}

		final shouldUseAntialiasing = antialiasing && (FlxSprite.canUseAntialiasing || forceAntialiasing);

		final batch = camera.startQuadBatch(frame.parent, colorTransform?.hasRGBMultipliers(), colorTransform?.hasRGBOffsets(), blend, shouldUseAntialiasing,
			shader);

		final pieceFrame = getPieceFrame();
		final pieceHeight = pieceFrame.frame.height;
		var drawnHeight = 0.0;

		while (drawnHeight < clipHeight) {
			pieceFrame.frame.height = Math.min((clipHeight - drawnHeight) / scale.y, pieceHeight);

			final pieceOffset = pieceHeight - pieceFrame.frame.height;
			pieceFrame.frame.y += pieceOffset;

			_drawMatrix.copyFrom(_matrix);
			_drawMatrix.tx += (sustainHeight - pieceFrame.frame.height * scale.y - drawnHeight) * -_sinAngle;
			_drawMatrix.ty += (sustainHeight - pieceFrame.frame.height * scale.y - drawnHeight) * _cosAngle;

			batch.addQuad(pieceFrame, _drawMatrix, colorTransform);

			drawnHeight += pieceFrame.frame.height * scale.y;
			pieceFrame.frame.y -= pieceOffset;
			pieceFrame.frame.height = pieceHeight;
		}

		final endFrame = getEndFrame();
		_drawMatrix.copyFrom(_matrix);
		_drawMatrix.tx += sustainHeight * -_sinAngle;
		_drawMatrix.ty += sustainHeight * _cosAngle;
		batch.addQuad(endFrame, _drawMatrix, colorTransform);
	}

	public inline function getPieceFrame():FlxFrame {
		return frames.frames[(parentNote.noteLane % Strumline.KEY_COUNT) * 2];
	}

	public inline function getEndFrame():FlxFrame {
		return frames.frames[(parentNote.noteLane % Strumline.KEY_COUNT) * 2 + 1];
	}
}
