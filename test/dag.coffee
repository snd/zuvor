Promise = require 'bluebird'

new Vorrang = require '../src/vorrang'

hasSameElements = (as, bs) ->
  if as.length isnt bs.length
    return false
  for a in as
    if -1 is bs.indexOf a
      return false
  return true

module.exports =

  'scenarios':

    'zero elements': (test) ->
      dag = new Vorrang()

      test.ok not dag.isIn 'a', 'b'

      test.ok not dag.isBefore 'a', 'b'
      test.ok not dag.isBefore 'b', 'a'

      test.equal 0, dag.elements().length
      test.equal 0, dag.parentless().length
      test.equal 0, dag.childless().length

      test.done()

    'one relation: a -> b': (test) ->
      dag = new Vorrang()
        .before('a', 'b')

      test.ok dag.isIn 'a'
      test.ok dag.isIn 'b'
      test.ok dag.isBefore 'a', 'b'
      test.ok not dag.isBefore 'b', 'a'

      test.ok hasSameElements ['b', 'a'], dag.elements()

      test.deepEqual ['a'], dag.parentless()
      test.deepEqual ['b'], dag.childless()

      test.deepEqual [], dag.whereAllParentsIn []
      test.deepEqual ['b'], dag.whereAllParentsIn ['a']
      test.deepEqual [], dag.whereAllParentsIn ['b']

      test.done()

    'transitive relation: a -> b, b -> c': (test) ->
      dag = new Vorrang()
        .before('a', 'b')
        .before('b', 'c')

      test.ok dag.isIn 'a'
      test.ok dag.isIn 'b'
      test.ok dag.isIn 'c'
      test.ok dag.isBefore 'a', 'b'
      test.ok not dag.isBefore 'b', 'a'
      test.ok dag.isBefore 'b', 'c'
      test.ok not dag.isBefore 'c', 'b'
      # transitive
      test.ok dag.isBefore 'a', 'c'
      test.ok not dag.isBefore 'c', 'a'

      test.ok hasSameElements ['b', 'a', 'c'], dag.elements()

      test.deepEqual ['a'], dag.parentless()
      test.deepEqual ['c'], dag.childless()

      test.deepEqual [], dag.whereAllParentsIn []
      test.deepEqual ['b'], dag.whereAllParentsIn ['a']
      test.deepEqual ['c'], dag.whereAllParentsIn ['b']
      test.deepEqual [], dag.whereAllParentsIn ['c']

      test.done()

  'failures':

    'keep it irreflexive: can not set a -> a': (test) ->
      dag = new Vorrang()
      try
        dag.before 'b', 'b'
        test.ok false
      catch e
        test.equal e.message, 'arguments must not be equal'
      test.done()

    'keep it cycle free: can not set a -> b and b -> a': (test) ->
      dag = new Vorrang()
        .before('a', 'b')

      try
        dag.before 'b', 'a'
        test.ok false
      catch e
        test.equal e.message, 'trying to set `b` -> `a` but already `a` -> `b`'
      test.done()

    'keep it cycle free for transitive: can not set c -> a if a -> b and b -> c': (test) ->
      dag = new Vorrang()
        .before('a', 'b')
        .before('b', 'c')

      try
        dag.before 'c', 'a'
        test.ok false
      catch e
        test.equal e.message, 'trying to set `c` -> `a` but already `a` -> `c`'
      test.done()

    'not a string or number': (test) ->
      dag = new Vorrang()

      try
        dag.before {}, 'b'
        test.ok false
      catch e
        test.equal e.message, 'argument a must be a string or number but is object'

      try
        dag.before 'a', {}
        test.ok false
      catch e
        test.equal e.message, 'argument b must be a string or number but is object'

      test.done()

    'whereAllParentsIn with element that is not in graph': (test) ->
      dag = new Vorrang()

      try
        dag.whereAllParentsIn ['a']
        test.ok false
      catch e
        test.equal e.message, 'searching whereAllParentsIn of `a` which is not in graph'

      test.done()
