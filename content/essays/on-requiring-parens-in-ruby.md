---
kind:             essay
title:            "On Requiring Parens in Ruby"
excerpt:          "I have been rethinking my idea of requiring parentheses in Ruby for a while, and I've come to the conclusion that requiring them is the wrong answer to a problem I didn't even explain well."
oneliner:         "Errata."
published_on:     "2008-01-29"
tags:             [ 'ruby' ]
---

My criticism on the Ruby programming language (no longer available) wasn't as well-received as I had hoped. Especially the idea of requiring parentheses in method calls got [loads of negative feedback](http://reddit.com/r/programming/info/65g1r/comments/).

I have been rethinking the idea for a while, and I've come to the conclusion that requiring parentheses is the wrong answer to a problem I didn't even explain well.

## Making Ruby Ugly

A Ruby variant where method calls require parentheses would quite simply be ugly. I'll prove it by giving a couple of examples.

### Getters

"Get" accessor methods are quite clean without parentheses. Even though an accessor is a method, you never treat it like a method. A sample getter could look like this in Ruby:

<pre><code><span class="n">address_book</span>.<span class="nf">people</span></code></pre>

When parentheses are required, you'd change that line and write something more like this instead:

<pre><code><span class="n">address_book</span>.<span class="nf">people</span>()</code></pre>

In this case, parentheses make the method call *explicit*. Without parentheses, it feels as if you're simply accessing a property, and not calling a method. With parentheses, you're explicitly calling a method.

Usually, explicit is better than implicit, but I believe this is an exception. A method name should be a verb, not a noun—after all, a method is a series of instructions. I would rather write:

<pre><code><span class="n">address_book</span>.<span class="nf">get_people</span>()</code></pre>

This code is understandable: it calls a `get_people` method which will fetch the people and return it. This piece of code is quite a bit longer than the original, though. Especially when chaining such getters, code gets ugly:

<pre><code><span class="n">address_book</span>.<span class="nf">get_people</span>().<span class="nf">get_last</span>().<span class="nf">get_first_name</span>()</code></pre>

### Setters

Requiring parens would make Ruby-style setters impossible. Imagine doing this:

<pre><code><span class="n">person</span>.<span class="nf">first_name=</span>(<span class="s">'Denis'</span>)</code></pre>

These kind of setters are definitely not as pretty as their parenthese-less brothers. In fact, I think the parens here do not make sense, and it would probably be less confusing to fall back to a more explicit "set":

<pre><code><span class="n">person</span>.<span class="nf">set_first_name</span>(<span class="s">'Denis'</span>)</code></pre>

And Ruby's charm is absent.

### Ruby DSLs

A Ruby on Rails "has many" declaration would look like this:

<pre><code><span class="nf">has_many</span>(<span class="ss">:people</span>)</code></pre>

The real beauty of Ruby DSLs is that method calls don't look like method calls. A parenthese-less `has_many` doesn't look like a method at all. Adding parentheses simply renders this ugly, and I actually believe it is a confusing construct—method names should be actions. If parentheses were required, I'd rather write:

<pre><code><span class="nf">set_relationship</span>(<span class="ss">:people</span>, <span class="ss">:many</span>)</code></pre>

Requiring parentheses would make writing Ruby DSLs impossible.

## The Real Problem

The real problem, which I totally failed to explain properly, is that method calls *with implicit self receiver* are indistinguishable from local variables.

Take a look at this piece of code:

	foo = bar

`bar` can either be a method or a local variable. Oddly, there can be a method named `foo=` but it will _not_ be called in the above example; `foo` will simply be a local variable. By simply looking at this line, there is no way to know for sure what `bar` is.

Now take a look at this:

	@foo.bar = @baz.quux

`bar=` definitely is a method, and so is `quux`. Both `@foo` and `@baz` are variables. There is no ambiguity.

### Why This Bothers Me

There are two reasons why I dislike this kind of ambiguity.

The first reason involves easy syntax highlighting. There is no way to correctly highlight method calls in Ruby, unless the entire source file is re-parsed every time a change is made, which is terribly slow.

The second reason is accidental performance loss. To illustrate, imagine having a class with a `data` method that reads data from the disk, formats and returns it. In another method in that class, you could be using `data`, treating it like a local variable instead of a rather expensive method.

## A Better Solution

Requiring parentheses is a solution, but probably one of the worst ones.

One better way of making local variables and methods look different is to require an explicit `self` receiver. For example:

<pre><code><span class="c"># foo and bar are methods</span>
<span class="n">self</span>.<span class="nf">foo</span> = <span class="n">self</span>.<span class="nf">bar</span>

<span class="c"># foo is a method, bar is a local variable</span>
<span class="n">self</span>.<span class="nf">foo</span> = <span class="n">bar</span>

<span class="c"># foo is a local variable, bar is a method</span>
<span class="n">foo</span> = <span class="n">self</span>.<span class="nf">bar</span>

<span class="c"># foo and bar are local variables</span>
<span class="n">foo</span> = <span class="n">bar</span></code></pre>

If you think typing `self` over and over again is too much work, then maybe you'll prefer omitting the explicit `self` receiver (thanks to apeiros for the idea):

<pre><code><span class="c"># foo and bar are methods</span>
.<span class="nf">foo</span> = .<span class="nf">bar</span>

<span class="c"># foo is a method, bar is a local variable</span>
.<span class="nf">foo</span> = <span class="n">bar</span>

<span class="c"># foo is a local variable, bar is a method</span>
<span class="n">foo</span> = .<span class="nf">bar</span>

<span class="c"># foo and bar are local variables</span>
<span class="n">foo</span> = <span class="n">bar</span></code></pre>

Problem solved.
