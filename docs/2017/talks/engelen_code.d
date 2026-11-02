//##############################################################
//##############################################################

// Measuring performance

int foo(int a, int b, int c) {
    return a + b + c;
}

void measureFunctionCall()
{
    int a = 5555, b = 123, c = 9090;
    startTimer();
    foreach (i; 0 .. 1_000_000)
        foo(a, b, c);
    stopTimer();
    printTimer();
}

void startTimer();
void stopTimer();
void printTimer();


//##############################################################
//##############################################################

// Inline assembly

extern(C):

int incr(int i) {
    return i + 1;
}

int incrASM(int i) {
    asm {
        add i, 1;
    }
    return i;
}

int incrASMnaked(int i) {
    asm {
        naked;
        mov EAX, EDI;
        add EAX, 1;
        ret;
    }
}





/*
import ldc.llvmasm;
pragma(LDC_inline_ir) R __ir(string s, R, P...)(P);

int incrASMldc(int i) {
  return __asm!(int)(
             "mov $1, $0    \n" ~
             "add $$1, $0",
              "={eax}, r", i);
}

int incrIR(int i) {
  return __ir!("%temp = add i32 %0, 1   \n" ~
               "ret i32 %temp",
               int, int)(i);
}
*/


//##############################################################
//##############################################################


// Loops

int foo(int i); // unknown function

void f1() {
    for (int a; a < 17; a++) {
      foo(a);
    }
}

void f2() {
    foreach (a; 0..17) {
      foo(a);
    }
}

void f3() {
    foreach (a; [0,1,2,3,4,5,6,7,
                 8,9,10,11,12,13,
                 14,15,16])
    {
      foo(a);
    }
}

void f4() {
    import std.range : iota;
    foreach (a; iota(0, 17))
    {
      foo(a);
    }
}

// n

// |
// V




void f5() {
    auto   list = [0,1,2,3,4,5,6,7,
                   8,9,10,11,12,13,
                   14,15,16];
    foreach (a; list)
    {
      foo(a);
    }
}




//##############################################################
//##############################################################


void foo() {
  // GC allocation, not optimized out, YET!
  const auto a = [1, 1];

  // Initializer is immutable link-time
  // constant, runtime code is optimized out.
  immutable auto b = [1, 1];
}

//##############################################################
//##############################################################

// Const ?

int foo(/* const */ int *a,
        ref int arr)
{
    auto b = *a;
    arr = 1;
    return *a + b;
}


//##############################################################
//##############################################################

// For Ali: pass by pointer, pass by ref?

extern(C):

alias T = int;
T byPtr(int n, T *c) {
  T sum;
  for (int i=0; i < n; ++i)
    if (i > 0)
      sum += *c;
  return sum;
}

T byRef(int n, ref T c) {
  T sum;
  for (int i=0; i < n; ++i)
    if (i > 0)
      sum += c;
  return sum;
}

int f(int);



//##############################################################
//##############################################################

// Interface or class?

interface I
//class I
{
 int foo();
}

class A : I {
  override int foo() { return 1;}
}

class B : A {
  override int foo() { return 2;}
}

A getB() { return new B; }

int getBcallfoo() {
    auto a = getB();
    return a.foo();
}

int callfoo(I a) {
    return a.foo();
}

int indirect(A a) {
    return callfoo(getB());
}




import ldc.attributes;


//##############################################################
//##############################################################


// Devirtualization

class A {
  int foo() { return 1;}
}

int callfoo()
{
  auto a = new A();
  /* cl nw */
  int total = 0;
  for (int i = 0; i < 2 /**/; i++)
  {
    total += a.foo();
  }
  return total;
}

void clobber(const A a);


// Class methods are not allowed to change the virtual pointer. Right? Check the spec!!! Recent work on Clang shows the path: after a class method call, tell the optimizer that the vptr field in the object is unchanged.


//##############################################################
//##############################################################

// Stat/Dyn array comparison

extern(C):

alias T = byte;
enum N = 40;
bool cmp(T[N] a, T[N] b)
{
     return a == b;
}


//##############################################################
//##############################################################

// Delegates are slow

extern(C):

alias V = int;
struct KV {
  align(1):
   byte k;
   V* v;
}

void fooTrusted(ref KV kv, V* v) @trusted {
  kv.v = v;
}

void fooSafe(ref KV kv, V* v) @safe {
  () @trusted { kv.v = v; }();
}


//##############################################################
//##############################################################


// Delegates

import ldc.attributes;
@weak
int add(int a, int b) { return a + b; }

int fooloop(int a, int b)
{
   int sum;
   for (int i=0; i < a; ++i) {
       sum += add(i, b);
   }
   return sum;
}

int fooloopLambda(int a, int b)
{
   int sum;
   auto f = (int n) => add(n, b);
   for (int i=0; i < a; ++i) {
       sum += f(i);
   }
   return sum;
}




int bar(int a, int delegate(int) f)
{
   int sum;
   for (int i=0; i < a; ++i) {
       sum += f(i);
   }
   return sum;
}

int callbar(int a, int b)
{
   auto f = delegate(int n) {
      return add(n, b);
   };
   return bar(a, f);
}



final class Adder {
  int b;
  this(int b_) {
    b = b_;
  }
  int opCall(int n) {
    return add(n, b);
  }
}

int barClass(int a, Adder f)
{
  int sum;
  for (int i=0; i < a; ++i) {
      sum += f(i);
  }
  return sum;
}

int callbarClass(int a, int b)
{
   auto f = new Adder(b);
   return barClass(a, f);
}






//##############################################################
//##############################################################


import ldc.attributes;
@weak
void bar(int a, void delegate(int) f)
{
   for (int i=0; i < a; ++i) {
       f(i);
   }
}

int callbar(int a, int b)
{
   int sum;
   auto f = delegate(int n) {
      sum += n;
   };
   bar(a, f);
   return sum;
}




//##############################################################
//##############################################################


// Example from "D as a Better C" presentation.

import io = std.stdio;

class A {
    void output() {
        io.writeln("hoi");
    }
}

void main() {
    //auto i = new int;
    auto a = new A();
    a.output();
}






//##############################################################
//##############################################################

import std.algorithm;
import std.range;

int total(int n)
{
  return iota(1,100)
         .map!((int a) => 3*a)
         .reduce!((int a, int b) => a+b);
}

//##############################################################
//##############################################################




// double struct initialization:


struct S {
  int[100] a;
  float b;

  this(float f) { b = f; }
}

void unknown(ref S);

void foo() {
    auto s = S(1.0);
    unknown(s);
}

void bar() {
    S s = void;
    s.b = 1.0;
    unknown(s);
}

void great() {
    S s = void;
    s.__ctor(1.0);
    unknown(s);
}



