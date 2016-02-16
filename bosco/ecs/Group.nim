
proc count*(this : Group) : int =
  return this.entities.len

proc constructor*(this : Group, matcher : Matcher): void =
  this.entities = initTable[int, Entity]()
  this.entitiesCache = @[]
  this.matcher = matcher
  return

proc addEntitySilently(this : Group, entity : Entity): void =
  if not this.entities.hasKey(entity.id):
    this.entities[entity.id] = entity
    this.entitiesCache = nil
    this.singleEntityCache = nil
    entity.addRef()

proc removeEntitySilently(this : Group, entity : Entity): void =
  if this.entities.hasKey(entity.id):
    this.entities.del(entity.id)
    this.entitiesCache = nil
    this.singleEntityCache = nil
    entity.release()

proc addEntity(this : Group, entity : Entity, index : int, component : IComponent): void =
  if not this.entities.hasKey(entity.id):
    this.entities[entity.id] = entity
    this.entitiesCache = nil
    this.singleEntityCache = nil
    entity.addRef()

proc removeEntity(this : Group, entity : Entity, index : int, component : IComponent): void =
  if this.entities.hasKey(entity.id):
    this.entities.del(entity.id)
    this.entitiesCache = nil
    this.singleEntityCache = nil
    entity.release()

proc handleEntitySilently(this : Group, entity : Entity): void =
  if this.matcher.matches(entity):
    this.addEntitySilently(entity)
  else:
    this.removeEntitySilently(entity)

proc handleEntity(this : Group, entity : Entity, index : int, component : IComponent): void =
  if this.matcher.matches(entity):
    this.addEntity(entity, index, component)
  else:
    this.removeEntity(entity, index, component)

proc containsEntity(this : Group, entity : Entity) : bool =
  return this.entities.hasKey(entity.id)

proc getEntities(this : Group) : seq[Entity] =
  if this.entitiesCache.len == 0:
    this.entitiesCache = @[]
    for i in 0..this.entities.len-1:
      this.entitiesCache.add(this.entities[i])

  return this.entitiesCache

proc getSingleEntity(this : Group) : Entity =
  if this.singleEntityCache == nil:
    var c = this.entities.len
    if c == 1:
      for e in this.entities.values:
        this.singleEntityCache = e
    elif c == 0:
      return nil
    else:
      raise newException(OSError, interp"SingleEntityException {this.matcher.toString()}")
  return this.singleEntityCache

proc toString(this : Group) : string =
  if this.toStringCache == nil:
    var sb = ""
    for i in 0..this.matcher.indices.len-1:
        sb = sb & "" #World.componentsEnum[index].replace("Component", "")
    this.toStringCache = "Group(" & sb & ")"
  return this.toStringCache

proc newGroup*(matcher : Matcher): Group =
  new(result)
  result.constructor(matcher)
