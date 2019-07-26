package rxpattern;

import rxpattern.Category;
import rxpattern.RxPattern;

@:asserts class CategorySpec {

    public function new() {}

    public function test4() {
        var wordStart = Category.L | RxPattern.Char("_");
        var wordChar = wordStart | Category.N;
        var word = wordStart >> wordChar.many();
        var pattern4 = RxPattern.AtStart >> word >> RxPattern.AtEnd;
        
        var rx4 = pattern4.build();
        
        asserts.assert(rx4.match("function"));
        asserts.assert(rx4.match("int32_t"));
        asserts.assert(rx4.match("\u3042"));
        asserts.assert(!rx4.match("24hours"));

        return asserts.done();
    }

}