var assert = require('assert');
var Vorrang = require('./src/vorrang');

var benchmark = function(n) {
  console.log('# n = ' + n + '\n');

  console.time('before');
  var dag = new Vorrang();
  for(i = 1; i < n; i++) {
    dag.before(i, i + 1);
  }
  console.timeEnd('before');

  console.time('elements');
  var elements = dag.elements();
  console.timeEnd('elements');
  assert.equal(n, elements.length);

  console.time('parentless');
  var parentless = dag.parentless();
  console.timeEnd('parentless');
  assert.deepEqual(parentless, [1]);

  console.time('childless');
  var childless = dag.childless();
  console.timeEnd('childless');
  assert.deepEqual(childless, [n]);

  console.time('isBefore');
  assert(dag.isBefore(1, n));
  console.timeEnd('isBefore');

  console.log('\n');
};

benchmark(1000);
benchmark(10000);
benchmark(100000);
benchmark(500000);
