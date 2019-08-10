/*
 * Utilities to construct regexp pattern strings.
 */
package rxpattern;

import unifill.*;
import rxpattern.CharSet;
import rxpattern.RxErrors;
import rxpattern.UnicodePatternUtil;
import rxpattern.internal.CodeUtil;
import rxpattern.internal.RangeUtil;

#if (eval || macro)
import haxe.macro.Expr;
import rxpattern.internal.Define;
#end

using rxpattern.UnicodePatternUtil;

// An enum to describe the context of the expression
enum abstract Precedence(Int) {
    var Disjunction = 0;
    var Alternative = 1;
    var Term = 2;
    var Atom = 3;
    @:op(A > B) static function gt(lhs:Precedence, rhs:Precedence):Bool;
}

/* A class to construct the pattern string with minimum number of parenthesis */
@:final
@:unreflective
@:allow(rxpattern.RxPattern)
class Pattern {

    var pattern(default, null):String;
    var prec(default, null):Precedence;

    inline function new(pattern:String, prec:Precedence) {
        this.pattern = pattern;
        this.prec = prec;
    }

    inline function withPrec(prec:Precedence) {
        return prec > this.prec
            ? "(?:" + this.pattern + ")"
            :this.pattern;
    }

}

@:notNull abstract RxPattern(Pattern) {

    public inline function new(pattern:String, prec:Precedence) {
        this = new Pattern(pattern, prec);
    }

    public static inline function Disjunction(pattern:String) {
        return new Disjunction(pattern);
    }

    public static inline function Alternative(pattern:String) {
        return new Alternative(pattern);
    }

    public static inline function Term(pattern:String) {
        return new Term(pattern);
    }

    public static inline function Atom(pattern:String) {
        return new Atom(pattern);
    }

    public static var AnyCodePoint(get, never):#if ((js && !(nodejs || js_es > 5)) || cs) Disjunction #else Atom #end;

    #if !(eval || macro) inline #end
    static function get_AnyCodePoint()
        #if ((js && !(nodejs || js_es > 5)) || cs)
            return Disjunction("[\\u0000-\\uD7FF\\uE000-\\uFFFF]|[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]".translate());
        #elseif flash
            return Atom("[\u0000-\u{10FFFF}]");
        #elseif (eval || hl || neko || php || java)
            return Atom("(?s:.)");
        #elseif (python || (js && nodejs) || (js && js_es > 5))
            return Atom("[\\S\\s]");
        #else
            return Atom("[\\u0000-\\u10FFFF]".translate());
        #end

    #if !(eval || macro)
        private static var rxSpecialChar = ~/^[\^\$\\\.\*\+\?\(\)\[\]\{\}\|]$/;
        private static var rxSingleCodePoint =
            #if (js || cs)
                (AtStart >> AnyCodePoint >> AtEnd).build();
            #else
                // `s` flag not supported on javascript.
                new rxpattern.internal.EReg("^.$", 'us');
            #end
    #end

    public static function escapeChar(c:String) {
        #if !(eval || macro)
            #if debug
                if (!rxSingleCodePoint.match(c)) {
                    throw Char_NotSingleCharacter;
                }
            #end
            return if (rxSpecialChar.match(c)) {
                "\\" + c;
            } else  {
                c;
            }
        #else
            if (c.length == 0) {
                throw Char_NotSingleCharacter;
            }

            var x = InternalEncoding.codePointAt(c, 0);

            if (CodePoint.fromInt(x) != c) {
                throw Char_NotSingleCharacter;
            }

            return if ("^$\\.*+?()[]{}|".indexOf(c) != -1) {
                "\\" + c;
            } else {
                c;
            }
        #end
    }

    public static inline function escapeString(s:String) {
        return ~/[\^\$\\\.\*\+\?\(\)\[\]\{\}\|]/g.map(s, e -> "\\" + e.matched(0));
    }

    #if ((js && !(nodejs || js_es > 5)) || cs)
        public static function CharS(s:String):RxPattern {
            #if debug
            if (!rxSingleCodePoint.match(s)) {
                throw Char_NotSingleCharacter;
            }
            #end
            var v = s.charCodeAt(0);

            return if (0xD800 <= v && v < 0xDC00) {
                Alternative(s);
            } else {
                Atom(escapeChar(s));
            }
        }
    #end
    
    public static macro function Char(x:ExprOf<String>) {
        return rxpattern.internal.Macros._Char(x);
    }
    
    public static macro function String(x:ExprOf<String>) {
        return rxpattern.internal.Macros._String(x);
    }

    public static var AnyExceptNewLine(get, never):#if ((js && !(nodejs || js_es > 5)) || cs) Disjunction #else Atom #end;

    static inline function get_AnyExceptNewLine()
    #if ((js && !(nodejs || js_es > 5)))
        return Disjunction("[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]|(?![\\uD800-\\uDFFF]).".translate());
    #elseif (cs)
        return Disjunction("[\\uD800-\\uDBFF][\\uDC00-\\uDFFF]|[^\\r\\n\\u2028\\u2029\\uD800-\\uDFFF]".translate());
    #else
        return Atom(".");
    #end

    public static var NewLine(get, never):Atom; 
    
    static inline function get_NewLine() return Atom("\\n");

    public static var LineTerminator(get, never):Disjunction; 
    
    static inline function get_LineTerminator() {
        /* TODO:U+0085 NEL */
        /* U+2028:Line Separator, U+2029 Paragraph Separator */
        return Disjunction("\\r\\n|[\\r\\n\\u2028\\u2029]".translate());
    }

    public static var LineTerminatorChar(get, never):Atom; 
    
    static inline function get_LineTerminatorChar() {
        return Atom("[\\r\\n\\u2028\\u2029]".translate());
    }

    public static var Empty(get, never):Alternative; 

    static inline function get_Empty() return Alternative("");

    public static var AtStart(get, never):Term;
    public static var AtEnd(get, never):Term; 
    
    private static inline function get_AtStart()
    #if !js
        return Term("\\A");
    #else
        return Term("^");
    #end 
    
    private static inline function get_AtEnd()
    #if python
        return Term("\\Z");
    #elseif !js
        return Term("\\z");
    #else
        return Term("$");
    #end

    public static inline function LookAhead(e:Disjunction):Term {
        return Term("(?=" + e.toDisjunction() + ")");
    }

    public static inline function NotFollowedBy(e:Disjunction):Term {
        return Term("(?!" + e.toDisjunction() + ")");
    }

    public static var Never(get, never):Term;
    static inline function get_Never(){
        return Term("(?!)");
    }

    private static inline function SimpleCharSet(set:CharSet, invert:Bool):RxPattern {
        return RangeUtil.printRanges(set, invert);
    }

    public static inline function CharSet(set:CharSet) {
        return RangeUtil.printRanges(set, false);
    }
    
    public static inline function NotInSet(set:CharSet) {
        return RangeUtil.printRanges(set, true);
    }
    
    public static macro function CharSetLit(s:ExprOf<String>):ExprOf<RxPattern> {
        return rxpattern.internal.Macros._CharSetLit(s);
    }
    
    public static macro function NotInSetLit(s:ExprOf<String>):ExprOf<RxPattern> {
        return rxpattern.internal.Macros._NotInSetLit(s);
    }

    public static inline function Group(p:Disjunction):Atom{
        return Atom("(" + p.toDisjunction() + ")");
    }

    // Operations on RxPatterns
    @:op(A >> B)
    public inline function then(rhs:Alternative){
        return new Alternative(toAlternative() + rhs.toAlternative());
    }

    @:op(A | B)
    public inline function or(rhs:Disjunction){
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
    }

    public static function sequence(a:Iterable<RxPattern>):Alternative {
        var p:Alternative = Empty;
        for (q in a) {
            p = p >> q;
        }
        return p;
    }

    public static function choice(a:Iterable<RxPattern>):RxPattern {
        var it = a.iterator();
        return if (it.hasNext()) {
            var p = it.next();
            for (q in it) {
                p = p | q;
            }
            p;
        } else {
            Never;
        }
    }

    // Accessors
    public inline function get(){
        return this.pattern;
    }

    private inline function getPrec(){
        return this.prec;
    }

    public inline function build(options = #if ((js && !(nodejs || js_es > 5))) '' #else "u" #end){
        return new rxpattern.internal.EReg(this.pattern, options);
    }

    public static inline function getPattern(x:Disjunction){
        return x.get();
    }

    public static inline function buildEReg(x, options = #if ((js && !(nodejs || js_es > 5))) '' #else "u" #end) {
        return new rxpattern.internal.EReg(getPattern(x), options);
    }

    public inline function toDisjunction(){
        return this.pattern;
    }

    public inline function toAlternative(){
        return this.withPrec(Precedence.Alternative);
    }

    public inline function toTerm(){
        return this.withPrec(Precedence.Term);
    }

    public inline function toAtom(){
        return this.withPrec(Precedence.Atom);
    }

    // Quantifiers
    public inline function option(){
        return Term(toAtom() + "?");
    }

    public inline function many(){
        return Term(toAtom() + "*");
    }

    public inline function many1(){
        return Term(toAtom() + "+");
    }

    // Implicit casts
    @:to public inline function asDisjunction() {
        return new Disjunction(toDisjunction());
    }

    @:to public inline function asAlternative() {
        return new Alternative(toAlternative());
    }

    @:to public inline function asTerm() {
        return new Term(toTerm());
    }

    @:to public inline function asAtom() {
        return new Atom(toAtom());
    }

}

