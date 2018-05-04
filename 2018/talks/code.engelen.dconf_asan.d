class A {
    int i;
}

void inc(A a) {
    a.i += 1; // Line 6
}

auto makeA() {  // Line 9
    import std.algorithm : move;
    // "scope" allocates object on the stack instead of the heap
    scope a = new A();
    return move(a);
}

void main() {
    auto a = makeA();
    a.inc(); // Line 18
}

// ~/ldc/ldc2-1.9.0-osx-x86_64/bin/ldc2 -g -fsanitize=address dconf_asan.d
// ASAN_OPTIONS=detect_stack_use_after_return=1 ./dconf_asan 2>&1 | ddemangle