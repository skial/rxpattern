package rxpattern;

import rxpattern.internal.Util.*;

#if (js || cs || hl || flash) 
                
            #elseif python

            #else

            #end

@:asserts class PrintCodeSpec {

    public function new() {}

    public function printCodes() {
        asserts.assert( printCode('a'.code) == 'a' );
        asserts.assert( printCode('@'.code) == '@' );
        asserts.assert( printCode(0x75) == 'u' );
        asserts.assert( 
            printCode(0xD7FF) ==
            #if (js || cs || hl || flash) 
                #if (nodejs || js && js_es > 5) 
                    '\\u{D7FF}'
                #else
                    '\\uD7FF'
                #end
            #elseif python
                '\\uD7FF'
            #else
                '\\x{D7FF}'
            #end
        );
        asserts.assert( 
            printCode(0x10FFFF) ==
            #if (js || cs || hl || flash) 
                #if (nodejs || js && js_es > 5) 
                    '\\u{10FFFF}'
                #else
                    '\\u10FFFF'
                #end
            #elseif python
                '\\U0010FFFF'
            #else
                '\\x{10FFFF}'
            #end
        );
        return asserts.done();
    }

}