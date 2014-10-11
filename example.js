var Promise = require('bluebird');

var Vorrang = require('./src/vorrang');

///////////////////////////////////////////////////////////////////////////////////
// services

var services = {
  redisOne: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  redisTwo: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  serverOne: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  serverTwo: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  serverThree: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  elasticSearch: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  mailAPI:{
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  cache: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  postgres: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  loadBalancer: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  workerOne: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  },
  workerTwo: {
    start: function() { return Promise.delay(100); },
    stop: function() { return Promise.delay(100); }
  }
}

///////////////////////////////////////////////////////////////////////////////////
// order

var dag = new Vorrang()
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
  ;

///////////////////////////////////////////////////////////////////////////////////
// start & stop

var starting = [];
var running = [];
var stopping = [];
var stopped = [];

var start = function(names) {
  return Promise.all(names.map(function(name) {
    if (-1 !== starting.indexOf(name)) {
      return;
    }
    if (-1 !== running.indexOf(name)) {
      return;
    }
    console.log('starting: ' + name);
    var callback = services[name].start;
    var promise = Promise.resolve(callback());
    starting.push(name);
    return promise.then(function() {
      console.log('running:  ' + name);
      running.push(name);
      return start(dag.whereAllParentsIn(running));
    });
  }));
};

var stop = function(names) {
  return Promise.all(names.map(function(name) {
    if (-1 !== stopping.indexOf(name)) {
      return;
    }
    if (-1 !== stopped.indexOf(name)) {
      return;
    }
    console.log('stopping: ' + name);
    var callback = services[name].stop;
    var promise = Promise.resolve(callback());
    stopping.push(name);
    return promise.then(function() {
      console.log('stopped:  ' + name);
      stopped.push(name);
      return stop(dag.whereAllChildrenIn(stopped));
    });
  }));
};

start(dag.parentless()).then(function() {
  // TODO assert that all are really running
  console.log('running:  ALL');
  return Promise.delay(1000);
}).then(function() {
  return stop(dag.childless());
}).then(function() {
  console.log('stopped:  ALL');
});
