package funkin.util;

import openfl.events.Event;
import openfl.net.URLRequest;
import openfl.net.URLLoader;

class HttpUtil {
	public static var userAgent:String = 'request';

	public static function requestText(url:String):Null<String> {
		var result:Null<String> = null;

		final request = new URLRequest(url);
		request.userAgent = 'request';

		final loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, event -> {
			result = loader.data;
		});
		loader.load(request);

		return result;
	}
}
