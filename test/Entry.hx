package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Entry {

    public static function main() {
        Runner.run(TestBatch.make([
            new rxpattern.IntSetSpec(),
            new rxpattern.RxPatternSpec(),
            new rxpattern.ExampleSpec(),
        ])).handle( Runner.exit );
    }

}