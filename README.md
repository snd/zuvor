# zuvor

## TODO

- clean up naming/terminology

- finish readme
  - good short description
  - good longer description

- example.js (taken from integration test)

- push
- make sure travis is working
- npm publish

---

[![NPM version](https://badge.fury.io/js/zuvor.svg)](http://badge.fury.io/js/zuvor)
[![Build Status](https://travis-ci.org/snd/zuvor.svg?branch=master)](https://travis-ci.org/snd/zuvor/branches)
[![Dependencies](https://david-dm.org/snd/zuvor.svg)](https://david-dm.org/snd/zuvor)

> simple and reasonably fast implementation of DAGs (directed acyclic graphs) and sets
> as building blocks for dynamically finding the optimal execution order
> of interdependent tasks with nondeterministic execution times

- [is it any good?](#is-it-any-good)
- [how do i install it?](#how-do-i-install-it)
- [Set-API](#set-api)
- [Dag-API](#dag-api)
- [is it fast?](#is-it-fast)
- [is it stable?](#is-it-stable)
- [how is it implemented?](#how-is-it-implemented)
- [how can i contribute?](#how-can-i-contribute)
- [license](#license-mit)

### why?

i had a list of tasks where some tasks needed to run before other tasks.
for example: `A before B`, `C before A`, `D before B`, ...

i needed a programatic way to run those tasks in the most efficient order.

i built *vorrang* to model and query the underlying [partial order](http://en.wikipedia.org/wiki/Partially_ordered_set):

zuvor gives to the building blocks to do exactly that.

browser?

vorrang can be used to model

- shutdown orders
- task orders
- class hierarchies
- ancestor relationships
- taxonomies
- partial orders
- event orders
- production chains
- dependency graphs
- ...


no dependencies

first let's model the task order:

only works with strings

```javascript
var Vorrang = require('vorrang');

var dag = new Vorrang()
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

### what can i do with it?


### is it stable?

[![Build Status](https://travis-ci.org/snd/zuvor.svg?branch=master)](https://travis-ci.org/snd/zuvor/branches)

it has a large [testsuite](test)!

there are probably bugs.

if you find one i appreciate it if you [make an issue](https://github.com/snd/zuvor/issues/new).

### is it fast?

the current focus is on functionality and correctness rather than performance.

i did not optimize prematurely.
i chose the data types carefully.
its fast enough for my use case.
its probably fast enough for your use case.

if you need something faster and have an idea definitely send me an email or make an issue.

query performance
memory usage

it currently uses too much memory

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

### how can i contribute?

if you need a function that is not in the API just [make an issue](https://github.com/snd/zuvor/issues/new)
and we can discuss and how to implement it best.

i appreciate it if you open an issue first before 

## Set API

tries to follow the ECMA6 set api.

#### `new Set(Nothing or Array or Set)` -> `Set` create a set

```javascript
var emptySet = new Set();
// or
var setFromArgs = new Set(1, 2, 3);
// or
var setFromArray = new Set([1, 2, 3]);
// or
var clonedSet = new Set(setFromArray);
```
*Time complexity: O(n) where n = number of elements in argument array or set*

#### `.size` -> `Integer` number of elements in the set

```javascript
new Set().size;           // -> 0
new Set(1, 2, 3).size;    // -> 3
```

*Time complexity: O(1)*

#### `.values()` -> `Array` returns an array of all the elements in the set

```javascript
new Set().values();           // -> []
new Set(1, 2, 3).values();  // -> [1, 2, 3]
```

*Time complexity: O(n) where n = number of elements in the set*

#### `.toString()` -> `String` returns a string representation of the set

```javascript
new Set().toString();            // -> '#{}'
new Set(1, 2, 3).toString();   // -> '#{1 2 3}'
```

*Time complexity: O(n) where n = number of elements in the set*

#### `.equals(Set)` -> `Boolean` returns whether two sets contain the same elements

```javascript
new Set().equals(new Set());             // -> true
new Set().equals(new Set(1, 2, 3));    // -> false

var set = new Set(1, 2, 3);
set.equals(new Set(1, 2));             // -> false
set.equals(new Set(1, 2, 3));          // -> true

set.equals(set);                         // -> true
```

*Time complexity: best case: O(1). worst case: O(n) where n = number of elements in the set*

#### `.has(Value)` -> `Boolean` returns whether a value is in the set

```javascript
var set = new Set(1, 2, 3);
set.has(1);  // -> true
set.has(4);  // -> false
```

*Time complexity: O(1)*

#### `.add(Value or Array or Set)` -> `Set` add elements to the set

```javascript
var set = new Set();

set.add(1);
// add side effects original set!
set.elements();   // -> [1]

set.add(2, 3);
set.elements();   // -> [1, 2, 3]

set.add([4, 5]);
set.elements();   // -> [1, 2, 3, 4, 5]

set.add(new Set([6, 7]));
set.elements();   // -> [1, 2, 3, 4, 5, 6, 7]

// add can be chained
set
  .add(8)
  .add(9)
  .add(10);
set.elements();   // -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

*Time complexity: O(1) for a single value. O(n) for a set (array) where n = number of elements in the set (array)*

#### `.delete(Value or Array or Set)` -> `Set` delete elements from the set

```javascript
var set = new Set(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

set.delete(1);
// delete side effects original set!
set.elements();   // -> [2, 3, 4, 5, 6, 7, 8, 9, 10]

set.delete(2, 3);
set.elements();   // -> [4, 5, 6, 7, 8, 9, 10]

set.delete([4, 5]);
set.elements();   // -> [6, 7, 8, 9, 10]

set.delete(new Set([6, 7]));
set.elements();   // -> [8, 9, 10]

// delete can be chained
set
  .delete(8)
  .delete(9)
  .delete(10);
set.elements();   // -> []
```

*Time complexity: O(1) for a single value. O(n) for a set (array) where n = number of elements in the set (array)*

#### `.clone()` -> `Set` returns a new set that has the same elements as the original set

```javascript
var set = new Set(1, 2, 3);
var clone = set.clone();
set.isEqual(clone);     // -> true
```

*Time complexity: O(n) where n = number of elements in the set*

#### `.clear()` -> `Set` clears the set and returns it

```javascript
var set = new Set(1, 2, 3);
set.size;     // -> 3
set.clear();
set.size;     // -> 0
```

*Time complexity: O(1)*

## Dag API

## [license: MIT](LICENSE)
