package rxpattern;

import rxpattern.RxPattern;
import rxpattern.UnicodePatternUtil.printCategory;

@:notNull
@:forward
@:forwardStatics
abstract Category(RxPattern) to RxPattern {

    public static var Letter_UpperCase = printCategory("Lu");
    public static var Letter_LowerCase = printCategory("Ll");
    public static var Letter_TitleCase = printCategory("Lt");
    public static var Letter_Modifier = printCategory("Lm");
    public static var Mark_NonSpacing = printCategory("Mn");
    public static var Mark_SpacingCombining = printCategory("Mc");
    public static var Mark_Enclosing = printCategory("Me");
    public static var Number_DecimalDigit = printCategory("Nd");
    public static var Number_Letter = printCategory("Nl");
    public static var Number_Other = printCategory("No");
    public static var Punctuation_Connector = printCategory("Pc");
    public static var Punctuation_Dash = printCategory("Pd");
    public static var Punctuation_Open = printCategory("Ps");
    public static var Punctuation_Close = printCategory("Pe");
    public static var Punctuation_InitialQuote = printCategory("Pi");
    public static var Punctuation_FinalQuote = printCategory("Pf");
    public static var Punctuation_Other = printCategory("Po");
    public static var Symbol_Math = printCategory("Sm");
    public static var Symbol_Currency = printCategory("Sc");
    public static var Symbol_Modifier = printCategory("Sk");
    public static var Symbol_Other = printCategory("So");
    public static var Separator_Space = printCategory("Zs");
    public static var Separator_Line = printCategory("Zl");
    public static var Separator_Paragraph = printCategory("Zp");
    public static var Other_Control = printCategory("Cc");
    public static var Other_Format = printCategory("Cf");
    public static var Other_Surrogate = printCategory("Cs");
    public static var Other_PrivateUse = printCategory("Co");

    public static var Cc = printCategory("Cc");
    public static var Cf = printCategory("Cf");
    public static var Co = printCategory("Co");
    public static var Cs = printCategory("Cs");
    public static var C = printCategory("C");
    public static var Ll = printCategory("Ll");
    public static var Lm = printCategory("Lm");
    public static var Lo = printCategory("Lo");
    public static var Lt = printCategory("Lt");
    public static var Lu = printCategory("Lu");
    public static var L = printCategory("L");
    public static var Mc = printCategory("Mc");
    public static var Me = printCategory("Me");
    public static var Mn = printCategory("Mn");
    public static var M = printCategory("M");
    public static var Nd = printCategory("Nd");
    public static var Nl = printCategory("Nl");
    public static var No = printCategory("No");
    public static var N = printCategory("N");
    public static var Pc = printCategory("Pc");
    public static var Pd = printCategory("Pd");
    public static var Pe = printCategory("Pe");
    public static var Pf = printCategory("Pf");
    public static var Pi = printCategory("Pi");
    public static var Po = printCategory("Po");
    public static var Ps = printCategory("Ps");
    public static var P = printCategory("P");
    public static var Sc = printCategory("Sc");
    public static var Sk = printCategory("Sk");
    public static var Sm = printCategory("Sm");
    public static var So = printCategory("So");
    public static var S = printCategory("S");
    public static var Zl = printCategory("Zl");
    public static var Zp = printCategory("Zp");
    public static var Zs = printCategory("Zs");
    public static var Z = printCategory("Z");
}