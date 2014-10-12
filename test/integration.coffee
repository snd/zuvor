Promise = require 'bluebird'

new Vorrang = require '../src/vorrang'

module.exports =

  'systems are started and stopped in the most efficient order': (test) ->

    ###################################################################################
    # services

    services =
      redisOne:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      redisTwo:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      serverOne:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      serverTwo:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      serverThree:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      elasticSearch:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      mailAPI:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      cache:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      postgres:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      loadBalancer:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      workerOne:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)
      workerTwo:
        start: -> Promise.delay(100)
        stop: -> Promise.delay(100)

    ###################################################################################
    # graph

    dag = new Vorrang()
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

    starting = []
    running = []
    stopping = []
    stopped = []

    start = (names) ->
      Promise.all names.map (name) ->
        if name in starting or name in running
          return
        console.log('starting: ' + name)
        callback = services[name].start
        promise = Promise.resolve(callback())
        starting.push(name)
        promise.then ->
          console.log('running:  ' + name)
          running.push(name)
          start dag.whereAllParentsIn(running)

    stop = (names) ->
      return Promise.all names.map (name) ->
        if name in stopping or name in stopped
          return
        console.log('stopping: ' + name)
        callback = services[name].stop
        promise = Promise.resolve callback()
        stopping.push(name)
        promise.then ->
          console.log('stopped:  ' + name)
          stopped.push(name)
          stop dag.whereAllChildrenIn(stopped)

    start(dag.parentless())
      .then ->
        # TODO assert that all are really running
        console.log('running:  ALL')
        Promise.delay(1000)
      .then ->
        stop dag.childless()
      .then ->
        console.log('stopped:  ALL')
        test.done()

