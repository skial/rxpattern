package rxpattern.internal;

@:forward
enum abstract Escape(String) to String {
    public var Start = 
    #if ((js && nodejs) || (js && js_es > 5))
        '\\u{'
    #elseif (cs || js || python)
        '\\u'
    #else 
        '\\x{'
    #end;

    public var End = 
    #if ((js && nodejs) || (js && js_es > 5))
        '}'
    #else 
        ''
    #end;
}