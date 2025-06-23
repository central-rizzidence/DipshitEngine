package macros;

import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr.Field;

final class AssetFrontEndMacro {
	public static macro function add():Array<Field> {
		Compiler.addGlobalMetadata('flixel.system.frontEnds.AssetFrontEnd', '@:build(macros.AssetFrontEndMacro.build())', false);
		return Context.getBuildFields();
	}

	@:noCompletion
	public static macro function build():Array<Field> {
		final fields = Context.getBuildFields();

		switch Lambda.find(fields, f -> f.name == 'getJsonUnsafe').kind {
			case FFun(f):
				f.ret = macro :Dynamic;
			case _:
		}

		switch Lambda.find(fields, f -> f.name == 'getJson').kind {
			case FFun(f):
				f.ret = macro :Dynamic;
			case _:
		}

		return fields;
	}
}
