package rxpattern;

enum abstract RxErrors(String) to String {
    var Char_NotSingleCharacter = "rxpattern.RxPattern.Char: Not a single character.";
    var CharSet_NotCodePoint = "rxpattern.CharSet: Not a single code point.";
    var Unicode_InvalidEscape = "Invalid Unicode escape sequence.";
    var Unicode_GreaterThanBMP = "This platform does not support Unicode escape beyond BMP.";
}