---
date: 2023-12-17
authors:
  - caiomts
categories:
  - Tests
tags:
  - Tests 
  - Python
---

# Why I use random data instead of plain text inputs when testing

I prefer to generate random data on the fly to test my code, rather than hardcoding fake data.
In the past, I did this almost instinctively. I was just a little lazy to think of examples, so I just used [Faker](https://faker.readthedocs.io/en/master/)
or [random](https://docs.python.org/3/library/random.html?) to generate random data for me.

But a while ago I experienced a situation that made me think more about my choice and why I thought it was a good approach.

<!-- more -->

To make my point I'll discuss about how I test my code in first place. It's neither a right or wrong choice nor a religion, but I do think
that more important than the style or theory you are applying is reasoning about it.

## But why should I test the code in first place?

If I'm writing some code that has a good chance of being used more than a couple of times, it will probably need maintenance and improvements as time passes.  

If I'm writing this kind of code it's also probably that this code is bigger than a simple script to automate a small task. 
It will have interaction between different objects, functions, abstraction levels and so on. Writing tests makes you more confident to change, evolve and maintain your
code, because after each modification you can simply run your test suites and if everything passes, you are in a right track.

But testing isn't only about confidence. Test helps me reason about the kind of code I write in first place. How I should interact with it. 
How objects should interact with each other. How coupled it is and how difficult it will be to maintain and evolve if I go in one direction instead of another.

When I test a part of the code, the code itself should not exist in first place. Design the test first[^1], a.k.a TDD, helps me reason about all those questions.
When I test a function, for example, I'm forced to think about the function signature, and not how it solve the problem itself. I think which arguments
the function needs to perform the calculation. Doesn't matter yet how the things are combined internally. It forces me to think about the constrains I should
impose to the arguments themselves. 


[^1]: Test-Driven development is a process applied in software development. I'm not going into details, but you can start here: https://en.wikipedia.org/wiki/Test-driven_development if you're interested. 

Let's start with a very simple example. 

The balance account is updated whenever the account receives a transaction. 

To make it very simple:

!!! note ""

    **Given** a transaction amount;  
    **When** an account receives this transaction;  
    **Then** the balance account increases the same amount it receives.  

So we already stated the expected behavior now let's think about the inputs:

We have two objects a *transaction amount* and an *account*. 

As we don't have a lot of context yet, let's use a very simple approach. 

The *transaction* we can be easily represented as a `#!python float`. it's just a *Value Object*[^2], which is important is just the amount itself. 
However the *account* has a balance and it's updated, which means it have a previous state and it change when receiving a transaction.
Therefore, the *account* is an *Entity*[^3] object which has a property `balance` and implements a method to alter the balance state. 

[^2]: A *Value Object* holds data but has neither identity nor state. It's what it holds. It's usually represented as immutable. 
[^3]: A *Entity* has identity and state. It typically holds data but also has methods for modifying its internal state.

*There is always some context and requirements missing.* 

For example, from our general knowledge and reasoning, we need to decide whether transactions are always positive and an account can receive or send a transaction, 
or the direction of the transaction is defined by the value itself (positive/negative).

By now, suppose *transactions* are always positive and *Account* implements `send`/`receive` methods. 

It's also very important to tackle one problem at a time and always try the simplest solution.

Let's first implement our test and then we can think about what code we should implement to pass the test.


```python title="test_account.py" hl_lines="7" linenums="3"
--8<-- "code/test_random/test_account.py:4:11"
```

1.  Instantiate the account as we don't have any other context we are just only doing that without thinking about the balance itself.
2.  Down below it'll become clear why I instantiate the transaction as a random number.

!!! failure
    The test failed as we can see from the snippet below.

*I decluttered pytest outputs for the sake of simplicity* 

```bash title="bash prompt"
$ pytest -vv .
==================================== test session starts ================================
# --- omitted for simplicity---

test_account.py::test_balance_account_increases_when_receive_a_transaction FAILED [100%]

# --- omitted for simplicity ---
```
Let's code the simplest implementation.

```python title="account_model.py" hl_lines="9" linenums="3"
--8<-- "code/test_random/account_model.py:3:11"
```
!!! success
    And now the test passed.

```bash title="bash prompt"
$ pytest -vv .
==================================== test session starts ================================
# --- omitted for simplicity---

test_account.py::test_balance_account_increases_when_receive_a_transaction PASSED [100%]

# --- omitted for simplicity ---
```

But why on earth I highlighted the assertion in the test and the method implementation?

This is the inflection point which generated this post in first place.

## Why did I repeat the same equation if I was suppose to test it?

It can be rightly said that in fact the test assertion implements exactly the same thing as the method itself. Both are a simple sum equation. 

In this case I was not testing anything as `a + b` is always equals to `a + b`. and it's always true.   
  
The solution would be, though:

```python title="test_account.py" hl_lines="7" linenums="11"
--8<-- "code/test_random/test_account.py:14:20"
```

Seems reasonable as in this case we are testing `a + b` against a real value. 

!!! warning
    In fact, you just calculate `a + b` somewhere else, even if in your mind, and set the final value as if it were different from `a + b`. 
    It's not much different that what I did, but that's another history.

There are some misunderstandings that I'd like to discuss.

First, we should test the behavior of the method, not the equation.

**Indeed it's not possible properly test simple equations either we know the equation or we don't know.**

Suppose a more complex equation, some expert will provide the equation or we'll copy it from some paper, and then we put into our code *ipsi literis*.
Now we can, either (1) copy it into our test or (2) calculate with a given values on a sheet of paper and put just the result into our test.

However, as I stated before, **calculating elsewhere is no different from letting the test calculate it on the fly**.

Secondly, and most importantly, is that: 

!!! danger
    When you calculate an equation with given numbers, there is no reason why another equation with the same numbers wouldn't return the same result just by chance.

In our case I could wrongly implement:

```python title="account_model.py" hl_lines="3" linenums="3"
--8<-- "code/test_random/account_model_wrong.py:9:11"
```
!!! bug
    As we can see, when testing using a hardcoded value the test passed, when it should fail as the method implementation is incorrect.

!!! failure   
    However, when faking values using random the test failed as expected.

```bash
$ pytest -vv code/test_account.py 
==================================== test session starts ====================================
# --- omitted for simplicity---                                                                      

code/test_account.py::test_balance_account_increases_when_receive_a_transaction FAILED [ 50%]
code/test_account.py::test_balance_account_increases_when_receive_a_transaction_assert_4 PASSED [100%]

# --- omitted for simplicity---
```

## The function is so simple. It just implements an equation that we cannot fully test. why should we implement this test in the first place?

Remember, we implemented the test before, so theoretically we didn't know that the implementation would be so simple.

Indeed, the method will likely evolve as we narrow down the requirements. for example, (1) we can get to know that transactions can be positive and negative,
as they can be used for different purposes, but the method we implement has only one purpose and must first test the direction of the transaction. (2) `balance`
can be set to 3 decimal places, so we must round the results before updating the state of the Entity. (3) transaction may contain sender/recipient information and then
we also need to update some ledger. The possibilities are endless.

In this context, the test suite will probably evolve to cover new behaviors and simple tests may be suppressed, as their behavior will already be covered by another test. 
But this is another story...
