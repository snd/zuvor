var assert = require('assert');
var vorrang = require('../src/vorrang');

var benchmark = function(n) {
  console.log('# n = ' + n + '\n');

  console.time('before');
  var dag = new vorrang.Dag();
  for(i = 1; i < n; i++) {
    dag.before(i, i + 1);
  }
  console.timeEnd('before');

  console.time('elements');
  var elements = dag.elements();
  console.timeEnd('elements');
  assert.equal(n, elements.length);

  console.time('minElements');
  var minElements = dag.minElements();
  console.timeEnd('minElements');
  assert.deepEqual(minElements, [1]);

  console.time('maxElements');
  var maxElements = dag.maxElements();
  console.timeEnd('maxElements');
  assert.deepEqual(maxElements, [n]);

  console.time('isBefore');
  assert(dag.isBefore(1, n));
  console.timeEnd('isBefore');

  console.log('\n');
};

benchmark(1000);
benchmark(10000);
benchmark(100000);
benchmark(1000000);
