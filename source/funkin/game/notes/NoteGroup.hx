package funkin.game.notes;

import haxe.ds.Vector;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteGroup extends FlxTypedGroup<Note> {
	public function new() {
		super();
	}

	public function prealloc(nnotes:Int) {
		length = 0;
		if (_memberRemoved != null) {
			for (member in members)
				onMemberRemove(member);
		}
		members = cast new Vector<Note>(nnotes, null);
	}
}
