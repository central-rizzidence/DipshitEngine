package funkin.util;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end

class MemoryUtil {
	public static function clearAll() {
		#if openfl
		clearOpenFLCache();
		#end
		#if flixel
		flixel.FlxG.bitmap.clearCache();
		destroyFlixelZombies();
		#end
		runGc();
	}

	#if openfl
	public static function clearOpenFLCache() {
		final cache = Std.downcast(openfl.Assets.cache, openfl.utils.AssetCache);
		if (cache == null)
			return;

		for (id in cache.bitmapData.keys())
			cache.removeBitmapData(id);

		for (id in cache.font.keys())
			cache.removeFont(id);

		for (id in cache.sound.keys())
			cache.removeSound(id);
	}
	#end

	#if flixel
	public static function destroyFlixelZombies() {
		#if cpp
		var zombie:Null<Dynamic>;
		do {
			zombie = Gc.getNextZombie();
			if (zombie is flixel.util.FlxDestroyUtil.IFlxDestroyable)
				flixel.util.FlxDestroyUtil.destroy(zombie);
		} while (zombie != null);
		#end
	}
	#end

	public static function runGc() {
		#if (cpp || java || neko)
		Gc.run(true);
		#elseif hl
		Gc.major();
		#end
	}

	#if hl
	@:access(hl.Gc)
	#end
	public static function getUsed():Int {
		#if cpp
		return Gc.memUsage();
		#elseif hl
		var totalAllocated = 0.0, allocationCount = 0.0, currentMemory = 0.0;
		Gc._stats(totalAllocated, allocationCount, currentMemory);
		return Math.floor(currentMemory);
		#elseif (java || neko)
		final stats = Gc.stats();
		return stats.heap - stats.free;
		#end
	}

	#if hl
	@:access(hl.Gc)
	#end
	public static function getAllocated():Int {
		#if cpp
		return Gc.memInfo(Gc.MEM_INFO_RESERVED);
		#elseif hl
		var totalAllocated = 0.0, allocationCount = 0.0, currentMemory = 0.0;
		Gc._stats(totalAllocated, allocationCount, currentMemory);
		return Math.floor(totalAllocated);
		#elseif (java || neko)
		final stats = Gc.stats();
		return stats.heap;
		#end
	}
}