@:notNull
abstract Disjunction(String) {

    public inline function new(pattern:String) this = pattern;

    // Accessors
    public inline function get() return this;
    public inline function build(options = #if ((js && !(nodejs || js_es > 5))) '' #else "u" #end) {
        return new rxpattern.internal.EReg(this, options);
    }

    public inline function toDisjunction() return this;
    public inline function toAlternative() return "(?:" + this + ")";
    public inline function toTerm() return "(?:" + this + ")";
    public inline function toAtom() return "(?:" + this + ")";

    // Implicit casts
    @:to public inline function asAlternative() {
        return new Alternative(toAlternative());
    }

    @:to public inline function asTerm() {
        return new Term(toTerm());
    }

    @:to public inline function asAtom() {
        return new Atom(toAtom());
    }

    @:to public inline function asPattern() {
        return new RxPattern(this, Precedence.Disjunction);
    }

    // Quantifiers
    public inline function option() return new Term(toAtom() + "?");
    public inline function many() return new Term(toAtom() + "*");
    public inline function many1() return new Term(toAtom() + "+");

    // Binary operators
    @:op(A >> B)
    public inline function then(rhs:Alternative){
        return new Alternative(toAlternative() + rhs.toAlternative());
    }

    @:op(A | B)
    public inline function or(rhs:Disjunction){
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
    }

}

