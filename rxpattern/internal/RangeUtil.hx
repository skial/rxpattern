package rxpattern.internal;

typedef RangeUtil = 
#if (interp || eval || macro)
    rxpattern.internal.eval.RangeUtil
#elseif (js || cs) 
    #if ((js && nodejs) || (js && js_es > 5))
        rxpattern.internal.js.RangeUtil
    #else
        rxpattern.internal.utf16.RangeUtil
    #end
#elseif python
    rxpattern.internal.python.RangeUtil
#elseif hl
    rxpattern.internal.hl.RangeUtil
#else
    rxpattern.internal.std.RangeUtil
#end
;