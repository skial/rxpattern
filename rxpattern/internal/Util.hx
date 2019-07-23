package rxpattern.internal;

/*#if (macro || eval)
import haxe.macro.Context;
import rxpattern.internal.Target;
#end
import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;

using rxpattern.internal.Util;

/*class Util {

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

    #if (eval || macro)
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
            
            case x if (isValidAscii(x)):
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
                (JavaScript && 
                Context.defined('js-es') && 
                Std.parseInt(Context.definedValue('js-es')) > 5) || 
                NodeJS) {
            // Haxe only supports es5 or greater.
            // ES6/ES2015 introduced `u` flag & `\u{0123}` format.
            '\\u{' + hex + '}';

        } else {
            '\\u' + hex;

        }
    }

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
    #elseif (neko || cpp || php || lua || java)
    public static inline function printCode(v:Int):String {
        if (isValidAscii(v)) {
            return String.fromCharCode(v);
        }
        return '\\x{' + StringTools.hex(v, 0) + '}';
    }
    #elseif python
    public static function printCode(v:Int):String {
        if (isValidAscii(v)) {
            return String.fromCharCode(v);
        }
        var hex = StringTools.hex(v, (v >= 0x10000) ? 8 : 4);
        return if (v >= 0x10000) {
            '\\U' + hex;

        } else {
            '\\u' + hex;

        }
    }
    #elseif (js || cs || hl || flash)
    public static function printCode(v:Int):String {
        switch v {
            #if (!nodejs && js)
            case 0:
                return js.Syntax.code("\"\\0\"");
            #end

            case _.isValidAscii() => true:
                return String.fromCharCode(v);

            case _:

        }
        return 
        #if (nodejs || (js && js_es > 5))
            // Haxe only supports es5 or greater.
            // ES6/ES2015 introduced `u` flag & `\u{0123}` format.
            '\\u{' + StringTools.hex(v, 4) + '}';
        #else
            '\\u' + StringTools.hex(v, 4);
        #end
    }
    #end
    
    #if !(eval || macro)
    public static function printRanges(ranges:Ranges):RxPattern {
        #if (cs || js && !nodejs)
        ranges = ranges.copy();
        #end
        var label = 0;
        var buf = new StringBuf();
        var open:Null<Bool> = true;
        var includeHighSurrogates = true;

        #if (cs || js && !nodejs)
        var hi = new Range(0xD800, 0xDBFF);
        var lo = new Range(0xDC00, 0xDFFF);
        var surrogate = new Range(hi.min, lo.max);
        #end

        var idx = 0;
        var len = ranges.values.length - 1;
        var range = null;
        var patterns:Array<RxPattern> = [];

        while (idx <= len) {
            range = ranges.values[idx];

            #if (cs || js && !nodejs)
            if (surrogate.min > range.min && surrogate.max < range.max) {
                var left = new Range(range.min, surrogate.min-1);
                var right = new Range(surrogate.max+1, range.max);
                ranges.values[idx] = left;
                ranges.values.insert( idx + 1, right );

                patterns.push( 
                    RxPattern.CharSet( new Ranges([hi.copy()]) ) 
                    >> RxPattern.NotFollowedBy( 
                        RxPattern.CharSet( new Ranges([lo.copy()]) ) 
                    )
                );
                patterns.push( 
                    RxPattern.Atom( 
                        '(?:[^' + printCode(hi.min) + '-' + printCode(hi.max) + ']|^)'
                    ) >> RxPattern.CharSet( new Ranges([lo.copy()]) ) 
                );

                len = ranges.values.length - 1;
                range = left;
            }
            #end

            if (open != null && open) {
                #if (cs || js && !nodejs)
                if (range.min >= 0xDC00 && range.max <= 0xDFFF) {
                    buf.add('(?:[^' + printCode(0xD800) + '-' + printCode(0xDBFF) + ']|^)');
                }
                #end
                buf.add('[');
                open = false;
            }

            if (range.min >= 0x10000) {
                includeHighSurrogates = false;
                var minhi = ((range.min - 0x10000) >> 10) | 0xD800;
                var minlo = ((range.min - 0x10000) & 0x3FF) | 0xDC00;
                var maxhi = ((range.max - 0x10000) >> 10) | 0xD800;
                var maxlo = ((range.max - 0x10000) & 0x3FF) | 0xDC00;

                var high = minhi;
                if (high != label) {
                    if (open != null && !open) {
                        buf.add(']');
                        #if (cs || js && !nodejs)
                        if (patterns.length > 0) {
                            for (pattern in patterns) {
                                buf.add( '|' );
                                buf.add(pattern.get());
                            }
                            patterns = [];
                        }
                        #end
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
                label = range.min;
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

            idx++;
        }

        if (open != null && !open) {
            buf.add(']');
            #if (cs || js && !nodejs)
            if (patterns.length > 0) {
                for (pattern in patterns) {
                    buf.add( '|' );
                    buf.add(pattern.get());
                }
            }
            #end
            if (includeHighSurrogates && label >= 0xD800 && label <= 0xDBFF) {
                buf.add('(?![' + printCode(0xDC00) + '-' + printCode(0xDFFF) + '])');
            }
            open = null;
        }

        return RxPattern.Atom(buf.toString());
    }
    #end
}*/

typedef Util = 
#if (eval || macro)
    rxpattern.internal.eval.Util
#elseif (!nodejs && js || cs) 
    rxpattern.internal.utf16.Util
#elseif python
    rxpattern.internal.python.Util
#else
    rxpattern.internal.std.Util
#end;