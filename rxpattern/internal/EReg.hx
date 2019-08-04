package rxpattern.internal;

#if (js && (nodejs || js_es > 5))
import js.lib.RegExp;
#end

@:forward abstract EReg(ERegImpl) from ERegImpl {

    public inline function new(r:String, opt:String) {
        this = new ERegImpl(r, opt);
    }
    @:to public inline function asStdEReg():std.EReg {
        return cast this;
    }
}

typedef ERegImpl = #if !(js && (nodejs || js_es > 5))
    std.EReg
#elseif (js && (nodejs || js_es > 5))
    _JsEReg
#end
;

#if (js && (nodejs || js_es > 5))
class _JsEReg {

	var r : HaxeRegExp;

	public inline function new( r : String, opt : String ) : Void {
		this.r = new HaxeRegExp(r, opt);
	}

	public function match( s : String ) : Bool {
		if( r.global ) r.lastIndex = 0;
		r.m = r.exec(s);
		r.s = s;
		return (r.m != null);
	}

	public function matched( n : Int ) : String {
		return if( r.m != null && n >= 0 && n < r.m.length ) r.m[n] else throw "EReg::matched";
	}

	public function matchedLeft() : String {
		if( r.m == null ) throw "No string matched";
		return r.s.substr(0,r.m.index);
	}

	public function matchedRight() : String {
		if( r.m == null ) throw "No string matched";
		var sz = r.m.index+r.m[0].length;
		return r.s.substr(sz,r.s.length-sz);
	}

	public function matchedPos() : { pos : Int, len : Int } {
		if( r.m == null ) throw "No string matched";
		return { pos : r.m.index, len : r.m[0].length };
	}

	public function matchSub( s : String, pos : Int, len : Int = -1):Bool {
		return if (r.global) {
			r.lastIndex = pos;
			r.m = r.exec(len < 0 ? s : s.substr(0, pos + len));
			var b = r.m != null;
			if (b) {
				r.s = s;
			}
			b;
		} else {
			// TODO: check some ^/$ related corner cases
			var b = match( len < 0 ? s.substr(pos) : s.substr(pos,len) );
			if (b) {
				r.s = s;
				r.m.index += pos;
			}
			b;
		}
	}

	public function split( s : String ) : Array<String> {
		// we can't use directly s.split because it's ignoring the 'g' flag
		var d = "#__delim__#";
		return replace(s,d).split(d);
	}

	public inline function replace( s : String, by : String ) : String {
		return (cast s).replace(r,by);
	}

	public function map( s : String, f : _JsEReg -> String ) : String {
		var offset = 0;
		var buf = new StringBuf();
		do {
			if (offset >= s.length)
				break;
			else if (!matchSub(s, offset)) {
				buf.add(s.substr(offset));
				break;
			}
			var p = matchedPos();
			buf.add(s.substr(offset, p.pos - offset));
			buf.add(f(this));
			if (p.len == 0) {
				buf.add(s.substr(p.pos, 1));
				offset = p.pos + 1;
			}
			else
				offset = p.pos + p.len;
		} while (r.global);
		if (!r.global && offset > 0 && offset < s.length)
			buf.add(s.substr(offset));
		return buf.toString();
	}

	public static inline function escape( s : String ) : String {
		return (cast s).replace(escapeRe, "\\$&");
	}
	static var escapeRe = new js.lib.RegExp("[.*+?^${}()|[\\]\\\\]", "g");
}
@:native("RegExp")
private extern class HaxeRegExp extends js.lib.RegExp {
	var m:js.lib.RegExp.RegExpMatch;
	var s:String;
}
#end