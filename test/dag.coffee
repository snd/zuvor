Dag = require('../src/zuvor').Dag

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
      dag = new Dag

      test.ok not dag.isIn 'a', 'b'

      test.ok not dag.isBefore 'a', 'b'
      test.ok not dag.isBefore 'b', 'a'

      test.equal 0, dag.values().length
      test.equal 0, dag.parentless().length
      test.equal 0, dag.childless().length

      test.deepEqual dag.edges(), []

      test.done()

    'a -> b': (test) ->
      dag = new Dag()
        .before('a', 'b')

      test.ok dag.isIn 'a'
      test.ok dag.isIn 'b'

      test.ok dag.isBefore 'a', 'b'
      test.ok not dag.isBefore 'b', 'a'

      test.ok hasSameElements ['b', 'a'], dag.values()

      test.deepEqual ['a'], dag.parentless()
      test.deepEqual ['b'], dag.childless()

      test.deepEqual [], dag.whereAllParentsIn []
      test.deepEqual ['b'], dag.whereAllParentsIn ['a']
      test.deepEqual [], dag.whereAllParentsIn ['b']

      test.deepEqual [], dag.whereAllChildrenIn []
      test.deepEqual [], dag.whereAllChildrenIn ['a']
      test.deepEqual ['a'], dag.whereAllChildrenIn ['b']

      test.deepEqual dag.edges(), [['a', 'b']]

      test.done()

    'a -> b, b -> c (transitive)': (test) ->
      dag = new Dag()
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

      test.ok hasSameElements ['b', 'a', 'c'], dag.values()

      test.deepEqual ['a'], dag.parentless()
      test.deepEqual ['c'], dag.childless()

      test.deepEqual [], dag.whereAllParentsIn []
      test.deepEqual ['b'], dag.whereAllParentsIn ['a']
      test.deepEqual ['c'], dag.whereAllParentsIn ['b']
      test.deepEqual [], dag.whereAllParentsIn ['c']

      test.deepEqual [], dag.whereAllChildrenIn []
      test.deepEqual [], dag.whereAllChildrenIn ['a']
      test.deepEqual ['a'], dag.whereAllChildrenIn ['b']
      test.deepEqual ['b'], dag.whereAllChildrenIn ['c']

      test.deepEqual dag.edges(), [['a', 'b'], ['b', 'c']]

      test.done()

    'a -> b, b -> c, a -> c': (test) ->
      dag = new Dag()
        .before('a', 'b')
        .before('b', 'c')
        .before('a', 'c')

      test.ok dag.isIn 'a'
      test.ok dag.isIn 'b'
      test.ok dag.isIn 'c'

      test.ok dag.isBefore 'a', 'b'
      test.ok not dag.isBefore 'b', 'a'
      test.ok dag.isBefore 'b', 'c'
      test.ok not dag.isBefore 'c', 'b'
      test.ok dag.isBefore 'a', 'c'
      test.ok not dag.isBefore 'c', 'a'

      test.ok hasSameElements ['b', 'a', 'c'], dag.values()

      test.deepEqual ['a'], dag.parentless()
      test.deepEqual ['c'], dag.childless()

      test.deepEqual [], dag.whereAllParentsIn []
      test.deepEqual ['b'], dag.whereAllParentsIn ['a']
      test.deepEqual [], dag.whereAllParentsIn ['b']
      test.deepEqual ['c'], dag.whereAllParentsIn ['b', 'a']
      test.deepEqual [], dag.whereAllParentsIn ['c']

      test.deepEqual [], dag.whereAllChildrenIn []
      test.deepEqual [], dag.whereAllChildrenIn ['a']
      test.deepEqual [], dag.whereAllChildrenIn ['b']
      test.deepEqual ['a'], dag.whereAllChildrenIn ['b', 'c']
      test.deepEqual ['b'], dag.whereAllChildrenIn ['c']

      test.deepEqual dag.edges(), [['a', 'b'], ['a', 'c'], ['b', 'c']]

      test.done()

    'large graph': (test) ->
      # taken from http://stackoverflow.com/a/12790718
      dag = new Dag()
        .before(0, 7)
        .before(0, 10)
        .before(0, 13)
        .before(1, 2)
        .before(1, 9)
        .before(1, 13)
        .before(2, 10)
        .before(2, 12)
        .before(2, 13)
        .before(2, 14)
        .before(3, 6)
        .before(3, 8)
        .before(3, 9)
        .before(3, 11)
        .before(4, 7)
        .before(5, 6)
        .before(5, 7)
        .before(5, 9)
        .before(5, 10)
        .before(6, 15)
        .before(7, 14)
        .before(8, 15)
        .before(9, 11)
        .before(9, 14)
        .before(10, 14)

      numbers = [0..15]
      for number in numbers
        test.ok dag.isIn number
      test.ok not dag.isIn 16

      test.ok hasSameElements numbers, dag.values()

      test.ok hasSameElements [0, 1, 3, 4, 5], dag.parentless()
      test.ok hasSameElements [12, 13, 14, 11, 15], dag.childless()

      test.ok hasSameElements [12, 13, 14, 11, 15], dag.childless()

      test.deepEqual [], dag.whereAllParentsIn []
      test.ok hasSameElements [2], dag.whereAllParentsIn [1]
      test.ok hasSameElements [6, 8], dag.whereAllParentsIn [5, 3]
      test.ok hasSameElements [7], dag.whereAllParentsIn [0, 4, 5]
      test.ok hasSameElements [8], dag.whereAllParentsIn [3]
      test.ok hasSameElements [9, 2, 8, 6], dag.whereAllParentsIn [1, 3, 5]
      test.ok hasSameElements [10, 12], dag.whereAllParentsIn [2, 0, 5]
      test.ok hasSameElements [11, 8], dag.whereAllParentsIn [3, 9]
      test.ok hasSameElements [12], dag.whereAllParentsIn [2]
      test.ok hasSameElements [13, 12], dag.whereAllParentsIn [2, 1, 0]
      test.ok hasSameElements [14, 12], dag.whereAllParentsIn [2, 0, 10, 7, 9]
      test.ok hasSameElements [15], dag.whereAllParentsIn [6, 8]

      test.deepEqual [], dag.whereAllChildrenIn []
      test.ok hasSameElements [1], dag.whereAllChildrenIn [2, 13, 9]
      test.ok hasSameElements [2, 7], dag.whereAllChildrenIn [10, 12, 13, 14]
      test.ok hasSameElements [3], dag.whereAllChildrenIn [9, 6, 8, 11]
      test.ok hasSameElements [4], dag.whereAllChildrenIn [7]
      test.ok hasSameElements [5, 4], dag.whereAllChildrenIn [10, 7, 9, 6]
      test.ok hasSameElements [6, 8], dag.whereAllChildrenIn [15]
      test.ok hasSameElements [7, 10], dag.whereAllChildrenIn [14]
      test.ok hasSameElements [8, 6], dag.whereAllChildrenIn [15]
      test.ok hasSameElements [9, 7, 10], dag.whereAllChildrenIn [11, 14]
      test.ok hasSameElements [10, 7], dag.whereAllChildrenIn [14]

      test.deepEqual dag.edges(), [
        [0, 7]
        [0, 10]
        [0, 13]
        [1, 2]
        [1, 9]
        [1, 13]
        [2, 10]
        [2, 12]
        [2, 13]
        [2, 14]
        [3, 6]
        [3, 8]
        [3, 9]
        [3, 11]
        [4, 7]
        [5, 6]
        [5, 7]
        [5, 9]
        [5, 10]
        [6, 15]
        [7, 14]
        [8, 15]
        [9, 11]
        [9, 14]
        [10, 14]
      ]

      test.done()

  'failures':

    'keep it irreflexive: can not set a -> a': (test) ->
      dag = new Dag()
      try
        dag.before 'b', 'b'
        test.ok false
      catch e
        test.equal e.message, 'arguments must not be equal'
      test.done()

    'keep it cycle free: can not set a -> b and b -> a': (test) ->
      dag = new Dag()
        .before('a', 'b')

      try
        dag.before 'b', 'a'
        test.ok false
      catch e
        test.equal e.message, 'trying to set `b` -> `a` but already `a` -> `b`'
      test.done()

    'keep it cycle free for transitive: can not set c -> a if a -> b and b -> c': (test) ->
      dag = new Dag()
        .before('a', 'b')
        .before('b', 'c')

      try
        dag.before 'c', 'a'
        test.ok false
      catch e
        test.equal e.message, 'trying to set `c` -> `a` but already `a` -> `c`'
      test.done()

    'not a string or number': (test) ->
      dag = new Dag()

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
      dag = new Dag()

      try
        dag.whereAllParentsIn ['a']
        test.ok false
      catch e
        test.equal e.message, 'searching whereAllParentsIn of `a` which is not in graph'

      test.done()

    'whereAllChildrenIn with element that is not in graph': (test) ->
      dag = new Dag()

      try
        dag.whereAllChildrenIn ['a']
        test.ok false
      catch e
        test.equal e.message, 'searching whereAllChildrenIn of `a` which is not in graph'

      test.done()