@:notNull
@:forward(get, build, option, many, many1)
abstract Alternative(Disjunction) {

    public inline function new(pattern:String) this = new Disjunction(pattern);

    // Accessors
    public inline function toDisjunction() return this.get();
    public inline function toAlternative() return this.get();
    public inline function toTerm() return "(?:" + this.get() + ")";
    public inline function toAtom() return "(?:" + this.get() + ")";

    // Implicit casts
    @:to public inline function asDisjunction() {
        return this;
    }

    @:to public inline function asTerm() {
        return new Term(toTerm());
    }

    @:to public inline function asAtom() {
        return new Atom(toAtom());
    }

    @:to public inline function asPattern() {
        return new RxPattern(this.get(), Precedence.Alternative);
    }

    // Binary operators
    @:op(A >> B)
    public inline function then(rhs:Alternative) {
        return new Alternative(toAlternative() + rhs.toAlternative());
    }

    @:op(A | B)
    public inline function or(rhs:Disjunction) {
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
    }

}

@:notNull
@:forward(get, build, option, many, many1)
abstract Term(Alternative) {

    public inline function new(pattern:String) this = new Alternative(pattern);

    // Accessors
    public inline function toDisjunction() {
        return this.get();
    }

    public inline function toAlternative() {
        return this.get();
    }

    public inline function toTerm() {
        return this.get();
    }

    public inline function toAtom() {
        return "(?:" + this.get() + ")";
    }

    // Implicit casts
    @:to public inline function asDisjunction() {
        return this.asDisjunction();
    }

    @:to public inline function asAlternative() {
        return this;
    }

    @:to public inline function asAtom() {
        return new Atom(toAtom());
    }

    @:to public inline function asPattern() {
        return new RxPattern(this.get(), Precedence.Term);
    }

    // Binary operators
    @:op(A >> B)
    public inline function then(rhs:Alternative){
        return new Alternative(toAlternative() + rhs.toAlternative());
    }

    @:op(A | B)
    public inline function or(rhs:Disjunction){
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
    }

}

@:notNull
@:forward(get, build)
abstract Atom(Term) {

    public inline function new(pattern:String) this = new Term(pattern);

    // Accessors
    public inline function toDisjunction() return this.get();
    public inline function toAlternative() return this.get();
    public inline function toTerm() return this.get();
    public inline function toAtom() return this.get();

    // Implicit casts
    @:to public inline function asDisjunction() {
        return this.asDisjunction();
    }

    @:to public inline function asAlternative() {
        return this.asAlternative();
    }

    @:to public inline function asTerm() {
        return this;
    }

    @:to public inline function asPattern() {
        return new RxPattern(this.get(), Precedence.Atom);
    }

    // Quantifiers (redefine here because toAtom() is differently defined from Term)
    public inline function option() return new Term(toAtom() + "?");
    public inline function many() return new Term(toAtom() + "*");
    public inline function many1() return new Term(toAtom() + "+");

    // Binary operators
    @:op(A >> B)
    public inline function then(rhs:Alternative) {
        return new Alternative(toAlternative() + rhs.toAlternative());
    }

    @:op(A | B)
    public inline function or(rhs:Disjunction) {
        return new Disjunction(toDisjunction() + "|" + rhs.toDisjunction());
    }

}
