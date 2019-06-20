package rxpattern.internal;

import haxe.macro.Context;

enum abstract Target(String) from String to String {
    var JavaScript = 'js';
    var CSharp = 'cs';
    var Java = 'java';
    var Python = 'python';
    var Neko = 'neko';
    var Cpp = 'cpp';
    var Php = 'php';
    var Lua = 'lua';
    var Flash = 'flash';
    var HashLink = 'hl';
    // Should be used over `macro` or `eval`.
    var Interp = 'interp';

    @:to public inline function defined():Bool {
        return Context.defined(this);
    }

    @:op(A || B) public static inline function orTarget(a:Target, b:Target):Bool {
        return a.defined() || b.defined();
    }

    @:commutative 
    @:op(A || B) public static inline function orBool(a:Target, b:Bool):Bool {
        return a.defined() || b;
    }
}