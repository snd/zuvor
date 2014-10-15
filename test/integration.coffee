Promise = require 'bluebird'

{Dag, Set} = require('../src/zuvor')

###################################################################################
# test

module.exports =

  'systems are started and stopped in the most efficient order': (test) ->
    test.expect 28

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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)
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
          Promise.delay(100)

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

    starting = new Set
    running = new Set
    stopping = new Set
    stopped = new Set

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
      return Promise.all names.map (name) ->
        callback = services[name].stop
        promise = Promise.resolve callback()
        promise.then ->
          stopping.delete name
          stopped.add name
          # stop all we can stop now that have not been stopped
          toStop = new Set(dag.whereAllChildrenIn(stopped.keys()))
            .delete(stopping)
            .delete(stopped)
            .keys()
          stop toStop

    start(dag.parentless())
      .then ->
        test.ok running.equals new Set Object.keys(services)
        test.ok starting.equals new Set
        stop dag.childless()
      .then ->
        test.ok stopped.equals new Set Object.keys(services)
        test.ok stopping.equals new Set
        test.done()
