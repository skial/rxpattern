package rxpattern.internal.utf16;

import unifill.Unicode;
import uhx.sys.seri.Range;
import uhx.sys.seri.Ranges;
import rxpattern.RxPattern;
import rxpattern.internal.Util as TargetUtil;
import rxpattern.internal.std.Util as StdUtil;

using rxpattern.internal.std.Util;

class Util {

    /*public static function printCode(v:Int):String {
        switch v {
            #if (!nodejs && js)
            case 0:
                return js.Syntax.code("\"\\0\"");
            #end

            case _.isValidAscii() => true:
                return String.fromCharCode(v);

            case _:

        }
        return 
        #if (nodejs || (js && js_es > 5))
            // Haxe only supports es5 or greater.
            // ES6/ES2015 introduced `u` flag & `\u{0123}` format.
            '\\u{' + StringTools.hex(v, 4) + '}';
        #else
            '\\u' + StringTools.hex(v, 4);
        #end
    }*/
    public static inline function printCode(v:Int):String
        return switch v {
            #if js
            case 0: return '\\0';
            case x if(!x.isValidAscii() && x <= 0xFF): return '\\x' + StringTools.hex(v, 2);
            #end
            case _: rxpattern.internal.std.Util.printCode(v);
        }

    public static var HI = new Range(0xD800, 0xDBFF);
    public static var LO = new Range(0xDC00, 0xDFFF);

    // @see https://github.com/mathiasbynens/regenerate/blob/master/regenerate.js#L667
    public static function splitAtBMP(ranges:Ranges) {
        var loneHi = [];
        var loneLo = [];
        var bmp = [];
        var astral = [];

        var idx = 0;
        var len = ranges.values.length;

        var range:Range;

        while (idx < len) {
            range = ranges.values[idx];
            ////untyped console.log( range );
            
            if (range.min < HI.min) {

                // The range starts and ends before the high surrogate range.
				// E.g. (0, 0x10).
                if (range.max < HI.min) {
                    bmp.push(range.copy());
                }

                // The range starts before the high surrogate range and ends within it.
				// E.g. (0, 0xD855).
				if (range.max >= HI.min && range.max <= HI.max) {
					bmp.push(new Range(range.min, HI.min-1));
					loneHi.push(new Range(HI.min, range.max));
				}

                // The range starts before the high surrogate range and ends in the low
				// surrogate range. E.g. (0, 0xDCFF).
				if (range.max >= LO.min && range.max <= LO.max) {
					bmp.push(new Range(range.min, HI.min-1));
					loneHi.push(new Range(HI.min, HI.max));
					loneLo.push(new Range(LO.min, range.max));
				}

                // The range starts before the high surrogate range and ends after the
				// low surrogate range. E.g. (0, 0x10FFFF).
				if (range.max > LO.max) {
					bmp.push(new Range(range.min, HI.min-1));
					loneHi.push(new Range(HI.min, HI.max));
					loneLo.push(new Range(LO.min, LO.max));
					if (range.max <= 0xFFFF) {
						bmp.push(new Range(LO.max+1, range.max));

					} else {
						bmp.push(new Range(LO.max+1, 0xFFFF));
						astral.push(new Range(0xFFFF+1, range.max));

					}
				}

            } else if (range.min >= HI.min && range.min <= HI.max) {

                // The range starts and ends in the high surrogate range.
				// E.g. (0xD855, 0xD866).
				if (range.max >= HI.min && range.max <= HI.max) {
					loneHi.push(range.copy());
				}

				// The range starts in the high surrogate range and ends in the low
				// surrogate range. E.g. (0xD855, 0xDCFF).
				if (range.max >= LO.min && range.max <= LO.max) {
					loneHi.push(new Range(range.min, HI.max));
					loneLo.push(new Range(LO.min, range.max));
				}

				// The range starts in the high surrogate range and ends after the low
				// surrogate range. E.g. (0xD855, 0x10FFFF).
				if (range.max > LO.max) {
					loneHi.push(new Range(range.min, HI.max));
					loneLo.push(new Range(LO.min, LO.max));
					if (range.max <= 0xFFFF) {
						bmp.push(new Range(LO.max+1, range.max));

					} else {
						bmp.push(new Range(LO.max+1, 0xFFFF));
						astral.push(new Range(0xFFFF+1, range.max));

					}
				}

            } else if (range.min >= LO.min && range.min <= LO.max) {

                // The range starts and ends in the low surrogate range.
				// E.g. (0xDCFF, 0xDDFF).
				if (range.max >= LO.min && range.max <= LO.max) {
					loneLo.push(range.copy());
				}

				// The range starts in the low surrogate range and ends after the low
				// surrogate range. E.g. (0xDCFF, 0x10FFFF).
				if (range.max > LO.max) {
					loneLo.push(new Range(range.min, LO.max));
					if (range.max <= 0xFFFF) {
						bmp.push(new Range(LO.max+1, range.max));

					} else {
						bmp.push(new Range(LO.max+1, 0xFFFF));
						astral.push(new Range(0xFFFF+1, range.max));

					}
				}

            } else if (range.min > LO.max && range.min <= 0xFFFF) {

                // The range starts and ends after the low surrogate range.
				// E.g. (0xFFAA, 0x10FFFF).
				if (range.max <= 0xFFFF) {
					bmp.push(range.copy());

				} else {
					bmp.push(new Range(range.min, 0xFFFF));
					astral.push(new Range(0xFFFF+1, range.max));

				}

            } else {

                // The range starts and ends in the astral range.
				astral.push(range.copy());

            }

            idx++;
            ////untyped console.log('' + bmp);

        }

        return { loneHi: loneHi, loneLo: loneLo, bmp: bmp, astral: astral };
    }

