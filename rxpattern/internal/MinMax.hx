package rxpattern.internal;

#if (eval || macro)
import rxpattern.internal.Target;
#end

class MinMax {

    public static var MIN:Int = 
    #if (eval || macro) 
        if (Target.Neko) {
            1;
        } else {
            unifill.Unicode.minCodePoint;
        }
    #elseif neko
        1
    #else
        unifill.Unicode.minCodePoint;
    #end
    ;

    public static var MAX:Int = unifill.Unicode.maxCodePoint;

}