package rxpattern.internal;

typedef Util = 
#if (interp || eval || macro)
    rxpattern.internal.eval.Util
#elseif (js || cs) 
    #if !nodejs
        rxpattern.internal.utf16.Util
    #else
        rxpattern.internal.js.Util
    #end
#elseif python
    rxpattern.internal.python.Util
#elseif hl
    rxpattern.internal.hl.Util
#else
    rxpattern.internal.std.Util
#end
;