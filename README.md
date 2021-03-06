# zuvor

**THIS IS ALPHA, UNSTABLE, WORK IN PROGRESS !**

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

``` js
var Vorrang = require('vorrang');

var dag = new Vorrang()
  .before('A', 'B')
  .before('C', 'A')
  .before('D', 'B');
```

then i can find out what i can run immediately:

``` js
dag.minElements();
// => ['C', 'D']
```

sweet - we can already start tasks `C` and `D`.

let's assume `C` has finished.

``` js
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

``` js
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

run will call `callback` once for every id in `ids` that is not in `done`.
call them 

options:

- `ids` an `Array` or [`Set`](#set) of ids to run
- `callback` a `Function` that is called for each id that is not in `done`
  - can return a promise
- `graph` a `Graph` (optional) that models the dependencies/order between the `ids`
- `done` an *optional* `Set` (default `new Set()`) that contains
  - ids that are done are added to the set
  - can be used to blacklist `ids`
  - things that are already done are not run
- `pending` an *optional* `Set` (default `new Set()`) that contains the ids
  that have been called and have returned a promise that is not yet resolved
  - `ids` in this set will not be called. can be used to blacklist `ids`.
- `reversed` a `Boolean` (optional, default `false`) whether to treat the `graph` (if present) in reverse order
- `strict` an *optional* `Boolean` (default `false`)
- `debug`

strict ignore orderings that dont exist

order between some of them

run returns a promise that is resolved when all things have been run

### `Set`

follows the ECMA6 set API where sensible.

##### create a set: `new Set(Nothing or Array or Set)` -> `Set`

``` js
var emptySet = new Set();
// or
var setFromArgs = new Set(1, 2, 3);
// or
var setFromArray = new Set([1, 2, 3]);
// or
var clonedSet = new Set(setFromArray);
```
*O(n) where n = number of elements in argument array or set*

##### number of elements in the set: `.size` = `Integer`

``` js
new Set().size;                           // -> 0
new Set(1, 2, 3).size;                    // -> 3
```

*O(1)*

##### return an array of all the elements in the set: `.values()` or `.keys()` -> `Array`

``` js
new Set().values();                       // -> []
new Set(1, 2, 3).values();                // -> [1, 2, 3]
new Set(1, 2, 3).keys();                  // -> [1, 2, 3]
```

*O(n) where n = number of elements in the set*

##### return a string representation of the set: `.toString()` -> `String`

``` js
new Set().toString();                     // -> '#{}'
new Set(1, 2, 3).toString();              // -> '#{1 2 3}'
```

*O(n) where n = number of elements in the set*

##### return whether two sets contain the same elements: `.equals(Set or Array)` -> `Boolean`

``` js
new Set().equals(new Set());              // -> true
new Set().equals(new Set(1, 2, 3));       // -> false

var set = new Set(1, 2, 3);
set.equals(new Set(1, 2));                // -> false
set.equals(new Set(1, 2, 3));             // -> true

set.equals(set);                          // -> true

set.equals([1, 2, 3]);                    // -> true
set.equals([1, 2]);                       // -> false
```

*best case if size differs is O(1). worst case is O(n) where n = number of elements in the set*

##### return whether a value is in the set: `.has(Value)` -> `Boolean`

``` js
var set = new Set(1, 2, 3);
set.has(1);                               // -> true
set.has(4);                               // -> false
```

*O(1)*

##### add elements to the set and return set: `.add(Value or Array or Set)` -> `Set`

``` js
var set = new Set();

set.add(1);
// add side effects original set!
set.values();                             // -> [1]

set.add(2, 3);
set.values();                             // -> [1, 2, 3]

set.add([4, 5]);
set.values();                             // -> [1, 2, 3, 4, 5]

set.add(new Set([6, 7]));
set.values();                             // -> [1, 2, 3, 4, 5, 6, 7]

// add can be chained
set
  .add(8)
  .add(9)
  .add(10);
set.values();                             // -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

*O(1) for a single value. O(n) for a set (array) where n = number of elements in the set (array)*

##### delete elements from the set and return set: `.delete(Value or Array or Set)` -> `Set`

``` js
var set = new Set(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

set.delete(1);
// delete side effects original set!
set.values();                             // -> [2, 3, 4, 5, 6, 7, 8, 9, 10]

set.delete(2, 3);
set.values();                             // -> [4, 5, 6, 7, 8, 9, 10]

set.delete([4, 5]);
set.values();                             // -> [6, 7, 8, 9, 10]

set.delete(new Set([6, 7]));
set.values();                             // -> [8, 9, 10]

// delete can be chained
set
  .delete(8)
  .delete(9)
  .delete(10);
set.values();                             // -> []
```

*O(1) for a single value. O(n) for a set (array) where n = number of elements in the set (array)*

##### return a new set that has the same elements as the set: `.clone()` -> `Set`

``` js
var set = new Set(1, 2, 3);
var clone = set.clone();
set.equals(clone);                        // -> true
```

*O(n) where n = number of elements in the set*

##### delete all elements from the set and return set: `.clear()` -> `Set`

``` js
var set = new Set(1, 2, 3);
set.size;                                 // -> 3
set.clear();
set.size;                                 // -> 0
```

*O(1)*

### `Graph`

`Value` = `String` or `Number`

##### create a graph: `new Graph` -> `Graph`

``` js
var graph = new Graph();
```

*O(1)*

##### add an edge and return graph: `.add(from Value, to Value)` -> `Graph`

``` js
var graph = new Graph()
  .add('a', 'b')
  .add('b', 'c')
  .add('a', 'c');
```

*O(1)*

##### return whether node `a` or path from `a` to `b` exists: `.has(a Value, [b Value])` -> `Boolean`

``` js
var graph = new Graph()
  .add('a', 'b')
  .add('b', 'c')

graph.has('a');                           // -> true
graph.has('d');                           // -> false

graph.has('a', 'b');                      // -> true
graph.has('b', 'a');                      // -> false

// transitive path: a to c via b
graph.has('a', 'c');                      // -> true
```

*whether node exists: O(1)*

*if direct edge between a and b exists: O(1)*

*if a transitive path between a and b exists:
worst case O(n * m) where n is the number of edges in the path and m is the max number of edges connected to any node in the graph.*

##### return an array of all the nodes in the graph: `.values()` or `.keys()` -> `Array`

``` js
new Graph().values();                     // -> []
new Graph()
  .add('a', 'b')
  .values();                              // -> ['a', 'b']
new Graph()
  .add('a', 'b')
  .keys();                                // -> ['a', 'b']
```

*O(n) where n = number of nodes in the graph*

##### return an array of all the edges in the graph: `.edges()` -> `Array`

``` js
new Graph() .edges();                     // -> []
new Graph()
  .add('a', 'b')
  .edges();                               // -> [['a', 'b']]
```

*O(n) where n = number of edges in the graph*

##### return nodes that have no parents (no incoming edges): `.parentless()` -> `Array`

``` js
new Graph()
  .add('a', 'b')
  .parentless();                          // -> ['a']
```

*O(n) where n = number of nodes in the graph*

##### return nodes that have no children (no outgoing edges): `.childless()` -> `Array`

``` js
new Graph()
  .add('a', 'b')
  .childless();                           // -> ['b']
```

*O(n) where n = number of nodes in the graph*

##### return nodes whose parents are all in array: `.whereAllParentsIn(Array or Set)` -> `Array`

``` js
var graph = new Graph()
  .add('a', 'b')
  .add('a', 'c')
  .add('c', 'd')
  .add('b', 'd')

graph.whereAllParentsIn(['a']);                           // -> ['b', 'c']
// nodes in the source array are not in the output array
graph.whereAllParentsIn(['a', 'b']);                      // -> ['c']
graph.whereAllParentsIn(new Set('a', 'b', 'c'));          // -> ['d']
```

*worst case: O(n * m) where n = number of elements in the array/set and
m = max number of parents of any node in the array/set*

##### return nodes whose children are all in array: `.whereAllChildrenIn(Array or Set)` -> `Array`

``` js
var graph = new Graph()
  .add('a', 'b')
  .add('a', 'c')
  .add('c', 'd')
  .add('b', 'd')

graph.whereAllChildrenIn(['d']);                           // -> ['c', 'b']
// nodes in the source array are not in the output array
graph.whereAllChildrenIn(['d', 'b']);                      // -> ['c']
graph.whereAllChildrenIn(new Set('d', 'b', 'c'));          // -> ['a']
```

*worst case: O(n * m) where n = number of elements in the array/set and
m = max number of children of any node in the array/set*

## [license: MIT](LICENSE)

## TODO

- handle strictness
  - build a scenario where that is a problem
  - in graph but not in ids and blockings children that depend on it
- test edge cases of the run function

- document run function in readme

- use zuvor run function from blaze for shutdown

- finish readme
  - read api again
  - description
  - question sections
  - example

- example.js (taken from integration test)

- npm publish
- publish
- make sure travis is working

---

uses and includes a set and a graph datatype

where an order exists only for some services

you can use it for

tasks are run as soon as they are ready to run
