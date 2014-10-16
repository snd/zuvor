Promise = require 'bluebird'

{Dag, Set} = require('../src/zuvor')

###################################################################################
# test

module.exports =

  'systems are started and stopped in the most efficient order': (test) ->
    # test.expect 28

    starting = new Set
    running = new Set
    stopping = new Set

    debug = ->
      console.log 'starting', starting.toString()
      console.log 'stopping', stopping.toString()
      console.log 'running', running.toString()

    ###################################################################################
    # services

    services =
      redisOne:
        start: ->
          test.ok starting.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI')
          )
          test.ok running.equals(
            new Set
          )
          Promise.delay(10)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'mailAPI'
            )
          )
          test.ok running.equals(new Set())
          Promise.delay(10)
      redisTwo:
        start: ->
          test.ok starting.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI')
          )
          test.ok running.equals(
            new Set
          )
          Promise.delay(20)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'mailAPI'
            )
          )
          test.ok running.equals(new Set())
          Promise.delay(20)
      serverOne:
        start: ->
          test.ok starting.equals(
            new Set('mailAPI', 'serverOne', 'serverTwo', 'serverThree')
          )
          test.ok running.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'cache')
          )
          Promise.delay(5)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'workerTwo',
              'serverOne',
              'serverTwo',
              'serverThree'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
              'mailAPI',
            )
          )
          Promise.delay(5)
      serverTwo:
        start: ->
          test.ok starting.equals(
            new Set(['mailAPI', 'serverOne', 'serverTwo', 'serverThree'])
          )
          test.ok running.equals(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'cache'])
          )
          Promise.delay(30)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'workerTwo',
              'serverOne',
              'serverTwo',
              'serverThree'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
              'mailAPI',
            )
          )
          Promise.delay(30)
      serverThree:
        start: ->
          test.ok starting.equals(
            new Set(['mailAPI', 'serverOne', 'serverTwo', 'serverThree'])
          )
          test.ok running.equals(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'cache'])
          )
          Promise.delay(60)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'workerTwo',
              'serverOne',
              'serverTwo',
              'serverThree'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
              'mailAPI',
            )
          )
          Promise.delay(60)
      elasticSearch:
        start: ->
          test.ok starting.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI')
          )
          test.ok running.equals(
            new Set
          )
          Promise.delay(25)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'elasticSearch'
              'postgres'
              'cache'
              'mailAPI'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
            )
          )
          Promise.delay(25)
      mailAPI:
        start: ->
          test.ok starting.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI')
          )
          test.ok running.equals(
            new Set
          )
          Promise.delay(60)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'serverThree'
              'mailAPI'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
            )
          )
          Promise.delay(60)
      cache:
        start: ->
          test.ok starting.equals(
            new Set('elasticSearch', 'mailAPI', 'cache')
          )
          test.ok running.equals(
            new Set('redisOne', 'redisTwo', 'postgres')
          )
          Promise.delay(30)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'elasticSearch'
              'postgres'
              'cache'
              'mailAPI'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
            )
          )
          Promise.delay(30)
      postgres:
        start: ->
          test.ok starting.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI')
          )
          test.ok running.equals(
            new Set
          )
          Promise.delay(15)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'elasticSearch'
              'postgres'
              'cache'
              'mailAPI'
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
            )
          )
          Promise.delay(15)
      loadBalancer:
        start: ->
          test.ok starting.equals(
            new Set('workerTwo', 'loadBalancer')
          )
          test.ok running.equals(
            new Set(
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
            )
          )
          Promise.delay(20)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'loadBalancer',
              'workerOne',
              'workerTwo',
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
              'serverOne',
              'serverTwo',
              'serverThree',
              'mailAPI',
            )
          )
          Promise.delay(20)
      workerOne:
        start: ->
          test.ok starting.equals(
            new Set('serverTwo', 'serverThree', 'workerOne', 'workerTwo')
          )
          test.ok running.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'cache', 'serverOne', 'mailAPI')
          )
          Promise.delay(10)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'loadBalancer',
              'workerOne',
              'workerTwo',
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
              'serverOne',
              'serverTwo',
              'serverThree',
              'mailAPI',
            )
          )
          Promise.delay(10)
      workerTwo:
        start: ->
          test.ok starting.equals(
            new Set('serverTwo', 'serverThree', 'workerOne', 'workerTwo')
          )
          test.ok running.equals(
            new Set('redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'cache', 'serverOne', 'mailAPI')
          )
          Promise.delay(60)
        stop: ->
          test.ok stopping.equals(
            new Set(
              'loadBalancer',
              'workerOne',
              'workerTwo',
            )
          )
          test.ok running.equals(
            new Set(
              'redisOne',
              'redisTwo',
              'postgres',
              'elasticSearch',
              'cache',
              'serverOne',
              'serverTwo',
              'serverThree',
              'mailAPI',
            )
          )
          Promise.delay(60)

    all = new Set Object.keys(services)

    ###################################################################################
    # graph

    dag = new Dag()
      .before('redisOne', 'cache')
      .before('redisTwo', 'cache')

      .before('cache', 'serverOne')
      .before('cache', 'serverTwo')
      .before('cache', 'serverThree')

      .before('postgres', 'serverOne')
      .before('postgres', 'serverTwo')
      .before('postgres', 'serverThree')

      .before('elasticSearch', 'serverOne')
      .before('elasticSearch', 'serverTwo')
      .before('elasticSearch', 'serverThree')

      .before('elasticSearch', 'workerOne')
      .before('elasticSearch', 'workerTwo')

      .before('postgres', 'workerOne')
      .before('postgres', 'workerTwo')

      .before('mailAPI', 'workerOne')
      .before('mailAPI', 'workerTwo')

      .before('serverOne', 'loadBalancer')
      .before('serverTwo', 'loadBalancer')
      .before('serverThree', 'loadBalancer')

    ###################################################################################
    # start & stop

    start = (names) ->
      starting.add names
      Promise.all names.map (name) ->
        callback = services[name].start
        promise = Promise.resolve(callback())
        promise.then ->
          starting.delete name
          running.add name
          # start all we can start now that have not been started
          toStart = new Set(dag.whereAllParentsIn(running.keys()))
            .delete(starting)
            .delete(running)
            .keys()
          start toStart

    stop = (names) ->
      stopping.add names
      running.delete names
      return Promise.all names.map (name) ->
        callback = services[name].stop
        promise = Promise.resolve callback()
        promise.then ->
          stopping.delete name
          stopped = all
            .clone()
            .delete(running)
            .delete(stopping)
          # stop all we can stop now that have not been stopped
          toStop = new Set(dag.whereAllChildrenIn(stopped.keys()))
            .delete(stopping)
            .delete(stopped)
            .keys()
          stop toStop

    start(dag.parentless())
      .then ->
        test.ok running.equals all
        test.equal starting.size, 0
        test.equal stopping.size, 0
        stop dag.childless()
      .then ->
        test.equal starting.size, 0
        test.equal stopping.size, 0
        test.equal running.size, 0
        test.done()
