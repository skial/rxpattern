package rxpattern.internal.js;

import uhx.sys.seri.Ranges;

using StringTools;
using rxpattern.internal.std.Util;

class Util {

    public static function printCode(v:Int):String {
        return switch v {
            case 0: return '\\0';
            case x if (!x.isValidAscii() && x <= 0xFF): return '\\x' + StringTools.hex(v, 2);
            #if (nodejs || js_es > 5)
            case x if (x.isValidAscii()):
                String.fromCharCode(v);
                
            case x if (x > 0xFFFF):
                '\\u{${StringTools.hex(v, 4)}}';

            case _:
                '\\u' + StringTools.hex(v, 4);
            #else
            case _: rxpattern.internal.std.Util.printCode(v);
            #end
        }
    }

    public static inline function printRanges(ranges:Ranges):RxPattern {
        return rxpattern.internal.std.Util.printRanges(ranges);
    }

}