package rxpattern.internal.python;

import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.std.CodeUtil;

class CodeUtil {

    public static function printCode(v:Int):String {
        if (inline rxpattern.internal.std.CodeUtil.isValidAscii(v)) {
            return String.fromCharCode(v);
        }
        var hex = StringTools.hex(v, (v >= 0x10000) ? 8 : 4);
        return if (v >= 0x10000) {
            '\\U' + hex;

        } else {
            '\\u' + hex;

        }
    }

}