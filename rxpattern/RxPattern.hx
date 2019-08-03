/*
 * Utilities to construct regexp pattern strings.
 */
package rxpattern;

import unifill.*;
import uhx.sys.seri.Ranges;
import rxpattern.CharSet;
import rxpattern.RxErrors;
import rxpattern.internal.MinMax.*;
import rxpattern.UnicodePatternUtil;
import rxpattern.internal.CodeUtil;
import rxpattern.internal.RangeUtil;

#if (eval || macro)
import haxe.macro.Expr;
import rxpattern.internal.Define;
#end

// An enum to describe the context of the expression
enum abstract Precedence(Int) {
    var Disjunction = 0;
    var Alternative = 1;
    var Term = 2;
    var Atom = 3;
    @:op(A > B) static function gt(lhs: Precedence, rhs: Precedence): Bool;
}

/* A class to construct the pattern string with minimum number of parenthesis */
@:final
@:unreflective
@:allow(rxpattern.RxPattern)
class Pattern
{
    var pattern(default, null): String;
    var prec(default, null): Precedence;
    inline function new(pattern: String, prec: Precedence)
    {
        this.pattern = pattern;
        this.prec = prec;
    }
    inline function withPrec(prec: Precedence)
    {
        return prec > this.prec
            ? "(?:" + this.pattern + ")"
            : this.pattern;
    }
}

