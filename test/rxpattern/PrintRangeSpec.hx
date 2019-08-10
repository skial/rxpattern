package rxpattern;

import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.internal.RangeUtil.*;
import rxpattern.internal.CodeUtil.printCode as p;

#if js
#if nodejs 
@:jsRequire('../regenerate') 
#else
@:native('regenerate')
#end
extern class Regenerate {
    public function new();
    public function addRange(min:Int, max:Int):Regenerate;
    public function removeRange(min:Int, max:Int):Regenerate;
    public function add(v:Int):Regenerate;
    public function remove(v:Int):Regenerate;
    public function toString(?options:{}):String;
}
#end

// @see https://github.com/mathiasbynens/regenerate/blob/master/tests/tests.js
@:asserts class PrintRangeSpec {

    public function new() {}

    public static var NUL = p(0);

    public function printRanges1() {
        var rs = new Ranges([new Range(0x305, 0x374)]);
        asserts.assert( printRanges(rs, false).get() == '[${p(0x305)}-${p(0x374)}]' );
        #if js
        var rg = new Regenerate().addRange(0x305, 0x374);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end
        return asserts.done();
    }

    public function printRanges2() {
        var rs = new Ranges([new Range(0, 0x300)]);
        rs.remove(new Range(0x100, 0x200));
        
        asserts.assert( 
            printRanges(rs, false).get() == 
            '[$NUL-${p(0x00FF)}${p(0x0201)}-${p(0x0300)}]' 
        );
        #if js
        var rg = new Regenerate().addRange(0, 0x300).removeRange(0x100, 0x200);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end
        return asserts.done();
    }

    public function printRanges3() {
        var rs = new Ranges([]);
        for (i in 'A'.code...'I'.code) rs.add(i);
        rs.add(0x5A);
        rs.add(0x61);

        asserts.assert( printRanges(rs, false).get() == '[A-HZa]' );
        #if js
        var rg = new Regenerate();
        for (i in 'A'.code...'I'.code) rg.add(i);
        rg.add(0x5A);
        rg.add(0x61);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end
        return asserts.done();
    }

    public function printRanges4() {
        var rs = new Ranges([]);
        rs.add(' '.code);
        rs.add('!'.code);
        rs.add('#'.code);
        rs.add('\\'.code); // code 92
        rs.add('/'.code); // code 47

        asserts.assert( printRanges(rs, false).get() == '[ !#\\/\\\\]' );

        #if js
        var rg = new Regenerate();
        rg.add(' '.code);
        rg.add('!'.code);
        rg.add('#'.code);
        rg.add('\\'.code); // code 92
        rg.add('/'.code); // code 47
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function unmatchedHighSurrogates() {
        var rs = new Ranges([]);
        rs.add(0xD800);
        rs.add(0xD801);
        rs.add(0xD802);
        rs.add(0xD803);
        rs.add(0xDBFF);

        asserts.assert( 
            printRanges(rs, false).get() == 
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[${p(0xD800)}-${p(0xD803)}${p(0xDBFF)}](?![${p(0xDC00)}-${p(0xDFFF)}])' 
            #else
            '[${p(0xD800)}-${p(0xD803)}${p(0xDBFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate();
        rg.add(0xD800);
        rg.add(0xD801);
        rg.add(0xD802);
        rg.add(0xD803);
        rg.add(0xDBFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function unmatchedLowSurrogates() {
        var rs = new Ranges([]);
        rs.add(0xDC00);
        rs.add(0xDC01);
        rs.add(0xDC02);
        rs.add(0xDC03);
        rs.add(0xDC04);
        rs.add(0xDC05);
        rs.add(0xDFFB);
        rs.add(0xDFFD);
        rs.add(0xDFFE);
        rs.add(0xDFFF);

        asserts.assert( 
            printRanges(rs, false).get() == 
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDC00)}-${p(0xDC05)}${p(0xDFFB)}${p(0xDFFD)}-${p(0xDFFF)}]' 
            #else
            '[${p(0xDC00)}-${p(0xDC05)}${p(0xDFFB)}${p(0xDFFD)}-${p(0xDFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate();
        rg.add(0xDC00);
        rg.add(0xDC01);
        rg.add(0xDC02);
        rg.add(0xDC03);
        rg.add(0xDC04);
        rg.add(0xDC05);
        rg.add(0xDFFB);
        rg.add(0xDFFD);
        rg.add(0xDFFE);
        rg.add(0xDFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function mixedBMPAstralCodePoints() {
        var rs = new Ranges([]);
        rs.add(0x0);
        rs.add(0x1);
        rs.add(0x2);
        rs.add(0x3);
        rs.add(0x1D306);
        rs.add(0x1D307);
        rs.add(0x1D308);
        rs.add(0x1D30A);

        asserts.assert( 
            printRanges(rs, false).get() == 
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[$NUL-${p(0x0003)}]|${p(0xD834)}[${p(0xDF06)}-${p(0xDF08)}${p(0xDF0A)}]' 
            #else
            '[${p(0)}-${p(0x3)}${p(0x1D306)}-${p(0x1D308)}${p(0x1D30A)}]'
            #end
        );

        #if js
        var rg = new Regenerate();
        rg.add(0x0);
        rg.add(0x1);
        rg.add(0x2);
        rg.add(0x3);
        rg.add(0x1D306);
        rg.add(0x1D307);
        rg.add(0x1D308);
        rg.add(0x1D30A);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function allBMPCodePoints() {
        var rs = new Ranges([new Range(0x0, 0xFFFF)]);

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[$NUL-${p(0xD7FF)}${p(0xE000)}-${p(0xFFFF)}]|[${p(0xD800)}-${p(0xDBFF)}](?![${p(0xDC00)}-${p(0xDFFF)}])|(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDC00)}-${p(0xDFFF)}]'
            #else
            '[${p(0)}-${p(0xFFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate();
        rg.addRange(0x0, 0xFFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function surrogateBounds() {
        var rs = new Ranges([new Range(0x103FE, 0x10401)]);

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '${p(0xD800)}[${p(0xDFFE)}${p(0xDFFF)}]|${p(0xD801)}[${p(0xDC00)}${p(0xDC01)}]'
            #else
            '[${p(0x103FE)}-${p(0x10401)}]'
            #end
        );

        #if js
        var rg = new Regenerate();
        rg.addRange(0x103FE, 0x10401);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end
        return asserts.done();
    }

    public function allAstralCodePoints() {
        var rs = new Ranges([]);
        rs.add(new Range(0x010000, 0x10FFFF));

        asserts.assert( 
            printRanges(rs, false).get() == 
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[${p(0xD800)}-${p(0xDBFF)}][${p(0xDC00)}-${p(0xDFFF)}]'
            #else
            '[${p(0x010000)}-${p(0x10FFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().addRange(0x010000, 0x10FFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end
        return asserts.done();
    }

    public function allUnicodeCodePoints() {
        var rs = new Ranges([]);
        rs.add(new Range(0x00, 0x10FFFF));

        asserts.assert(
            printRanges(rs, false).get() == 
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[$NUL-${p(0xD7FF)}${p(0xE000)}-${p(0xFFFF)}]|[${p(0xD800)}-${p(0xDBFF)}][${p(0xDC00)}-${p(0xDFFF)}]|[${p(0xD800)}-${p(0xDBFF)}](?![${p(0xDC00)}-${p(0xDFFF)}])|(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDC00)}-${p(0xDFFF)}]'
            #else
            '[${p(0x00)}-${p(0x10FFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().addRange(0x00, 0x10FFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRange0_0DCFF() {
        var rs = new Ranges([]);
        rs.add(new Range(0, 0xDCFF));

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[$NUL-${p(0xD7FF)}]|[${p(0xD800)}-${p(0xDBFF)}](?![${p(0xDC00)}-${p(0xDFFF)}])|(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDC00)}-${p(0xDCFF)}]'
            #else
            '[${p(0)}-${p(0xDCFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().addRange(0, 0xDCFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRange0xD800minus1() {
        var rs = new Ranges([]);
        rs.add(0xD800 - 1);
        rs.add(new Range(0xD800, 0xDBFF));

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '${p(0xD7FF)}|[${p(0xD800)}-${p(0xDBFF)}](?![${p(0xDC00)}-${p(0xDFFF)}])'
            #else
            '[${p(0xD7FF)}-${p(0xDBFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().add(0xD800 - 1).addRange(0xD800, 0xDBFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRangeStartsHi_endsLo() {
        var rs = new Ranges([]);
        rs.add(new Range(0xD855, 0xFFFF));

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[${p(0xE000)}-${p(0xFFFF)}]|[${p(0xD855)}-${p(0xDBFF)}](?![${p(0xDC00)}-${p(0xDFFF)}])|(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDC00)}-${p(0xDFFF)}]'
            #else
            '[${p(0xD855)}-${p(0xFFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().addRange(0xD855, 0xFFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRangeStartsEndLo() {
        var rs = new Ranges([]);
        rs.add(new Range(0xDCFF, 0xDDFF));

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDCFF)}-${p(0xDDFF)}]'
            #else
            '[${p(0xDCFF)}-${p(0xDDFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().addRange(0xDCFF, 0xDDFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRangeStartsLo_endsAfterLo() {
        var rs = new Ranges([]);
        rs.add(new Range(0xDCFF, 0x10FFFF));

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[${p(0xE000)}-${p(0xFFFF)}]|[${p(0xD800)}-${p(0xDBFF)}][${p(0xDC00)}-${p(0xDFFF)}]|(?:[^${p(0xD800)}-${p(0xDBFF)}]|^)[${p(0xDCFF)}-${p(0xDFFF)}]'
            #else
            '[${p(0xDCFF)}-${p(0x10FFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate().addRange(0xDCFF, 0x10FFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRangeVariousCodePonts() {
        var rs = new Ranges([0x200C]);
        rs.add(new Range(0xF900, 0xFDCF));
        rs.add(new Range(0xFDF0, 0xFFFD));
        rs.add(new Range(0x010000, 0x0EFFFF));

        asserts.assert(
            printRanges(rs, false).get() ==
            #if ((!(nodejs || js_es > 5) && (js || cs)))
            '[${p(0x200C)}${p(0xF900)}-${p(0xFDCF)}${p(0xFDF0)}-${p(0xFFFD)}]|[${p(0xD800)}-${p(0xDB7F)}][${p(0xDC00)}-${p(0xDFFF)}]'
            #else 
            '[${p(0x200C)}${p(0xF900)}-${p(0xFDCF)}${p(0xFDF0)}-${p(0xFFFD)}${p(0x10000)}-${p(0xEFFFF)}]'
            #end
        );

        #if js
        var rg = new Regenerate()
            .add(0x200C)
            .addRange(0xF900, 0xFDCF)
            .addRange(0xFDF0, 0xFFFD)
            .addRange(0x010000, 0x0EFFFF);
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        #end

        return asserts.done();
    }

    public function testRange_rxpatternComplement() {
        var rs = new Ranges([]);
        rs.add('h'.code);
        rs.add('e'.code);
        rs.add('l'.code);
        rs.add('o'.code);
        asserts.assert( printRanges(rs, false).get() == '[ehlo]' );
        var rs1 = Ranges.complement(rs);

        #if js
        var rg = new Regenerate();
        rg.add('h'.code);
        rg.add('e'.code);
        rg.add('l'.code);
        rg.add('o'.code);
        var rg1 = new Regenerate();
        rg1.addRange(0x00, 0x10FFFF);
        rg1.remove(untyped rg);
        
        asserts.assert( rg.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs, false).get() );
        asserts.assert( rg1.toString(#if (nodejs || js_es > 5) {hasUnicodeFlag: true} #end) == printRanges(rs1, false).get() );
        #end

        return asserts.done();
    }

}