// RUN: ~/ldc/ldc2-1.9.0-osx-x86_64/bin/ldc2 -g -i -fsanitize=fuzzer fuzz_dxml.d

import ldc.libfuzzer;
mixin DefineTestOneInput!fuzzMe;

int fuzzMe(in ubyte[] data)
{
    import dxml.parser;
    try
    {
        int sum;
        auto range = parseXML(cast(char[])data);
        foreach (elem; range) {
            // Do something unpredictable to actually test the parser
            sum += cast(int) elem.type;
        }
        return sum > 1;
    }
    catch (XMLParsingException)
    {
        return 0;
    }
}
