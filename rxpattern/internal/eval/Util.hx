package rxpattern.internal.eval;

import haxe.macro.Context;
import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.Target;
import rxpattern.internal.std.Util as StdUtil;

class Util {

    private static var pythonStyle:Bool = Python; // \uHHHH or \UHHHHHHHH
    private static var perlStyle:Bool = Neko || Cpp || Php || Lua || Java; // \x{HHHH}
    private static var jsStyle:Bool = JavaScript || CSharp || Flash || HashLink; // \uHHHH
    private static var onlyBMP:Bool = JavaScript || CSharp;

    public static function printCode(v:Int):String {
        switch v {
            case 0x09:
                return '\t';

            case 0x0A:
                return '\n';
            
            case x if (StdUtil.isValidAscii(x)):
                return String.fromCharCode(v);
            
            case 0 if (!NodeJS && JavaScript):
                return '\\0';

            case _:

        }
        var hex = StringTools.hex(v, (perlStyle) ? 0 : (pythonStyle && v >= 0x10000) ? 8 : 4);
        return if (perlStyle) {
            '\\x{' + hex + '}';

        } else if (pythonStyle && v >= 0x10000) {
            '\\U' + hex;

        } else if (
                (JavaScript && NodeJS ||
                JavaScript && Context.defined('js-es') && 
                Std.parseInt(Context.definedValue('js-es')) > 5)) {
            // Haxe only supports es5 or greater.
            // ES6/ES2015 introduced `u` flag & `\u{0123}` format.
            '\\u{' + hex + '}';

        } else {
            '\\u' + hex;

        }
    }

    public static function printRanges(ranges:Ranges):RxPattern {
        return if ((!NodeJS && JavaScript) || CSharp) {
            rxpattern.internal.utf16.Util.printRanges(ranges);
        } else if (Python) {
            rxpattern.internal.python.Util.printRanges(ranges);
        } else {
            rxpattern.internal.std.Util.printRanges(ranges);
        }
    }

}