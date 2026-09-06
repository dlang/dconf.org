// RUN: ~/ldc/ldc2-1.9.0-osx-x86_64/bin/ldc2 -g -fsanitize=fuzzer dconf_fuzz.d

import ldc.libfuzzer;

// Set "fuzzMe" as fuzz entry point
mixin DefineTestOneInput!fuzzMe;

int fuzzMe(in ubyte[] data)
{
    // Test that the first and Nth element are '<' and '>',
    // and that two chars in the middle are equal.
    enum N = 10;
    if (data.length >= N  &&
        data[0] == '<'    &&
        data[N/2] == data[N/2+1] &&
        data[N] == '>')
    {
        return 1;
    }

    return 0;
}
