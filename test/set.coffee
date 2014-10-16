Set = require('../src/zuvor').Set

module.exports =

  'zero elements': (test) ->
    set = new Set

    test.ok not set.has 'A'
    test.equal set.toString(), '#{}'

    test.done()

  'one element': (test) ->
    set = new Set

    set
      .add 'A'
      .add 'A'

    test.ok set.has 'A'
    test.ok not set.has 'B'
    test.equal set.toString(), '#{A}'

    test.done()

  'three elements': (test) ->
    set = new Set

    set
      .add 1
      .add 1
      .add 2.2
      .add 2.2
      .add 'A'
      .add 'A'

    test.ok set.has 1
    test.ok set.has 2.2
    test.ok set.has 'A'
    test.ok not set.has 2
    test.ok not set.has 3.3
    test.ok not set.has 'B'
    test.equal set.toString(), '#{1 2.2 A}'

    test.done()

  'add': (test) ->
    set = new Set

    set.add 1

    test.ok set.has 1
    test.ok not set.has 2
    test.ok not set.has 3
    test.ok not set.has 4
    test.ok not set.has 5

    set.add [2, 3]

    test.ok set.has 1
    test.ok set.has 2
    test.ok set.has 3
    test.ok not set.has 4
    test.ok not set.has 5

    set.add new Set [4, 5]

    test.ok set.has 1
    test.ok set.has 2
    test.ok set.has 3
    test.ok set.has 4
    test.ok set.has 5

    test.done()

  'delete': (test) ->
    set = new Set [1, 2, 3, 4, 5]

    set.delete 1

    test.ok not set.has 1
    test.ok set.has 2
    test.ok set.has 3
    test.ok set.has 4
    test.ok set.has 5

    set.delete [2, 3]

    test.ok not set.has 1
    test.ok not set.has 2
    test.ok not set.has 3
    test.ok set.has 4
    test.ok set.has 5

    set.delete new Set [4, 5]

    test.ok not set.has 1
    test.ok not set.has 2
    test.ok not set.has 3
    test.ok not set.has 4
    test.ok not set.has 5

    test.done()

  'failures':

    'can not add objects': (test) ->
      set = new Set
      test.throws ->
        set.add {}
      test.throws ->
        set.add null
      test.done()

  'properties that hold for any set': (test) ->
    xss = [
      []
      ['A']
      ['A', 'B']
      ['A', 'B', 'C']
      ['A', 'B', 'C', 'D']
      ['A', 'B', 'C', 'D', 'E']
      [1...1000]
    ]

    xss.forEach (xs) ->
      # construction method 1
      set = new Set xs

      # construction method 2
      set2 = new Set
      set2.add xs

      # construction method 3
      set2 = new Set
      set2.add xs

      # construction method 3
      set3 = new Set
      xs.forEach (x) ->
        set3.add x

      # construction method 4
      set4 = new Set
      set4.add xs...

      # construction method 5
      set5 = new Set xs...

      # construction methods are equivalent
      test.ok set.equals set2
      test.ok set2.equals set3
      test.ok set3.equals set4
      test.ok set4.equals set5

      test.equal xs.length, set.size
      test.deepEqual xs, set.keys()
      test.deepEqual xs, set.values()

      # every element is in the set
      xs.forEach (x) ->
        test.ok set.has x

      # an element is not in the set
      test.ok not set.has 'F'

      # size matches
      test.equal set.size, xs.length

      # any set is equal to itself
      test.ok set.equals set

      # any set is equal to its clone
      test.ok set.equals set.clone()

      # any set is equal to a new set initialized with it
      test.ok set.equals new Set set

      # adding the set again doesn't change it
      clone = set.clone()
      clone.add set
      test.ok set.equals clone

      # adding the array again doesn't change it
      clone = set.clone()
      clone.add xs
      test.ok set.equals clone

      # removing a set from itself results in the empty set
      clone = set.clone()
      clone.delete set
      test.equals 0, clone.size

      # clearing a set results in the empty set
      clone = set.clone()
      clone.clear()
      test.equals 0, clone.size

      # original set is unchanged
      test.equals set.size, xs.length
      test.deepEqual xs, set.keys()

    test.done()
