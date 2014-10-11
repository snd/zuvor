
  ###################################################################################
  # task example

  'task example': (test) ->

    started = mori.set()
    completed = mori.set()

    callbacks =
      worker: () ->
        console.log 'stopping worker'
        Promise.delay 100, 5
      postgres: () ->
        console.log 'stopping postgres'
        Promise.delay 100, 5
      server: () ->
        console.log 'stopping server'
        Promise.delay 100, 5
      redis: () ->
        console.log 'stopping redis'
        Promise.delay 100, 5

    poset = mori.pipeline(
      vorrang.poset()
      # shutdown worker before shutting down postgres
      mori.curry(vorrang.setLower, 'worker', 'postgres')
      # shutdown server before shutting down postgres
      mori.curry(vorrang.setLower, 'server', 'postgres')
      # shutdown server before shutting down redis
      mori.curry(vorrang.setLower, 'server', 'redis')
    )

    start = (names) ->
      console.log 'call', names
      iterator = (name) ->
        if mori.get(called, name)?
          throw new Error "can not call what is already called: #{name}"
        if mori.get(stopped, name)?
          throw new Error "can not call what is already stopped: #{name}"
        callback = callbacks[name]
        unless callback?
          throw new Error "no callback for: #{name}"
        promise = Promise.resolve callback()
        return promise.then ->
          console.log name, 'is now stopped'
          # the service is now stopped
          stopped = mori.conj stopped, name
          return stop()
      Promise.all mori.into_array mori.map iterator, names

    console.log poset

    stop = ->
      console.log 'stop'
      console.log 'called', called
      console.log 'stopped', stopped
      noneCalledYet = mori.is_empty(called)
      if noneCalledYet
        # we are just getting started
        minElements = vorrang.minElements poset
        console.log 'minElements', minElements
        promise = call minElements
        # remember that we called those names
        called = mori.into called, minElements
        return promise

      minUpperBound = vorrang.minUpperBound poset, stopped
      console.log 'minUpperBound', minUpperBound
      # do not call any that have already been called
      nowReadyAndNotYetCalled = mori.difference minUpperBound, called
      promise = call nowReadyAndNotYetCalled
      # remember that we called those names
      called = mori.into called, nowReadyAndNotYetCalled
      return promise

    stop().then ->
      test.done()
