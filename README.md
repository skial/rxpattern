# RxPattern

This library provides a human-friendly way to write complex regular expression patterns.

The patterns generated by this library always work with Unicode code points, even if the target is JavaScript or C#.

| Php | Python | Java{6/7}/JVM | C# | Js/Node/ES{5/6} | Interp | Neko | HashLink | Lua | CPP | Flash
| - | -| - | - | - | -| - | - | - | - | - |
| ✅ | ✅     | ✅  | ✅ | ✅     | ✅ | ✅  | ✅       | ➖ | ➖ | ➖ |

## Examples

```haxe
var pattern1 = (RxPattern.Char("a") | RxPattern.Char("b")).many();
var rx1:EReg = pattern1.build();
rx1.match("abaab"); // => true
```

```haxe
var pattern2 = RxPattern.String("gr")
               >> (RxPattern.Char("a") | RxPattern.Char("e"))
               >> RxPattern.String("y");
var rx2 = pattern2.build();
rx2.match("grey"); // => true
rx2.match("gray"); // => true
```

```haxe
var pattern3 = RxPattern.AtStart
               >> RxPattern.String("colo")
               >> RxPattern.Char("u").option()
               >> RxPattern.String("r")
               >> RxPattern.AtEnd;
var rx3 = pattern3.build();
rx3.match("color"); // => true
rx3.match("colour"); // => true
rx3.match("color\n"); // => false
rx3.match("\ncolour"); // => false
```

```haxe
var wordStart = Category.L | RxPattern.Char("_");
var wordChar = wordStart | Category.N;
var word = wordStart >> wordChar.many();
var pattern4 = RxPattern.AtStart >> word >> RxPattern.AtEnd;
var rx4 = pattern4.build();
rx4.match("function"); // => true
rx4.match("int32_t"); // => true
rx4.match("\u3042"); // => true
rx4.match("24hours"); // => false
```

## Manual

This library provides the following classes:

- `rxpattern.RxPattern`
- `rxpattern.CharSet`
- `rxpattern.Category`

### Basic Patterns

- `RxPattern.AnyCodePoint:RxPattern`
    - Matches any Unicode code point, i.e. U+0000 to U+10FFFF (may or may not excluding surrogates).
- `RxPattern.Char(c:String):RxPattern`
    - Matches a Unicode code point represented by the string `c`.
    - `c` must consist of a single code point.
- `RxPattern.String(s:String):RxPattern`
    - Matches a string.
	- Special characters are escaped.
- `RxPattern.LineTerminator:RxPattern`
    - Matches a line terminator.
	- The following sequence / characters are treated as a line terminator:
        - CR LF
        - CR
        - LF
        - U+2028 LINE SEPARATOR
        - U+2029 PARAGRAPH SEPARATOR
        - TODO: Also include U+0085 NEL?
- `RxPattern.Empty:RxPattern`
    - Matches an empty string.

### Binary Operators

The variables `pattern1` and `pattern2` are of type `RxPattern`.

- `pattern1 >> pattern2`
    - Matches the sequence of `pattern`s.
- `pattern1 | pattern2`
    - Matches `pattern1` or `pattern2`.
- `pattern1.then(pattern2):RxPattern`
    - Same as `pattern1 >> pattern2`.
- `pattern1.or(pattern2):RxPattern`
    - Same as `pattern1 | pattern2`.
- `RxPattern.sequence(patterns:Iterable<RxPattern>):RxPattern`
    - Applies `>>` to the elements of `patterns`.
	- Returns `RxPattern.Empty` if `patterns` is empty.
- `RxPattern.choice(patterns:Iterable<RxPattern>):RxPattern`
    - Applies `|` to the elements of `patterns`.
	- Returns `RxPattern.Never` if `patterns` is empty.

### Quantifiers

The variable `pattern` is of type `RxPattern`.

- `pattern.option():RxPattern`
    - Matches `pattern` or an empty string.
	- Equivalent to `pattern | RxPattern.Empty`.
- `pattern.many():RxPattern`
    - Matches zero or more repetition of `pattern`.
- `pattern.many1():RxPattern`
    - Matches one or more repetition of `pattern`.

TODO: Add methods for the quantifiers `{m}`, `{m,}` and `{m,n}`.

### Assertions

- `RxPattern.AtStart:RxPattern`
    - Matches at the start of the string.
- `RxPattern.AtEnd:RxPattern`
    - Matches at the end of the string.
- `RxPattern.LookAhead(pattern:RxPattern):RxPattern`
    - Positive look ahead.
- `RxPattern.NotFollowedBy(pattern:RxPattern):RxPattern`
    - Negative look ahead.
- `RxPattern.Never:RxPattern`
    - Never matches anything.
	- Equivalent to `RxPattern.NotFollowedBy(RxPattern.Empty)`.

### Grouping

- `RxPattern.Group(pattern:RxPattern):RxPattern`
    - Creates a capture group.

Since non-capturing groups are automatically created when necessary, there is no function to explicitly create them.

### Accessing Pattern String and EReg object

The variable `pattern` is of type `RxPattern`.

- `pattern.build(options = "u"):EReg`
    - Build an `EReg` object with `pattern`.
- `pattern.get():String`
    - Get the pattern string.
- `RxPattern.buildEReg(pattern:RxPattern, options = "u"):EReg`
    - Same as `pattern.build(options)`
