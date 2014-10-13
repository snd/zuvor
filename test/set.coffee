Set = require('../src/zuvor').Set

module.exports =

  'zero elements': (test) ->
    set = new Set

    test.ok not set.isIn 'A'
    test.equal set.toString(), '#{}'

    test.ok set.remove set

    test.done()

  'one element': (test) ->
    set = new Set

    set
      .add 'A'
      .add 'A'

    test.ok set.isIn 'A'
    test.ok not set.isIn 'B'
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

    test.ok set.isIn 1
    test.ok set.isIn 2.2
    test.ok set.isIn 'A'
    test.ok not set.isIn 2
    test.ok not set.isIn 3.3
    test.ok not set.isIn 'B'
    test.equal set.toString(), '#{1 2.2 A}'

    test.done()

  'can not add objects': (test) ->
    set = new Set
    test.throws ->
      set.add {}
    test.throws ->
      set.add null
    test.done()

  'add': (test) ->
    set = new Set

    set.add 1

    test.ok set.isIn 1
    test.ok not set.isIn 2
    test.ok not set.isIn 3
    test.ok not set.isIn 4
    test.ok not set.isIn 5

    set.add [2, 3]

    test.ok set.isIn 1
    test.ok set.isIn 2
    test.ok set.isIn 3
    test.ok not set.isIn 4
    test.ok not set.isIn 5

    set.add new Set [4, 5]

    test.ok set.isIn 1
    test.ok set.isIn 2
    test.ok set.isIn 3
    test.ok set.isIn 4
    test.ok set.isIn 5

    test.done()

  'remove': (test) ->
    set = new Set [1, 2, 3, 4, 5]

    set.remove 1

    test.ok not set.isIn 1
    test.ok set.isIn 2
    test.ok set.isIn 3
    test.ok set.isIn 4
    test.ok set.isIn 5

    set.remove [2, 3]

    test.ok not set.isIn 1
    test.ok not set.isIn 2
    test.ok not set.isIn 3
    test.ok set.isIn 4
    test.ok set.isIn 5

    set.remove new Set [4, 5]

    test.ok not set.isIn 1
    test.ok not set.isIn 2
    test.ok not set.isIn 3
    test.ok not set.isIn 4
    test.ok not set.isIn 5

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

      set3 = new Set

      # construction method 3
      xs.forEach (x) ->
        set3.add x

      # construction methods are equivalent
      test.ok set.isEqual set2
      test.ok set2.isEqual set3

      test.equal xs.length, set.length
      test.deepEqual xs, set.elements()

      # the empty set is empty
      test.equal set.isEmpty(), xs.length is 0

      # any set is equal to itself
      test.ok set.isEqual set

      clone = set.clone()
      # any set is equal to its clone
      test.ok set.isEqual clone
      # any set is equal to a new set initialized with it
      test.ok set.isEqual new Set set
      # adding the set again doesn't change it
      set.add set
      test.ok set.isEqual clone
      # adding the array again doesn't change it
      set.add xs
      test.ok set.isEqual clone

      # every element is in the set
      xs.forEach (x) ->
        test.ok set.isIn x

      test.ok not set.isIn 'F'

      # removing a set from itself results in the empty set
      clone2 = set.clone()
      clone2.remove clone2
      test.ok clone2.isEmpty()
      test.equal clone2.length, 0

    test.done()
