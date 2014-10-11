var vorrang = require('./src/vorrang');

var dag = new vorrang.Dag()
  .before('tytos', 'tywin')

  .before('tywin', 'jaime')
  .before('joanna', 'jaime')

  .before('tywin', 'cersei')
  .before('joanna', 'cersei')

  .before('tywin', 'tyrion')
  .before('joanna', 'tyrion')

  .before('jaime', 'tommen')
  .before('cersei', 'tommen')

  .before('jaime', 'jeoffrey')
  .before('cersei', 'jeoffrey')

  .before('jaime', 'mycella')
  .before('cersei', 'mycella')
  ;

console.log(dag);

console.log('jaime < jeoffrey', dag.isBefore('jaime', 'jeoffrey'));

console.log('minElements', dag.minElements());
console.log('maxElements', dag.maxElements());
