package rxpattern;

enum abstract RxErrors(String) to String {
    var Char_NotSingleCharacter = "rxpattern.RxPattern.Char: not a single character";
    var CharSet_NotCodePoint = "rxpattern.CharSet: not a single code point";
    var Unicode_InvalidEscape = "Invalid unicode escape sequence";
    var Unicode_GreaterThanBMP = "This platform does not support Unicode escape beyond BMP.";
}