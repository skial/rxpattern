package rxpattern;

#if (eval || macro)
import haxe.macro.Expr;
import haxe.macro.Context;
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
    macro public static function translateUnicodeEscape(s: String)
    {
        var pos = Context.currentPos();
        var pythonStyle = Python.defined(); // \uHHHH or \UHHHHHHHH
        var perlStyle = Neko || Cpp || Php || Lua || Java; // \x{HHHH}
        var jsStyle = JavaScript || CSharp || Flash || HashLink; // \uHHHH
        var onlyBMP = JavaScript || CSharp;
        function codeprint(v:Int) {
            var hex = StringTools.hex(v, (perlStyle) ? 0 : (pythonStyle && v > 0x10000) ? 8 : 4);
            return if (perlStyle) {
                '\\x{$hex}';

            } else if (pythonStyle && v > 0x10000) {
                '\\U$hex';
            } else {
                '\\u$hex';
            }
        }
        var i = 0;
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
                    Context.error("Invalid unicode escape sequence", pos);
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
                translatedBuf.add(codeprint(value));
            } else {
                if (value > 0x10000) {
                    if (pythonStyle) {
                        translatedBuf.add(codeprint(value));
                    } else if (jsStyle || !onlyBMP) {
                        var hi = ((value - 0x10000) >> 10) | 0xD800;
                        var lo = ((value - 0x10000) & 0x3FF) | 0xDC00;
                        translatedBuf.add(codeprint(hi) + codeprint(lo));
                    } else {
                        Context.error("This platform does not support Unicode escape beyond BMP.", pos);
                        return null;
                    }
                } else {
                    translatedBuf.add(codeprint(value));
                }
            }
        }
        translatedBuf.add(s.substr(i));
        var r = translatedBuf.toString();
        
        return {pos: pos, expr: ExprDef.EConst(Constant.CString(r))};
    }

    #if (eval || macro)
        private static function hexToInt(c: String)
        {
            var i = "0123456789abcdef".indexOf(c.toLowerCase());
            if (i == -1) {
                throw "Invalid unicode escape";
            } else {
                return i;
            }
        }
    #end
}
