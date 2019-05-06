package rxpattern.unicode;

import unifill.CodePointIter;
import unifill.CodePoint as UCP;
import unifill.InternalEncoding;

abstract CodePoint(Int) {

    public static inline function fromCodePoint(v:Int):String {
        return UCP.fromInt(v);
    }

    public static inline function codePointAt(v:String, i:Int):UCP {
        return InternalEncoding.codePointAt(v, i);
    }

    public static inline function codePointIterator(v:String):Iterator<UCP> {
        return new CodePointIter(v);
    }

}