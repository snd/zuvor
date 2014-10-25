{Graph, Set, run} = require('../src/zuvor')

module.exports =

  'orderless': (test) ->
    run(
      ids: ['a', 'b', 'c']
      graph: new Graph
      callback: (id) ->
        console.log id
        id
    ).then (result) ->
      console.log result
      test.done()

  'values from parents are passed to children': (test) ->
    table =
      a: (values) ->
        test.ok not values
        1
      b: (values) ->
        test.deepEqual values,
          a: 1
        2
      c: (values) ->
        test.deepEqual values,
          b: 2
          d: 4
        3
      d: (values) ->
        test.ok not values
        4
      e: (values) ->
        test.ok not values
        5
      f: (values) ->
        test.ok not values
        6
      g: (values) ->
        test.ok not values
        7

    graph = new Graph()
      .add('a', 'b')
      .add('b', 'c')
      .add('d', 'c')

    run(
      ids: ['a', 'b', 'c', 'd', 'e', 'f', 'g']
      graph: graph
      callback: (id, values) -> table[id](values)
    ).then (result) ->
      test.deepEqual result,
        a: 1
        b: 2
        c: 3
        d: 4
        e: 5
        f: 6
        g: 7
      test.done()
