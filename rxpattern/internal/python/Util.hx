package rxpattern.internal.python;

import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.std.Util as StdUtil;

class Util {

    public static function printCode(v:Int):String {
        if (inline StdUtil.isValidAscii(v)) {
            return String.fromCharCode(v);
        }
        var hex = StringTools.hex(v, (v >= 0x10000) ? 8 : 4);
        return if (v >= 0x10000) {
            '\\U' + hex;

        } else {
            '\\u' + hex;

        }
    }

    public static inline function printRanges(ranges:Ranges):RxPattern 
        return StdUtil.printRanges(ranges);

}