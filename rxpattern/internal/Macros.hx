package rxpattern.internal;

import haxe.macro.Expr;
import haxe.macro.Context;
import rxpattern.RxPattern;
import rxpattern.unicode.*;

using tink.MacroApi;

class Macros {

    // RxPattern macros

    public static function _toStatic(pat: RxPattern, pos: Position):Expr @:privateAccess {
        var e = {pos: pos, expr: ExprDef.EConst(Constant.CString(pat.get()))};

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
        var useSurrogates = Context.defined('js') || Context.defined('cs');
        
        switch x.expr {
            case EConst(CString(v)):
                
                if (v.length == 0) {
                    Context.error("rxpattern.RxPattern.Char: not a single character", pos);
                    return null;
                }

                var y = CodePoint.codePointAt(v, 0);
                
                if (CodePoint.fromCodePoint(y) != v) {
                    Context.error("rxpattern.RxPattern.Char: not a single character", pos);
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
        switch s.expr {
            case EConst(CString(v)):
                try {
                    var cs = RxPattern.CharSet(CharSet.fromStringD(v));
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

    public static function _NotInSetLit(s:ExprOf<String>):Null<Expr> {
        var pos = s.pos;
        switch s.expr {
            case EConst(CString(v)):
                try {
                    var cs = RxPattern.NotInSet(CharSet.fromStringD(v));
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
                    var expr = {pos: pos, expr: EConst(CString(escaped)) };
                    var useSurrogates = Context.defined('js') || Context.defined('cs');
                    if (v.length == 0) {
                        return macro new rxpattern.RxPattern.Alternative($expr);
                    }

                    var y = CodePoint.codePointAt(v, 0);
                    var isSingleCodePoint = CodePoint.fromCodePoint(y) == v;
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
                    var set = IntSet.fromIterator(cast CodePoint.codePointIterator(s)).iterator();
                    var elements = [for (c in set) {
                        macro $v{c};
                    }];
                    var r = macro new rxpattern.CharSet(new rxpattern.IntSet([$a{elements}]));
                    //trace( r.toString() );
                    return r;

                } catch (e:Any) {
                    Context.error(e, pos);
                    return null;

                }

            case _:

        }

        return macro rxpattern.CharSet.fromStringD($x);
    }

}