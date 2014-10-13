var assert = require('assert');
var Set = require('../src/zuvor').Set;

var benchmark = function(n) {
  console.log('# n = ' + n + '\n');

  console.time('add');
  var set = new Set();
  for(i = 1; i < n; i++) {
    set.add(i);
  }
  console.timeEnd('add');

  assert(!set.isEmpty());

  console.time('isIn');
  for(i = 1; i < n; i++) {
    set.isIn(i);
  }
  console.timeEnd('isIn');

  console.time('elements');
  set.elements();
  console.timeEnd('elements');

  console.time('isEqual');
  assert(set.isEqual(set));
  console.timeEnd('isEqual');

  console.time('remove');
  for(i = 1; i < n; i++) {
    set.remove(i);
  }
  console.timeEnd('remove');

  assert(set.isEmpty());

  console.log('\n');
};

benchmark(1000);
benchmark(10000);
benchmark(100000);
benchmark(1000000);
benchmark(10000000);
