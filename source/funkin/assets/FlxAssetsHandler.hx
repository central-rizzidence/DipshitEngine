package funkin.assets;

import lime.graphics.cairo.CairoImageSurface;
import flixel.system.frontEnds.AssetFrontEnd;
import openfl.display.BitmapData;

typedef GetAssetFunction = (id:String, type:FlxAssetType, ?useCache:Bool) -> Any;

final class FlxAssetsHandler {
	public static function replaceFunctions() {
		final defaultMethod = FlxG.assets.getAssetUnsafe;

		FlxG.assets.getAssetUnsafe = (id, type, useCache = true) -> {
			return switch type {
				case IMAGE: _getBitmapData(id, useCache, defaultMethod);
				case t: defaultMethod(id, t, useCache);
			}
		}
	}

	public static inline function isOnGPU(bitmapData:BitmapData):Bool {
		return !bitmapData.readable && bitmapData.image == null;
	}

	@:access(openfl.display.BitmapData)
	private static function _getBitmapData(id:String, useCache:Bool = true, defaultMethod:GetAssetFunction):Null<BitmapData> {
		final result:BitmapData = defaultMethod(id, IMAGE, useCache);
		if (Config.gpuBitmaps && FlxG.stage.context3D != null && !isOnGPU(result)) {
			// Upload image to gpu memory
			result.getTexture(FlxG.stage.context3D);
			result.__surface ??= CairoImageSurface.fromImage(result.image);

			// Dispose image so as not to overload memory
			result.disposeImage();
			result.image = null;
		}
		return result;
	}
}
