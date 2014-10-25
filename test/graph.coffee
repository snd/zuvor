{Graph, Set} = require('../src/zuvor')

module.exports =

  'scenarios':

    'zero elements': (test) ->
      graph = new Graph

      test.ok not graph.has 'a'
      test.ok not graph.has 'b'

      test.ok not graph.has 'a', 'b'
      test.ok not graph.has 'b', 'a'

      test.equal 0, graph.values().length
      test.equal 0, graph.parentless().length
      test.equal 0, graph.childless().length

      test.deepEqual graph.edges(), []

      test.done()

    'a -> b': (test) ->
      graph = new Graph()
        .add('a', 'b')

      test.ok graph.has 'a'
      test.ok graph.has 'b'
      test.ok not graph.has 'c'

      test.ok graph.has 'a', 'b'
      test.ok not graph.has 'b', 'a'

      test.ok new Set('b', 'a').equals graph.values()

      test.deepEqual ['a'], graph.parentless()
      test.deepEqual ['b'], graph.childless()

      test.deepEqual ['a'], graph.parents('b')
      test.deepEqual [], graph.parents('a')

      test.deepEqual ['b'], graph.children('a')
      test.deepEqual [], graph.children('b')

      test.deepEqual [], graph.whereAllParentsIn []
      test.deepEqual [], graph.whereAllParentsIn new Set()
      test.deepEqual ['b'], graph.whereAllParentsIn ['a']
      test.deepEqual ['b'], graph.whereAllParentsIn new Set('a')
      test.deepEqual [], graph.whereAllParentsIn ['b']
      test.deepEqual [], graph.whereAllParentsIn new Set('b')

      test.deepEqual [], graph.whereAllChildrenIn []
      test.deepEqual [], graph.whereAllChildrenIn new Set()
      test.deepEqual [], graph.whereAllChildrenIn ['a']
      test.deepEqual [], graph.whereAllChildrenIn new Set('a')
      test.deepEqual ['a'], graph.whereAllChildrenIn ['b']
      test.deepEqual ['a'], graph.whereAllChildrenIn new Set('b')

      test.deepEqual graph.edges(), [['a', 'b']]

      test.done()

    'a -> b, b -> c (transitive)': (test) ->
      graph = new Graph()
        .add('a', 'b')
        .add('b', 'c')

      test.ok graph.has 'a'
      test.ok graph.has 'b'
      test.ok graph.has 'c'

      test.ok graph.has 'a', 'b'
      test.ok not graph.has 'b', 'a'
      test.ok graph.has 'b', 'c'
      test.ok not graph.has 'c', 'b'
      # transitive
      test.ok graph.has 'a', 'c'
      test.ok not graph.has 'c', 'a'

      test.ok new Set('b', 'a', 'c').equals graph.values()

      test.deepEqual ['a'], graph.parentless()
      test.deepEqual ['c'], graph.childless()

      test.deepEqual ['b'], graph.parents('c')
      test.deepEqual ['a'], graph.parents('b')
      test.deepEqual [], graph.parents('a')

      test.deepEqual ['b'], graph.children('a')
      test.deepEqual ['c'], graph.children('b')
      test.deepEqual [], graph.children('c')

      test.deepEqual [], graph.whereAllParentsIn []
      test.deepEqual ['b'], graph.whereAllParentsIn ['a']
      test.deepEqual ['c'], graph.whereAllParentsIn ['b']
      test.deepEqual [], graph.whereAllParentsIn ['c']

      test.deepEqual [], graph.whereAllChildrenIn []
      test.deepEqual [], graph.whereAllChildrenIn ['a']
      test.deepEqual ['a'], graph.whereAllChildrenIn ['b']
      test.deepEqual ['b'], graph.whereAllChildrenIn ['c']

      test.deepEqual graph.edges(), [['a', 'b'], ['b', 'c']]

      test.done()

    'a -> b, b -> c, a -> c': (test) ->
      graph = new Graph()
        .add('a', 'b')
        .add('b', 'c')
        .add('a', 'c')

      test.ok graph.has 'a'
      test.ok graph.has 'b'
      test.ok graph.has 'c'

      test.ok graph.has 'a', 'b'
      test.ok not graph.has 'b', 'a'
      test.ok graph.has 'b', 'c'
      test.ok not graph.has 'c', 'b'
      test.ok graph.has 'a', 'c'
      test.ok not graph.has 'c', 'a'

      test.ok new Set(['b', 'a', 'c']).equals graph.values()

      test.deepEqual ['a'], graph.parentless()
      test.deepEqual ['c'], graph.childless()

      test.ok new Set('b', 'a').equals graph.parents('c')
      test.deepEqual ['a'], graph.parents('b')
      test.deepEqual [], graph.parents('a')

      test.ok new Set('b', 'c').equals graph.children('a')
      test.deepEqual ['c'], graph.children('b')
      test.deepEqual [], graph.children('c')

      test.deepEqual [], graph.whereAllParentsIn []
      test.deepEqual ['b'], graph.whereAllParentsIn ['a']
      test.deepEqual [], graph.whereAllParentsIn ['b']
      test.deepEqual ['c'], graph.whereAllParentsIn ['b', 'a']
      test.deepEqual [], graph.whereAllParentsIn ['c']

      test.deepEqual [], graph.whereAllChildrenIn []
      test.deepEqual [], graph.whereAllChildrenIn ['a']
      test.deepEqual [], graph.whereAllChildrenIn ['b']
      test.deepEqual ['a'], graph.whereAllChildrenIn ['b', 'c']
      test.deepEqual ['b'], graph.whereAllChildrenIn ['c']

      test.deepEqual graph.edges(), [['a', 'b'], ['a', 'c'], ['b', 'c']]

      test.done()

    'large graph': (test) ->
      # taken from http://stackoverflow.com/a/12790718
      graph = new Graph()
        .add(0, 7)
        .add(0, 10)
        .add(0, 13)
        .add(0, 14)
        .add(1, 2)
        .add(1, 9)
        .add(1, 13)
        .add(2, 10)
        .add(2, 12)
        .add(2, 13)
        .add(2, 14)
        .add(3, 6)
        .add(3, 8)
        .add(3, 9)
        .add(3, 11)
        .add(4, 7)
        .add(5, 6)
        .add(5, 7)
        .add(5, 9)
        .add(5, 10)
        .add(6, 15)
        .add(7, 14)
        .add(8, 15)
        .add(9, 11)
        .add(9, 14)
        .add(10, 14)

      numbers = [0..15]
      for number in numbers
        test.ok graph.has number
      test.ok not graph.has 16

      test.ok new Set(numbers).equals graph.values()

      test.ok new Set(0, 1, 3, 4, 5).equals graph.parentless()
      test.ok new Set(12, 13, 14, 11, 15).equals graph.childless()

      test.ok new Set(12, 13, 14, 11, 15).equals graph.childless()

      test.ok new Set(0, 1, 2).equals graph.parents(13)
      test.ok new Set(2, 0, 10, 7, 9).equals graph.parents(14)

      test.ok new Set(10, 12, 13, 14).equals graph.children(2)
      test.ok new Set(10, 7, 9, 6).equals graph.children(5)

      test.ok new Set().equals graph.whereAllParentsIn []
      test.ok new Set(2).equals graph.whereAllParentsIn [1]
      test.ok new Set(6, 8).equals graph.whereAllParentsIn [5, 3]
      test.ok new Set(7).equals graph.whereAllParentsIn [0, 4, 5]
      test.ok new Set(8).equals graph.whereAllParentsIn [3]
      test.ok new Set(9, 2, 8, 6).equals graph.whereAllParentsIn [1, 3, 5]
      test.ok new Set(10, 12).equals graph.whereAllParentsIn [2, 0, 5]
      test.ok new Set(11, 8).equals graph.whereAllParentsIn [3, 9]
      test.ok new Set(12).equals graph.whereAllParentsIn [2]
      test.ok new Set(13, 12).equals graph.whereAllParentsIn [2, 1, 0]
      test.ok new Set(14, 12).equals graph.whereAllParentsIn [2, 0, 10, 7, 9]
      test.ok new Set(15).equals graph.whereAllParentsIn [6, 8]

      test.ok new Set().equals graph.whereAllChildrenIn []
      test.ok new Set(1).equals graph.whereAllChildrenIn [2, 13, 9]
      test.ok new Set(2, 7).equals graph.whereAllChildrenIn [10, 12, 13, 14]
      test.ok new Set(3).equals graph.whereAllChildrenIn [9, 6, 8, 11]
      test.ok new Set(4).equals graph.whereAllChildrenIn [7]
      test.ok new Set(5, 4).equals graph.whereAllChildrenIn [10, 7, 9, 6]
      test.ok new Set(6, 8).equals graph.whereAllChildrenIn [15]
      test.ok new Set(7, 10).equals graph.whereAllChildrenIn [14]
      test.ok new Set(8, 6).equals graph.whereAllChildrenIn [15]
      test.ok new Set(9, 7, 10).equals graph.whereAllChildrenIn [11, 14]
      test.ok new Set(10, 7).equals graph.whereAllChildrenIn [14]

      test.deepEqual graph.edges(), [
        [0, 7]
        [0, 10]
        [0, 13]
        [0, 14]
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
      graph = new Graph()
      try
        graph.add 'b', 'b'
        test.ok false
      catch e
        test.equal e.message, 'arguments must not be equal'
      test.done()

    'keep it cycle free: can not set a -> b and b -> a': (test) ->
      graph = new Graph()
        .add('a', 'b')

      try
        graph.add 'b', 'a'
        test.ok false
      catch e
        test.equal e.message, 'trying to set `b` -> `a` but already `a` -> `b`'
      test.done()

    'keep it cycle free for transitive: can not set c -> a if a -> b and b -> c': (test) ->
      graph = new Graph()
        .add('a', 'b')
        .add('b', 'c')

      try
        graph.add 'c', 'a'
        test.ok false
      catch e
        test.equal e.message, 'trying to set `c` -> `a` but already `a` -> `c`'
      test.done()

    'add called with invalid arguments': (test) ->
      graph = new Graph()

      try
        graph.add {}, 'b'
        test.ok false
      catch e
        test.equal e.message, 'first argument must be a string or number but is object'

      try
        graph.add 'a', {}
        test.ok false
      catch e
        test.equal e.message, 'second argument must be a string or number but is object'

      try
        graph.add 'a'
        test.ok false
      catch e
        test.equal e.message, 'second argument must be a string or number but is undefined'

      test.done()

    'whereAllParentsIn with element that is not in graph': (test) ->
      graph = new Graph()

      try
        graph.whereAllParentsIn ['a']
        test.ok false
      catch e
        test.equal e.message, 'searching whereAllParentsIn of `a` which is not in graph'

      test.done()

    'whereAllChildrenIn with element that is not in graph': (test) ->
      graph = new Graph()

      try
        graph.whereAllChildrenIn ['a']
        test.ok false
      catch e
        test.equal e.message, 'searching whereAllChildrenIn of `a` which is not in graph'

      test.done()
