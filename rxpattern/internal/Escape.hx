package rxpattern.internal;

#if (eval || macro)
import haxe.macro.Context;
import rxpattern.internal.Define;
#end

@:forward
abstract Escape(String) to String {
    public static var Start#if (eval || macro)(get, never):String #else = 
        #if ((js && nodejs) || (js && js_es > 5))
            '\\u{'
        #elseif (cs || js || python || hl || (java && java_ver < 7))
            '\\u'
        #else 
            '\\x{'
        #end
    #end;

    public static var End#if (eval || macro)(get, never):String #else = 
        #if ((js && nodejs) || (js && js_es > 5))
            '}'
        #elseif (cs || js || python || hl || (java && java_ver < 7))
            ''
        #else 
            '}'
        #end
    #end;

    #if (eval || macro)
    private static function get_Start():String {
        return if ((JavaScript && NodeJS) || (ES_ && ES_ > 5)) {
            '\\u{';
        } else if (CSharp || JavaScript || Python || HashLink || (Java && JavaVersion && JavaVersion < 7)) {
            '\\u';
        } else {
            '\\x{';
        }
    }
    private static function get_End():String {
        return if ((JavaScript && NodeJS) || (ES_ && ES_ > 5)) {
            '}';
        } else if (CSharp || JavaScript || Python || HashLink || (Java && JavaVersion && JavaVersion < 7)) {
            '';
        } else {
            '}';
        }
    }
    #end
}