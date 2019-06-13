import strutils
import tables
import events
import entitas


type
  Group* = ref object of RootObj
    ##
    ## Group - members
    ##
    entities*             : Table[int,Entity]
    entitiesCache         : seq[Entity]
    matcher*              : Matcher
    singleEntityCache     : Entity
    toStringCache         : string
    onAddEntity*          : EventHandler
    onRemoveEntity*       : EventHandler

##
##  constructor
##
proc newGroup*(matcher : Matcher): Group =
  new(result)
  result.onAddEntity = initEventHandler("onAddEntity")
  result.onRemoveEntity = initEventHandler("onRemoveEntity")
  result.entities = initTable[int, Entity]()
  result.entitiesCache = newSeqOfCap[Entity](100) #@[]
  result.matcher = matcher

proc count*(this : Group) : int = return this.entities.len

proc addEntitySilently(this : Group, entity : Entity): void =
  if not this.entities.hasKey(entity.id):
    this.entities[entity.id] = entity
    this.entitiesCache = @[]
    this.singleEntityCache = nil
    entity.addRef()

proc removeEntitySilently(this : Group, entity : Entity): void =
  if this.entities.hasKey(entity.id):
    this.entities.del(entity.id)
    this.entitiesCache = @[]
    this.singleEntityCache = nil
    entity.release()

proc addEntity(this : Group, entity : Entity, index : int, component : IComponent): void =
  if not this.entities.hasKey(entity.id):
    this.entities[entity.id] = entity
    this.entitiesCache = @[]
    this.singleEntityCache = nil
    entity.addRef()
    entitas.EventEmitter.emit(this.onAddEntity, newEntityArgs(entity, index, component))

proc removeEntity(this : Group, entity : Entity, index : int, component : IComponent): void =
  if this.entities.hasKey(entity.id):
    this.entities.del(entity.id)
    this.entitiesCache = @[]
    this.singleEntityCache = nil
    entity.release()
    entitas.EventEmitter.emit(this.onRemoveEntity, newEntityArgs(entity, index, component))

proc handleEntitySilently*(this : Group, entity : Entity): void =
  if this.matcher.matches(entity):
    this.addEntitySilently(entity)
  else:
    this.removeEntitySilently(entity)

proc handleEntity*(this : Group, entity : Entity, index : int, component : IComponent): void =
  if this.matcher.matches(entity):
    this.addEntity(entity, index, component)
  else:
    this.removeEntity(entity, index, component)

proc containsEntity*(this : Group, entity : Entity) : bool =
  return this.entities.hasKey(entity.id)

proc getEntities*(this : Group) : seq[Entity] =
  if this.entitiesCache.len == 0:
    this.entitiesCache = newSeqOfCap[Entity](100) #@[]
    for entity in this.entities.values:
      this.entitiesCache.add entity

  return this.entitiesCache

proc getSingleEntity*(this : Group) : Entity =
  if this.singleEntityCache == nil:
    let c = this.entities.len
    if c == 1:
      for e in this.entities.values:
        this.singleEntityCache = e
    elif c == 0:
      return nil
    else:
      raise newException(OSError, "SingleEntityException {this.matcher.toString()}")
  return this.singleEntityCache

proc `$`*(this : Group) : string =
  if this.toStringCache.len() == 0:
    var sb : seq[string] = newSeqOfCap[string](MAX_COMPONENTS) #@[]
    for index in this.matcher.indices:
      sb.add WorldComponentsEnum[index] #.replace("Component", "")
    this.toStringCache =  "Group(" & sb.join(",") & ")"
  return this.toStringCache
