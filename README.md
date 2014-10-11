# vorrang

## TODO

- use real world tasks in example
- write example
- implement minUpperBound
- write task example test

- better name: ideas: vor
- best practices
- finish readme
- clean up terminology

---

[![NPM version](https://badge.fury.io/js/vorrang.svg)](http://badge.fury.io/js/vorrang)
[![Build Status](https://travis-ci.org/snd/vorrang.svg?branch=master)](https://travis-ci.org/snd/vorrang/branches)
[![Dependencies](https://david-dm.org/snd/vorrang.svg)](https://david-dm.org/snd/vorrang)

> vorrang is a simple and reasonably fast implementation of DAGs (directed acyclic graphs) / strict posets (partially ordered sets) for nodejs and the browser

#### ~~ VORRANG IS A WORK IN PROGRESS ~~

i had a list of tasks where some tasks needed to run before other tasks.
for example: `A before B`, `C before A`, `D before B`, ...

i needed a programatic way to run those tasks in the most efficient order.

i built *vorrang* to model and query the underlying [partial order](http://en.wikipedia.org/wiki/Partially_ordered_set):

browser?



no dependencies

only works for strings

first let's model the task order:

only works with strings

```javascript
var vorrang = require('vorrang');

var dag = new vorrang.Dag()
  .before('A', 'B')
  .before('C', 'A')
  .before('D', 'B');
```

then i can find out what i can run immediately:

```javascript
dag.minElements();
// => ['C', 'D']
```

sweet - we can already start tasks `C` and `D`.

let's assume `C` has finished.

```javascript
vorrang.minUpperBound(dag, ['C', 'D'])
// => ['A']
```

nice - we can start `A` now!

you get the idea...

[see the full example again](example.js)

### API

### get it


it uses mori

because of mori you can use sets as nodes [example]

example folder

functional api

this is ultimately a tradeoff between space and speed

### what can i do with it?


### is it stable?

testsuite

bugs


not fast for graphs with very long chains.

### is it fast?

the current focus is on functionality and correctness rather than performance.
i did not optimize prematurely.
i chose the data types carefully.
its fast enough for my use case.
its probably fast enough for your use case.

if you need it to be faster definitely let me know!

### how is it implemented?

here's the code its just x lines

```javascript
parents
children

ancestors
descendants

in
out

upstream
downstream
```

# v1

```javascript
{
  a: new Set
  b: new Set
}
```

# v2

```javascript
{
  a: {
    in: new Set
    out: new Set
  }
  b: {
    in: new Set
    out: new Set
  }
}
```

# v3

- less storage than v2

following an edge is just one property access

```javascript
{
  in: {
    a: new Set
    b:
  }
  out: {
    a:
    b:
  }
}
```

# v4

```javascript
{
  a: {
    value: 'a'
    in: {
      b: link to the node of b
    }
    out: {

    }
  b: new Node
}
```

min upper bound of a set S:
  put all outgoing of S into a set C
  loop through the list
  for all X in C:
    if any of X.in is in C
      remove X from C
  return C

"where none in the set has incoming edges from any in the set"

test it with a scenario where a -> b, a -> c, c -> b (only c is min upper bound of #{a})

maxLowerBound of a set S:
analog

## license: MIT
