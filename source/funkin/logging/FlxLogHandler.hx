package funkin.logging;

import flixel.util.FlxColor;
import haxe.PosInfos;
import flixel.system.debug.log.LogStyle;

class FlxLogHandler {
	public static function setupRetranslation() {
		for (style in [
			LogStyle.NORMAL,
			LogStyle.WARNING,
			LogStyle.ERROR,
			LogStyle.NOTICE,
			LogStyle.CONSOLE
		])
			style.onLog.add((data, ?pos) -> _retranslate(style, data, pos));
	}

	private static function _retranslate(style:LogStyle, data:Any, ?pos:PosInfos) {
		final output = _formatOutput(style, data, pos);
		#if sys
		Sys.println(output);
		#elseif js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(output);
		#end
	}

	private static function _formatOutput(style:LogStyle, data:Any, ?pos:PosInfos):String {
		final arrayData:Array<Dynamic> = data is Array ? data : [data];

		final styleColor = FlxColor.fromString('#${style.color}');

		final buf = new StringBuf();

		// Set color
		buf.add('\x1b[38;2;${styleColor.red};${styleColor.green};${styleColor.blue}m');

		// Set bold
		if (style.bold)
			buf.add('\x1b[1m');

		// Set italic
		if (style.italic)
			buf.add('\x1b[3m');

		// Set underlined
		if (style.underlined)
			buf.add('\x1b[4m');

		if (style.prefix?.length > 0)
			buf.add(style.prefix);

		buf.add(arrayData.join(' '));

		// Reset underlined
		if (style.underlined)
			buf.add('\x1b[24m');

		// Reset italic
		if (style.italic)
			buf.add('\x1b[23m');

		// Reset bold
		if (style.bold)
			buf.add('\x1b[22m');

		// Reset color
		buf.add('\x1b[39m');

		if (pos == null)
			return buf.toString();

		buf.addChar(' '.code);

		// Set dim
		buf.add('\x1b[2m');

		buf.add(pos.fileName);
		buf.addChar(':'.code);
		buf.add(pos.lineNumber);

		if (pos.customParams != null) {
			for (param in pos.customParams)
				buf.add(', $param');
		}

		// Reset dim
		buf.add('\x1b[22m');

		return buf.toString();
	}
}
