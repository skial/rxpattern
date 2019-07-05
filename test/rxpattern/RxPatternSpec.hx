package rxpattern;

import unifill.Unifill;
import tink.unit.AssertionBuffer;
import rxpattern.RxPattern.Disjunction;

using rxpattern.RxPatternSpec;

@:asserts class RxPatternSpec {

    public function new() {}

    public static inline function pattern(a:AssertionBuffer, s:String, p:RxPattern, ?pos:haxe.PosInfos):Void {
        a.assert( s == RxPattern.getPattern(p), '`${RxPattern.getPattern(p)}` == $s', pos );
    }

    public static inline function matches(a:AssertionBuffer, s:String, p:Disjunction, ?pos:haxe.PosInfos):Void {
        a.assert( RxPattern.buildEReg(p).match(s), '`RxPattern.buildEReg(p)` == ${RxPattern.buildEReg(p)} `.match(s)` == ${unifill.Unifill.uCharCodeAt(s, 0)}', pos );
    }

    public static inline function notMatches(a:AssertionBuffer, s:String, p:Disjunction, ?pos:haxe.PosInfos):Void {
        a.assert( !RxPattern.buildEReg(p).match(s), '`!RxPattern.buildEReg(p)` == ${RxPattern.buildEReg(p)} `.match(s)` == ${unifill.Unifill.uCharCodeAt(s, 0)}', pos );
    }

    public function testBasic() {
        asserts.pattern("a|xyz\\^\\\\", RxPattern.Char("a") | RxPattern.String("xyz^\\"));
        asserts.matches("a", RxPattern.Char("a") | RxPattern.String("xyz^\\"));
        asserts.matches("xyz^\\", RxPattern.Char("a") | RxPattern.String("xyz^\\"));
        asserts.pattern("[a-c]*|xyz", RxPattern.CharSet("abc").many() | RxPattern.String("xyz"));
        asserts.pattern("[a-c]*|(?:xyz)+", RxPattern.CharSet("abc").many() | RxPattern.String("xyz").many1());
        asserts.pattern("[a-c]*|(?:xyz)+", RxPattern.CharSetLit("abc").many() | RxPattern.String("xyz").many1());
        asserts.pattern("[a-c]?", RxPattern.CharSet("abc").option());
        return asserts.done();
    }

    public function testAny() {
        asserts.matches("A", RxPattern.AtStart >> RxPattern.AnyCodePoint >> RxPattern.AtEnd);
        asserts.matches("A", RxPattern.AtStart >> RxPattern.AnyExceptNewLine >> RxPattern.AtEnd);
        asserts.matches("x\ny", RxPattern.Char("x") >> RxPattern.AnyCodePoint >> RxPattern.Char("y"));
        asserts.notMatches("x\ny", RxPattern.Char("x") >> RxPattern.AnyExceptNewLine >> RxPattern.Char("y"));
        asserts.notMatches("\n", RxPattern.AtStart >> RxPattern.AnyExceptNewLine >> RxPattern.AtEnd);
        return asserts.done();
    }

    public function testAssertion() {
        asserts.notMatches("A\n", RxPattern.Char("A") >> RxPattern.AtEnd);
        asserts.notMatches("A\nB\n", RxPattern.AtStart >> RxPattern.Char("B"));
        return asserts.done();
    }

    public function testBasic2() {
        asserts.pattern("a|b", RxPattern.Char("a") | RxPattern.Char("b"));
        asserts.pattern("(a|b)c", RxPattern.Group(RxPattern.Char("a") | RxPattern.Char("b")) >> RxPattern.Char("c"));
        asserts.pattern("(?:a|b)c", (RxPattern.Char("a") | RxPattern.Char("b")) >> RxPattern.Char("c"));
        asserts.pattern("(?:ab)*", (RxPattern.Char("a") >> RxPattern.Char("b")).many());
        asserts.pattern("(?:ab)+", (RxPattern.Char("a") >> RxPattern.Char("b")).many1());
        return asserts.done();
    }

    public function testNever() {
        asserts.notMatches("abc", RxPattern.Never);
        asserts.notMatches("abc", RxPattern.String("abc") >> RxPattern.Never);
        asserts.matches("abc", RxPattern.Never | RxPattern.String("abc"));
        return asserts.done();
    }

    private function str(s:String) return s;

    public function testEscape() {
        asserts.pattern("a", RxPattern.Char("a"));
        asserts.pattern("a", RxPattern.Char(str("a")));
        asserts.matches("\\", RxPattern.Char("\\"));
        asserts.pattern("\\^", RxPattern.Char("^"));
        asserts.matches("[^xyz]\\A", RxPattern.String("[^xyz]\\A"));
        asserts.matches("aaa[^xyz]\\A", RxPattern.String("[^xyz]\\A"));
        asserts.notMatches("aaa[^xyz]\\A", RxPattern.AtStart >> RxPattern.String("[^xyz]\\A"));
        asserts.matches("[^xyz]\\A", RxPattern.String(str("[^xyz]\\A")));
        asserts.matches("\u{12345}", RxPattern.Char("\u{12345}"));
        asserts.matches("\u{12345}", RxPattern.Char(str("\u{12345}")));
        return asserts.done();
    }

    public function testUnicode() {
        asserts.matches("\u{10000}", RxPattern.Char("\u{10000}"));
        asserts.matches("\u{10000}", RxPattern.Char(str("\u{10000}")));
        asserts.matches("\u{10000}\u{10FFFF}", RxPattern.String("\u{10000}\u{10FFFF}"));
        asserts.matches("\u{10000}\u{10FFFF}", RxPattern.String(str("\u{10000}\u{10FFFF}")));
        asserts.matches("x\u{10000}y", RxPattern.Char("x") >> RxPattern.AnyExceptNewLine >> RxPattern.Char("y"));
        asserts.notMatches("x\u{10000}y", RxPattern.Char("x") >> RxPattern.AnyExceptNewLine >> RxPattern.AnyExceptNewLine >> RxPattern.Char("y"));
        asserts.matches("x\u{10000}y", RxPattern.Char("x") >> RxPattern.AnyCodePoint >> RxPattern.Char("y"));
        asserts.matches("\u{12345}", RxPattern.AtStart >> RxPattern.AnyCodePoint >> RxPattern.AtEnd);
        asserts.matches("\u{12345}", RxPattern.AtStart >> RxPattern.AnyExceptNewLine >> RxPattern.AtEnd);
        return asserts.done();
    }

    public function testSet() {
        asserts.pattern("[ehlo]", RxPattern.CharSet(CharSet.fromString("hello")));

        var p = RxPattern.NotInSet(CharSet.fromString("hello"));
        asserts.notMatches("h", p);
        asserts.notMatches("e", p);
        asserts.notMatches("l", p);
        asserts.notMatches("o", p);
        asserts.matches("AaZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        asserts.notMatches("AoZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        asserts.matches("A\u{10000}Z", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));

        var q = RxPattern.CharSet(CharSet.fromString("a\u{10000}\u{10002}"));
        asserts.matches("a", q);
        asserts.matches("\u{10000}", q);
        asserts.notMatches("\u{10001}", q);
        asserts.matches("\u{10002}", q);

        var r = RxPattern.NotInSet(CharSet.fromString("a\u{10000}\u{10002}"));
        asserts.notMatches("a", r);
        asserts.notMatches("\u{10000}", r);
        asserts.matches("\u{10001}", r);
        asserts.notMatches("\u{10002}", r);
        asserts.matches("\u{3042}", r);
        return asserts.done();
    }

    public function testSetDynamic() {
        asserts.pattern("[ehlo]", RxPattern.CharSet(CharSet.fromString(str("hello"))));

        var p = RxPattern.NotInSet(CharSet.fromString(str("hello")));
        asserts.notMatches("h", p);
        asserts.notMatches("e", p);
        asserts.notMatches("l", p);
        asserts.notMatches("o", p);
        asserts.matches("AaZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        asserts.notMatches("AoZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        asserts.matches("A\u{10000}Z", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));

        var q = RxPattern.CharSet(CharSet.fromString(str("a\u{10000}\u{10002}")));
        asserts.matches("a", q);
        asserts.matches("\u{10000}", q);
        asserts.notMatches("\u{10001}", q);
        asserts.matches("\u{10002}", q);

        var r = RxPattern.NotInSet(CharSet.fromString(str("a\u{10000}\u{10002}")));
        asserts.notMatches("a", r);
        asserts.notMatches("\u{10000}", r);
        asserts.matches("\u{10001}", r);
        asserts.notMatches("\u{10002}", r);
        asserts.matches("\u{3042}", r);
        return asserts.done();
    }

    public function testSetLiteral() {
        asserts.pattern("[ehlo]", RxPattern.CharSetLit("hello"));

        var p = RxPattern.NotInSetLit("hello");
        asserts.notMatches("h", p);
        asserts.notMatches("e", p);
        asserts.notMatches("l", p);
        asserts.notMatches("o", p);
        asserts.matches("AaZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        asserts.notMatches("AoZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        asserts.matches("A\u{10000}Z", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));

        var q = RxPattern.CharSetLit("a\u{10000}\u{10002}");
        asserts.matches("a", q);
        asserts.matches("\u{10000}", q);
        asserts.notMatches("\u{10001}", q);
        asserts.matches("\u{10002}", q);

        var r = RxPattern.NotInSetLit("a\u{10000}\u{10002}");
        asserts.notMatches("a", r);
        asserts.notMatches("\u{10000}", r);
        asserts.matches("\u{10001}", r);
        asserts.notMatches("\u{10002}", r);
        asserts.matches("\u{3042}", r);
        return asserts.done();
    }

}