abstract RxPattern(Pattern)
{
    @:extern
    public inline function new(pattern: String, prec: Precedence)
        this = new Pattern(pattern, prec);

    @:extern
    public static inline function Disjunction(pattern: String)
        return new Disjunction(pattern);

    @:extern
    public static inline function Alternative(pattern: String)
        return new Alternative(pattern);

    @:extern
    public static inline function Term(pattern: String)
        return new Term(pattern);

    @:extern
    public static inline function Atom(pattern: String)
        return new Atom(pattern);

    public static var AnyCodePoint(get, never): #if ((js && !nodejs) || cs) Disjunction #else Atom #end;
    #if !(eval || macro) inline #end
    static function get_AnyCodePoint()
        #if ((js && !nodejs) || cs)
            return Disjunction("[\\u0000-\\uD7FF\\uE000-\\uFFFF]|[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]");
        #elseif flash
            return Atom("[\u0000-\u{10FFFF}]");
        #elseif (eval || hl || neko || php || java)
            return Atom("(?s:.)");
        #elseif (python || nodejs)
            return Atom("[\\S\\s]");
        #else
            return Atom(UnicodePatternUtil.translateUnicodeEscape("[\\u0000-\\u10FFFF]"));
        #end

    #if !(eval || macro)
        private static var rxSpecialChar = ~/^[\^\$\\\.\*\+\?\(\)\[\]\{\}\|]$/;
        private static var rxSingleCodePoint =/*
            #if ((js && !nodejs) || cs)
                ~/^(?:[\\u0000-\\uD7FF\\uE000-\\uFFFF]|[\\uD800-\\uDBFF][\\uDC00-\\uDFFF])$/u;
            #else
                new rxpattern.internal.EReg("^.$", 'us');
            #end*/
            #if ((js && !nodejs) || cs)
                (AtStart >> AnyCodePoint >> AtEnd).build();
            #else
                new rxpattern.internal.EReg("^.$", 'us');
            #end
    #end
    public static function escapeChar(c: String)
    {
        #if !(eval || macro)
            #if debug
                if (!rxSingleCodePoint.match(c)) {
                    trace('ereg failure');
                    throw Char_NotSingleCharacter;
                }
            #end
            if (rxSpecialChar.match(c)) {
                return "\\" + c;
            } else  {
                return c;
            }
        #else
            if (c.length == 0) {
                trace( c.length );
                throw Char_NotSingleCharacter;
            }
            var x = InternalEncoding.codePointAt(c, 0);
            if (CodePoint.fromInt(x) != c) {
                trace( 'x != c');
                throw Char_NotSingleCharacter;
            }
            if ("^$\\.*+?()[]{}|".indexOf(c) != -1) {
                return "\\" + c;
            } else {
                return c;
            }
        #end
    }
    public static inline function escapeString(s: String)
    {
        return ~/[\^\$\\\.\*\+\?\(\)\[\]\{\}\|]/g.map(s, e -> "\\" + e.matched(0));
    }

    #if ((js && !nodejs) || cs)
        public static function CharS(s: String): RxPattern
        {
            #if debug
            trace(s);
            if (!rxSingleCodePoint.match(s)) {
                throw Char_NotSingleCharacter;
            }
            #end
            var v = s.charCodeAt(0);
            if (0xD800 <= v && v < 0xDC00) {
                return Alternative(s);
            } else {
                return Atom(escapeChar(s));
            }
        }
    #end
    
    macro public static function Char(x:ExprOf<String>) {
        return rxpattern.internal.Macros._Char(x);
    }
    
    macro public static function String(x:ExprOf<String>) {
        return rxpattern.internal.Macros._String(x);
    }

    public static var AnyExceptNewLine(get, never): #if ((js && !nodejs) || cs || (java && java_ver < 7)) Disjunction #else Atom #end;
    @:extern static inline function get_AnyExceptNewLine()
    #if (js && !nodejs)
        return Disjunction("[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]|(?![\\uD800-\\uDFFF]).");
    #elseif (cs || (java && java_ver < 7))
        return Disjunction("[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]|[^\\r\\n\\u2028\\u2029\\uD800-\\uDFFF]");
    #else
        return Atom(".");
    #end
    public static var NewLine(get, never): Atom;
    @:extern static inline function get_NewLine() return Atom("\\n");
    public static var LineTerminator(get, never): Disjunction;
    @:extern static inline function get_LineTerminator()
    {
        /* TODO: U+0085 NEL */
        /* U+2028: Line Separator, U+2029 Paragraph Separator */
        return Disjunction(UnicodePatternUtil.translateUnicodeEscape("\\r\\n|[\\r\\n\\u2028\\u2029]"));
    }
    public static var LineTerminatorChar(get, never): Atom;
    @:extern static inline function get_LineTerminatorChar()
        return Atom(UnicodePatternUtil.translateUnicodeEscape("[\\r\\n\\u2028\\u2029]"));
    public static var Empty(get, never): Alternative;
    @:extern static inline function get_Empty() return Alternative("");
    public static var AtStart(get, never): Term;
    public static var AtEnd(get, never): Term;
    @:extern static inline function get_AtStart()
    #if (python || neko || cpp || php || lua || java || cs || flash || hl || (eval || macro))
        return Term("\\A");
    #else
        return Term("^");
    #end
    @:extern static inline function get_AtEnd()
    #if python
        return Term("\\Z");
    #elseif (neko || cpp || php || lua || java || cs || flash || hl || (eval || macro))
        return Term("\\z");
    #else
        return Term("$");
    #end
    @:extern
    public static inline function LookAhead(e: Disjunction): Term
        return Term("(?=" + e.toDisjunction() + ")");
    @:extern
    public static inline function NotFollowedBy(e: Disjunction): Term
        return Term("(?!" + e.toDisjunction() + ")");
    #if js
        public static var Never(get, never): Atom;
        @:extern static inline function get_Never()
            return Atom("[]");
    #else
        public static var Never(get, never): Term;
        @:extern static inline function get_Never()
            return Term("(?!)");
    #end

    static function escapeSetChar(c: String)
    {
        switch (c) {
        case '^' | '-' | '[' | ']' | '\\':
            return '\\' + c;
        default:
            return c;
        }
    }
    #if ((js && !nodejs) || cs || (eval || macro))
        static function escapeChar_surrogate(x)
        {
            if (0xD800 <= x && x <= 0xDFFF) {
                //return "\\u" + StringTools.hex(x, 4);
                return CodeUtil.printCode(x);
            } else {
                return escapeChar(CodePoint.fromInt(x));
            }
        }
        static function escapeSetChar_surrogate(x)
        {
            if (0xD800 <= x && x <= 0xDFFF) {
                //return "\\u" + StringTools.hex(x, 4);
                return CodeUtil.printCode(x);
            } else {
                return escapeSetChar(CodePoint.fromInt(x));
            }
        }
    #end
    private static function SimpleCharSet(set: CharSet, invert: Bool, utf16CodeUnits: Bool): RxPattern
    {
        /*if (invert) {
            // NULL characters for Neko crash at runtime.
            //set = Ranges.complement(set, MIN, MAX);
        }*/
        //#if !java
        return RangeUtil.printRanges(set, invert);
        //#end
        var it = set.iterator();
        if (it.hasNext()) {
            var x = it.next();
            if (invert || it.hasNext()) {
                var buf = new StringBuf();
                buf.add(/*invert ? "[^" : */"[");
                var more = true;
                while (more) {
                    var start: Int = x;
                    var end: Int = x;
                    more = false;
                    while (it.hasNext()) {
                        x = it.next();
                        if (end == x - 1) {
                            end = x;
                        } else {
                            more = true;
                            break;
                        }
                    }
                    #if ((js && !nodejs) || cs)
                        buf.add(escapeSetChar_surrogate(start));
                    #elseif (eval || macro)
                        if (utf16CodeUnits) {
                            buf.add(escapeSetChar_surrogate(start));
                        } else {
                            buf.add(escapeSetChar(CodePoint.fromInt(start)));
                        }
                    #else
                        buf.add(escapeSetChar(CodePoint.fromInt(start)));
                    #end
                    if (start != end) {
                        if (start + 1 != end) {
                            buf.add("-");
                        }
                        #if ((js && !nodejs) || cs)
                            buf.add(escapeSetChar_surrogate(end));
                        #elseif (eval || macro)
                            if (utf16CodeUnits) {
                                buf.add(escapeSetChar_surrogate(end));
                            } else {
                                buf.add(escapeSetChar(CodePoint.fromInt(end)));
                            }
                        #else
                            buf.add(escapeSetChar(CodePoint.fromInt(end)));
                        #end
                    }
                }
                buf.add("]");
                var s = buf.toString();
                #if java
                trace( s );
                trace( RangeUtil.printRanges(set, false).get() );
                #end
                return Atom(s);
            } else {
                /* single code point */
                #if ((js && !nodejs) || cs)
                    var c = escapeChar_surrogate(x);
                    //trace( c );
                    return Atom(c);
                #elseif (eval || macro)
                    if (utf16CodeUnits) {
                        var c = escapeChar_surrogate(x);
                        //trace( c );
                        return Atom(c);
                    } else {
                        var c = escapeChar(CodePoint.fromInt(x));
                        //trace( c );
                        return Atom(c);
                    }
                #else
                    var c = escapeChar(CodePoint.fromInt(x));
                    //trace( c );
                    return Atom(c);
                #end
            }
        } else if (invert) {
            //trace( 'AnyCodePoint');
            return AnyCodePoint;
        } else {
            //trace( 'Never');
            return Never;
        }
    }
    #if ((js && !nodejs) || cs || eval || macro)
        private static function CharSet_surrogate(set: CharSet): RxPattern
        {
            var rs = RangeUtil.printRanges(set, false);
            return rs;
        }
        private static function NotInSet_surrogate(set: CharSet): RxPattern
        {
            //var set = Ranges.complement(set, MIN, MAX);
            var rs = RangeUtil.printRanges(set, true);
            return rs;
        }
    #end
    @:extern
    public static inline function CharSet(set: CharSet)
    {
        #if (eval || macro)
            if ((!NodeJS && JavaScript) || CSharp /*|| (Java && JavaVersion < 7)*/) {
                return CharSet_surrogate(set);
            } else {
                return SimpleCharSet(set, false, false);
            }
        #elseif ((js && !nodejs) || cs)
            return CharSet_surrogate(set);
        #else
            return SimpleCharSet(set, false, false);
        #end
    }
    @:extern
    public static inline function NotInSet(set: CharSet) {
        #if (eval || macro)
            if ((JavaScript && !NodeJS) || CSharp /*|| (Java && JavaVersion < 7)*/) {
                return NotInSet_surrogate(set);
            } else {
                return SimpleCharSet(set, true, false);
            }
        #elseif ((js && !nodejs) || cs)
            return NotInSet_surrogate(set);
        #else
            return SimpleCharSet(set, true, false);
        #end
    }
    
    macro public static function CharSetLit(s:ExprOf<String>):ExprOf<RxPattern> {
        return rxpattern.internal.Macros._CharSetLit(s);
    }
    
    macro public static function NotInSetLit(s:ExprOf<String>) {
        return rxpattern.internal.Macros._NotInSetLit(s);
    }

    @:extern
    public static inline function Group(p: Disjunction): Atom
        return Atom("(" + p.toDisjunction() + ")");

    // Operations on RxPatterns
    @:extern
    @:op(A >> B)
    public inline function then(rhs: Alternative)
        return new Alternative(toAlternative() + rhs.toAlternative());

    @:extern
    @:op(A | B)
    public inline function or(rhs: Disjunction)
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());

    public static function sequence(a: Iterable<RxPattern>): Alternative
    {
        var p: Alternative = Empty;
        for (q in a) {
            p = p >> q;
        }
        return p;
    }

    public static function choice(a: Iterable<RxPattern>): RxPattern
    {
        var it = a.iterator();
        if (it.hasNext()) {
            var p = it.next();
            for (q in it) {
                p = p | q;
            }
            return p;
        } else {
            return Never;
        }
    }

    // Accessors
    @:extern
    public inline function get()
        return this.pattern;
    @:extern
    private inline function getPrec()
        return this.prec;
    @:extern
    public inline function build(options = #if (js && !nodejs) '' #else "u" #end)
        return new rxpattern.internal.EReg(this.pattern, options);
    @:extern
    public static inline function getPattern(x: Disjunction)
        return x.get();
    @:extern
    public static inline function buildEReg(x, options = #if (js && !nodejs) '' #else "u" #end) {
        return new rxpattern.internal.EReg(getPattern(x), options);
    }

    @:extern
    public inline function toDisjunction()
        return this.pattern;
    @:extern
    public inline function toAlternative()
        return this.withPrec(Precedence.Alternative);
    @:extern
    public inline function toTerm()
        return this.withPrec(Precedence.Term);
    @:extern
    public inline function toAtom()
        return this.withPrec(Precedence.Atom);

    // Quantifiers
    @:extern
    public inline function option()
        return Term(toAtom() + "?");
    @:extern
    public inline function many()
        return Term(toAtom() + "*");
    @:extern
    public inline function many1()
        return Term(toAtom() + "+");

    // Implicit casts
    @:extern
    @:to public inline function asDisjunction() return new Disjunction(toDisjunction());
    @:extern
    @:to public inline function asAlternative() return new Alternative(toAlternative());
    @:extern
    @:to public inline function asTerm() return new Term(toTerm());
    @:extern
    @:to public inline function asAtom() return new Atom(toAtom());
}

