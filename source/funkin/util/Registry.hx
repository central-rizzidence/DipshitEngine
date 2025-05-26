package funkin.util;

import haxe.io.Path;

class TypedRegistry<E:IRegistryEntry<D>, D> {
	public final registryId:String;

	private var _entries:List<E>;

	private static var _allAssets:Null<Array<String>>;

	public function new(id:String) {
		registryId = id;
		_entries = new List<E>();
	}

	public function reloadEntries():TypedRegistry<E, D> {
		return this;
	}

	public function registerEntry(entry:E, ?overwrite:Bool = false):E {
		if (overwrite || !hasEntry(entry.id))
			_entries.add(entry);

		return entry;
	}

	public function unregisterEntry(entry:E):E {
		_entries.remove(entry);
		return entry;
	}

	public inline function hasEntry(id:String):Bool {
		return Lambda.exists(_entries, entry -> entry.id == id);
	}

	public inline function findEntry(id:String):Null<E> {
		return Lambda.find(_entries, entry -> entry.id == id);
	}

	public inline function listEntryIds():Array<String> {
		return [for (entry in _entries) entry.id];
	}

	public function destroyEntries():TypedRegistry<E, D> {
		for (entry in _entries)
			entry.destroy();
		_entries.clear();
		return this;
	}
}

class TypedAssetRegistry<E:IRegistryEntry<D>, D> extends TypedRegistry<E, D> {
	public var assetsDirectory(default, null):String;
	public var assetsExtension(default, null):String;

	private var _entryFactory:(String) -> E;

	public function new(id:String, directory:String, extension:String, entryFactory:(String) -> E) {
		super(id);
		assetsDirectory = Path.normalize(directory);
		assetsExtension = extension;
		_entryFactory = entryFactory;
	}

	override function reloadEntries():TypedAssetRegistry<E, D> {
		destroyEntries();
		for (entryId in scanEntryIds()) {
			final entry = _entryFactory(entryId);
			if (entry.hasValidData())
				registerEntry(entry);
			else
				entry.destroy();
		}
		return this;
	}

	public function scanEntryIds():Array<String> {
		final prefix = assetsDirectory.fastCodeAt(assetsDirectory.length - 1) == '/'.code ? assetsDirectory : '$assetsDirectory/';
		final suffix = assetsExtension.fastCodeAt(0) == '.'.code ? assetsExtension : '.$assetsExtension';

		return (TypedRegistry._allAssets ??= FlxG.assets.list()).filter(asset -> asset.startsWith(prefix) && asset.endsWith(suffix))
			.map(asset -> asset.substring(prefix.length, asset.length - suffix.length));
	}
}

interface IRegistryEntry<T> extends IFlxDestroyable {
	public final id:String;
	private var _data:Null<T>;

	public function hasValidData():Bool;
}
