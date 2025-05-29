package funkin.credits.github;

class GitHubContributor {
	public var login:String;
	public var id:Int;
	@:alias('node_id') public var nodeId:String;
	@:alias('avatar_url') public var avatarUrl:String;
	@:alias('gravatar_url') public var gravatarUrl:String;
	public var url:String;
	@:alias('html_url') public var htmlUrl:String;
	@:alias('followers_url') public var followersUrl:String;
	@:alias('following_url') public var followingUrl:String;
	@:alias('gists_url') public var gistsUrl:String;
	@:alias('starred_url') public var starredUrl:String;
	@:alias('subscriptions_url') public var subscriptionsUrl:String;
	@:alias('organizations_url') public var organizationsUrl:String;
	@:alias('repos_url') public var reposUrl:String;
	@:alias('events_url') public var eventsUrl:String;
	@:alias('received_events_url') public var receivedEventsUrl:String;
	public var type:String;
	@:alias('site_admin') public var siteAdmin:Bool;
	public var contributions:Int;
}
