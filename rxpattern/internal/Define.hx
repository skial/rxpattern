package rxpattern.internal;

#if (macro || eval)
import haxe.macro.Expr;
import haxe.macro.Context;
#end

enum abstract Define(String) from String to String {
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
    var ES_ = 'js_es';
    var JavaVersion = 'java_ver';

    private static macro function includeDefines():ExprOf<Array<Define>> {
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

    public inline function value():Null<String> {
        return Context.definedValue(this);
    }

    @:op(A || B) public static inline function orDefine(a:Define, b:Define):Bool {
        return a.defined() || b.defined();
    }

    @:commutative 
    @:op(A || B) public static inline function orBool(a:Define, b:Bool):Bool {
        return a.defined() || b;
    }

    @:commutative 
    @:op(A && B) public static inline function andBool(a:Define, b:Bool):Bool {
        return a.defined() && b;
    }

    @:op(!A) public static inline function not(a:Define):Bool {
        return !a.defined();
    }

    @:op(A == B) public static inline function hasStringValue(a:Define, b:String):Bool {
        var _dv = Context.definedValue(a);
        return _dv != null && _dv == b;
    }

    @:op(A == B) public static inline function hasIntValue(a:Define, b:Int):Bool {
        var _dv = Context.definedValue(a);
        return _dv != null && Std.parseInt(_dv) == b;
    }

    @:op(A > B) public static inline function hasGtIntValue(a:Define, b:Int):Bool {
        var _dv = Context.definedValue(a);
        return _dv != null && Std.parseInt(_dv) > b;
    }

    @:op(A >= B) public static inline function hasGteIntValue(a:Define, b:Int):Bool {
        var _dv = Context.definedValue(a);
        return _dv != null && Std.parseInt(_dv) >= b;
    }

    @:op(A < B) public static inline function hasLtIntValue(a:Define, b:Int):Bool {
        var _dv = Context.definedValue(a);
        return _dv != null && Std.parseInt(_dv) < b;
    }

    @:op(A <= B) public static inline function hasLteIntValue(a:Define, b:Int):Bool {
        var _dv = Context.definedValue(a);
        return _dv != null && Std.parseInt(_dv) <= b;
    }
}