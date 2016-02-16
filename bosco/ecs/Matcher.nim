proc newMatcher*(): Matcher =
  new(result)
  result.constructor

proc constructor*(this: Matcher): void =
  this.id = MatcherUniqueId
  MatcherUniqueId = MatcherUniqueId+1
  this.allOfIndices = @[]
  this.anyOfIndices = @[]
  this.noneOfIndices = @[]

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

proc MatchAllOf*(args : seq[int]) : Matcher =
  ## Matches allOf the components/indices specified
  result = newMatcher()
  result.allOfIndices = deduplicate(args)

proc MatchAnyOf*(args : seq[int]) : Matcher =
  ## Matches anyOf the components/indices specified
  result = newMatcher()
  result.anyOfIndices = deduplicate(args)
