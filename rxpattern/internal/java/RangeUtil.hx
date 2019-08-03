package rxpattern.internal.java;

import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;

class RangeUtil {

    public static function printRanges(ranges:Ranges, invert:Bool):RxPattern {
        return
        #if (java && java_ver < 7)
        rxpattern.internal.utf16.RangeUtil.printRanges(ranges, false);
        #else
        rxpattern.internal.std.RangeUtil.printRanges(ranges, invert);
        #end
    }

}