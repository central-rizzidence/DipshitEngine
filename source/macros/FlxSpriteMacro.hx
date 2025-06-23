package macros;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr.Field;

final class FlxSpriteMacro {
	public static macro function add():Array<Field> {
		Compiler.addGlobalMetadata('flixel.FlxSprite', '@:build(macros.FlxSpriteMacro.build())', false);
		return Context.getBuildFields();
	}

	@:noCompletion
	public static macro function build():Array<Field> {
		final fields = Context.getBuildFields();

		fields.push({
			name: 'canUseAntialiasing',
			doc: null, // TODO: Documentation
			access: [APublic, AStatic],
			kind: FVar(macro :Bool, macro $v{true}),
			pos: Context.currentPos()
		});

		fields.push({
			name: 'forceAntialiasing',
			doc: null, // TODO: Documentation
			access: [APublic],
			kind: FVar(macro :Bool, macro $v{false}),
			pos: Context.currentPos()
		});

		switch Lambda.find(fields, f -> f.name == 'drawSimple').kind {
			case FFun(f):
				f.expr = macro {
					getScreenPosition(_point, camera).subtract(offset);
					if (isPixelPerfectRender(camera))
						_point.floor();

					_point.copyTo(_flashPoint);
					camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing && (canUseAntialiasing
						|| forceAntialiasing));
				}
			case _:
		}

		switch Lambda.find(fields, f -> f.name == 'drawFrameComplex').kind {
			case FFun(f):
				f.expr = macro {
					final matrix = this._matrix; // TODO: Just use local?
					frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
					matrix.translate(-origin.x, -origin.y);
					matrix.scale(scale.x, scale.y);

					if (bakedRotationAngle <= 0) {
						updateTrig();

						if (angle != 0)
							matrix.rotateWithTrig(_cosAngle, _sinAngle);
					}

					getScreenPosition(_point, camera).subtract(offset);
					_point.add(origin.x, origin.y);
					matrix.translate(_point.x, _point.y);

					if (isPixelPerfectRender(camera)) {
						matrix.tx = Math.floor(matrix.tx);
						matrix.ty = Math.floor(matrix.ty);
					}

					camera.drawPixels(frame, framePixels, matrix, colorTransform, blend, antialiasing
						&& (canUseAntialiasing || forceAntialiasing), shader);
				}
			case _:
		}

		return fields;
	}
}
