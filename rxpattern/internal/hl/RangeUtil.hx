package rxpattern.internal.hl;

import uhx.sys.seri.Ranges;

class RangeUtil {

    public static inline function printRanges(ranges:Ranges, invert:Bool):RxPattern {
        return rxpattern.internal.std.RangeUtil.printRanges(ranges, invert);
    }

}