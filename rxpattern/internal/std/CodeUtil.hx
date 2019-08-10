package rxpattern.internal.std;

import rxpattern.internal.Escape;

class CodeUtil {

    public static function isEscapable(v:Int):Bool {
        return (v == 47 || v == 92);
    }

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
        if (inline isEscapable(v)) {
            return '\\' + String.fromCharCode(v);
        }

        if (inline isValidAscii(v)) {
            return String.fromCharCode(v);
        }
        
        return Escape.Start + StringTools.hex(v, 4) + Escape.End;
    }

}