    // @see https://github.com/mathiasbynens/regenerate/blob/master/regenerate.js#L893
    @:nullSafety(Strict) public static function surrogateSet(ranges:Ranges) {
        var idx = 0;
        var len = ranges.values.length;
        var surrogateMappings:Array<{a:Range, b:Range}> = [];
        var start = new Range(0, 0);
        var end = new Range(0, 0);
        var range:Range;
        var _end = 0;

        while (idx < len) {
            range = ranges.values[idx];
            _end = range.max;
            
            start.max = Unicode.encodeHighSurrogate(range.min); // startHigh
            start.min = Unicode.encodeLowSurrogate(range.min);  // startLow
            end.max = Unicode.encodeHighSurrogate(_end);   // endHigh
            end.min = Unicode.encodeLowSurrogate(_end);    // endLow

            var startsWithLowestLo = start.min == LO.min;
            var endsWithHighestLo = end.min == LO.max;
            var complete = false;

            // Append the previous high-surrogate-to-low-surrogate mappings.
			// Step 1: `(startHigh, startLow)` to `(startHigh, LOW_SURROGATE_MAX)`.
			if (
				start.max == end.max ||
				startsWithLowestLo && endsWithHighestLo
			) {
				surrogateMappings.push({
					a:new Range(start.max, end.max),
					b:new Range(start.min, end.min)
				});
				complete = true;
			} else {
				surrogateMappings.push({
					a:new Range(start.max, start.max),
					b:new Range(start.min, LO.max)
                });
			}

			// Step 2: `(startHigh + 1, LOW_SURROGATE_MIN)` to
			// `(endHigh - 1, LOW_SURROGATE_MAX)`.
			if (!complete && start.max+1 < end.max) {
				if (endsWithHighestLo) {
					// Combine step 2 and step 3.
					surrogateMappings.push({
						a:new Range(start.max+1, end.max),
						b:new Range(LO.min, end.min)
                    });
					complete = true;
				} else {
					surrogateMappings.push({
						a:new Range(start.max+1, end.max),
						b:new Range(LO.min, LO.max)
                    });
				}
			}

			// Step 3. `(endHigh, LOW_SURROGATE_MIN)` to `(endHigh, endLow)`.
			if (!complete) {
				surrogateMappings.push({
					a:new Range(end.max, end.max),
					b:new Range(LO.min, end.min)
                });
			}

            idx++;

        }
        // The format of `surrogateMappings` is as follows:
		//
		//     [ surrogateMapping1, surrogateMapping2 ]
		//
		// i.e.:
		//
		//     [
		//       [ highSurrogates1, lowSurrogates1 ],
		//       [ highSurrogates2, lowSurrogates2 ]
		//     ]
        //untyped console.log( surrogateMappings );
		return optimizeSurrogateMappings(surrogateMappings);
    }

