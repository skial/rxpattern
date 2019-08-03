package rxpattern;

import rxpattern.internal.CodeUtil.*;
import rxpattern.internal.RangeUtil.*;

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
            #if (js || cs || flash) 
                '\\uD7FF'
            #elseif python
                '\\uD7FF'
            #elseif (hl || java)
                '\u{D7FF}'
            #else
                '\\x{D7FF}'
            #end
        );
        asserts.assert( 
            printCode(0x10FFFF) ==
            #if (js || cs || flash) 
                #if (nodejs || js && js_es > 5) 
                    '\\u{10FFFF}'
                #else
                    '\\u10FFFF'
                #end
            #elseif python
                '\\U0010FFFF'
            #elseif (hl || java)
                '\u{10FFFF}'
            #else
                '\\x{10FFFF}'
            #end
        );
        return asserts.done();
    }

}