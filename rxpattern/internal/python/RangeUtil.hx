package rxpattern.internal.python;

import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;

class RangeUtil {

    public static inline function printRanges(ranges:Ranges, invert:Bool):RxPattern {
        return rxpattern.internal.std.RangeUtil.printRanges(ranges, invert);
    }

}