package rxpattern.internal.eval;

import haxe.macro.Context;
import rxpattern.internal.Define;

class CodeUtil {

    #if (eval || macro)
    public static function __init__() {
        trace( Context.getDefines() );
        trace( ES_, ES_.defined(), ES_.value() );
        trace( NodeJS, NodeJS.defined() );
    }
    #end

    public static function printCode(v:Int):String {
        return if (JavaScript) {
            rxpattern.internal.js.CodeUtil.printCode(v);

        } else if (Python) {
            rxpattern.internal.python.CodeUtil.printCode(v);

        } else if (HashLink) {
            rxpattern.internal.hl.CodeUtil.printCode(v);

        } else if (Java) {
            rxpattern.internal.java.CodeUtil.printCode(v);

        } else {
            rxpattern.internal.std.CodeUtil.printCode(v);

        }
    }

}