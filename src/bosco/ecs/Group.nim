##
## Group - method forward declarations
##
proc newGroup*(matcher : Matcher): Group
proc addEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc addEntitySilently(this : Group, entity : Entity): void
proc containsEntity(this : Group, entity : Entity) : bool
proc count*(this : Group) : int
proc getEntities*(this : Group) : seq[Entity]
proc getSingleEntity*(this : Group) : Entity
proc handleEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc handleEntitySilently(this : Group, entity : Entity): void
proc removeEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc removeEntitySilently(this : Group, entity : Entity): void
proc `$`*(this : Group) : string
##
##  constructor
##
proc newGroup*(matcher : Matcher): Group =
  new(result)
  result.onAddEntity = initEventHandler("onAddEntity")
  result.onRemoveEntity = initEventHandler("onRemoveEntity")
  result.entities = initTable[int, Entity]()
  result.entitiesCache = @[]
  result.matcher = matcher

proc count*(this : Group) : int = return this.entities.len

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
    EventEmitter.emit(this.onAddEntity, newEntityArgs(entity, index, component))

proc removeEntity(this : Group, entity : Entity, index : int, component : IComponent): void =
  if this.entities.hasKey(entity.id):
    this.entities.del(entity.id)
    this.entitiesCache = nil
    this.singleEntityCache = nil
    entity.release()
    EventEmitter.emit(this.onRemoveEntity, newEntityArgs(entity, index, component))

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

proc getEntities*(this : Group) : seq[Entity] =
  if this.entitiesCache.len == 0:
    this.entitiesCache = @[]
    for entity in this.entities.values:
      this.entitiesCache.add entity

  return this.entitiesCache

proc getSingleEntity*(this : Group) : Entity =
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

proc `$`*(this : Group) : string =
  if this.toStringCache == nil:
    var sb : seq[string] = @[]
    for index in this.matcher.indices:
      sb.add WorldComponentsEnum[index-1] #.replace("Component", "")
    this.toStringCache =  "Group(" & sb.join(",") & ")"
  return this.toStringCache
