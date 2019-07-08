package rxpattern.internal;

import unifill.*;
import haxe.macro.Expr;
import haxe.macro.Context;
import rxpattern.RxErrors;
import rxpattern.RxPattern;
import uhx.sys.seri.Ranges;
import rxpattern.internal.Target;
import rxpattern.internal.MinMax.*;

using tink.MacroApi;

class Macros {

    // RxPattern macros

    public static function _toStatic(pat: RxPattern, pos: Position):Expr @:privateAccess {
        trace( pat.get() );
        var e = macro @:pos(pos) $v{pat.get()};
        trace( e.toString() );
        return switch pat.getPrec() {
            case Precedence.Disjunction:
                macro new rxpattern.RxPattern.Disjunction($e);
            case Precedence.Alternative:
                macro new rxpattern.RxPattern.Alternative($e);
            case Precedence.Term:
                macro new rxpattern.RxPattern.Term($e);
            case Precedence.Atom:
                macro new rxpattern.RxPattern.Atom($e);
        }
    }

    public static function _Char(x:ExprOf<String>):Null<Expr> {
        var pos = x.pos;
        var useSurrogates = (!NodeJS && JavaScript) || CSharp;
        
        switch x.expr {
            case EConst(CString(v)):
                if (v.length == 0) {
                    Context.error(Char_NotSingleCharacter, pos);
                    return null;
                }

                var y = InternalEncoding.codePointAt(v, 0);
                
                if (CodePoint.fromInt(y) != v) {
                    Context.error(Char_NotSingleCharacter, pos);
                    return null;
                }
                
                if (useSurrogates && y >= 0x10000) {
                    var expr = macro @:pos(pos) $v{v};
                    return macro new rxpattern.RxPattern.Alternative($expr);
                } else {
                    var s = RxPattern.escapeChar(v);
                    var expr = macro @:pos(pos) $v{s};
                    return macro new rxpattern.RxPattern.Atom($expr);
                }

            case _:

        }

        return if (useSurrogates) {
            macro rxpattern.RxPattern.CharS($x);
        } else {
            macro new rxpattern.RxPattern.Atom(rxpattern.RxPattern.escapeChar($x));
        }
    }

    public static function _CharSetLit(s:ExprOf<String>):Null<ExprOf<RxPattern>> {
        var pos = s.pos;
        trace( s.toString() );
        switch s.expr {
            case EConst(CString(v)):
                try {
                    var cs = RxPattern.CharSet(CharSet2.fromStringD(v));
                    var ex = _toStatic(cs, pos);
                    trace( ex.toString() );
                    return ex;

                } catch (e:Any) {
                    Context.error(e, pos);
                    return null;
                }

            case _:

        }

        return null;
    }

    public static function _NotInSetLit(s:ExprOf<String>):Null<Expr> {
        var pos = s.pos;
        switch s.expr {
            case EConst(CString(v)):
                try {
                    var charset = CharSet2.fromStringD(v);
                    var invert = Ranges.complement(charset);
                    //var cs = RxPattern.NotInSet(charset);
                    var cs = RxPattern.CharSet(invert.clamp(MIN, MAX));
                    var ex = _toStatic(cs, pos);
                    return ex;

                } catch (e:Any) {
                    Context.error(e, pos);
                    return null;
                }

            case _:
        }

        return null;
    }

    public static function _String(x:ExprOf<String>):Null<ExprOf<RxPattern>> {
        var pos = x.pos;

        switch x.expr {
            case EConst(CString(v)):
                try {
                    var escaped = RxPattern.escapeString(v);
                    var expr = macro @:pos(pos) $v{escaped};
                    var useSurrogates = (!NodeJS && JavaScript) || CSharp;
                    if (v.length == 0) {
                        return macro new rxpattern.RxPattern.Alternative($expr);
                    }

                    var y = InternalEncoding.codePointAt(v, 0);
                    var isSingleCodePoint = CodePoint.fromInt(y) == v;
                    if (isSingleCodePoint && (y < 0x10000 || !useSurrogates)) {
                        // Single character (or single code unit on JS and C#)
                        return macro new rxpattern.RxPattern.Atom($expr);
                    } else {
                        return macro new rxpattern.RxPattern.Alternative($expr);
                    }

                } catch (e:Any) {
                    Context.error(e, pos);
                    return null;
                }

            case _:
                

        }

        return return macro new rxpattern.RxPattern.Alternative(rxpattern.RxPattern.escapeString($x));
    }

    // CharSet macros

    public static function _fromString(x:ExprOf<String>) {
        var pos = x.pos;

        switch x.expr {
            case EConst(CString(s)):
                try {
                    var set = IntSet.fromCodePointIterator(new CodePointIter(s)).iterator();
                    var elements = [for (c in set) {
                        macro $v{c};
                    }];
                    //var r = macro new rxpattern.CharSet(new rxpattern.IntSet([$a{elements}]));
                    var r = macro new rxpattern.CharSet2(new uhx.sys.seri.Ranges([$a{elements}]));
                    return r;

                } catch (e:Any) {
                    Context.error(e, pos);
                    return null;

                }

            case _:

        }

        return macro rxpattern.CharSet2.fromStringD($x);
    }

}