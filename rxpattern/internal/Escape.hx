package rxpattern.internal;

#if (eval || macro)
import rxpattern.internal.Target;
#end

@:forward
abstract Escape(String) to String {
    public static var Start#if (eval || macro)(get, never):String #else = 
        #if ((js && nodejs) || (js && js_es > 5))
            '\\u{'
        #elseif (cs || js || python || hl)
            '\\u'
        #else 
            '\\x{'
        #end
    #end;

    public static var End#if (eval || macro)(get, never):String #else = 
        #if ((js && nodejs) || (js && js_es > 5))
            '}'
        #elseif (cs || js || python || hl)
            ''
        #else 
            '}'
        #end
    #end;

    #if (eval || macro)
    private static function get_Start():String {
        return if (JavaScript && NodeJS) {
            '\\u{';
        } else if (CSharp || JavaScript || Python || HashLink) {
            '\\u';
        } else {
            '\\x{';
        }
    }
    private static function get_End():String {
        return if (JavaScript && NodeJS) {
            '}';
        } else if (CSharp || JavaScript || Python || HashLink) {
            '';
        } else {
            '}';
        }
    }
    #end
}