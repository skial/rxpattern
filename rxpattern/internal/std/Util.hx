package rxpattern.internal.std;

import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.Escape;
import rxpattern.internal.Util as TargetUtil;

class Util {

    public static function isValidAscii(v:Int):Bool {
        return (
            (v >= 32 && v <= 39) || 
            v == 44 || 
            (v >= 47 && v <= 62) || 
            v == 64 || 
            (v >= 65 && v <= 90) || 
            v == 92 ||
            (v >= 96 && v <= 122)
        );
    }

    public static function printCode(v:Int):String {
        if (inline isValidAscii(v)) {
            return String.fromCharCode(v);
        }
        return Escape.Start + StringTools.hex(v, 4) + Escape.End;
    }

    public static function printRanges(ranges:Ranges):RxPattern {
        var label = 0;
        var buf = new StringBuf();
        var open:Null<Bool> = true;

        var idx = 0;
        var len = ranges.values.length - 1;
        var range:Range;

        if (ranges.length == 0) return RxPattern.Atom(TargetUtil.printCode(ranges.min));

        while (idx <= len) {
            range = ranges.values[idx];

            if (open != null && open) {
                buf.add('[');
                open = false;
            }

            label = range.min;
            switch range.length {
                case 0: 
                    buf.add( TargetUtil.printCode(range.min) );

                case 1:
                    buf.add( TargetUtil.printCode(range.min) );
                    buf.add( TargetUtil.printCode(range.max) );

                case _:
                    buf.add( TargetUtil.printCode(range.min) + '-' + TargetUtil.printCode(range.max) );
                
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