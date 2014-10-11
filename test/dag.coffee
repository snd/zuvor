Promise = require 'bluebird'

vorrang = require '../src/vorrang'

hasSameElements = (as, bs) ->
  if as.length isnt bs.length
    return false
  for a in as
    if -1 is bs.indexOf a
      return false
  return true

module.exports =

  'zero elements': (test) ->
    dag = new vorrang.Dag()

    test.ok not dag.isIn 'a', 'b'

    test.ok not dag.isBefore 'a', 'b'
    test.ok not dag.isBefore 'b', 'a'

    test.equal 0, dag.elements().length
    test.equal 0, dag.minElements().length
    test.equal 0, dag.maxElements().length

    test.done()

  'one relation (a < b)': (test) ->
    dag = new vorrang.Dag()
      .before('a', 'b')

    test.ok dag.isIn 'a'
    test.ok dag.isIn 'b'
    test.ok dag.isBefore 'a', 'b'
    test.ok not dag.isBefore 'b', 'a'

    test.ok hasSameElements ['b', 'a'], dag.elements()

    test.deepEqual ['a'], dag.minElements()
    test.deepEqual ['b'], dag.maxElements()

    test.deepEqual [], dag.minUpperBound []
    test.deepEqual ['b'], dag.minUpperBound ['a']
    test.deepEqual [], dag.minUpperBound ['b']

    test.deepEqual [], dag.maxLowerBound []
    test.deepEqual ['a'], dag.maxLowerBound ['b']
    test.deepEqual [], dag.maxLowerBound ['a']

    test.done()

  'transitive relation (a < b, b < c)': (test) ->
    dag = new vorrang.Dag()
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

    test.deepEqual ['a'], dag.minElements()
    test.deepEqual ['c'], dag.maxElements()

    test.deepEqual [], dag.minUpperBound []
    test.deepEqual ['b'], dag.minUpperBound ['a']
    test.deepEqual ['c'], dag.minUpperBound ['b']
    test.deepEqual [], dag.minUpperBound ['c']

    test.deepEqual [], dag.maxLowerBound []
    test.deepEqual [], dag.maxLowerBound ['a']
    test.deepEqual ['a'], dag.maxLowerBound ['b']
    test.deepEqual ['b'], dag.maxLowerBound ['c']

    test.deepEqual ['a'], dag.maxLowerBound ['b', 'c']

    test.done()

#
#   'can not set a < a': (test) ->
#     poset = vorrang.poset()
#
#     try
#       vorrang.setLower poset, 'b', 'b'
#       test.ok false
#     catch e
#       test.equal e.message, 'arguments must not be equal'
#     test.done()
#
#   'can not set a < b and b < a': (test) ->
#     poset = mori.pipeline(
#       vorrang.poset()
#       mori.curry(vorrang.setLower, 'a', 'b')
#     )
#
#     try
#       vorrang.setLower poset, 'b', 'a'
#       test.ok false
#     catch e
#       test.equal e.message, 'trying to set `b` < `a` but already `a` < `b`'
#     test.done()
#
#   'can not set c < a if a < b and b < c (a < c transitive)': (test) ->
#     poset = mori.pipeline(
#       vorrang.poset()
#       mori.curry(vorrang.setLower, 'a', 'b')
#       mori.curry(vorrang.setLower, 'b', 'c')
#     )
#
#     try
#       vorrang.setLower poset, 'c', 'a'
#       test.ok false
#     catch e
#       test.equal e.message, 'trying to set `c` < `a` but already `a` < `c`'
#     test.done()
#
#   'adding the same relation multiple times is idempotent': (test) ->
#     alpha = vorrang.poset()
#
#     bravo = vorrang.setLower alpha, 'a', 'b'
#     charlie = vorrang.setLower bravo, 'a', 'b'
#
#     test.ok not mori.equals alpha.greater, bravo.greater
#     test.ok not mori.equals alpha.lower, bravo.lower
#
#     test.ok mori.equals bravo.greater, charlie.greater
#     test.ok mori.equals bravo.lower, charlie.lower
#
#     test.done()

  ###################################################################################
  # comparison

