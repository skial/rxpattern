package rxpattern.internal.java;

import uhx.sys.seri.Ranges;

class CodeUtil {

    public static inline function printCode(v:Int):String {
        if (inline rxpattern.internal.std.CodeUtil.isEscapable(v)) {
            return '\\' + String.fromCharCode(v);
        }
        // Surrogate values need to be escaped.
        if (v >= 0xD800 && v <= 0xDFFF) {
            return rxpattern.internal.std.CodeUtil.printCode(v);
        }
        return unifill.CodePoint.fromInt(v).toString();
    }

}