

proc MatcherDistinctIndices(indices : seq[int]) : seq[int] =
  ## Get the set if distinct (non-duplicate) indices from a list
  var indicesSet = initSet[int]()
  var res : seq[int] = @[]

  for index in indices:
      if not indicesSet.contains(index):
          result.add(index)
      indicesSet.incl(index)

  return res

proc constructor*(this: Matcher): void =
  this.id = MatcherUniqueId
  MatcherUniqueId = MatcherUniqueId+1

proc mergeIndices*(this: Matcher) : seq[int] =
  ## Merge list of component indices
  var indicesList : seq[int] = @[]
  if this.allOfIndices != nil:
      for i in this.allOfIndices:
          indicesList.add(i)

  if this.anyOfIndices != nil:
      for i in this.anyOfIndices:
          indicesList.add(i)

  if this.noneOfIndices != nil:
      for i in this.noneOfIndices:
          indicesList.add(i)

  return MatcherDistinctIndices(indicesList)

proc indices*(this: Matcher) : seq[int] =
  if this.indicesCache == nil:
    this.indicesCache = this.mergeIndices()
  return this.indicesCache

proc toString*(this : Matcher) : string =
  return

proc MatcherMerge(matchers : seq[Matcher]) : seq[int] =
  var indices : seq[int] = @[]
  for matcher in matchers:
    if matcher.indices.len != 1:
      raise newException(OSError, interp"MatcherException - ${matcher.toString()}")

    indices.add(matcher.indices[0])
  return indices


proc anyOf*(this: Matcher, args : seq[int]) : Matcher =
  ## Matches anyOf the components/indices specified
  this.anyOfIndices = MatcherDistinctIndices(args)
  this.indicesCache = nil
  return this

proc noneOf*(this: Matcher, args : seq[int]) : Matcher =
  ## Matches noneOf the components/indices specified
  this.noneOfIndices = MatcherDistinctIndices(args)
  this.indicesCache = nil
  return this

proc matches*(this: Matcher, entity : Entity) : bool =
  ## Check if the entity matches this matcher
  var matchesAllOf = if this.allOfIndices == nil : true else : entity.hasComponents(this.allOfIndices)
  var matchesAnyOf = if this.anyOfIndices == nil : true else : entity.hasAnyComponent(this.anyOfIndices)
  var matchesNoneOf = if this.noneOfIndices == nil : true else : not entity.hasAnyComponent(this.noneOfIndices)
  return matchesAllOf and matchesAnyOf and matchesNoneOf

proc MatcherAllOf*(args : seq[int]) : Matcher =
  ## Matches allOf the components/indices specified
  var matcher = Matcher()
  matcher.allOfIndices = MatcherDistinctIndices(args)
  return matcher

proc MatcherAnyOf*(args : seq[int]) : Matcher =
  ## Matches anyOf the components/indices specified
  var matcher = Matcher()
  matcher.anyOfIndices = MatcherDistinctIndices(args)
  return matcher
