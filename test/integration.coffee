Promise = require 'bluebird'

{Dag, Set} = require('../src/zuvor')

###################################################################################
# test

module.exports =

  'systems are started and stopped in the most efficient order': (test) ->

    ###################################################################################
    # services

    services =
      redisOne:
        start: ->
          test.ok starting.isEqual(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI'])
          )
          test.ok running.isEqual(
            new Set
          )
          Promise.delay(10)
        stop: ->
          Promise.delay(100)
      redisTwo:
        start: ->
          test.ok starting.isEqual(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI'])
          )
          test.ok running.isEqual(
            new Set
          )
          Promise.delay(20)
        stop: ->
          Promise.delay(100)
      serverOne:
        start: ->
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      serverTwo:
        start: ->
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      serverThree:
        start: ->
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      elasticSearch:
        start: ->
          test.ok starting.isEqual(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI'])
          )
          test.ok running.isEqual(
            new Set
          )
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      mailAPI:
        start: ->
          test.ok starting.isEqual(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI'])
          )
          test.ok running.isEqual(
            new Set
          )
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      cache:
        start: ->
          test.ok starting.isEqual(
            new Set(['postgres', 'elasticSearch', 'mailAPI', 'cache'])
          )
          test.ok running.isEqual(
            new Set(['redisOne', 'redisTwo'])
          )
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      postgres:
        start: ->
          test.ok starting.isEqual(
            new Set(['redisOne', 'redisTwo', 'postgres', 'elasticSearch', 'mailAPI'])
          )
          test.ok running.isEqual(
            new Set
          )
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      loadBalancer:
        start: ->
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      workerOne:
        start: ->
          Promise.delay(100)
        stop: ->
          Promise.delay(100)
      workerTwo:
        start: ->
          Promise.delay(100)
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
      console.log('starting:', names)
      starting.add names
      Promise.all names.map (name) ->
        callback = services[name].start
        promise = Promise.resolve(callback())
        promise.then ->
          console.log('running:  ' + name)
          starting.remove name
          running.add name
          # start all we can start now that have not been started
          toStart = new Set(dag.whereAllParentsIn(running.elements()))
            .remove(starting)
            .remove(running)
            .elements()
          start toStart

    stop = (names) ->
      console.log('stopping: ', names)
      stopping.add names
      return Promise.all names.map (name) ->
        callback = services[name].stop
        promise = Promise.resolve callback()
        promise.then ->
          console.log('stopped:  ' + name)
          stopping.remove name
          stopped.add name
          # stop all we can stop now that have not been stopped
          toStop = new Set(dag.whereAllChildrenIn(stopped.elements()))
            .remove(stopping)
            .remove(stopped)
            .elements()
          stop toStop

    start(dag.parentless())
      .then ->
        test.ok running.isEqual new Set Object.keys(services)
        test.ok starting.isEqual new Set
        stop dag.childless()
      .then ->
        test.ok stopped.isEqual new Set Object.keys(services)
        test.ok stopping.isEqual new Set
        test.done()
