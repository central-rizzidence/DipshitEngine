package funkin.extensions;

import flixel.math.FlxRect;
import openfl.display.BlendMode;
import flixel.math.FlxMath;
import flixel.util.FlxDirectionFlags;
import flixel.FlxCamera;
import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

typedef FlxSpriteParent = FlxTypedSpriteParent<FlxSpriteChild>;

class FlxTypedSpriteParent<T:FlxSpriteChild> extends FlxTypedSpriteContainer<T> {
	override function preAdd(member:T) {}

	override function draw() {
		for (member in members) {
			if (member != null && member.exists && member.visible) {
				member._parent = cast this;
				member.draw();
			}
		}
	}

	@:noCompletion
	override function set_camera(value:FlxCamera):FlxCamera {
		if (_cameras == null)
			_cameras = [value];
		else
			_cameras[0] = value;
		return value;
	}

	@:noCompletion
	override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera> {
		return _cameras = value;
	}

	@:noCompletion
	override function set_exists(value:Bool):Bool {
		return exists = value;
	}

	@:noCompletion
	override function set_visible(value:Bool):Bool {
		return visible = value;
	}

	@:noCompletion
	override function set_active(value:Bool):Bool {
		return active = value;
	}

	@:noCompletion
	override function set_alive(value:Bool):Bool {
		return alive = value;
	}

	@:noCompletion
	override function set_x(value:Float):Float {
		return x = value;
	}

	@:noCompletion
	override function set_y(value:Float):Float {
		return y = value;
	}

	@:noCompletion
	override function set_angle(value:Float):Float {
		return angle = value;
	}

	@:noCompletion
	override function set_alpha(value:Float):Float {
		return alpha = FlxMath.bound(value);
	}

	@:noCompletion
	override function set_facing(value:FlxDirectionFlags):FlxDirectionFlags {
		return facing = value;
	}

	@:noCompletion
	override function set_flipX(value:Bool):Bool {
		return flipX = value;
	}

	@:noCompletion
	override function set_flipY(value:Bool):Bool {
		return flipY = value;
	}

	@:noCompletion
	override function set_moves(value:Bool):Bool {
		return moves = value;
	}

	@:noCompletion
	override function set_immovable(value:Bool):Bool {
		return immovable = value;
	}

	@:noCompletion
	override function set_solid(value:Bool):Bool {
		allowCollisions = value ? ANY : NONE;
		return value;
	}

	@:noCompletion
	override function set_color(value:Int):Int {
		return color = value;
	}

	@:noCompletion
	override function set_blend(value:BlendMode):BlendMode {
		return blend = value;
	}

	@:noCompletion
	override function set_clipRect(value:FlxRect):FlxRect {
		return clipRect = value;
	}

	@:noCompletion
	override function set_width(value:Float):Float {
		return value;
	}

	@:noCompletion
	override function set_height(value:Float):Float {
		return value;
	}
}
