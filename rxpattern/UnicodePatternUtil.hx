package rxpattern;

import rxpattern.RxErrors;
import uhx.sys.seri.Category;
import rxpattern.internal.Util.printCode;

#if (eval || macro)
import haxe.macro.Expr;
import haxe.macro.Context;
import uhx.sys.seri.Ranges;
import rxpattern.internal.Target;
#end

/* This class is not used at runtime */
#if !(eval || macro) extern #end
class UnicodePatternUtil
{
    /*
     * Different regexp engines have different syntax for hexadecimal Unicode
     * escape sequence.  This macro translates Unicode escape sequences of
     * the form \uHHHH or \u{HHHHH} into the form recognized by the engine.
     *
     * Input: \uHHHH or \u{HHHHH}
     * Python: \uHHHH or \UHHHHHHHH
     * Perl-like (Neko VM, C++, PHP, Lua and Java): \x{HHHHH}
     * JavaScript, C#, Flash: \uHHHH
     */
    macro public static function translateUnicodeEscape(s:String):ExprOf<String> {
        var i = 0;
        var pos = Context.currentPos();
        var translatedBuf = new StringBuf();

        while (i < s.length) {
            var j = s.indexOf("\\u", i);
            if (j == -1) {
                break;
            }
            translatedBuf.add(s.substring(i, j));
            var m;
            if (s.charAt(j + 2) == '{') {
                var k = s.indexOf('}', j + 3);
                if (k == -1) {
                    Context.error(Unicode_InvalidEscape, pos);
                    return null;
                }
                m = s.substring(j + 3, k);
                i = k + 1;
            } else {
                m = s.substring(j + 2, j + 6);
                i = j + 6;
            }
            var value = 0;
            for (l in 0...m.length) {
                value = value * 16 + hexToInt(m.charAt(l));
            }
            if (perlStyle) {
                translatedBuf.add(printCode(value));

            } else {
                if (value > 0x10000) {
                    /*if (pythonStyle) {
                        translatedBuf.add(printCode(value));
                    } else */if (jsStyle || !onlyBMP) {
                        var hi = ((value - 0x10000) >> 10) | 0xD800;
                        var lo = ((value - 0x10000) & 0x3FF) | 0xDC00;
                        translatedBuf.add(printCode(hi) + printCode(lo));
                    } else {
                        Context.error(Unicode_GreaterThanBMP, pos);
                        return null;
                    }
                } else {
                    translatedBuf.add(printCode(value));

                }
            }
        }

        translatedBuf.add(s.substr(i));
        var r = translatedBuf.toString();
        return macro @:pos(pos) $v{r};
    }

    public macro static function printCategory(category:String):ExprOf<RxPattern> {
        var range:Ranges = (cast category:Category).asRange();
        if (range.min == 0 && range.max == 0) {
            // Incorrect Category.
            Context.error('$category is not a valid value of uhx.sys.seri.Category.', Context.currentPos());
            return null;
        } else {
            var pattern = if (jsStyle || pythonStyle || Cpp) {
                var value = printRanges(range);
                if (jsStyle) {
                    macro new RxPattern.Disjunction($v{value});
                } else {
                    macro new RxPattern.Atom($v{value});
                }

            } else {
                macro new RxPattern.Atom($v{'\\p{$category}'});
            }
            
            return pattern;

        }
    }

    #if (eval || macro)
    private static var pythonStyle:Bool = Python; // \uHHHH or \UHHHHHHHH
    private static var perlStyle:Bool = Neko || Cpp || Php || Lua || Java; // \x{HHHH}
    private static var jsStyle:Bool = JavaScript || CSharp || Flash || HashLink; // \uHHHH
    private static var onlyBMP:Bool = JavaScript || CSharp;

    private static function printRanges(ranges:Ranges):String {
        var buf = new StringBuf();
        var open:Null<Bool> = true;

        /*function handle(min:Int, max:Int) {
            if (min >= 0x10000) {
                var minhi = ((min - 0x10000) >> 10) | 0xD800;
                var minlo = ((min - 0x10000) & 0x3FF) | 0xDC00;
                var maxhi = ((max - 0x10000) >> 10) | 0xD800;
                var maxlo = ((max - 0x10000) & 0x3FF) | 0xDC00;
                
                if (open != null && !open) {
                    buf.add(']');
                    open = null;
                }
                buf.add( '|' + printCode(minhi) );
                buf.add( '[' + printCode(minlo) + '-' + printCode(maxlo) + ']');

            } else {
                buf.add( printCode(min) + '-' + printCode(max) );

            }
        }*/

        var label = '';
        for (range in ranges.values) {
            if (open != null && open) {
                buf.add('[');
                open = false;
            }
            /*switch range.length {
                case 0:
                    buf.add( printCode(range.min) );

                case 1:
                    //trace( range.min, range.max );
                    buf.add( printCode(range.min) );
                    buf.add( printCode(range.max) );

                case _:
                    /*if (range.min >= 0x10000) {
                        var minhi = ((range.min - 0x10000) >> 10) | 0xD800;
                        var minlo = ((range.min - 0x10000) & 0x3FF) | 0xDC00;
                        var maxhi = ((range.max - 0x10000) >> 10) | 0xD800;
                        var maxlo = ((range.max - 0x10000) & 0x3FF) | 0xDC00;
                        
                        if (open != null && !open) {
                            buf.add(']');
                            open = null;
                        }
                        buf.add( '|' + printCode(minhi) );
                        buf.add( '[' + printCode(minlo) + '-' + printCode(maxlo) + ']');

                    } else {
                        buf.add( printCode(range.min) + '-' + printCode(range.max) );

                    }*/
                    /*handle(range.min, range.max);

            }*/
            if (!NodeJS && range.min >= 0x10000) {
                var minhi = ((range.min - 0x10000) >> 10) | 0xD800;
                var minlo = ((range.min - 0x10000) & 0x3FF) | 0xDC00;
                var maxhi = ((range.max - 0x10000) >> 10) | 0xD800;
                var maxlo = ((range.max - 0x10000) & 0x3FF) | 0xDC00;

                var high = printCode(minhi);
                if (high != label) {
                    if (open != null && !open) {
                        buf.add(']');
                        open = null;
                    }
                    buf.add( '|'/* + printCode(minhi)*/ );
                    buf.add( high );
                    
                }
                //buf.add( '[' + printCode(minlo) + '-' + printCode(maxlo) + ']');

                switch range.length {
                    case 0: 
                        //buf.add( high );
                        buf.add( printCode(minlo) );

                    case 1:
                        //buf.add( high );
                        buf.add( printCode(minlo) );
                        buf.add( printCode(maxlo) );

                    case _:
                        //buf.add( high );
                        if (label != high) buf.add('[');
                        /*if (minlo == 57152) {
                            trace(printCode(range.min), printCode(range.max));
                            trace(range.min, range.max, range.length, high );
                            trace( minlo, minhi, maxlo, maxhi );
                            trace( printCode(minlo), printCode(minhi), printCode(maxlo), printCode(maxhi));
                        }*/
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
            open = null;
        }

        return buf.toString();
    }

    private static function hexToInt(c:String):Int {
        var i = "0123456789abcdef".indexOf(c.toLowerCase());
        if (i == -1) {
            throw Unicode_InvalidEscape;
        } else {
            return i;
        }
    }
    #end
}
