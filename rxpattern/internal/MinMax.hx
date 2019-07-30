package rxpattern.internal;

#if (eval || macro)
import rxpattern.internal.Target;
#end

class MinMax {

    public static var MIN:Int = 
    #if (interp || eval || macro) 
        if (Interp || Neko || HashLink || Php) {
            1;
        } else {
            unifill.Unicode.minCodePoint;
        }
    #elseif (neko || hl || php)
        1
    #else
        unifill.Unicode.minCodePoint
    #end
    ;

    public static var MAX:Int = unifill.Unicode.maxCodePoint;

}