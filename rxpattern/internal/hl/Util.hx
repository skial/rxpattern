package rxpattern.internal.hl;

import uhx.sys.seri.Ranges;

class Util {

    public static inline function printCode(v:Int):String {
        // Surrogate values need to be escaped.
        if (v >= 0xD800 && v <= 0xDFFF) {
            return rxpattern.internal.std.Util.printCode(v);
        }
        return unifill.CodePoint.fromInt(v).toString();
    }

    public static inline function printRanges(ranges:Ranges):RxPattern {
        return rxpattern.internal.std.Util.printRanges(ranges);
    }

}