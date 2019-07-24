package rxpattern;

import rxpattern.RxPattern;

@:asserts class CategorySpec {

    public function new() {}

    public function test4() {
        //trace( GeneralCategory.Letter );
        //trace( rxpattern.UnicodePatternUtil.printCategory('L') );
        var categoryL = rxpattern.UnicodePatternUtil.printCategory('L');
        //trace( categoryL );
        var wordStart = /*GeneralCategory.Letter*/categoryL | RxPattern.Char("_");
        var categoryN = rxpattern.UnicodePatternUtil.printCategory('N');
        /*trace( GeneralCategory.Number );
        trace( categoryN );*/
        var wordChar = wordStart | categoryN/*GeneralCategory.Number*/;
        var word = wordStart >> wordChar.many();
        var pattern4 = RxPattern.AtStart >> word >> RxPattern.AtEnd;
        //trace( pattern4.get() );
        //trace( pattern4 );
        var rx4 = pattern4.build();
        //trace( rx4 );
        asserts.assert(rx4.match("function"));
        asserts.assert(rx4.match("int32_t"));
        asserts.assert(rx4.match("\u3042"));
        asserts.assert(!rx4.match("24hours"));
        return asserts.done();
    }

}