package rxpattern.internal;

#if (macro || eval)
import haxe.macro.Expr;
import haxe.macro.Context;
#end

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
    var NodeJS = 'nodejs';

    private static macro function includeDefines():ExprOf<Array<Target>> {
        var r = [];
        if (JavaScript.defined()) r.push(macro $v{JavaScript});
        if (CSharp.defined()) r.push(macro $v{CSharp});
        if (Java.defined()) r.push(macro $v{Java});
        if (Python.defined()) r.push(macro $v{Python});
        if (Neko.defined()) r.push(macro $v{Neko});
        if (Cpp.defined()) r.push(macro $v{Cpp});
        if (Php.defined()) r.push(macro $v{Php});
        if (Lua.defined()) r.push(macro $v{Lua});
        if (Flash.defined()) r.push(macro $v{Flash});
        if (HashLink.defined()) r.push(macro $v{HashLink});
        if (Interp.defined()) r.push(macro $v{Interp});
        if (NodeJS.defined()) r.push(macro $v{NodeJS});
        return macro $a{r};
    }

    @:to public inline function defined():Bool {
        #if (macro || eval)
        return Context.defined(this);
        #else 
        return includeDefines().indexOf(this) > -1;
        #end
    }

    @:op(A || B) public static inline function orTarget(a:Target, b:Target):Bool {
        return a.defined() || b.defined();
    }

    @:commutative 
    @:op(A || B) public static inline function orBool(a:Target, b:Bool):Bool {
        return a.defined() || b;
    }

    @:commutative 
    @:op(A && B) public static inline function andBool(a:Target, b:Bool):Bool {
        return a.defined() && b;
    }

    @:op(!A) public static inline function not(a:Target):Bool {
        return !a.defined();
    }
}