@:notNull
abstract Disjunction(String)
{
    @:extern
    public inline function new(pattern: String) this = pattern;

    // Accessors
    @:extern
    public inline function get() return this;
    @:extern
    public inline function build(options = #if (js && !nodejs) '' #else "u" #end) 
        return new rxpattern.internal.EReg(this, options);
    @:extern
    public inline function toDisjunction() return this;
    @:extern
    public inline function toAlternative() return "(?:" + this + ")";
    @:extern
    public inline function toTerm() return "(?:" + this + ")";
    @:extern
    public inline function toAtom() return "(?:" + this + ")";

    // Implicit casts
    @:extern
    @:to public inline function asAlternative() return new Alternative(toAlternative());
    @:extern
    @:to public inline function asTerm() return new Term(toTerm());
    @:extern
    @:to public inline function asAtom() return new Atom(toAtom());
    @:extern
    @:to public inline function asPattern() return new RxPattern(this, Precedence.Disjunction);

    // Quantifiers
    @:extern
    public inline function option() return new Term(toAtom() + "?");
    @:extern
    public inline function many() return new Term(toAtom() + "*");
    @:extern
    public inline function many1() return new Term(toAtom() + "+");

    // Binary operators
    @:extern
    @:op(A >> B)
    public inline function then(rhs: Alternative)
        return new Alternative(toAlternative() + rhs.toAlternative());
    @:extern
    @:op(A | B)
    public inline function or(rhs: Disjunction)
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
}

@:notNull
@:forward(get, build, option, many, many1)
abstract Alternative(Disjunction)
{
    @:extern
    public inline function new(pattern: String) this = new Disjunction(pattern);

    // Accessors
    @:extern
    public inline function toDisjunction() return this.get();
    @:extern
    public inline function toAlternative() return this.get();
    @:extern
    public inline function toTerm() return "(?:" + this.get() + ")";
    @:extern
    public inline function toAtom() return "(?:" + this.get() + ")";

    // Implicit casts
    @:extern
    @:to public inline function asDisjunction() return this;
    @:extern
    @:to public inline function asTerm() return new Term(toTerm());
    @:extern
    @:to public inline function asAtom() return new Atom(toAtom());
    @:extern
    @:to public inline function asPattern() return new RxPattern(this.get(), Precedence.Alternative);

    // Binary operators
    @:extern
    @:op(A >> B)
    public inline function then(rhs: Alternative)
        return new Alternative(toAlternative() + rhs.toAlternative());
    @:extern
    @:op(A | B)
    public inline function or(rhs: Disjunction)
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
}

@:notNull
@:forward(get, build, option, many, many1)
abstract Term(Alternative)
{
    @:extern
    public inline function new(pattern: String) this = new Alternative(pattern);

    // Accessors
    @:extern
    public inline function toDisjunction() return this.get();
    @:extern
    public inline function toAlternative() return this.get();
    @:extern
    public inline function toTerm() return this.get();
    @:extern
    public inline function toAtom() return "(?:" + this.get() + ")";

    // Implicit casts
    @:extern
    @:to public inline function asDisjunction() return this.asDisjunction();
    @:extern
    @:to public inline function asAlternative() return this;
    @:extern
    @:to public inline function asAtom() return new Atom(toAtom());
    @:extern
    @:to public inline function asPattern() return new RxPattern(this.get(), Precedence.Term);

    // Binary operators
    @:extern
    @:op(A >> B)
    public inline function then(rhs: Alternative)
        return new Alternative(toAlternative() + rhs.toAlternative());
    @:extern
    @:op(A | B)
    public inline function or(rhs: Disjunction)
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
}

@:notNull
@:forward(get, build)
abstract Atom(Term)
{
    @:extern
    public inline function new(pattern: String) this = new Term(pattern);

    // Accessors
    @:extern
    public inline function toDisjunction() return this.get();
    @:extern
    public inline function toAlternative() return this.get();
    @:extern
    public inline function toTerm() return this.get();
    @:extern
    public inline function toAtom() return this.get();

    // Implicit casts
    @:extern
    @:to public inline function asDisjunction() return this.asDisjunction();
    @:extern
    @:to public inline function asAlternative() return this.asAlternative();
    @:extern
    @:to public inline function asTerm() return this;
    @:extern
    @:to public inline function asPattern() return new RxPattern(this.get(), Precedence.Atom);

    // Quantifiers (redefine here because toAtom() is differently defined from Term)
    @:extern
    public inline function option() return new Term(toAtom() + "?");
    @:extern
    public inline function many() return new Term(toAtom() + "*");
    @:extern
    public inline function many1() return new Term(toAtom() + "+");

    // Binary operators
    @:extern
    @:op(A >> B)
    public inline function then(rhs: Alternative)
        return new Alternative(toAlternative() + rhs.toAlternative());
    @:extern
    @:op(A | B)
    public inline function or(rhs: Disjunction)
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
}
