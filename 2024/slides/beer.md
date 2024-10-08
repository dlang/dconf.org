# Effective Dustmite

Dustmite is a tool written by CyberShadow that ships with the stock DMD download. It is a bug reducer.

Have you ever run into a compiler bug? Or some error message that you didn't understand, because it
involved too much source code? Have you formed a theory about what was its cause, only for your
simple testcase to end up unable to reproduce it? How does everybody else make those nice, simple
testcases anyways? The answer is Dustmite.

How does that work? In fully general terms, Dustmite takes two things: a test folder, and a tester.
The tester *demonstrates the presence* of the bug. In other words, the tester is some form of executable,
a D file, a Bash script, a bat file, that is executed in the test folder and succeeds if and only if the
bug is present.

# How do I do this?

Let's step through a basic reduction. This is the workflow I use, born from experience:

1. Make a new folder for the repro.
2. Copy your project to `./src1/` in the repro folder.
3. Create your repro script in `repro1.sh`. Note that this should run *from* `./src1/`, but
  it should be *placed* in the repro folder itself. Remember to make it executable with `chmod +x`!
4. Run dustmite: `dustmite src1 ../repro1.sh`. This will create `src1.reduced`.
5. Don't even look at that folder! **First,** copy the output folder to `src2` and the repro script to `repro2.sh`.
6. Look at the source and decide what follow-up steps to take.
7. Repeat 4-7 until your output is sufficiently minimal.

So you end up with this structure:

```
/test
/test/src1/
/test/src1.reduced/
/test/repro1.sh
/test/src2/
/test/src2.reduced/
/test/repro2.sh
/test/src3/
/test/repro3.sh
```

Why all the copying? It is *very* easy to look at the output and go "oh, I understand the issue now,
I'll simplify it a bit more and then file the bug." It's often not what you think! The `src.reduced` folder
is the product of **hours** of compute. Keep it pristine. If you mess up your `src2`, you can just delete it
and restart from `src1.reduced`.

That's it. However, the devil is in the details.

# How does Dustmite actually work?

To understand the following sections, it's important to have a good model for the actual thing that Dustmite does.

Dustmite internally:

- reads in the *complete* source folder.
- validates the repro script:
  it should succeed (that is, demonstrate the error) with the repro, but fail with an empty folder.
- In a loop:
  - performs a reduction operation, which is usually deleting a piece of the parse tree, ie. removing
    a function call, emptying a string, removing an empty loop, or even removing a whole file or function
  - writes out the modified source, then tests if the error still exists (the repro script still passes)
  - if yes, records the modified output as a success; if not, as a failure.
  - continues while it can remove parts of source code and the repro script keeps generating successes
- When it can find no more reductions, it exits.

# Writing a good repro script

In other tools, you may have different workflows for debugging a compiler crash, an application crash, or
a miscompilation. Dustmite doesn't care. The tester may use *any means* to ascertain the presence of the bug.
In technical terms, Dustmite looks at the exit status of the tester. This can mess you up: if you are testing
for a compiler crash, you have to *invert* the exit status:

```
#!/bin/bash
dmd test.d
# segfault
[ $? = 139 ]
```

Or to test the produced binary:

```
#!/bin/bash
dmd test.d -oftest
./test
[ $? = 139 ]
```

However, this is still not a very good repro. Why?

As a rule, we want to test for as much _relevant_ details as possible while excluding as many _irrelevant_ details
as we can. For instance, when debugging a segfault, it is common for Dustmite to replace one segfault with another,
totally unrelated segfault. It turns out that when removing code, it's easy to arrive at code that segfaults. :)

When at all possible, you should replace a generic segfault with something like an assertion at a specific line.
Debug the segfault, replace it with a null check that asserts out, then:

```
(./program && exit) 2>&1 |grep 'Error Message Goes Here'
```

Similarly, you can test for DMD error messages in the same way.

However, how do you avoid Dustmite optimizing out the assignment of the field that becomes null, then? One
easy trick is to hide the error message in a file that is outside your source folder, then compile it in with
`dmd ../error1.d`. In fact, this is exactly why we keep the tester outside the source folder: otherwise, Dustmite
would correctly notice that the easiest way to make the tester pass is to delete all lines of code inside it!

In other words, you can always protect a piece of code or script from being reduced by putting it outside the
source folder. Also, you can pull source into the source folder to trace it.

## Important Safety Warning

D reductions can end up with infinite loops and unlimited memory leaks!
Gauge the RAM your compilation takes, then set memory and CPU limits in your repro script:

```
# limit DMD to 10 seconds
ulimit -t 10
# limit DMD to 4 GB
ulimit -v $((4096*1024))
```

