package rxpattern;

@:asserts class IntSetSpec {

    public function new() {}

    public function testAdd() {
        var a = IntSet.empty();
        asserts.assert( !a.has(0) );
        a.add(3);
        asserts.assert( a.has(3) );
        a.add(8);
        asserts.assert( a.has(3) );
        asserts.assert( a.has(8) );
        return asserts.done();
    }

    public function testRemove() {
        var b = IntSet.fromIterable([1, 3, 5, 7]);
        asserts.assert( b.has(3) );
        asserts.assert( b.has(5) );
        asserts.assert( b.has(7) );
        asserts.assert( !b.has(4) );
        b.remove(5);
        asserts.assert( !b.has(5) );
        return asserts.done();
    }

    public function testFromRange() {
        var d = IntSet.fromRange(1, 10);
        asserts.assert( d.has(1) );
        asserts.assert( d.has(5) );
        asserts.assert( d.has(9) );
        asserts.assert( !d.has(10) );
        return asserts.done();
    }

    public function testUnion() {
        var a = IntSet.fromIterable([3, 8]);
        var b = IntSet.fromIterable([1, 3, 7]);
        var c = IntSet.union(a, b);
        asserts.assert( c.has(1) );
        asserts.assert( c.has(3) );
        asserts.assert( c.has(7) );
        asserts.assert( c.has(8) );
        return asserts.done();
    }

    public function testDifference() {
        var c = IntSet.fromIterable([1, 3, 7, 8]);
        var d = IntSet.fromRange(1, 10);
        var e = IntSet.difference(d, c);
        asserts.assert( !e.has(1) );
        asserts.assert( e.has(2) );
        asserts.assert( !e.has(3) );
        asserts.assert( e.has(4) );
        asserts.assert( e.has(5) );
        asserts.assert( e.has(6) );
        asserts.assert( !e.has(7) );
        asserts.assert( !e.has(8) );
        asserts.assert( e.has(9) );
        asserts.assert( !e.has(10) );
        return asserts.done();
    }

}