- `RxPattern.getPattern(pattern:RxPattern):String`
    - Same as `pattern.get()`

### Character Set

The variable `charset` is of type `CharSet`.

- `RxPattern.CharSet(set:CharSet):RxPattern`
- `RxPattern.NotInSet(set:CharSet):RxPattern`
- `CharSet.empty():CharSet`
    - Returns an empty character set.
- `CharSet.singleton(c:String):CharSet`
    - Returns a character set with one element `c`.
- `CharSet.fromString(s:String):CharSet`
    - Returns a character set with elements from the string `s`.
- `CharSet.intersection(a:CharSet, b:CharSet):CharSet`
- `CharSet.union(a:CharSet, b:CharSet):CharSet`
- `CharSet.difference(a:CharSet, b:CharSet):CharSet`
- `charset.has(c:String):Bool`
    - The string `c` must consist of a single code point.
- `charset.add(c:String):Void`
    - The string `c` must consist of a single code point.
- `charset.remove(c:String):Void`
    - The string `c` must consist of a single code point.
- `charset.hasCodePoint(x:Int):Bool`
- `charset.addCodePoint(x:Int):Void`
- `charset.removeCodePoint(x:Int):Void`
- `charset.codePointIterator():Iterator<Int>`
- `charset.length:Int`

### Unicode General Category

This library provides `RxPattern` values corresponding Unicode general categories.

If Unicode properties (or, `\p{}` patterns) are available, they are used.
Otherwise, patterns generated from the latest supported Unicode data in [`skial/seri`](https://github.com/skial/seri) will be used.

```haxe
abstract Category {
    var Cc;
    var Cf;
    var Co;
    var Cs;
    var C;
    var Ll;
    var Lm;
    var Lo;
    var Lt;
    var Lu;
    var L;
    var Mc;
    var Me;
    var Mn;
    var M;
    var Nd;
    var Nl;
    var No;
    var N;
    var Pc;
    var Pd;
    var Pe;
    var Pf;
    var Pi;
    var Po;
    var Ps;
    var P;
    var Sc;
    var Sk;
    var Sm;
    var So;
    var S;
    var Zl;
    var Zp;
    var Zs;
    var Z;
    var Letter_UpperCase;
    var Letter_LowerCase;
    var Letter_TitleCase;
    var Letter_Modifier;
    var Mark_NonSpacing;
    var Mark_SpacingCombining;
    var Mark_Enclosing;
    var Number_DecimalDigit;
    var Number_Letter;
    var Number_Other;
    var Punctuation_Connector;
    var Punctuation_Dash;
    var Punctuation_Open;
    var Punctuation_Close;
    var Punctuation_InitialQuote;
    var Punctuation_FinalQuote;
    var Punctuation_Other;
    var Symbol_Math;
    var Symbol_Currency;
    var Symbol_Modifier;
    var Symbol_Other;
    var Separator_Space;
    var Separator_Line;
    var Separator_Paragraph;
    var Other_Control;
    var Other_Format;
    var Other_Surrogate;
    var Other_PrivateUse;
}
```

### Raw Pattern Strings

The terms "Disjunction", "Alternative", "Term" and "Atom" correspond to the rules in [Typical Regular Expression Syntax](#typical-regular-expression-syntax).

The variable `pattern` is of type `RxPattern`.

- `RxPattern.Disjunction(s:String):RxPattern`
    - Returns a `RxPattern` value with given pattern string.
- `RxPattern.Alternative(s:String):RxPattern`
    - Returns a `RxPattern` value with given pattern string.
	- The string `s` must be able to be used as an Alternative: that is, the pattern `s + "a"` matches `s` and the character `a`.
- `RxPattern.Term(s:String):RxPattern`
    - Returns a `RxPattern` value with given pattern string.
	- The string `s` must be able to be used as a Term.
- `RxPattern.Atom(s:String):RxPattern`
    - Returns a `RxPattern` value with given pattern string.
	- The string `s` must be able to be used as an Atom: that is, the pattern `s + "*"` does mean zero or more repetition of `s`.
- `pattern.toDisjunction():String`
    - Returns a pattern string that can be used as a Disjunction. This is same as `pattern.get()`.
- `pattern.toAlternative():String`
    - Return a pattern string that can be used as an Alternative.
    - The string is surrounded by a non-capturing group if necessary.
- `pattern.toTerm():String`
    - Return a pattern string that can be used as a Term.
    - The string is surrounded by a non-capturing group if necessary.
- `pattern.toAtom():String`
    - Return a pattern string that can be used as an Atom.
    - The string is surrounded by a non-capturing group if necessary.

## Appendix

### Typical Regular Expression Syntax

        Pattern ::= Disjunction
    Disjunction ::= Alternative
                  | Alternative "|" Disjunction
    Alternative ::= ""
                  | Alternative Term
           Term ::= Assertion
                  | Atom
                  | Atom Quantifier
      Assertion ::= "^" | "$"
                  | "(?=" Disjunction ")"
                  | "(?!" Disjunction ")"
     Quantifier ::= "*" | "+" | "?"
           Atom ::= PatternCharacter
                  | "\" AtomEscape
                  | CharacterClass
                  | "(" Disjunction ")"
                  | "(?:" Disjunction ")"

