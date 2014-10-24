var assert = require('assert');
var Graph = require('../src/zuvor').Graph;

var benchmark = function(n) {
  console.log('# n = ' + n + '\n');

  console.time('add');
  var graph = new Graph();
  for(i = 1; i < n; i++) {
    graph.add(i, i + 1);
  }
  console.timeEnd('add');

  console.time('keys');
  var keys = graph.keys();
  console.timeEnd('keys');
  assert.equal(n, keys.length);

  console.time('parentless');
  var parentless = graph.parentless();
  console.timeEnd('parentless');
  assert.deepEqual(parentless, [1]);

  console.time('childless');
  var childless = graph.childless();
  console.timeEnd('childless');
  assert.deepEqual(childless, [n]);

  console.time('has');
  assert(graph.has(1, n));
  console.timeEnd('has');

  console.log('\n');
};

benchmark(1000);
benchmark(10000);
benchmark(100000);
benchmark(500000);
