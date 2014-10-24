Promise = require 'bluebird'

{Graph, Set, run} = require('../src/zuvor')

###################################################################################
# test

module.exports =

  'systems are started and stopped in the most efficient order': (test) ->
    # test.expect (12 * 4) + (2 * 4)

    starting = new Set
    running = new Set
    stopping = new Set
    stopped = new Set

    debug = ->
      console.log 'starting', starting.toString()
      console.log 'stopping', stopping.toString()
      console.log 'running', running.toString()
      console.log 'stopped', stopped.toString()

    ###################################################################################
    # services

    services =
      redisOne:
        start: ->
          test.ok starting.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'mailAPI'
          ])
          test.ok running.equals([])
          Promise.delay(10)
        stop: ->
          test.ok stopping.equals([
            'redisOne',
            'redisTwo',
            'mailAPI'
          ])
          test.ok stopped.equals([
            'serverOne'
            'serverTwo'
            'serverThree'
            'elasticSearch'
            'cache'
            'postgres'
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          Promise.delay(10)
      redisTwo:
        start: ->
          test.ok starting.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'mailAPI'
          ])
          test.ok running.equals([])
          Promise.delay(20)
        stop: ->
          test.ok stopping.equals([
            'redisOne',
            'redisTwo',
            'mailAPI'
          ])
          test.ok stopped.equals([
            'serverOne'
            'serverTwo'
            'serverThree'
            'elasticSearch'
            'cache'
            'postgres'
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          Promise.delay(20)
      serverOne:
        start: ->
          test.ok starting.equals([
            'mailAPI'
            'serverOne'
            'serverTwo'
            'serverThree'
          ])
          test.ok running.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'cache'
          ])
          Promise.delay(5)
        stop: ->
          test.ok stopping.equals([
            'workerTwo',
            'serverOne',
            'serverTwo',
            'serverThree'
          ])
          test.ok stopped.equals([
            'workerOne'
            'loadBalancer'
          ])
          Promise.delay(5)
      serverTwo:
        start: ->
          test.ok starting.equals([
            'mailAPI'
            'serverOne'
            'serverTwo'
            'serverThree'
          ])
          test.ok running.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'cache'
          ])
          Promise.delay(30)
        stop: ->
          test.ok stopping.equals([
            'workerTwo',
            'serverOne',
            'serverTwo',
            'serverThree'
          ])
          test.ok stopped.equals([
            'workerOne'
            'loadBalancer'
          ])
          Promise.delay(30)
      serverThree:
        start: ->
          test.ok starting.equals([
            'mailAPI'
            'serverOne'
            'serverTwo'
            'serverThree'
          ])
          test.ok running.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'cache'
          ])
          Promise.delay(60)
        stop: ->
          test.ok stopping.equals([
            'workerTwo',
            'serverOne',
            'serverTwo',
            'serverThree'
          ])
          test.ok stopped.equals([
            'workerOne'
            'loadBalancer'
          ])
          Promise.delay(60)
      elasticSearch:
        start: ->
          test.ok starting.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'mailAPI'
          ])
          test.ok running.equals([])
          Promise.delay(25)
        stop: ->
          test.ok stopping.equals([
            'elasticSearch'
            'postgres'
            'cache'
            'mailAPI'
          ])
          test.ok stopped.equals([
            'serverOne'
            'serverTwo'
            'serverThree'
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          Promise.delay(25)
      mailAPI:
        start: ->
          test.ok starting.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'mailAPI'
          ])
          test.ok running.equals([])
          Promise.delay(60)
        stop: ->
          test.ok stopping.equals([
            'serverThree'
            'mailAPI'
          ])
          test.ok stopped.equals([
            'serverOne'
            'serverTwo'
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          Promise.delay(60)
      cache:
        start: ->
          test.ok starting.equals([
            'elasticSearch'
            'mailAPI'
            'cache'
          ])
          test.ok running.equals([
            'redisOne'
            'redisTwo'
            'postgres'
          ])
          Promise.delay(30)
        stop: ->
          test.ok stopping.equals([
            'elasticSearch'
            'postgres'
            'cache'
            'mailAPI'
          ])
          test.ok stopped.equals([
            'serverOne'
            'serverTwo'
            'serverThree'
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          Promise.delay(30)
      postgres:
        start: ->
          test.ok starting.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'mailAPI'
          ])
          test.ok running.equals([])
          Promise.delay(15)
        stop: ->
          test.ok stopping.equals([
            'elasticSearch'
            'postgres'
            'cache'
            'mailAPI'
          ])
          test.ok stopped.equals([
            'serverOne'
            'serverTwo'
            'serverThree'
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          Promise.delay(15)
      loadBalancer:
        start: ->
          test.ok starting.equals([
            'workerTwo'
            'loadBalancer'
          ])
          test.ok running.equals([
            'redisOne',
            'redisTwo',
            'postgres',
            'elasticSearch',
            'cache',
            'serverOne',
            'serverTwo',
            'serverThree',
            'mailAPI',
            'workerOne'
          ])
          Promise.delay(20)
        stop: ->
          test.ok stopping.equals([
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          test.ok stopped.equals([])
          Promise.delay(20)
      workerOne:
        start: ->
          test.ok starting.equals([
            'serverTwo'
            'serverThree'
            'workerOne'
            'workerTwo'
          ])
          test.ok running.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'cache'
            'serverOne'
            'mailAPI'
          ])
          Promise.delay(10)
        stop: ->
          test.ok stopping.equals([
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          test.ok stopped.equals([])
          Promise.delay(10)
      workerTwo:
        start: ->
          test.ok starting.equals([
            'serverTwo'
            'serverThree'
            'workerOne'
            'workerTwo'
          ])
          test.ok running.equals([
            'redisOne'
            'redisTwo'
            'postgres'
            'elasticSearch'
            'cache'
            'serverOne'
            'mailAPI'
          ])
          Promise.delay(60)
        stop: ->
          test.ok stopping.equals([
            'loadBalancer'
            'workerOne'
            'workerTwo'
          ])
          test.ok stopped.equals([])
          Promise.delay(60)

    all = new Set Object.keys(services)

    ###################################################################################
    # graph

    graph = new Graph()
      .add('redisOne', 'cache')
      .add('redisTwo', 'cache')

      .add('cache', 'serverOne')
      .add('cache', 'serverTwo')
      .add('cache', 'serverThree')

      .add('postgres', 'serverOne')
      .add('postgres', 'serverTwo')
      .add('postgres', 'serverThree')

      .add('elasticSearch', 'serverOne')
      .add('elasticSearch', 'serverTwo')
      .add('elasticSearch', 'serverThree')

      .add('elasticSearch', 'workerOne')
      .add('elasticSearch', 'workerTwo')

      .add('postgres', 'workerOne')
      .add('postgres', 'workerTwo')

      .add('mailAPI', 'workerOne')
      .add('mailAPI', 'workerTwo')

      .add('serverOne', 'loadBalancer')
      .add('serverTwo', 'loadBalancer')
      .add('serverThree', 'loadBalancer')

    ###################################################################################
    # start & stop

    run(
      ids: all
      callback: (id) -> services[id].start()
      graph: graph
      pending: starting
      done: running
      debug: console.log.bind(console)
    )
      .then ->
        test.ok running.equals all
        test.equal starting.size, 0
        test.equal stopping.size, 0
        test.equal stopped.size, 0

        run(
          ids: all
          callback: (id) -> services[id].stop()
          graph: graph
          reversed: true
          pending: stopping
          done: stopped
          debug: console.log.bind(console)
        )
      .then ->
        test.equal starting.size, 0
        test.ok running.equals all
        test.equal stopping.size, 0
        test.ok stopped.equals all

        test.done()
