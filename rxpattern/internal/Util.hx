package rxpattern.internal;

#if (macro || eval)
import haxe.macro.Context;
import rxpattern.internal.Target;
#end

class Util {

    #if (macro || eval)
    private static var pythonStyle:Bool = Python; // \uHHHH or \UHHHHHHHH
    private static var perlStyle:Bool = Neko || Cpp || Php || Lua || Java; // \x{HHHH}
    private static var jsStyle:Bool = JavaScript || CSharp || Flash || HashLink; // \uHHHH
    private static var onlyBMP:Bool = JavaScript || CSharp;

    public static function printCode(v:Int):String {
        if (v >= 'A'.code && v <= 'Z'.code || v >= 'a'.code && v <= 'z'.code) {
            return String.fromCharCode(v);
        }
        var hex = StringTools.hex(v, (perlStyle) ? 0 : (pythonStyle && v > 0x10000) ? 8 : 4);
        return if (perlStyle) {
            '\\x{' + hex + '}';

        } else if (pythonStyle && v > 0x10000) {
            '\\U' + hex;

        } else if (
                (JavaScript && 
                Context.defined('js-es') && 
                Std.parseInt(Context.definedValue('js-es')) > 5) || 
                NodeJS) {
            // Haxe only supports es5 or greater.
            // ES6/ES2015 introduced `u` flag & `\u{0123}` format.
            '\\u{' + hex + '}';

        } else {
            '\\u' + hex;

        }
    }
    #elseif (neko || cpp || php || lua || java)
    public static inline function printCode(v:Int):String {
        if (v >= 'A'.code && v <= 'Z'.code || v >= 'a'.code && v <= 'z'.code) {
            return String.fromCharCode(v);
        }
        return '\\x{' + StringTools.hex(v, 0) + '}';
    }
    #elseif (python)
    public static function printCode(v:Int):String {
        if (v >= 'A'.code && v <= 'Z'.code || v >= 'a'.code && v <= 'z'.code) {
            return String.fromCharCode(v);
        }
        var hex = StringTools.hex(v, (v > 0x10000) ? 8 : 4);
        return if (v > 0x10000) {
            '\\U' + hex;

        } else {
            '\\u' + hex;

        }
    }
    #elseif (js || cs || hl || flash)
    public static inline function printCode(v:Int):String {
        if (v >= 'A'.code && v <= 'Z'.code || v >= 'a'.code && v <= 'z'.code) {
            return String.fromCharCode(v);
        }
        return 
        #if (nodejs || (js && js_es > 5))
            // Haxe only supports es5 or greater.
            // ES6/ES2015 introduced `u` flag & `\u{0123}` format.
            '\\u{' + StringTools.hex(v, 4) + '}';
        #else
            '\\u' + StringTools.hex(v, 4);
        #end
    }
    #end

}