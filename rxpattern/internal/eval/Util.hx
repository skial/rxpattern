package rxpattern.internal.eval;

import haxe.macro.Context;
import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.Target;
import rxpattern.internal.std.Util as StdUtil;

class Util {

    private static var pythonStyle:Bool = Python; // \uHHHH or \UHHHHHHHH
    private static var perlStyle:Bool = Neko || Cpp || Php || Lua || Java || Interp; // \x{HHHH}
    private static var jsStyle:Bool = JavaScript || CSharp || Flash || HashLink; // \uHHHH
    private static var onlyBMP:Bool = JavaScript || CSharp;

    public static function printCode(v:Int):String {
        return if (JavaScript || CSharp) {
            if (
                CSharp ||
                (JavaScript && !NodeJS) || 
                !(Context.defined('js-es') && Std.parseInt(Context.definedValue('js-es')) > 5)
            ) {
                rxpattern.internal.utf16.Util.printCode(v);

            } else {
                rxpattern.internal.js.Util.printCode(v);

            }

        } else if (Python) {
            rxpattern.internal.python.Util.printCode(v);

        } else if (HashLink) {
            rxpattern.internal.hl.Util.printCode(v);

        } else {
            rxpattern.internal.std.Util.printCode(v);

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