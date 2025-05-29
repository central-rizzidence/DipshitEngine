package funkin.logging;

import openfl.events.UncaughtErrorEvent;
import flixel.math.FlxMath;
import haxe.CallStack;

final class CrashHandler {
	public static function setupCallbacks() {
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(_onCriticalError);
		#elseif hl
		hl.Api.setErrorHandler(_onCriticalError);
		#end
		FlxG.stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, _onUncaughtError);
	}

	private static function _onCriticalError(error:Dynamic) {
		final quickReport = _buildQuickReport(error);

		FlxG.stage.window.alert(quickReport, 'Critical Error Encountered!');
		#if sys
		Sys.exit(1);
		#end
	}

	private static function _onUncaughtError(event:UncaughtErrorEvent) {
		throw event.error;
	}

	private static function _buildQuickReport(error:Dynamic):String {
		final buf = new StringBuf();

		buf.add('$error');
		buf.add('Called from:');
		for (stackItem in _buildStackStrings())
			buf.add('\n\t$stackItem');

		return buf.toString();
	}

	private static function _buildFullReport(error:Dynamic):String {
		final buf = new StringBuf();

		buf.add('Critical Error Encountered: ');
		buf.add(_buildQuickReport(error));
		buf.add('\n\n');
		buf.add(_buildSessionInfo());
		buf.add('\n\n');
		buf.add(_buildSystemInfo());
		buf.add('\n\n');
		buf.add(_buildGcInfo());

		return buf.toString();
	}

	private static function _buildStackStrings():Array<String> {
		var stack = CallStack.exceptionStack(true);
		if (stack.length == 0)
			stack = CallStack.callStack();

		return stack.map(_stackItem2string);
	}

	private static function _stackItem2string(item:StackItem):String {
		return switch item {
			case CFunction: 'a C Function';
			case Module(m): 'module $m';
			case FilePos(s, file, line, column): s != null ? _stackItem2string(s) + '($file line $line)' : '$file line $line';
			case Method(classname, method): '$classname.$method';
			case LocalFunction(v): 'local function #$v';
		}
	}

	private static function _buildSessionInfo():String {
		final buf = new StringBuf();

		buf.add('Session Info:');
		#if sys
		buf.add('\n - Duration: ${Sys.cpuTime()} seconds');
		#end

		return buf.toString();
	}

	private static function _buildSystemInfo():String {
		final buf = new StringBuf();

		buf.add('System Info:');
		buf.add('\n - 3D Driver: ${FlxG.stage.context3D?.driverInfo ?? 'N/A'}');
		#if sys
		buf.add('\n - Platform: ${Sys.systemName()}');
		buf.add('\n - Host Name: ${sys.net.Host.localhost()}');
		#end
		buf.add('\n - Render Method: ${FlxG.renderMethod}');

		return buf.toString();
	}

	private static function _buildGcInfo():String {
		final buf = new StringBuf();

		#if cpp
		buf.add('HXCPP-Immix:');
		buf.add('\n - Memory Used: ${_buildMemoryString(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE))}');
		buf.add('\n - Memory Reserved: ${_buildMemoryString(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED))}');
		buf.add('\n - Memory Current: ${_buildMemoryString(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_CURRENT))}');
		buf.add('\n - Memory Large: ${_buildMemoryString(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_LARGE))}');
		buf.add('\n - GC Moving: ${#if HXCPP_GC_MOVING 'Enabled' #else 'Disabled' #end}');
		buf.add('\n - GC Dynamic Size: ${#if HXCPP_GC_DYNAMIC_SIZE 'Enabled' #else 'Disabled' #end}');
		buf.add('\n - GC Big Blocks: ${#if HXCPP_GC_BIG_BLOCKS 'Enabled' #else 'Disabled' #end}');
		#elseif hl
		buf.add('HashLink-Immix:');
		final stats = hl.Gc.stats();
		buf.add('\n - Current Memory: ${_buildMemoryString(stats.currentMemory)}');
		buf.add('\n - Total Allocated: ${_buildMemoryString(stats.totalAllocated)}');
		buf.add('\n - Allocation Count: ${stats.allocationCount}');
		final flags = hl.Gc.flags;
		buf.add('\n - GC Profile: ${flags.has(Profile) ? 'Enabled' : 'Disabled'}');
		buf.add('\n - GC Dump Memory: ${flags.has(DumpMem) ? 'Enabled' : 'Disabled'}');
		buf.add('\n - GC No Threads: ${flags.has(NoThreads) ? 'Enabled' : 'Disabled'}');
		buf.add('\n - GC Force Major: ${flags.has(ForceMajor) ? 'Enabled' : 'Disabled'}');
		#elseif java
		buf.add('JVM-Garbage-Collector:'); // TODO: какой именно сборщик мусора используется?
		final stats = java.vm.Gc.stats();
		buf.add('\n - Heap: ${_buildMemoryString(stats.heap)}');
		buf.add('\n - Free: ${_buildMemoryString(stats.free)}');
		#elseif js
		buf.add('JS-MNS:');
		buf.add('\n - JS Heap Size Limit: ${_buildMemoryString(js.Syntax.code('(window.performance && window.performance.memory) ? window.performance.memory.jsHeapSizeLimit : 0'))}');
		buf.add('\n - Total JS Heap Size: ${_buildMemoryString(js.Syntax.code('(window.performance && window.performance.memory) ? window.performance.memory.totalJSHeapSize : 0'))}');
		buf.add('\n - Used JS Heap Size: ${_buildMemoryString(js.Syntax.code('(window.performance && window.performance.memory) ? window.performance.memory.usedJSHeapSize : 0'))}');
		#elseif neko
		buf.add('Boehm-GC:');
		final stats = neko.vm.Gc.stats();
		buf.add('\n - Heap: ${_buildMemoryString(stats.heap)}');
		buf.add('\n - Free: ${_buildMemoryString(stats.free)}');
		#else
		buf.add('Unknown GC');
		#end

		return buf.toString();
	}

	private static final MEMORY_UNITS = ['Bytes', 'kB', 'MB', 'GB', 'TB', 'PB'];

	private static function _buildMemoryString(bytes:Float):String {
		var curUnit = 0;
		var memory = bytes;
		while (memory >= 1024 && curUnit < MEMORY_UNITS.length - 1) {
			memory /= 1024;
			curUnit++;
		}

		return '${FlxMath.roundDecimal(memory, 2)} ${MEMORY_UNITS[curUnit]} ($bytes Bytes)';
	}
}
