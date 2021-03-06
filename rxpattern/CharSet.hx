package rxpattern;

import unifill.*;
import rxpattern.RxErrors;
import uhx.sys.seri.Ranges;

@:forward
abstract CharSet(Ranges) from Ranges to Ranges {
    
    public inline function new(s:Ranges) this = s;
    
    public static inline function empty():CharSet {
        return new CharSet( new Ranges([]) );
    }

    public static inline function singleton(c:String) {
        return new CharSet( new Ranges( [singleCodePoint(c)] ) );
    }

    @:from public static inline function fromStringD(s:String) {
        var rs = new Ranges([]);
        for (i in new CodePointIter(s)) {
            if (!rs.has(i.toInt())) rs.add(i.toInt());
        }
        var c = new CharSet(rs);
        return c;
    }

    public static macro function fromString(x:ExprOf<String>) {
        return rxpattern.internal.Macros._fromString(x);
    }

    public inline function getCodePointSet(){
        return this;
    }

    public inline function hasCodePoint(x:Int){
        return this.has(x);
    }

    public inline function has(c:String){
        return this.has(singleCodePoint(c));
    }

    public inline function add(c:String) {
        this.add(singleCodePoint(c));
    }

    public inline function removeCodePoint(x:Int) {
        this.remove(x);
    }

    public inline function remove(c:String) {
        this.remove(singleCodePoint(c));
    }

    public inline function codePointIterator():Iterator<Int> {
        return this.iterator();
    }

    private static function singleCodePoint(s:String):Int {
        #if (eval || macro)
            if (s.length == 0) {
                throw CharSet_NotCodePoint;
            }
            var x = InternalEncoding.codePointAt(s, 0);
            if (CodePoint.fromInt(x) != s) {
                throw CharSet_NotCodePoint;
            }
        #else
            if (!@:privateAccess RxPattern.rxSingleCodePoint.match(s)) {
                throw CharSet_NotCodePoint;
            }
        #end
        return InternalEncoding.codePointAt(s, 0);
    }

    @:to public inline function asRxPattern():RxPattern {
        return rxpattern.internal.RangeUtil.printRanges(this, false);
    }
}
