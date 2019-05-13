package ;

import unifill.CodePoint;
import unifill.CodePointIter;
import unifill.InternalEncoding;

class UnicodeTest extends haxe.unit.TestCase
{
    public function testFromCodePoint()
    {
        assertEquals("\u{32}", CodePoint.fromInt(0x32));
        assertEquals("\u{304}", CodePoint.fromInt(0x304));
        assertEquals("\u{3042}", CodePoint.fromInt(0x3042));
        assertEquals("\u{12345}", CodePoint.fromInt(0x12345));
    }

    public function testCodePointAt()
    {
        assertEquals(0x32, InternalEncoding.codePointAt("\u0032", 0));
        assertEquals(0x304, InternalEncoding.codePointAt("\u0304", 0));
        assertEquals(0x3042, InternalEncoding.codePointAt("\u3042", 0));
        assertEquals(0x12345, InternalEncoding.codePointAt("\u{12345}", 0));
    }

    public function testCodePointIterator()
    {
        #if hl
        // HashLink breaks on NULL characters
        // @see https://github.com/HaxeFoundation/haxe/issues/8201
        var it = new CodePointIter("x\u3042\u{12345}\u{20A0}");
        #else
        var it = new CodePointIter("\u0000x\u3042\u{12345}\u{20A0}");
        assertEquals(it.next(), 0);
        #end
        assertEquals(it.next(), 'x'.charCodeAt(0));
        assertEquals(it.next(), 0x3042);
        assertEquals(it.next(), 0x12345);
        assertEquals(it.next(), 0x20A0);
        assertFalse(it.hasNext());
    }

    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new UnicodeTest());
        r.run();
    }
}
