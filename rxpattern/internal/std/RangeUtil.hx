package rxpattern.internal.std;

import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.Escape;
import rxpattern.internal.CodeUtil;

class RangeUtil {

    public static function printRanges(ranges:Ranges, invert:Bool):RxPattern {
        var label = 0;
        var buf = new StringBuf();
        var open:Null<Bool> = true;

        var idx = 0;
        var len = ranges.values.length - 1;
        var range:Range;

        if (ranges.length == 0) return RxPattern.Atom(CodeUtil.printCode(ranges.min));

        while (idx <= len) {
            range = ranges.values[idx];

            if (open != null && open) {
                buf.add('[');
                if (idx == 0 && invert) buf.add('^');
                open = false;
            }

            label = range.min;
            switch range.length {
                case 0: 
                    buf.add( CodeUtil.printCode(range.min) );

                case 1:
                    buf.add( CodeUtil.printCode(range.min) );
                    buf.add( CodeUtil.printCode(range.max) );

                case _:
                    buf.add( CodeUtil.printCode(range.min) + '-' + CodeUtil.printCode(range.max) );
                
            }

            idx++;
        }

        if (open != null && !open) {
            buf.add(']');
            open = null;
        }

        return RxPattern.Atom(buf.toString());
    }

}