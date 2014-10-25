# do -> = module pattern in coffeescript

do ->
  zuvor = {}

  ###################################################################################
  # nodejs or browser?

  if window?
    unless window.Promise?
      throw new Error 'zuvor requires Promise global by bluebird to be present'
    window.zuvor = zuvor
  else if module?.exports?
    Promise = require 'bluebird'
    module.exports = zuvor
  else
    throw new Error 'either the `window` global or the `module.exports` global must be present'

  ###################################################################################
  # helpers

  isObjectEmpty = (x) ->
    for own v of x
      return false
    return true

  isThenable = (x) ->
    x is Object(x) and 'function' is typeof x.then

  ###################################################################################
  # set

  zuvor.Set = Set = (args...) ->
    # create a new object that doesn't inherit any properties from Object
    this._map = Object.create(null)
    this.size = 0
    if args.length isnt 0
      this.add args...
    return this

  Set.prototype =
    # O(1)
    has: (x) ->
      this._map[x]?
    # O(1) best case. O(n) worst case.
    equals: (other) ->
      if Array.isArray other
        other = new Set other
      unless other instanceof Set
        throw new TypeError 'argument must be a set or array'
      that = this
      that.size is other.size and other.keys().every (x) ->
        that.has x
    # O(n)
    toString: ->
      '#{' + this.keys().join(' ') + '}'
    # O(n)
    keys: ->
      elements = []
      for k, v of this._map
        if v
          elements.push k
      return elements
    # O(n)
    forEach: (f) ->
      for k, v of this._map
        if v
          f k
    # O(n) where n is the amount of elements in other
    add: (args...) ->
      for arg in args
        type = typeof arg
        if type is 'string' or type is 'number'
          unless this.has arg
            this._map[arg] = true
            this.size++
        else if arg instanceof Set
          that = this
          arg.forEach (x) ->
            unless that.has x
              that._map[x] = true
              that.size++
        else if Array.isArray arg
          for v in arg
            unless this.has v
              this._map[v] = true
              this.size++
        else
          throw new TypeError 'unsupported argument type'
      # for chaining
      return this
    # O(n) where n is the amount of elements in other
    delete: (args...) ->
      for arg in args
        type = typeof arg
        if type is 'string' or type is 'number'
          if this.has arg
            # delete is dog slow
            this._map[arg] = undefined
            this.size--
        else if arg instanceof Set
          that = this
          arg.forEach (x) ->
            if that.has x
              # delete is dog slow
              that._map[x] = undefined
              that.size--
        else if Array.isArray arg
          for v in arg
            if this.has v
              # delete is dog slow
              this._map[v] = undefined
              this.size--
        else
          throw new TypeError 'unsupported argument type'
        # for chaining
      return this
    # O(n) where n is the amount of elements in the smaller set
    # intersection: (other) ->
    #   result = new Set
    #   if this.size > other.size
    #     bigger = this
    #     smaller = other
    #   else
    #     bigger = other
    #     smaller = this
    #   smaller.forEach (x) ->
    #     if bigger.has x
    #       result.add x
    #   return result
    clear: ->
      # create a new object that doesn't inherit any properties from Object
      this._map = Object.create(null)
      this.size = 0
      # for chaining
      return this
    # O(n)
    clone: ->
      new Set this

  Set.prototype.values = Set.prototype.keys

  ###################################################################################
  # directed acyclic graph

  Node = (value) ->
    this.value = value
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    this.parents = Object.create null
    this.children = Object.create null
    return this

  Node.prototype =
    addParent: (node) ->
      this.parents[node.value] = node
    addChild: (node) ->
      this.children[node.value] = node

  zuvor.Graph = Graph = ->
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    this.nodes = Object.create null
    return this

  Graph.prototype = {}

  # O(1) if a and b not in graph. O(?) otherwise
  Graph.prototype.add = (a, b) ->
    typeA = typeof a
    if not (typeA is 'string' or typeA is 'number')
      throw new TypeError "first argument must be a string or number but is #{typeA}"
    typeB = typeof b
    if not (typeB is 'string' or typeB is 'number')
      throw new TypeError "second argument must be a string or number but is #{typeB}"

    # keep it irreflexive (not a < a)
    if a is b
      throw new Error 'arguments must not be equal'

    # check that asymetry is kept
    # keeping transitivity
    # keeping it cycle free
    if this.has b, a
      throw new Error "trying to set `#{a}` -> `#{b}` but already `#{b}` -> `#{a}`"

    nodeA = this.nodes[a]
    unless nodeA?
      nodeA = new Node a
      this.nodes[a] = nodeA
    nodeB = this.nodes[b]
    unless nodeB?
      nodeB = new Node b
      this.nodes[b] = nodeB

    # link the nodes
    nodeA.addChild nodeB
    nodeB.addParent nodeA

    # for chaining
    return this

  # O(1) if called with only one argument O(?) otherwise
  Graph.prototype.has = (a, b) ->
    unless b?
      return this.nodes[a]?

    that = this

    nodeA = this.nodes[a]
    nodeB = this.nodes[b]

    # this shortcut greatly speeds up construction of large graphs
    if not nodeA? or not nodeB?
      return false

    # TODO does the search direction matter here?
    # TODO you might optimize this by looking for the direction that has the smaller set

    nodes = [nodeA]

    # breadth first search

    while nodes.length isnt 0
      nextNodes = []

      for node in nodes
        if node.children[b]?
          return true
        # look into every child on the next iteration
        for key,child of node.children
          nextNodes.push child

      nodes = nextNodes

    return false

  # O(n)
  Graph.prototype.keys = ->
    keys = []
    for key,node of this.nodes
      keys.push node.value
    return keys

  # O(?)
  Graph.prototype.edges = ->
    edges = []
    for key,node of this.nodes
      for key,child of node.children
        edges.push [node.value, child.value]
    return edges

  # returns a reversed version of this graph
  # Graph.prototype.reversed = ->

  # O(n) where n is the number of parents of x
  Graph.prototype.parents = (x) ->
    node = this.nodes[x]
    unless node?
      return []
    elements = []
    for key,parent of this.nodes[x].parents
      elements.push parent.value
    return elements

  # O(n) where n is the number of children of x
  Graph.prototype.children = (x) ->
    node = this.nodes[x]
    unless node?
      return []
    elements = []
    for key,child of this.nodes[x].children
      elements.push child.value
    return elements

  # elements without parents
  # O(n)
  Graph.prototype.parentless = ->
    elements = []
    for key,node of this.nodes
      if isObjectEmpty node.parents
        elements.push node.value
    return elements

  # elements without children
  # O(n)
  Graph.prototype.childless = ->
    elements = []
    for key,node of this.nodes
      if isObjectEmpty node.children
        elements.push node.value
    return elements

  # find those elements whose parents are all in xs
  Graph.prototype.whereAllParentsIn = (xs...) ->
    unless xs instanceof Set
      xs = new Set xs...
    # for fast lookup
    for x in xs
      xsSet[x] = true
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    resultSet = Object.create(null)
    that = this
    xs.forEach (x) ->
      node = that.nodes[x]
      unless node?
        throw new Error "searching whereAllParentsIn of `#{x}` which is not in graph"
      for key, child of node.children
        # dont look at the same node twice
        if resultSet[key]?
          continue
        # ignore nodes in the source set
        if xs.has key
          continue
        allParentsIn = true
        for parentValue of child.parents
          unless xs.has parentValue
            allParentsIn = false
            break
        resultSet[key] = allParentsIn
    results = []
    for k, v of resultSet
      if v
        results.push this.nodes[k].value
    return results

  # find those elements whose children are all in xs
  Graph.prototype.whereAllChildrenIn = (xs...) ->
    unless xs instanceof Set
      xs = new Set xs...
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    resultSet = Object.create(null)
    that = this
    xs.forEach (x) ->
      node = that.nodes[x]
      unless node?
        throw new Error "searching whereAllChildrenIn of `#{x}` which is not in graph"
      for key, parent of node.parents
        # dont look at the same node twice
        if resultSet[key]?
          continue
        # ignore nodes in the source set
        if xs.has key
          continue
        allChildrenIn = true
        for childValue of parent.children
          unless xs.has childValue
            allChildrenIn = false
            break
        resultSet[key] = allChildrenIn
    results = []
    for k, v of resultSet
      if v
        results.push this.nodes[k].value
    return results

  Graph.prototype.values = Graph.prototype.keys

  ###################################################################################
  # run

  zuvor.run = (options) ->
    unless 'function' is typeof options.callback
      throw new TypeError 'options.callback must be a Function'

    options.done ?= new Set
    unless options.done instanceof Set
      throw new TypeError 'options.done must be a Set'

    options.pending ?= new Set
    unless options.pending instanceof Set
      throw new TypeError 'options.pending must be a Set'

    if options.graph? and not options.graph instanceof Graph
      throw new TypeError 'options.graph must be a Graph'

    options.strict ?= false
    options.reversed ?= false

    if options.debug? and not 'function' is typeof options.debug
      throw new TypeError 'options.debug must be a Function'

    results = {}

    # immediately run those that have no order

    orderless = new Set(options.ids).delete(options.graph.keys()).keys()

    options.pending.add orderless

    orderlessPromise = Promise.all orderless.map (id) ->
      promise = Promise.resolve options.callback id
      promise.then (value) ->
        options.pending.delete id
        options.done.add id
        results[id] = value

    # run those with order in order

    start = (names) ->
      valid = new Set(names).delete(options.pending).delete(options.done)
      options.pending.add valid
      Promise.all valid.keys().map (id) ->
        # TODO pass in results of parents
        promise = Promise.resolve options.callback id
        promise.then (value) ->
          options.pending.delete id
          options.done.add id
          results[id] = value

          candidates = if options.reversed
            options.graph.whereAllChildrenIn(options.done.keys())
          else
            options.graph.whereAllParentsIn(options.done.keys())

          # start all we can start now that have not been started
          next = new Set(candidates)
            .delete(options.pending)
            .delete(options.done)
            .keys()
          start next

    orderedPromise = start if options.reversed
      options.graph.childless()
    else
      options.graph.parentless()

    # wait for everything to finish and return results

    Promise.all([orderlessPromise, orderedPromise]).then ->
      results
