package rxpattern.internal.js;

import uhx.sys.seri.Ranges;
import rxpattern.internal.MinMax.*;

class RangeUtil {

    public static inline function printRanges(ranges:Ranges, invert:Bool):RxPattern {
        if (invert) ranges = Ranges.complement(ranges, MIN, MAX);
        return rxpattern.internal.std.RangeUtil.printRanges(ranges, false);
    }

}