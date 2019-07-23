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

/*
    public static function printRanges(ranges:Ranges):RxPattern {
        var label = 0;
        var buf = new StringBuf();
        var open:Null<Bool> = true;
        var includeHighSurrogates = true;

        for (range in ranges.values) {
            if (open != null && open) {
                // utf16
                if (range.min >= 0xDC00 && range.max <= 0xDFFF) {
                    buf.add('(?:[^' + printCode(0xD800) + '-' + printCode(0xDBFF) + ']|^)');
                }
                buf.add('[');
                open = false;
            }

            if (!NodeJS && !Python && range.min >= 0x10000) {
                includeHighSurrogates = false;
                var minhi = ((range.min - 0x10000) >> 10) | 0xD800;
                var minlo = ((range.min - 0x10000) & 0x3FF) | 0xDC00;
                var maxhi = ((range.max - 0x10000) >> 10) | 0xD800;
                var maxlo = ((range.max - 0x10000) & 0x3FF) | 0xDC00;

                var high = minhi;
                if (high != label) {
                    if (open != null && !open) {
                        buf.add(']');
                        open = null;
                    }
                    buf.add( '|' );
                    buf.add( printCode(high) );
                    
                }

                switch range.length {
                    case 0: 
                        buf.add( printCode(minlo) );

                    case 1:
                        buf.add( printCode(minlo) );
                        buf.add( printCode(maxlo) );

                    case _:
                        if (label != high) buf.add('[');
                        buf.add( printCode(minlo) + '-' + printCode(maxlo) );
                        open = false;
                    
                }

                if (label != high) {
                    label = high;
                }

            } else {
                switch range.length {
                    case 0: 
                        buf.add( printCode(range.min) );

                    case 1:
                        buf.add( printCode(range.min) );
                        buf.add( printCode(range.max) );

                    case _:
                        buf.add( printCode(range.min) + '-' + printCode(range.max) );
                    
                }

            }
        }

        if (open != null && !open) {
            buf.add(']');
            // utf16
            if (includeHighSurrogates && label >= 0xD800 && label <= 0xDBFF) {
                buf.add('(?![' + printCode(0xDC00) + '-' + printCode(0xDFFF) + '])');
            }
            open = null;
        }

        return RxPattern.Atom(buf.toString());
    }
*/
}