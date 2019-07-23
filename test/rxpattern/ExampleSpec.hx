package rxpattern;

import rxpattern.internal.EReg;

@:asserts class ExampleSpec {

    public function new() {}

    public function test1() {
        var pattern1 = (RxPattern.Char("a") | RxPattern.Char("b")).many();
        var rx1 : EReg = pattern1.build();
        asserts.assert( rx1.match("abaab") );
        return asserts.done();
    }

    public function test2() {
        var pattern2 = RxPattern.String("gr")
                       >> (RxPattern.Char("a") | RxPattern.Char("e"))
                       >> RxPattern.String("y");
        var rx2 = pattern2.build();
        asserts.assert(rx2.match("grey"));
        asserts.assert(rx2.match("gray"));
        return asserts.done();
    }

    public function test3() {
        var pattern3 = RxPattern.AtStart
                       >> RxPattern.String("colo")
                       >> RxPattern.Char("u").option()
                       >> RxPattern.String("r")
                       >> RxPattern.AtEnd;
        
        var rx3 = pattern3.build();
        asserts.assert(rx3.match("color"));
        asserts.assert(rx3.match("colour"));
        asserts.assert(!rx3.match("color\n"));
        asserts.assert(!rx3.match("\ncolour"));
        return asserts.done();
    }

}