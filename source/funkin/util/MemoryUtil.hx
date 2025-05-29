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

final class MemoryUtil {
	public static function clearAll() {
		clearOpenFLCache();
		flixel.FlxG.bitmap.clearCache();
		destroyFlixelZombies();
		runGc();
	}

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

	public static function destroyFlixelZombies() {
		#if cpp
		var zombie:Null<Dynamic>;
		while ((zombie = Gc.getNextZombie()) != null) {
			if (zombie is flixel.util.FlxDestroyUtil.IFlxDestroyable)
				flixel.util.FlxDestroyUtil.destroy(zombie);
		}
		#end
	}

	public static inline function runGc() {
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
		#else
		return js.Syntax.code('(window.performance && window.performance.memory) ? window.performance.memory.usedJSHeapSize : 0');
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
		#else
		return js.Syntax.code('(window.performance && window.performance.memory) ? window.performance.memory.totalJSHeapSize : 0');
		#end
	}
}
