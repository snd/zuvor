var assert = require('assert');
var Set = require('../src/zuvor').Set;

var benchmark = function(n) {
  console.log('# n = ' + n + '\n');

  console.time('add');
  var set = new Set();
  for(i = 0; i < n; i++) {
    set.add(i);
  }
  console.timeEnd('add');

  assert.equal(set.size, n);

  console.time('has');
  for(i = 1; i < n; i++) {
    assert(set.has(i));
  }
  console.timeEnd('has');

  console.time('keys');
  var keys = set.keys();
  console.timeEnd('keys');
  assert.equal(n, keys.length);

  console.time('equals');
  assert(set.equals(set));
  console.timeEnd('equals');

  console.time('delete');
  for(i = 0; i < n; i++) {
    set.delete(i);
  }
  console.timeEnd('delete');

  assert.equal(set.size, 0);

  console.log('\n');
};

benchmark(1000);
benchmark(10000);
benchmark(100000);
benchmark(1000000);
benchmark(10000000);
