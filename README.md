# zuvor

## TODO

- integration test: tasks are executed in the right order
  - draw the graph
  - devise an interesting timing
  - add assertions for the correct run (in the callbacks)
  - add test.expect

- clean up naming/terminology

- finish readme
  - good short description
  - good longer description

- best practices
  - package.json

- example.js

- push
- make sure travis is working
- npm publish

---

[![NPM version](https://badge.fury.io/js/vorrang.svg)](http://badge.fury.io/js/vorrang)
[![Build Status](https://travis-ci.org/snd/vorrang.svg?branch=master)](https://travis-ci.org/snd/vorrang/branches)
[![Dependencies](https://david-dm.org/snd/vorrang.svg)](https://david-dm.org/snd/vorrang)

> simple and reasonably fast implementation of directed acyclic graphs and sets
> with focus on finding the fastest execution order of interdependent tasks

> vorrang is a simple and reasonably fast implementation of DAGs (directed acyclic graphs) OR strict posets (partially ordered sets) for nodejs and the browser
with a focus on finding the optimal (shortest) execution order of tasks that depend on each others completion and whose completion time is not known ahead of time.

### why?

i had a list of tasks where some tasks needed to run before other tasks.
for example: `A before B`, `C before A`, `D before B`, ...

i needed a programatic way to run those tasks in the most efficient order.

i built *vorrang* to model and query the underlying [partial order](http://en.wikipedia.org/wiki/Partially_ordered_set):

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

### API

### what can i do with it?


### is it stable?

it has a large testsuite.

there are probably bugs.

not fast for graphs with very long chains.

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

## license: MIT