    // @see https://github.com/mathiasbynens/regenerate/blob/master/regenerate.js#L794
    @:nullSafety(Strict) public static function optimizeSurrogateMappings(surrogateMappings:Array<{a:Range, b:Range}>) {
        var result:Array<{a:Ranges, b:Ranges}> = [];
        var tmpLow = new Ranges([]);
        var addLow = false;
        var mapping:{a:Range, b:Range};
        var nextMapping:{a:Range, b:Range};
        var hi:Range;
        var lo:Range;
        var nextHi:Range;
        var nextLo:Range;
        var idx = -1;
        var len = surrogateMappings.length;
        //trace( surrogateMappings );
        while (++idx < len) {
            mapping = surrogateMappings[idx];
            //trace( mapping );
            nextMapping = surrogateMappings[idx + 1];

            if (nextMapping == null) {
                //result.push(mapping);
                result.push( {a:new Ranges([mapping.a]), b:new Ranges([mapping.b])} );
                //result.push(mapping.b);
                continue;
            }

            hi = mapping.a;
            lo = mapping.b;
            nextHi = nextMapping.a;
            nextLo = nextMapping.b;

            // Check for identical high surrogate ranges.
            tmpLow = new Ranges([lo]);
            while (nextHi != null && hi.min == nextHi.min && hi.max == nextHi.max) {
                // Merge with the next item.
                if (nextLo.length == 1) {
                    tmpLow.add(nextLo.min);

                } else {
                    tmpLow.add(new Range(nextLo.min, nextLo.max/*-1*/));

                }
                ++idx;
                mapping = surrogateMappings[idx];
                hi = mapping.a;
                lo = mapping.b;
                addLow = true;
                if (surrogateMappings[idx+1] != null) {
                    nextMapping = surrogateMappings[idx + 1];
                    nextHi = nextMapping.a;
                    nextLo = nextMapping.b;

                } else {
                    break;
                }
                
            }
            result.push( {a:new Ranges([hi]), b:addLow ? tmpLow : new Ranges([lo])} );
            //addLow ? for (r in tmpLow.values) result.push(r) : result.push(lo);
            addLow = false;
        }

        //////untyped console.log( result );
        return optimizeByLowSurrogates(result);
        //trace( result );
        //return result;
    }

    // @see https://github.com/mathiasbynens/regenerate/blob/master/regenerate.js#L853
    @:nullSafety(Strict) public static function optimizeByLowSurrogates(surrogateMappings:Array<{a:Ranges, b:Ranges}>) {
        if (surrogateMappings.length == 1) return surrogateMappings;
        var idx = -1;
        var innerIdx = -1;

        while (++idx < surrogateMappings.length) {
            var mapping = surrogateMappings[idx];
            var low = mapping.b.values;
            var lowStart = low[0].min;
            var lowEnd = low[0].max;
            innerIdx = idx;

            while (++innerIdx < surrogateMappings.length) {
                var otherMapping = surrogateMappings[innerIdx];
                var otherLow = otherMapping.b.values;
                var otherLowStart = otherLow[0].min;
                var otherLowEnd = otherLow[0].max;

                if (lowStart == otherLowStart && lowEnd == otherLowEnd) {
                    if (otherMapping.a.values.length == 1) {
                        mapping.a.add(otherMapping.a.values[0]);
                    } else {
                        mapping.a.add(new Range(otherMapping.a.values[0].min, otherMapping.a.values[1].max-1));
                    }

                    surrogateMappings.splice(innerIdx, 1);
                    --innerIdx;
                }
            }
        }
        return surrogateMappings;
    }

    public static function printRanges(ranges:Ranges):RxPattern {
        //#if (cs || js && !nodejs)
        ranges = ranges.copy();
        var results = [];
        var parts = splitAtBMP(ranges);
        //untyped console.log( parts );
        var loneHi = parts.loneHi;
        var loneLo = parts.loneLo;
        var bmp = parts.bmp;
        var astral = parts.astral;
        var hasLoneHi = loneHi.length > 0;
        var hasLoneLo = loneLo.length > 0;
        var surrogateMappings = surrogateSet(new Ranges(astral));
        //untyped console.log( surrogateMappings );
        
        if (bmp.length > 0) {
            results.push( StdUtil.printRanges(new Ranges(bmp)).get() );
        }
        if (surrogateMappings.length > 0) {
            for (mapping in surrogateMappings) {
                results.push(
                    StdUtil.printRanges(mapping.a).get() +
                    StdUtil.printRanges(mapping.b).get()
                );
            }
        }
        if (hasLoneHi) {
            results.push(
                StdUtil.printRanges(new Ranges(loneHi)).get() + 
                '(?![${TargetUtil.printCode(0xDC00)}-${TargetUtil.printCode(0xDFFF)}])'
            );
        }
        if (hasLoneLo) {
            results.push(
                '(?:[^${TargetUtil.printCode(0xD800)}-${TargetUtil.printCode(0xDBFF)}]|^)' +
                StdUtil.printRanges(new Ranges(loneLo)).get()
            );
        }
        return RxPattern.Disjunction(results.join('|'));
    }

}