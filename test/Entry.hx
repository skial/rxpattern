package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Entry {

    public static function main() {
        Runner.run(TestBatch.make([
            new rxpattern.PrintCodeSpec(),
            new rxpattern.PrintRangeSpec(),
            new rxpattern.IntSetSpec(),
            new rxpattern.RxPatternSpec(),
            new rxpattern.ExampleSpec(),
            new rxpattern.CategorySpec(),
        ])).handle( Runner.exit );
    }

}