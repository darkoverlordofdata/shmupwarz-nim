##
## Matcher - method forward declarations
##
proc MatchAllOf*(args : seq[int]) : Matcher
proc MatchAnyOf*(args : seq[int]) : Matcher
proc MergeIndices(args : seq[Matcher]) : seq[int]
proc newMatcher*() : Matcher
proc anyOf*(this: Matcher, args : seq[int]) : Matcher
proc indices*(this: Matcher) : seq[int]
proc matches*(this: Matcher, entity : Entity) : bool
proc noneOf*(this: Matcher, args : seq[int]) : Matcher
proc `$`*(this : Matcher) : string
##
##  constructor
##
proc newMatcher*(): Matcher =
  new(result)
  result.id = MatcherUniqueId
  MatcherUniqueId = MatcherUniqueId+1
  result.allOfIndices = @[]
  result.anyOfIndices = @[]
  result.noneOfIndices = @[]

proc indices*(this: Matcher) : seq[int] =
  if this.indicesCache == nil:
    this.indicesCache = deduplicate(concat(this.allOfIndices, this.anyOfIndices, this.noneOfIndices))
  return this.indicesCache

proc componentsToString(a : seq[int]) : string =
  var sb : seq[string] = @[]
  for index in a:
    sb.add $WorldComponentsEnum[index-1]
  return sb.join(",")

proc `$`*(this : Matcher) : string =
  if this.toStringCache == nil:
    var sb : seq[string] = @[]
    if this.allOfIndices.len > 0:
      sb.add "AllOf("
      sb.add componentsToString(this.allOfIndices)
      sb.add ")"

    if this.anyOfIndices.len > 0:
      if this.allOfIndices.len > 0: sb = sb & "."
      sb.add "AnyOf("
      sb.add componentsToString(this.anyOfIndices)
      sb.add ")"

    if this.noneOfIndices.len > 0:
      sb.add ".NoneOf("
      sb.add componentsToString(this.noneOfIndices)
      sb.add ")"

    this.toStringCache = sb.join("")

  return this.toStringCache

proc anyOf*(this: Matcher, args : seq[int]) : Matcher =
  ## Matches anyOf the components/indices specified
  this.anyOfIndices = deduplicate(args)
  this.indicesCache = nil
  return this

proc noneOf*(this: Matcher, args : seq[int]) : Matcher =
  ## Matches noneOf the components/indices specified
  this.noneOfIndices = deduplicate(args)
  this.indicesCache = nil
  return this

proc matches*(this: Matcher, entity : Entity) : bool =
  ## Check if the entity matches this matcher
  var matchesAllOf = if this.allOfIndices.len == 0 : true else : entity.hasComponents(this.allOfIndices)
  var matchesAnyOf = if this.anyOfIndices.len == 0 : true else : entity.hasAnyComponent(this.anyOfIndices)
  var matchesNoneOf = if this.noneOfIndices.len == 0 : true else : not entity.hasAnyComponent(this.noneOfIndices)
  return matchesAllOf and matchesAnyOf and matchesNoneOf

proc MergeIndices(args: seq[Matcher]) : seq[int] =
  result = @[]
  for matcher in args:
    if matcher.indices.len != 1:
      raise newException(OSError, "matcher.indices.length must be 1")
    result.add matcher.indices[0]

proc MatchAllOf*(args : seq[int]) : Matcher =
  ## Matches allOf the components/indices specified
  result = newMatcher()
  result.allOfIndices = deduplicate(args)

proc MatchAllOf*(args : seq[Matcher]) : Matcher =
  ## Matches allOf the components/indices specified
  MatchAllOf(MergeIndices(args))

proc MatchAnyOf*(args : seq[int]) : Matcher =
  ## Matches anyOf the components/indices specified
  result = newMatcher()
  result.anyOfIndices = deduplicate(args)
