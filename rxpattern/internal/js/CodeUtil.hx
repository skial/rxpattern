package rxpattern.internal.js;

#if (eval || macro)
import rxpattern.internal.Define;
#end

using StringTools;
using rxpattern.internal.std.CodeUtil;

class CodeUtil {

    #if (eval || macro)
    public static function printCode(v:Int):String {
        return switch v {
            case 0: '\\0';
            case x if (!x.isValidAscii() && x <= 0xFF): '\\x' + StringTools.hex(v, 2);
            case _.isValidAscii() => true: String.fromCharCode(v);
            case x if (x > 0xFFFF && (NodeJS || ES_ && ES_ > 5)):
                '\\u{${StringTools.hex(v, 4)}}';

            case _:
                '\\u' + StringTools.hex(v, 4);
        }
    }
    #else
    public static function printCode(v:Int):String {
        return switch v {
            case 0: '\\0';
            case _.isEscapable() => true: '\\' + String.fromCharCode(v);
            case x if (!x.isValidAscii() && x <= 0xFF): '\\x' + StringTools.hex(v, 2);
            case _.isValidAscii() => true: String.fromCharCode(v);
            #if ((nodejs || js_es > 5))
            case x if (x > 0xFFFF):
                '\\u{${StringTools.hex(v, 4)}}';

            case _:
                '\\u' + StringTools.hex(v, 4);
            #else
            case _: rxpattern.internal.std.CodeUtil.printCode(v);
            #end
        }
    }

    #end

}