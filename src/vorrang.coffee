do ->
  vorrang = {}

  ###################################################################################
  # nodejs or browser?

  if window?
    window.vorrang = vorrang
  else if module?.exports?
    module.exports = vorrang
  else
    throw new Error 'either the `window` global or the `module.exports` global must be present'

  ###################################################################################
  # helpers

  isObjectEmpty = (x) ->
    for own v of x
      return false
    return true

  ###################################################################################
  # set datatype

  Set = (other) ->
    # create a new object that doesn't inherit any properties from Object
    this._map = Object.create(null)
    this.length = 0
    if other?
      this.add other
    return this

  Set.prototype =
    # O(1)
    isIn: (x) ->
      this._map[x]?
    # O(1)
    isEmpty: ->
      this.length is 0
    # O(1) best case. O(n) worst case.
    isEqual: (other) ->
      that = this
      that.length is other.length and other.elements().every (x) ->
        that.isIn x
    # O(n)
    toString: ->
      '#{' + Object.keys(this._map).join(' ') + '}'
    # O(n)
    elements: ->
      elements = []
      for k, v of this._map
        if v
          elements.push k
      return elements
    # O(n) where n is the amount of elements in other
    add: (other) ->
      type = typeof other
      if type is 'string' or type is 'number'
        unless this.isIn other
          this._map[other] = true
          this.length++
      else if other instanceof Set
        for key of other._map
          unless this.isIn key
            this._map[key] = true
            this.length++
      else if Array.isArray other
        for v in other
          unless this.isIn v
            this._map[v] = true
            this.length++
      else
        throw new TypeError 'unsupported argument type'
      # for chaining
      return this
    # O(n) where n is the amount of elements in other
    remove: (other) ->
      type = typeof other
      if type is 'string' or type is 'number'
        if this.isIn other
          # delete is dog slow
          this._map[other] = undefined
          this.length--
      else if other instanceof Set
        for key of other._map
          if this.isIn key
            # delete is dog slow
            this._map[key] = undefined
            this.length--
      else if Array.isArray other
        for v in other
          if this.isIn v
            # delete is dog slow
            this._map[v] = undefined
            this.length--
      else
        throw new TypeError 'unsupported argument type'
      # for chaining
      return this
    # O(n)
    clone: ->
      new Set this

  ###################################################################################
  # directed acyclic graph datatype

  Dag = ->
    # a hashmap mapping elements to sets of elements that come directly before them
    # B < A, C < A is represented as {A #{B C}}

    # create a new object that doesn't inherit any properties from Object
    this._before = Object.create(null)
    return this

  Dag.prototype =

  ###################################################################################
  # manipulation

    before: (a, b) ->
      # keep it irreflexive (not a < a)
      if a is b
        throw new Error 'arguments must not be equal'

      # check that asymetry is kept
      # keeping transitivity
      # keeping it cycle free
      if this.isBefore b, a
        throw new Error "trying to set `#{a}` < `#{b}` but already `#{b}` < `#{a}`"

      # add relation by adding A to the set of elements that come before B
      unless this._before[b]?
        this._before[b] = new Set
      this._before[b].add a
      unless this._before[a]?
        this._before[a] = new Set

      # for chaining
      return this

  ###################################################################################
  # predicates

    # O(1)
    isIn: (x) ->
      this._before[x]?

    isBefore: (a, b) ->
      that = this

      # this shortcut greatly speeds up construction of large graphs
      if not this.isIn a or not this.isIn b
        return false

      # find all `c < b`
      before = that._before[b]

      # we do not store empty sets: that means that if an element has no lower-than-set
      # there are no lower elements

      unless before?
        return false

      # breadth first search for `a` below `b`

      # we use a loop here to prevent stack overflow for very large DAGs
      while not before.isEmpty()
        # is `a < c`?
        if before.isIn a
          return true

        evenBefore = new Set()

        # find next level of `c < b`

        # loop through duplicate elements

        before.elements().forEach (c) ->
          beforeC = that._before[c]
          if beforeC?
            evenBefore.add beforeC

        before = evenBefore

      return false

  ###################################################################################
  # elements

    # O(n)
    elements: ->
      Object.keys(this._before)

    # O(n)
    minElements: ->
      # all elements which have nothing before them
      # are not themselves greater than any element
      minElements = []
      for k, v of this._before
        if v.isEmpty()
          minElements.push k
      return minElements

    # large
    maxElements: ->
      # all elements that are not before anything
      maxElements = new Set Object.keys(this._before)
      for k, v of this._before
        maxElements.remove v
      return maxElements.elements()

  ###################################################################################
  # alternative implementation

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

  Dag2 = ->
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    this.nodes = Object.create null
    return this

  Dag2.prototype = {}

  # O(1) if a and b not in dag. O(?) otherwise
  Dag2.prototype.before = (a, b) ->
    # keep it irreflexive (not a < a)
    if a is b
      throw new Error 'arguments must not be equal'

    # check that asymetry is kept
    # keeping transitivity
    # keeping it cycle free
    if this.isBefore b, a
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

  # O(1)
  Dag2.prototype.isIn = (x) ->
    this.nodes[x]?

  # O(?)
  Dag2.prototype.isBefore = (a, b) ->
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
  Dag2.prototype.elements = ->
    Object.keys(this.nodes)

  # elements without parents
  # O(n)
  Dag2.prototype.minElements = ->
    elements = []
    for key,node of this.nodes
      if isObjectEmpty node.parents
        elements.push node.value
    return elements

  # elements without children
  # O(n)
  Dag2.prototype.maxElements = ->
    elements = []
    for key,node of this.nodes
      if isObjectEmpty node.children
        elements.push node.value
    return elements

  # O(?)
  Dag2.prototype.minUpperBound = (xs) ->
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    candidates = Object.create(null)
    for x in xs
      node = this.nodes[x]
      unless node?
        throw new Error "searching minUpperBound of `#{x}` which is not in graph"
      for key,child of node.children
        candidates[child.value] = child
    # filter out those that are already in the set
    for x in xs
      if candidates[x]?
        delete candidates[x]
    # filter out those that have parents (which are better candidates) in the candidates set
    for key,candidate of candidates
      for key,parent of candidate.parents
        # has parent that is already a candidate?
        if candidates[parent.value]?
          delete candidates[candidate.value]
          # we dont need to look at any more parents of this candidate
          break
    return Object.keys candidates

  # O(?)
  Dag2.prototype.maxLowerBound = (xs) ->
    # dont inherit from the Object prototype such that we dont need to use hasOwnProperty
    candidates = Object.create(null)
    for x in xs
      node = this.nodes[x]
      unless node?
        throw new Error "searching maxLowerBound of `#{x}` which is not in graph"
      for key,child of node.parents
        candidates[child.value] = child
    # filter out those that are already in the set
    for x in xs
      if candidates[x]?
        delete candidates[x]
    # filter out those that have children (which are better candidates) in the candidates set
    for key,candidate of candidates
      for key,child of candidate.children
        # has child that is already a candidate?
        if candidates[child.value]?
          delete candidates[candidate.value]
          # we dont need to look at any more parents of this candidate
          break
    return Object.keys candidates

  vorrang.Set = Set
  # vorrang.Dag = Dag
  vorrang.Dag = Dag2
  # vorrang.Dag2 = Dag2
