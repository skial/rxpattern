package rxpattern.internal;

#if nodejs
import js.lib.RegExp;
#end

#if java
import java.util.regex.*;
#end

@:forward abstract EReg(ERegImpl) from ERegImpl {

    public inline function new(r:String, opt:String) {
        this = new ERegImpl(r, opt);
    }
    @:to public inline function asStdEReg():std.EReg {
        return cast this;
    }
}

typedef ERegImpl = #if !(nodejs || java)
    std.EReg
#elseif (nodejs && js)
    _JsEReg
#elseif java
	_JavaEReg
#end
;

#if nodejs
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
#elseif java
class _JavaEReg {
	private var pattern:String;
	private var matcher:Matcher;
	private var cur:String;
	private var isGlobal:Bool;

	public function new(r:String, opt:String) {
		var flags = 0;
		for (i in 0...opt.length) {
			switch (StringTools.fastCodeAt(opt, i)) {
				case 'i'.code:
					flags |= Pattern.CASE_INSENSITIVE;
				case 'm'.code:
					flags |= Pattern.MULTILINE;
				case 's'.code:
					flags |= Pattern.DOTALL;
				case 'g'.code:
					isGlobal = true;
			}
		}

		flags |= Pattern.UNICODE_CASE;
		#if !android // see https://github.com/HaxeFoundation/haxe/issues/7632
		flags |= Pattern.UNICODE_CHARACTER_CLASS;
		#end
		flags |= Pattern.CANON_EQ;
		var _p = Pattern.compile(r, flags);
		//trace( _p.pattern() );
		matcher = _p.matcher("");
		pattern = r;
	}

	public function match(s:String):Bool {
		cur = s;
		matcher = matcher.reset(s);
		return matcher.find();
	}

	public function matched(n:Int):String {
		if (n == 0)
			return matcher.group();
		else
			return matcher.group(n);
	}

	public function matchedLeft():String {
		return untyped cur.substring(0, matcher.start());
	}

	public function matchedRight():String {
		return untyped cur.substring(matcher.end(), cur.length);
	}

	public function matchedPos():{pos:Int, len:Int} {
		var start = matcher.start();
		return {pos: start, len: matcher.end() - start};
	}

	public function matchSub(s:String, pos:Int, len:Int = -1):Bool {
		matcher = matcher.reset(len < 0 ? s : s.substr(0, pos + len));
		cur = s;
		return matcher.find(pos);
	}

	public function split(s:String):Array<String> {
		if (isGlobal) {
			var ret = [];
			while (this.match(s)) {
				ret.push(matchedLeft());
				s = matchedRight();
			}
			ret.push(s);
			return ret;
		} else {
			var m = matcher;
			m.reset(s);
			if (m.find()) {
				return untyped [s.substring(0, m.start()), s.substring(m.end(), s.length)];
			} else {
				return [s];
			}
		}
	}

	inline function start(group:Int):Int {
		return matcher.start(group);
	}

	inline function len(group:Int):Int {
		return matcher.end(group) - matcher.start(group);
	}

	public function replace(s:String, by:String):String {
		matcher.reset(s);
		by = by.split("$$").join("\\$");
		return isGlobal ? matcher.replaceAll(by) : matcher.replaceFirst(by);
	}

	public function map(s:String, f:_JavaEReg->String):String {
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
			} else
				offset = p.pos + p.len;
		} while (isGlobal);
		if (!isGlobal && offset > 0 && offset < s.length)
			buf.add(s.substr(offset));
		return buf.toString();
	}

	public static inline function escape(s:String):String {
		return Pattern.quote(s);
	}
}
#end