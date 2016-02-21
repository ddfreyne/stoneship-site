---
kind:             essay
title:            "TDD Bypasses Your Brain"
excerpt:          "Test-Driven Development can result in an overreliance of tests. True 100% code coverage is a myth, and mindlessly modifying code until all tests pass is bound to introduce bugs for which no tests exist."
published_on:     "2013-03-16 12:00:00"
---

Here is a bold statement: writing code in a _test-driven_ way bypasses your brain and makes you not think properly about what you are doing.

_Test-Driven Development_ (TDD) is a method of sofware development that puts a focus on writing tests _up front_ to ensure that all code is covered by tests. TDD makes it very easy to write robust code fast, and also enables refactoring.

However, developing in a test-driven way can result in an _overreliance on tests_: when a test starts failing (and you know the test is correct), there is a tendency to mindlessly modify code until the test passes. Furthermore, true 100% code coverage by tests is a myth: no matter how many good tests you write, not all cases will be covered. Therefore, mindlessly modifying code until all tests pass is likely to introduce new bugs for which no tests exist.

I find this particularly striking when modifying algorithms. _Algorithms must be understood_ before being modified, and modifications must be done as if no tests exist at all.

### An Example

Imagine that you are working on a complex algorithm that contains bounded loops. The algorithm is written in a test-driven way, and there is a very high number of tests present. Suppose now that you discover a possible optimisation and start modifying the algorithm code. No new tests need to be written, because nothing changes functionally.

You apply the optimisation, and some tests start failing. After investigating the test failures, it seems that the bounds of one of those loops are incorrect, so you modify the bounds and add a +1, because that is what the test failures seem to hint at. You re-run the tests, but find out that some tests still fail. You play around with the code and modify the +1 into -1, and now the tests work.

You now have an optimised algorithms which passes all the tests. But how can you be sure that the algorithm still works? How can you be sure that the mindless modifications did not introduce edge cases that were not tested before? The answer is simple: _you cannot_.

### Think!

Moral of the story: no matter which software development methods you use, do not forget to use your brain. Remember what <cite>Edsger W. Dijkstra</cite> said:

> Program testing can be a very effective way to show the presence of bugs, but it is hopelessly inadequate for showing their absence.
