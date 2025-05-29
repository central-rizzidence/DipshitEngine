package funkin.credits.github;

import funkin.util.HttpUtil;
import json2object.JsonParser;

class GitHub {
	private static final _contributorParser:JsonParser<Array<GitHubContributor>> = new JsonParser<Array<GitHubContributor>>();

	public static function getContributors(repository:String, owner:String):Null<Array<GitHubContributor>> {
		final json = HttpUtil.requestText('https://api.github.com/repos/$owner/$repository/contributors');
		_contributorParser.fromJson(json, 'url');
		return _contributorParser.value;
	}
}
