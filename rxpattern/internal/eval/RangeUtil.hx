package rxpattern.internal.eval;

import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.Define;

class RangeUtil {

    public static function printRanges(ranges:Ranges, invert:Bool):RxPattern {
        return if (JavaScript || CSharp) {
            if ((JavaScript && NodeJS) || (ES_ && ES_ > 5)) {
                rxpattern.internal.js.RangeUtil.printRanges(ranges, invert);

            } else {
                rxpattern.internal.utf16.RangeUtil.printRanges(ranges, invert);

            }

        } else if (Python) {
            rxpattern.internal.python.RangeUtil.printRanges(ranges, invert);

        } else if (HashLink) {
            rxpattern.internal.hl.RangeUtil.printRanges(ranges, invert);

        }/* else if (Java && JavaVersion && JavaVersion < 7) {
            rxpattern.internal.utf16.RangeUtil.printRanges(ranges, invert);

        } */else {
            rxpattern.internal.std.RangeUtil.printRanges(ranges, invert);

        }
    }

}