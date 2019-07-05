package rxpattern;

import unifill.*;
import rxpattern.IntSet;
import rxpattern.RxErrors;
import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;

@:forward
abstract CharSet2(Ranges) from Ranges to Ranges {
    
    public inline function new(s:Ranges) this = s;
    
    public static inline function empty():CharSet2 {
        return new CharSet2( new Ranges([]) );
    }

    public static inline function singleton(c:String) {
        return new CharSet2( new Ranges( [singleCodePoint(c)] ) );
    }

    @:from

    public static inline function fromStringD(s:String) {
        var rs = new Ranges([]);
        for (i in new CodePointIter(s)) 
            if (!rs.has(i.toInt())) rs.insert(i.toInt());
        
        var c = new CharSet2(rs);
        return c;
    }

    macro public static function fromString(x:ExprOf<String>) {
        return rxpattern.internal.Macros._fromString(x);
    }

    public inline function getCodePointSet()
        return this;

    public inline function hasCodePoint(x:Int)
        return this.has(x);

    public inline function has(c:String)
        return this.has(singleCodePoint(c));

    public inline function add(c:String)
        this.add(singleCodePoint(c));

    public inline function removeCodePoint(x:Int)
        this.remove(x);

    public inline function remove(c:String)
        this.remove(singleCodePoint(c));

    public inline function codePointIterator():Iterator<Int>
        return this.iterator();

    /*@:extern
    public static inline function intersection(a: CharSet, b: CharSet)
        return new CharSet(IntSet.intersection(a.getCodePointSet(), b.getCodePointSet()));*/

    /*@:extern
    public static inline function union(a: CharSet, b: CharSet)
        return new CharSet(IntSet.union(a.getCodePointSet(), b.getCodePointSet()));*/

    /*@:extern
    public static inline function difference(a: CharSet, b: CharSet)
        return new CharSet(IntSet.difference(a.getCodePointSet(), b.getCodePointSet()));*/

    #if !(eval || macro)
        private static var rxSingleCodePoint =
            #if ((!nodejs && js) || cs || hl)
                ~/^(?:[\u0000-\uD7FF\uE000-\uFFFF]|[\uD800-\uDBFF][\uDC00-\uDFFF])$/;
            #else
                ~/^.$/us;
            #end
    #end
    private static function singleCodePoint(s: String): Int
    {
        #if (eval || macro)
            if (s.length == 0) {
                throw CharSet_NotCodePoint;
            }
            var x = InternalEncoding.codePointAt(s, 0);
            if (CodePoint.fromInt(x) != s) {
                throw CharSet_NotCodePoint;
            }
        #else
            if (!rxSingleCodePoint.match(s)) {
                throw CharSet_NotCodePoint;
            }
        #end
        return InternalEncoding.codePointAt(s, 0);
    }
}
