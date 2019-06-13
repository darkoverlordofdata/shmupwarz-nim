import strutils
import sequtils
import entitas

type
    Matcher* = ref object of RootObj
      ##
      ## Matcher - members
      ##
      allOfIndices*         : seq[int]
      anyOfIndices*         : seq[int]
      id*                   : int
      indicesCache          : seq[int]
      noneOfIndices*        : seq[int]
      toStringCache         : string
  
  
##
##  constructor
##
proc newMatcher*(): Matcher =
  new(result)
  result.id = MatcherUniqueId
  MatcherUniqueId = MatcherUniqueId+1
  result.allOfIndices = newSeqOfCap[int](MAX_COMPONENTS) #@[]
  result.anyOfIndices = newSeqOfCap[int](MAX_COMPONENTS) #@[]
  result.noneOfIndices = newSeqOfCap[int](MAX_COMPONENTS) #@[]

proc indices*(this: Matcher) : seq[int] =
  if this.indicesCache.len() == 0:
    this.indicesCache = deduplicate(concat(this.allOfIndices, this.anyOfIndices, this.noneOfIndices))
  return this.indicesCache

proc componentsToString(a : seq[int]) : string =
  var sb : seq[string] = newSeqOfCap[string](MAX_COMPONENTS) #@[]
  for index in a:
    sb.add $WorldComponentsEnum[index]
  return sb.join(",")

proc `$`*(this : Matcher) : string =
  if this.toStringCache.len() == 0:
    var sb : seq[string] = newSeqOfCap[string](MAX_COMPONENTS) #@[]
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
  this.indicesCache = @[]
  return this

proc noneOf*(this: Matcher, args : seq[int]) : Matcher =
  ## Matches noneOf the components/indices specified
  this.noneOfIndices = deduplicate(args)
  this.indicesCache = @[]
  return this

proc matches*(this: Matcher, entity : Entity) : bool =
  ## Check if the entity matches this matcher
  let matchesAllOf = if this.allOfIndices.len == 0 : true else : entity.hasComponents(this.allOfIndices)
  let matchesAnyOf = if this.anyOfIndices.len == 0 : true else : entity.hasAnyComponent(this.anyOfIndices)
  let matchesNoneOf = if this.noneOfIndices.len == 0 : true else : not entity.hasAnyComponent(this.noneOfIndices)
  return matchesAllOf and matchesAnyOf and matchesNoneOf

proc MergeIndices(args: seq[Matcher]) : seq[int] =
  result = newSeqOfCap[int](MAX_COMPONENTS) #@[]
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