You can use `timeout` under Windows, but I'm afraid there is no simple equivalent for the memory limit.

# Getting the source folder ready for the initial run

So how do you go about things? First of all, whatever build tool you use, dub, jinja, reggae, you *can* keep using
it, but usually you want to get down to a DMD command line. This puts the minimal distance between you and the actual
run, and lets you easily inspect the exit code and error.

As the second step, you should clean up all built binaries in your source folder. Dustmite *can* do this for you,
by noticing they don't affect the error, but it's awkward because it has to load the whole binary into memory.
Also if you start with only source code, you don't have to worry that you're accidentally testing the wrong binary.

Note that the source code being reduced does not have to be D, or any known programming language at all. Dustmite
will try to parse all files in its directory as D, but it has other strategies: for instance, you can configure
it to split files by line:

```
dustmite --split *.csv:lines
```

And it will try to remove lines from CSV files.

# First run

So now you have a source folder `src1`, you manually run your repro script and it exits with success. It's time to
start your first dustmite run:

```
$ dustmite src1 ../repro1.sh
```

Now dustmite will tell you if your repro script has an issue, but if everything is well it will begin
its run.

At this point, I recommend going home for the weekend. :-) DMD is not the fastest compiler (depends on source), and
Dustmite will now potentially kick off tens of thousands of DMD runs. When you come back, you should have a new
directory: `src1.reduced`, containing the minimal source code that still passes the test.

At this point, again, immediately copy this folder to `src2`. It represents the outcome of potentially multiple days
of compute time, and must be protected. In `src2`, you can look around and edit as much as you want.

# What now?

If you're lucky, you will be done. However, this is unlikely, because there are many patterns that Dustmite cannot
reduce:

- mutual dependencies (`foo(a) -> bar(a) -> foo(a)`, where `a` is not necessary)
- type changes (`template!T` to `template!int`)
- and generally any sort of changes that require understanding.

However, the first thing you should do is rerun your repro command and double-check that you've ended up with
the *same* bug as you started out with. It's possible to look at the source code and go "oh duh, of course this
crashes now." This is usually because Dustmite removed some code that turned an incidental crash into an obvious
crash, for instance removing a variable assignment to a pointer. In that case, you've sadly wasted your time, and
have to go back and find a better setup for your initial source and repro script.

Assuming your reproduction is good, but you want to reduce it further, there are several strategies that can be used:

## Inlining libraries or Phobos modules

Often at this point you find that most of the problem is in a Dub or Phobos library. The easiest way to handle this
is to just copy the entire library into your project.

The dub sources are at `$HOME/.dub/packages/{name}/{version}/{repo}`. The Phobos sources are at `{DMDDIR}/src/` in
your install folder, or `/usr/lib/ldc/x86_64-linux-gnu/include/d` for Ubuntu LDC.

Now, copy the module in question into your project, and immediately change the name to something else! This is
important, because it means that Dustmite can't just remove the entire file and go back to importing the existing
file. Make sure it still runs, by deleting everything that doesn't - this usually isn't much. Change `package`
to `public` where required. Mass-replace all your imports and references over to the new name.
Then just rerun Dustmite with the new folder:

```
$ dustmite src2 ../repro2.sh
```

## Specializing templates

Often issues hide inside templates that are instantiated with multiple different types in your remaining source,
split into different `static if`s or different code paths. This can make it hard to see what the actual necessary
code is.

For instance, if you descended into `std.typecons`, you may now have `Nullable!int` and `Nullable!string`
remaining in your repro code.

You can break this template open by simply making two copies:

```
struct Nullable_int(T) { ... }
struct Nullable_string(T) { ... }
```

And referencing each separately. This will allow Dustmite to strip out the parts that the `int` version doesn't
need, and the parts that the `string` version doesn't need, making each case easier to follow.

You can also try replacing all uses of `T` in each with `int` or `string` directly, though that may not work.

## Wild flailing

Honestly, at this stage your code is probably small enough that you can just file a bug directly. However,
if you want to have some fun, form a theory about what the issue is and try it out: for instance, replace
type parameters with `int`, or parameters with `0` and see if it still breaks.

Often, the final reproduction is *distressingly* simple. From a user level, it's common to think of bugs in terms
of a domain problem, but from the perspective of the compiler it's usually something like "three particular
features were used in an order that nobody has tried before". Even staring directly at the final reduction,
it can be hard to understand what the actual problem even is.

Remember that if you went the wrong way in your reduction, you can always go back to a previous state.

If your final repro contains `__traits(compiles, <expr>)`, take a drink.
You've joined the club of speculative semantic pass bugs. About half my bugs contain this line.

And of course, thanks to CyberShadow for his excellent tool.

That's it. Have fun!