package funkin.sound;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

final class HxVlcVolumeMacro {
	public static macro function rebuildVolumeChangeMethod():Array<Field> {
		final fields = Context.getBuildFields();

		switch Lambda.find(fields, field -> field.name == 'onVolumeChange').kind {
			case FFun(f):
				f.expr = macro {
					final flixelVolume = FlxG.sound.applySoundCurve(vol * volumeAdjust);
					final currentVolume = Math.floor(flixelVolume * DefineMacro.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 125));

					if (volume != currentVolume)
						volume = currentVolume;
				}

			case _:
		}

		return fields;
	}
}
