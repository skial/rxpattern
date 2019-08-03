package rxpattern.internal;

typedef CodeUtil = 
#if (interp || eval || macro)
    rxpattern.internal.eval.CodeUtil
#elseif js
    rxpattern.internal.js.CodeUtil
#elseif python
    rxpattern.internal.python.CodeUtil
#elseif hl
    rxpattern.internal.hl.CodeUtil
#elseif java
    rxpattern.internal.java.CodeUtil
#else
    rxpattern.internal.std.CodeUtil
#end
;