---
title: "Talk: Taming Memory"
---

I gave this talk, _Taming memory: performance-tuning a (Crystal) application_, at [RUG::B](http://rug-b.de/) on December 3rd, 2015.

## Abstract

When developing a game, you need to pay attention to performance. After all, a game needs to run fast, and have a predictable frame rate, and stuttering will throw people off.

I’ve had performance issues even in Crystal, a fast, compiled, statically-typed language with a syntax inspired by Ruby. As it turns out, the way a program handles memory can have a huge impact on performance. Luckily, Crystal gives a great deal of control over how this can be done. It’s also possible to use familiar tools with Crystal to debug issues and identify bottlenecks.

In this talk, I’ll share what I’ve learnt about memory and performance tuning, and give an introduction to several powerful tools for identifying performance issues.

## Slides

<img src="images/slide-001.png" style="width: 100%; height: auto;" alt="Slide 1">

Hi, I’m Denis. I’d like to start off by giving thanks to my employer, SoundCloud…

<img src="images/slide-002.png" style="width: 100%; height: auto;" alt="Slide 2">

… for giving me the time to work on this talk, which I also gave at SoundCloud HQ last week. I work as a backend engineer, and none of the stuff that I’ll talk about has anything to do with my daily job. I traditionally start of with a disclaimer and this talk is no exception, so …

<img src="images/slide-003.png" style="width: 100%; height: auto;" alt="Slide 3">

The contents of this talk aren’t particularly revolutionary. They’re not the kinds of things that I get to touch on in my job as a backend engineer, but I’m sure that people having to do with latency-critical frontend work are more familiar with this.

<img src="images/slide-004.png" style="width: 100%; height: auto;" alt="Slide 4">

I’ve been interested in game development for a very long time, and only recently I’ve started to spend a lot of time on it. Bought books, started experimenting, even attended a game jam (8 hours—quite exhausting after a week of working).

<img src="images/slide-005.png" style="width: 100%; height: auto;" alt="Slide 5">

A proper choice of language to program in, is important to me—especially for hobby projects, because it’s for fun. I have tried 8 or 9 languages, but I eventually ended up with…

<img src="images/slide-006.png" style="width: 100%; height: auto;" alt="Slide 6">

… Crystal, for three reasons:

* it’s fast
* has good tooling for analysing performance
* is good for prototyping

<img src="images/slide-007.png" style="width: 100%; height: auto;" alt="Slide 7">

Another disclaimer! I don’t know much about game development. I am not a professional game developer. I’ve never even released a game. But this doesn’t matter, because this talk isn’t about games. It’s about stuff I discovered *through* game development.

I figured I need some credentials so you believe that I actually make games, so here we go.

<img src="images/slide-008.png" style="width: 100%; height: auto;" alt="Slide 8">

This is a game built from scratch in eight hours at the Berlin Mini Game Jam.

<img src="images/slide-009.png" style="width: 100%; height: auto;" alt="Slide 9">

This is an old attempt at writing a real-time strategy (RTS) game. Writing RTSes is hard!

<img src="images/slide-010.png" style="width: 100%; height: auto;" alt="Slide 10">

This is a little puzzle game with bad gameplay.

<img src="images/slide-011.png" style="width: 100%; height: auto;" alt="Slide 11">

This is a space exploration game, in the spirit of _Escape Velocity_, written in JavaScript with a horrible codebase.

<img src="images/slide-012.png" style="width: 100%; height: auto;" alt="Slide 12">

This is a top-down, two-dimensional Minecraft clone.

<img src="images/slide-013.png" style="width: 100%; height: auto;" alt="Slide 13">

Lastly, here’s an experiment in animations. I wanted a high-level way of describing animations, and a simple card game felt like a good fit.

<img src="images/slide-014.png" style="width: 100%; height: auto;" alt="Slide 14">

Now, this talk isn’t about memory, the game, but rather about the computer concept.

<img src="images/slide-015.png" style="width: 100%; height: auto;" alt="Slide 15">

In Ruby, Java, Scala, and a whole bunch of other languages, a very common thing is READ. This means reserving space in memory to hold data.

<img src="images/slide-016.png" style="width: 100%; height: auto;" alt="Slide 16">

Here, we create a new `Donkey` instance. This new donkey instance occupies some space in memory—it needs space in memory to store its instance variables (in this case, a three-year-old grey donkey).

<img src="images/slide-017.png" style="width: 100%; height: auto;" alt="Slide 17">

We can split the `.new` into an allocation step and an initialization step. The call to `.allocate` allocates memory to be used for this instance of `Donkey`, and afterwards we call `#initialize`, to write data to the newly allocated object.

What `.allocate` does is find out how much memory is needed for this instance, and then allocate it. We could write it like this:

<img src="images/slide-018.png" style="width: 100%; height: auto;" alt="Slide 18">

Here, we allocate 6 bytes. Hopefully that is enough to hold a `Donkey`!

<img src="images/slide-019.png" style="width: 100%; height: auto;" alt="Slide 19">

But what *is* memory exactly?

<img src="images/slide-020.png" style="width: 100%; height: auto;" alt="Slide 20">

Here, I’ve represented memory as a grid. Each square is one byte.

<img src="images/slide-021.png" style="width: 100%; height: auto;" alt="Slide 21">

Memory increments to the right and wraps to the next line. Memory is not two-dimensional! It’s just easier to represent memory as a grid rather than a line.

When allocating memory with `malloc`, the application will find unused space, and claim it.

<img src="images/slide-022.png" style="width: 100%; height: auto;" alt="Slide 22">

In this example, we’ve claimed six bytes. Now we can initialise it, by writing data to that section of memory:

<img src="images/slide-023.png" style="width: 100%; height: auto;" alt="Slide 23">

The first byte is the age, followed by the string “grey” and an end-of-string marker, so we know how big the string is. (There are other, probably better ways of indicating the length of a string, but this’ll do.)

Allocating memory for objects is fine, but there needs to be a way to reclaim memory that is no longer used. Memory is finite after all.

<img src="images/slide-024.png" style="width: 100%; height: auto;" alt="Slide 24">

Freeing memory manually is common in languages like C and C++. Imagine a Ruby where you needed to call `#free` for unused objects:

<img src="images/slide-025.png" style="width: 100%; height: auto;" alt="Slide 25">

If you forget to free memory that is no longer needed, you will slowly run out of memory. This is called a memory leak. Terrifying. But there’s an alternative:

<img src="images/slide-026.png" style="width: 100%; height: auto;" alt="Slide 26">

With garbage collection (or _GC_ for short), unused memory will be reclaimed automatically. I will explain a little bit more about garbage collection and its implications, but first, I’ll take a detour…

<img src="images/slide-027.png" style="width: 100%; height: auto;" alt="Slide 27">

… and explain how function calls work.

<img src="images/slide-028.png" style="width: 100%; height: auto;" alt="Slide 28">

A long time ago (in a galaxy very close by), programs were written in assembly-like languages, full of GOTOs, leading to incomprehensible and unmaintainable spaghetti code.

<img src="images/slide-029.png" style="width: 100%; height: auto;" alt="Slide 29">

Here’s some code written in BASIC.

<img src="images/slide-030.png" style="width: 100%; height: auto;" alt="Slide 30">

The second-to-last line is a GOTO statement. GOTOs are scary.

Near the end of the 60s, smart people realized that there was a need for a more maintainable way of writing programs, and they came up with *structured programming*. Wikipedia has a long definition, which I’ll abbreviate as…

<img src="images/slide-031.png" style="width: 100%; height: auto;" alt="Slide 31">

… _structured programming makes extensive use of subroutines_. A subroutine is a function or a method—it’s just an antiquated term.

The interesting bit about a function is that once it has finished executing, whatever called the function will resume executing.

<img src="images/slide-032.png" style="width: 100%; height: auto;" alt="Slide 32">

That’s what the _return_ is for. The _return_ keyword is optional in some languages, such as Ruby and Scala, but it’s always there behind the scenes.

<img src="images/slide-033.png" style="width: 100%; height: auto;" alt="Slide 33">

Here’s some assembly code from the MySQL client library. Note the bold line: this is a `call` instruction: this instruction calls the function `my_printf_error`.

<img src="images/slide-034.png" style="width: 100%; height: auto;" alt="Slide 34">

Here’s the assembly code for the `my_printf_error` function. At the end of the function, there’s a `ret` instruction, which ends the function call, and makes the caller of this function resume execution.

<img src="images/slide-035.png" style="width: 100%; height: auto;" alt="Slide 35">

Imagine the `main` function calls `my_printf_error`. The CPU needs to know where in main to return to when `my_printf_error` finishes. For this, we have a stack, which contains return addresses. In this case, it’ll contain the address in main to return to.

`my_printf_error` can call a function of its own, e.g. `my_vsnprintf_ex`, and that’ll push the return address of `my_printf_error` on the stack.

To return from a function, pop the topmost return address off the stack, and resume execution at that address.

<img src="images/slide-036.png" style="width: 100%; height: auto;" alt="Slide 36">

Functions often take arguments, and those are typically passed on the stack.

<img src="images/slide-037.png" style="width: 100%; height: auto;" alt="Slide 37">

Here we have a stack that has some stuff on it already. To call a function with two params, push the two params on the stack, and then call the function. After the function call, remove the two params off the stack.

<img src="images/slide-038.png" style="width: 100%; height: auto;" alt="Slide 38">

This can get more complicated. For example, we first call a function with two params, followed by a function with one param, followed by a function with zero params. Return, return, return.

<img src="images/slide-039.png" style="width: 100%; height: auto;" alt="Slide 39">

Functions can have local variables, and those will also be stored on the stack.

<img src="images/slide-040.png" style="width: 100%; height: auto;" alt="Slide 40">

Here we call a function with two arguments. If that function needs local variables, it can push them on the stack. When the function returns, those local variables will be removed off the stack automatically.

<img src="images/slide-041.png" style="width: 100%; height: auto;" alt="Slide 41">

Here’s a more complex example:

* A function with two parameters and one local variable
* A function with one parameter and three local variables
* A function with two parameters and one local variable
* A function with one parameter and one local variable
* A function with zero parameters and one local variable

<img src="images/slide-042.png" style="width: 100%; height: auto;" alt="Slide 42">

Knowing how function calls work, we can now implement a garbage collector.

<img src="images/slide-043.png" style="width: 100%; height: auto;" alt="Slide 43">

Here is a function call in progress. Some local variables are the result of malloc calls; they contain addresses of allocated slices of memory. When the function returns, there is nothing pointing to two of those slices of memory anymore.

<img src="images/slide-044.png" style="width: 100%; height: auto;" alt="Slide 44">

This would be a memory leak: there is no way to free a slice of memory without having a reference to it. Oops!

Luckily, we have a garbage collector. When the GC runs, it will do two things: first, it will walk the stack and find all pointers to reachable slices of memory. This is the mark phase.

<img src="images/slide-045.png" style="width: 100%; height: auto;" alt="Slide 45">

In this case, only one slice of memory is reachable.

In the second phase, all non-marked memory slices will be freed.

<img src="images/slide-046.png" style="width: 100%; height: auto;" alt="Slide 46">

This is the sweep phase.

<img src="images/slide-047.png" style="width: 100%; height: auto;" alt="Slide 47">

This technique is known as _mark and sweep_. It is the simplest garbage collection technique. There are more advanced techniques, but they follow the same idea.

GC removes a giant burden off the developer’s shoulder. Manual memory management is tricky. Still, it imposes a runtime cost.

<img src="images/slide-048.png" style="width: 100%; height: auto;" alt="Slide 48">

I was once debugging a performance issue in a Ruby application, and it turned out it spent the vast majority of the time garbage collection.

<img src="images/slide-049.png" style="width: 100%; height: auto;" alt="Slide 49">

79% of the time spend in the garbage collector‽ That’s insane.

<img src="images/slide-050.png" style="width: 100%; height: auto;" alt="Slide 50">

By the way, the glyph at the end is called an interrobang. Unicode code point 203D in hexadecimal, or 8253 in decimal!

<img src="images/slide-051.png" style="width: 100%; height: auto;" alt="Slide 51">

If we spent 80% of time in the GC, clearly there’s something wrong, and we need to stop this GC madness.

Generally speaking, the more often you allocate memory, the more often the GC will have to run. So, to avoid GC, avoid allocating memory as often.

<img src="images/slide-052.png" style="width: 100%; height: auto;" alt="Slide 52">

For this, I have three techniques.

<img src="images/slide-053.png" style="width: 100%; height: auto;" alt="Slide 53">

The first technique avoids allocations through explicit reuse.

<img src="images/slide-054.png" style="width: 100%; height: auto;" alt="Slide 54">

This piece of code loops one million times. Every iteration of the loop allocates a point with a random width and a random height, and draws it on the screen.

This will cause a million points to be allocated on the heap, and they will have to be garbage collected at some point. Now, one million is not that many, but imagine a billion points, thirty times per second… the impact of the garbage collector will be significant.

<img src="images/slide-055.png" style="width: 100%; height: auto;" alt="Slide 55">

We could pull the allocation outside of the loop, and inside the loop, mutate the point by changing the X and Y attributes. This way, we’ll only have a single allocation instead of a million.

<img src="images/slide-056.png" style="width: 100%; height: auto;" alt="Slide 56">

This technique works well, but has two drawbacks: it only works for a single instance, and mutating state can lead to bugs.

<img src="images/slide-057.png" style="width: 100%; height: auto;" alt="Slide 57">

The second technique avoids allocations through memory pooling.

<img src="images/slide-058.png" style="width: 100%; height: auto;" alt="Slide 58">

This technique is an evolution of the first one. Here, we pre-allocate a bunch of objects in a so-called memory pool. At first, all objects are marked as “not in use”.

Whenever we need a new instance, rather than allocating it, we find an unused instance and claim it, marking it as “in use”. When we no longer need the object, we can release it back into the pool, so it can be reused elsewhere.

<img src="images/slide-059.png" style="width: 100%; height: auto;" alt="Slide 59">

With this technique, multiple objects can be reused, but the drawback is that memory management becomes more manual. You can even have memory leaks if you’re not careful.

<img src="images/slide-060.png" style="width: 100%; height: auto;" alt="Slide 60">

The third and last technique avoids heap allocations through stack allocation.

<img src="images/slide-061.png" style="width: 100%; height: auto;" alt="Slide 61">

Here, we have a function call in progress. This function has two local variables. As mentioned previously, when a function returns, the local variables will be automatically deallocated. Therefore, local variables, also known as stack-allocated variables, do not need to be garbage collected.

<img src="images/slide-062.png" style="width: 100%; height: auto;" alt="Slide 62">

This is the definition of a `Point` class in Crystal. Classes are allocated on the heap and will be subject to garbage collection.

<img src="images/slide-063.png" style="width: 100%; height: auto;" alt="Slide 63">

In Crystal, we can use the `struct` keyword instead of `class`. A struct is allocated on the stack, rather than the heap.

<img src="images/slide-064.png" style="width: 100%; height: auto;" alt="Slide 64">

Let’s return to our million-points example from before. When `Point` is now a struct rather than a class, this code will execute significantly faster, because there is no garbage collection involved.

<img src="images/slide-065.png" style="width: 100%; height: auto;" alt="Slide 65">

The advantage of this technique is that there is no explicit memory management required. The drawback is that is only works for local variables.

<img src="images/slide-066.png" style="width: 100%; height: auto;" alt="Slide 66">

Computers have different kinds of memory. Aside from the main memory, there’s also the CPU cache. Using the CPU cache properly can have a significant impact on performance.

<img src="images/slide-067.png" style="width: 100%; height: auto;" alt="Slide 67">

There is the HD (or SSD) and RAM, but also the cache. The hard drive latency is around a million nanoseconds, RAM around 500 nanoseconds and the cache 1 to 10 nanoseconds.

<img src="images/slide-068.png" style="width: 100%; height: auto;" alt="Slide 68">

When data is loaded from RAM, it is placed in the cache. A CPU cache consists of cache lines. Here is one. In this case, it is 32 bytes long (represented by 32 squares).

<img src="images/slide-069.png" style="width: 100%; height: auto;" alt="Slide 69">

The green here indicates the bytes that were loaded from RAM into the cache. If you load something from RAM, the *entire* block of 32 bytes will be places in the cache, and you can now access other bytes from that block without going to the main memory.

<img src="images/slide-070.png" style="width: 100%; height: auto;" alt="Slide 70">

For maximum speed, keep similar data together in memory. Let me illustrate!

<img src="images/slide-071.png" style="width: 100%; height: auto;" alt="Slide 71">

Here is an example cache line filled with information about a few entities, each with a position (blue), velocity (green), etc. The game will run through all entities, and update the position based on the velocity.

<img src="images/slide-072.png" style="width: 100%; height: auto;" alt="Slide 72">

When we do so, we only use 8 out of 24 bytes per entity. This means that the cache line contains unused data; only 12 bytes out of 32 are useful—only 37% efficiency.

<img src="images/slide-073.png" style="width: 100%; height: auto;" alt="Slide 73">

Let’s revisit the cache. A cache has multiple cache lines. We don’t have direct control how the cache is used, but we can structure our program in a way that fills some cache line with positions, and some with velocities.

<img src="images/slide-074.png" style="width: 100%; height: auto;" alt="Slide 74">

In this example, three cache lines here filled with positions, and three more with velocities. When we update the positions now, we have 100% efficiency. The way we achieve this is by…

<img src="images/slide-075.png" style="width: 100%; height: auto;" alt="Slide 75">

… storing similar data in contiguous arrays. Contiguous arrays store their elements next to each other in memory, so that loading one array element is likely to bring other array elements into the cache. This can make a huge speed difference!

<img src="images/slide-076.png" style="width: 100%; height: auto;" alt="Slide 76">

This technique works really well with memory pools, because those are contiguous blocks of memory. So we can have a pool of positions and one for velocities.

<img src="images/slide-077.png" style="width: 100%; height: auto;" alt="Slide 77">

I’ve prepared two demos.

<img src="images/slide-078.png" style="width: 100%; height: auto;" alt="Slide 78">

Demo number one: the impact of stack allocation.

<img src="images/slide-079.png" style="width: 100%; height: auto;" alt="Slide 79">

For this, I’ve shamelessly copied something from Tobi’s talk at last month’s RUG::B.

<img src="images/slide-080.png" style="width: 100%; height: auto;" alt="Slide 80">

We’re going to approximate π. The way we’re doing this is as follows: draw a circle with radius r, inscribed in a square with edge 2r. Now generate billions of random points inside that square.

<img src="images/slide-081.png" style="width: 100%; height: auto;" alt="Slide 81">

Count the total number of points, and divide it by the total number of points inside the circle. Mathematics tells us that this ratio will be almost equal to the area of the square divided by the area of the circle.

<img src="images/slide-082.png" style="width: 100%; height: auto;" alt="Slide 82">

Simplifying, we get this, and rearranging gives us that…

<img src="images/slide-083.png" style="width: 100%; height: auto;" alt="Slide 83">

… π is almost equal to four times the ratio of points inside over the total points.

<img src="images/slide-084.png" style="width: 100%; height: auto;" alt="Slide 84">

*(sound of typing and oohs and aahs)*

<img src="images/slide-085.png" style="width: 100%; height: auto;" alt="Slide 85">

In this next demo, I’ll show you the impact of cache usage.

<img src="images/slide-086.png" style="width: 100%; height: auto;" alt="Slide 86">

*(sound of typing and oohs and aahs)*

<img src="images/slide-087.png" style="width: 100%; height: auto;" alt="Slide 87">

I’m pretty sure that all this will come in handy in my future game development career, if that actually takes off. Probably not though.

That’s all I have, hope you enjoyed it!

<img src="images/slide-088.png" style="width: 100%; height: auto;" alt="Slide 88">
