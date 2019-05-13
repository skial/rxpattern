package rxpattern;

#if (eval || macro)
import haxe.macro.Expr;
import haxe.macro.Context;
#end

import rxpattern.IntSet;
import unifill.CodePoint;
import unifill.CodePointIter;
import unifill.InternalEncoding;

@:forward(length, iterator)
abstract CharSet(IntSet) from IntSet
{
    @:extern
    public inline function new(s : IntSet)
        this = s;

    @:extern
    public static inline function empty()
        return new CharSet(IntSet.empty());

    @:extern
    public static inline function singleton(c: String)
        return new CharSet(IntSet.singleton(singleCodePoint(c)));

    @:from
    @:extern
    public static inline function fromStringD(s: String)
        return new CharSet(IntSet.fromCodePointIterator(new CodePointIter(s)));

    macro public static function fromString(x:ExprOf<String>) {
        return rxpattern.internal.Macros._fromString(x);
    }

    @:extern
    public inline function getCodePointSet()
        return this;

    @:extern
    public inline function hasCodePoint(x: Int)
        return this.has(x);

    @:extern
    public inline function has(c: String)
        return this.has(singleCodePoint(c));

    @:extern
    public inline function addCodePoint(x: Int)
        this.add(x);

    @:extern
    public inline function add(c: String)
        this.add(singleCodePoint(c));

    @:extern
    public inline function removeCodePoint(x: Int)
        this.remove(x);

    @:extern
    public inline function remove(c: String)
        this.remove(singleCodePoint(c));

    @:extern
    public inline function codePointIterator():Iterator<Int>
        return this.iterator();

    @:extern
    public static inline function intersection(a: CharSet, b: CharSet)
        return new CharSet(IntSet.intersection(a.getCodePointSet(), b.getCodePointSet()));

    @:extern
    public static inline function union(a: CharSet, b: CharSet)
        return new CharSet(IntSet.union(a.getCodePointSet(), b.getCodePointSet()));

    @:extern
    public static inline function difference(a: CharSet, b: CharSet)
        return new CharSet(IntSet.difference(a.getCodePointSet(), b.getCodePointSet()));

    #if !(eval || macro)
        private static var rxSingleCodePoint =
            #if (js || cs || hl)
                ~/^(?:[\u0000-\uD7FF\uE000-\uFFFF]|[\uD800-\uDBFF][\uDC00-\uDFFF])$/;
            #else
                ~/^.$/us;
            #end
    #end
    private static function singleCodePoint(s: String): Int
    {
        #if (eval || macro)
            if (s.length == 0) {
                throw "rxpattern.CharSet: not a single code point";
            }
            var x = InternalEncoding.codePointAt(s, 0);
            if (CodePoint.fromInt(x) != s) {
                throw "rxpattern.CharSet: not a single code point";
            }
        #else
            if (!rxSingleCodePoint.match(s)) {
                throw "rxpattern.CharSet: not a single code point";
            }
        #end
        return InternalEncoding.codePointAt(s, 0);
    }
}
