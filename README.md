# zuvor

## TODO

- write run function

- use vorrang from blaze

- finish readme
  - description
  - question sections
  - example
  - clean up naming/terminology

- example.js (taken from integration test)

- push
- make sure travis is working
- npm publish

---

uses and includes a set and a graph datatype

---

[![NPM version](https://badge.fury.io/js/zuvor.svg)](http://badge.fury.io/js/zuvor)
[![Build Status](https://travis-ci.org/snd/zuvor.svg?branch=master)](https://travis-ci.org/snd/zuvor/branches)
[![Dependencies](https://david-dm.org/snd/zuvor.svg)](https://david-dm.org/snd/zuvor)

> simple and reasonably fast implementation of DAGs (directed acyclic graphs) and sets
> as building blocks for dynamically finding the optimal execution order
> of interdependent tasks with nondeterministic execution times

a task will run at the earliest possible point when it can run

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

## API

### `run(options)` -> `Promise`

options:

- `ids` an `Array` or [`Set`](#set) of ids
- `call` a `Function` that is called for each
- `graph` a `Graph` (optional) that models the dependencies/order between the `ids`
- `reversed` a `Boolean` (optional, default `false`) whether to treat the `graph` (if present) in reverse order
- `strict` an *optional* `Boolean` (default `false`)
- `done` an *optional* `Set` (default `new Set()`) that contains
  - side effected
  - can be used to blacklist `ids`
- `pending` an *optional* `Set` (default `new Set()`) that contains the ids
  - `ids` in this set will not be called. can be used to blacklist `ids`.

order between some of them

### `Set`

loosely follows the ECMA6 set api where possible.

##### `new Set(Nothing or Array or Set)` -> `Set` create a set

```javascript
var emptySet = new Set();
// or
var setFromArgs = new Set(1, 2, 3);
// or
var setFromArray = new Set([1, 2, 3]);
// or
var clonedSet = new Set(setFromArray);
```
*O(n) where n = number of elements in argument array or set*

##### `.size` -> `Integer` number of elements in the set

```javascript
new Set().size;           // -> 0
new Set(1, 2, 3).size;    // -> 3
```

*O(1)*

##### `.values()` -> `Array` returns an array of all the elements in the set

```javascript
new Set().values();           // -> []
new Set(1, 2, 3).values();    // -> [1, 2, 3]
```

*O(n) where n = number of elements in the set*

##### `.toString()` -> `String` returns a string representation of the set

```javascript
new Set().toString();         // -> '#{}'
new Set(1, 2, 3).toString();  // -> '#{1 2 3}'
```

*O(n) where n = number of elements in the set*

##### `.equals(Set)` -> `Boolean` returns whether two sets contain the same elements

```javascript
new Set().equals(new Set());          // -> true
new Set().equals(new Set(1, 2, 3));   // -> false

var set = new Set(1, 2, 3);
set.equals(new Set(1, 2));            // -> false
set.equals(new Set(1, 2, 3));         // -> true

set.equals(set);                      // -> true
```

*best case if size differs is O(1). worst case is O(n) where n = number of elements in the set*

##### `.has(Value)` -> `Boolean` returns whether a value is in the set

```javascript
var set = new Set(1, 2, 3);
set.has(1);  // -> true
set.has(4);  // -> false
```

*O(1)*

##### `.add(Value or Array or Set)` -> `Set` add elements to the set

```javascript
var set = new Set();

set.add(1);
// add side effects original set!
set.values();     // -> [1]

set.add(2, 3);
set.values();     // -> [1, 2, 3]

set.add([4, 5]);
set.values();     // -> [1, 2, 3, 4, 5]

set.add(new Set([6, 7]));
set.values();     // -> [1, 2, 3, 4, 5, 6, 7]

// add can be chained
set
  .add(8)
  .add(9)
  .add(10);
set.values();     // -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

*O(1) for a single value. O(n) for a set (array) where n = number of elements in the set (array)*

##### `.delete(Value or Array or Set)` -> `Set` delete elements from the set

```javascript
var set = new Set(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

set.delete(1);
// delete side effects original set!
set.values();     // -> [2, 3, 4, 5, 6, 7, 8, 9, 10]

set.delete(2, 3);
set.values();     // -> [4, 5, 6, 7, 8, 9, 10]

set.delete([4, 5]);
set.values();     // -> [6, 7, 8, 9, 10]

set.delete(new Set([6, 7]));
set.values();     // -> [8, 9, 10]

// delete can be chained
set
  .delete(8)
  .delete(9)
  .delete(10);
set.values();     // -> []
```

*O(1) for a single value. O(n) for a set (array) where n = number of elements in the set (array)*

##### `.clone()` -> `Set` returns a new set that has the same elements as the original set

```javascript
var set = new Set(1, 2, 3);
var clone = set.clone();
set.equals(clone);     // -> true
```

*O(n) where n = number of elements in the set*

##### `.clear()` -> `Set` clears the set and returns it

```javascript
var set = new Set(1, 2, 3);
set.size;     // -> 3
set.clear();
set.size;     // -> 0
```

*O(1)*

### `Graph`

## [license: MIT](LICENSE)