#   'comparison': (test) ->
#     poset = mori.pipeline(
#       vorrang.poset()
#       mori.curry(vorrang.setLower, 'postgres', 'server')
#       mori.curry(vorrang.setLower, 'redis', 'server')
#       mori.curry(vorrang.setLower, 'server', 'worker')
#     )
#
#     # non elements are incomparable
#     test.equal 'incomparable', vorrang.compare poset, 'mongodb', 'server'
#
#     test.ok not vorrang.isComparable poset, 'mongodb', 'server'
#     test.ok not vorrang.isLower poset, 'mongodb', 'server'
#     test.ok not vorrang.isGreater poset, 'mongodb', 'server'
#     test.ok not vorrang.isEqual poset, 'mongodb', 'server'
#
#     # equal non elements are incomparable
#     test.equal 'incomparable', vorrang.compare poset, 'mongodb', 'mongodb'
#
#     # unordered elements are incomparable
#     test.equal 'incomparable', vorrang.compare poset, 'postgres', 'redis'
#
#     # equal elements are equal
#     test.equal 'equal', vorrang.compare poset, 'postgres', 'postgres'
#
#     test.ok vorrang.isComparable poset, 'postgres', 'postgres'
#     test.ok not vorrang.isLower poset, 'postgres', 'postgres'
#     test.ok not vorrang.isGreater poset, 'postgres', 'postgres'
#     test.ok vorrang.isEqual poset, 'postgres', 'postgres'
#
#     test.equal 'equal', vorrang.compare poset, 'redis', 'redis'
#     test.equal 'equal', vorrang.compare poset, 'server', 'server'
#     test.equal 'equal', vorrang.compare poset, 'worker', 'worker'
#
#     # directly ordered elements are ordered
#     test.equal 'lower', vorrang.compare poset, 'postgres', 'server'
#
#     test.ok vorrang.isComparable poset, 'postgres', 'server'
#     test.ok vorrang.isLower poset, 'postgres', 'server'
#     test.ok not vorrang.isGreater poset, 'postgres', 'server'
#     test.ok not vorrang.isEqual poset, 'postgres', 'server'
#
#     test.equal 'greater', vorrang.compare poset, 'server', 'postgres'
#
#     test.ok vorrang.isComparable poset, 'server', 'postgres'
#     test.ok not vorrang.isLower poset, 'server', 'postgres'
#     test.ok vorrang.isGreater poset, 'server', 'postgres'
#     test.ok not vorrang.isEqual poset, 'server', 'postgres'
#
#     test.equal 'lower', vorrang.compare poset, 'redis', 'server'
#     test.equal 'greater', vorrang.compare poset, 'server', 'redis'
#
#     test.equal 'lower', vorrang.compare poset, 'server', 'worker'
#     test.equal 'greater', vorrang.compare poset, 'worker', 'server'
#
#     # indirectly (transitive) ordered elements are ordered
#
#     test.equal 'lower', vorrang.compare poset, 'postgres', 'worker'
#     test.equal 'greater', vorrang.compare poset, 'worker', 'postgres'
#
#     test.equal 'lower', vorrang.compare poset, 'redis', 'worker'
#     test.equal 'greater', vorrang.compare poset, 'worker', 'redis'
#
#     test.done()
#
#   ###################################################################################
#   # predicates
#
#   'isIn': (test) ->
#     alpha = vorrang.poset()
#
#     bravo = vorrang.setLower alpha, 'a', 'b'
#     charlie = vorrang.setLower bravo, 'c', 'b'
#
#     test.ok vorrang.isIn charlie, 'a'
#     test.ok vorrang.isIn charlie, 'b'
#     test.ok vorrang.isIn charlie, 'c'
#     test.ok not vorrang.isIn charlie, 'd'
#
#     test.done()
#
#   ###################################################################################
#   # elements
#
#   'elements': (test) ->
#     alpha = vorrang.poset()
#
#     bravo = vorrang.setLower alpha, 'a', 'b'
#     charlie = vorrang.setLower bravo, 'c', 'b'
#
#     test.deepEqual ['a', 'b', 'c'], vorrang.elements charlie
#
#     test.done()
#
#   'minELements': (test) ->
#     alpha = vorrang.poset()
#
#     bravo = vorrang.setLower alpha, 'a', 'b'
#     charlie = vorrang.setLower bravo, 'c', 'b'
#
#     test.deepEqual ['a', 'c'], vorrang.minElements charlie
#
#     test.done()
#
#   'maxElements': (test) ->
#     alpha = vorrang.poset()
#
#     bravo = vorrang.setLower alpha, 'a', 'b'
#     charlie = vorrang.setLower bravo, 'c', 'b'
#
#     test.deepEqual ['b'], vorrang.maxElements charlie
#
#     test.done()

