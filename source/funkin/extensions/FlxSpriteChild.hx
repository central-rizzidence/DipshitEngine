package funkin.extensions;

import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

using flixel.util.FlxColorTransformUtil;

/** TODO: origin и scale плохо работают, наверное offset тоже, хуй знает **/
class FlxSpriteChild extends FlxSprite {
	@:allow(funkin.extensions.FlxSpriteParent)
	private var _parent:Null<FlxSpriteParent>;

	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint {
		if (result == null)
			result = FlxPoint.get();

		if (camera == null)
			camera = getDefaultCamera();

		if (_parent != null) {
			result.set(x * _parent.scale.x + _parent.x, y * _parent.scale.y + _parent.y);

			if (_parent.angle != 0) {
				// result.subtract(_parent.x, _parent.y);
				final angleBetween = FlxAngle.angleBetweenPoint(_parent, result);
				final distance = FlxMath.distanceToPoint(_parent, result);
				final rotation = FlxAngle.asRadians(_parent.angle);
				result.set(distance * Math.cos(angleBetween + rotation) + _parent.x, distance * Math.sin(angleBetween + rotation) + _parent.y);
			}

			if (_parent.pixelPerfectPosition)
				result.floor();
		} else
			result.set(x, y);

		if (pixelPerfectPosition)
			result.floor();

		return result.subtract(camera.scroll.x * scrollFactor.x * _parent?.scrollFactor?.x ?? 1,
			camera.scroll.y * scrollFactor.y * _parent?.scrollFactor?.y ?? 1);
	}

	override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (newRect == null)
			newRect = FlxRect.get();

		if (camera == null)
			camera = getDefaultCamera();

		getScreenPosition(_point, camera);
		newRect.setPosition(_point.x, _point.y);

		if (pixelPerfectPosition)
			newRect.floor();

		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);

		if (_parent != null) {
			_scaledOrigin.scale(_parent.scale.x, _parent.scale.y);

			newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
			newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
		} else {
			newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
			newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
		}

		if (isPixelPerfectRender(camera))
			newRect.floor();

		newRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));
		if (_parent != null) {
			newRect.width *= _parent.scale.x;
			newRect.height *= _parent.scale.y;
		}
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	}

	override function isPixelPerfectRender(?camera:FlxCamera):Bool {
		return super.isPixelPerfectRender(camera) || _parent?.isPixelPerfectRender(camera);
	}

	override function isSimpleRenderBlit(?camera:FlxCamera):Bool {
		var result:Bool = (angle == 0 || bakedRotationAngle > 0) && scale.x == 1 && scale.y == 1 && blend == null;
		result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);

		if (_parent != null)
			result = result
				&& _parent.angle != 0
				&& _parent.scale.x == 1
				&& _parent.scale.y == 1
				&& (blend == null ? _parent.blend == null : true);

		return result;
	}

	@:noCompletion
	override function drawSimple(camera:FlxCamera):Void {
		getScreenPosition(_point, camera).subtract(offset);

		if (_parent != null)
			_point.subtract(_parent.offset);

		if (isPixelPerfectRender(camera))
			_point.floor();

		if (_parent != null)
			colorTransform.setMultipliers(color.redFloat * _parent.color.redFloat, color.greenFloat * _parent.color.greenFloat,
				color.blueFloat * _parent.color.blueFloat, alpha * _parent.alpha);

		_point.copyTo(_flashPoint);
		camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend ?? _parent?.blend, antialiasing && _parent?.antialiasing);

		if (_parent != null)
			colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
	}

	override function drawFrameComplex(frame:FlxFrame, camera:FlxCamera) {
		final matrix = this._matrix; // TODO: Just use local?
		frame.prepareMatrix(matrix, 0, checkFlipX(), checkFlipY());

		matrix.translate(-origin.x, -origin.y);
		if (bakedRotationAngle <= 0) {
			updateTrig();

			if (angle != 0)
				matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		matrix.scale(scale.x, scale.y);

		if (_parent != null) {
			if (_parent.angle != 0) {
				matrix.translate(origin.x, origin.y);
				matrix.translate(-_parent.origin.x, -_parent.origin.y);
				final radians = FlxAngle.asRadians(_parent.angle);
				matrix.rotateWithTrig(Math.cos(radians), Math.sin(radians));
				matrix.translate(-origin.x, -origin.y);
			}
		}

		getScreenPosition(_point, camera).subtract(offset);
		if (_parent != null)
			_point.subtract(_parent.offset);
		_point.add(origin);
		matrix.translate(_point.x, _point.y);
		if (_parent != null)
			_matrix.translate(_parent.origin.x, _parent.origin.y);

		if (isPixelPerfectRender(camera)) {
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}

		camera.drawPixels(frame, framePixels, matrix, colorTransform, blend ?? _parent.blend, antialiasing && _parent.antialiasing, shader ?? _parent.shader);
	}
}
