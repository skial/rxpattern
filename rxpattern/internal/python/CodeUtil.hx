package rxpattern.internal.python;

import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.std.CodeUtil as StdCodeUtil;

class CodeUtil {

    public static function printCode(v:Int):String {
        if (inline StdCodeUtil.isValidAscii(v)) {
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