#   'isCovered & getCovering': (test) ->
#       poset = vorrang.poset()
#       test.deepEqual [], vorrang.getCovering(poset, 'a')
#       test.ok not vorrang.isCovered poset, 'b', 'a'
#       test.ok not vorrang.isCovered poset, 'c', 'a'
#
#       # no effect
#       poset = vorrang.setLte poset, 'a', 'a'
#       test.deepEqual [], vorrang.getCovering(poset, 'a')
#       test.ok not vorrang.isCovered poset, 'b', 'a'
#       test.ok not vorrang.isCovered poset, 'c', 'a'
#
#       poset = vorrang.setLte poset, 'b', 'a'
#       test.deepEqual ['b'], vorrang.getCovering(poset, 'a')
#       test.ok vorrang.isCovered poset, 'b', 'a'
#       test.ok not vorrang.isCovered poset, 'c', 'a'
#
#       poset = vorrang.setLte poset, 'c', 'a'
#       test.deepEqual ['b', 'c'], vorrang.getCovering(poset, 'a')
#       test.ok vorrang.isCovered poset, 'b', 'a'
#       test.ok vorrang.isCovered poset, 'c', 'a'
#
#       # no effect
#       poset = vorrang.setLte poset, 'c', 'b'
#       test.deepEqual ['b', 'c'], vorrang.getCovering(poset, 'a')
#       test.ok vorrang.isCovered poset, 'b', 'a'
#       test.ok vorrang.isCovered poset, 'c', 'a'
#
#       test.done()
#
#   # TODO test that cycles fail


  ###################################################################################
  # task example

#   'task example': (test) ->
#
#     started = mori.set()
#     completed = mori.set()
#
#     callbacks =
#       worker: () ->
#         console.log 'stopping worker'
#         Promise.delay 100, 5
#       postgres: () ->
#         console.log 'stopping postgres'
#         Promise.delay 100, 5
#       server: () ->
#         console.log 'stopping server'
#         Promise.delay 100, 5
#       redis: () ->
#         console.log 'stopping redis'
#         Promise.delay 100, 5
#
#     poset = mori.pipeline(
#       vorrang.poset()
#       # shutdown worker before shutting down postgres
#       mori.curry(vorrang.setLower, 'worker', 'postgres')
#       # shutdown server before shutting down postgres
#       mori.curry(vorrang.setLower, 'server', 'postgres')
#       # shutdown server before shutting down redis
#       mori.curry(vorrang.setLower, 'server', 'redis')
#     )
#
#     start = (names) ->
#       console.log 'call', names
#       iterator = (name) ->
#         if mori.get(called, name)?
#           throw new Error "can not call what is already called: #{name}"
#         if mori.get(stopped, name)?
#           throw new Error "can not call what is already stopped: #{name}"
#         callback = callbacks[name]
#         unless callback?
#           throw new Error "no callback for: #{name}"
#         promise = Promise.resolve callback()
#         return promise.then ->
#           console.log name, 'is now stopped'
#           # the service is now stopped
#           stopped = mori.conj stopped, name
#           return stop()
#       Promise.all mori.into_array mori.map iterator, names
#
#     console.log poset
#
#     stop = ->
#       console.log 'stop'
#       console.log 'called', called
#       console.log 'stopped', stopped
#       noneCalledYet = mori.is_empty(called)
#       if noneCalledYet
#         # we are just getting started
#         minElements = vorrang.minElements poset
#         console.log 'minElements', minElements
#         promise = call minElements
#         # remember that we called those names
#         called = mori.into called, minElements
#         return promise
#
#       minUpperBound = vorrang.minUpperBound poset, stopped
#       console.log 'minUpperBound', minUpperBound
#       # do not call any that have already been called
#       nowReadyAndNotYetCalled = mori.difference minUpperBound, called
#       promise = call nowReadyAndNotYetCalled
#       # remember that we called those names
#       called = mori.into called, nowReadyAndNotYetCalled
#       return promise
#
#     stop().then ->
#       test.done()
