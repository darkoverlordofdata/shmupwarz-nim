import strfmt
import strutils
import lists
import tables
import sets
import queues
import sequtils
import nuuid
import events

const MAX_COMPONENTS = 31

type
  IComponent* = ref object of RootObj
    ##
    ## Base Component
    ##

  Entity* = ref object of RootObj
    ##
    ## Entity - members
    ##
    components            : array[0..MAX_COMPONENTS, IComponent]
    componentIndicesCache : seq[int]
    componentsCache       : seq[IComponent]
    creationIndex*        : int
    id*                   : int
    isEnabled*            : bool
    name*                 : string
    owner                 : World
    refCount              : int
    toStringCache         : string
    totalComponents       : int
    uuid*                 : string

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

  World* = ref object of RootObj
    ##
    ## World - members
    ##
    entities              : Table[int,Entity]
    componentsEnum        : seq[string]
    creationIndex         : int
    entitiesCache         : seq[Entity]
    executeSystems        : seq[System]
    groups                : Table[int,Group]
    groupsForIndex        : Table[int, seq[Group]]
    initializeSystems     : seq[System]
    name*                 : string
    retainedEntities      : Table[int,Entity]
    reusableEntities      : Queue[Entity]
    totalComponents*      : int

  System* = ref object of RootObj
    ##
    ## System - members
    ##
    world*                 : World

  EntityArgs* = object of EventArgs
    entity*: Entity
    index* : int
    component* : IComponent

var
  EntityInstanceIndex     : int
  MatcherUniqueId         : int = 0
  WorldInstance           : World
  WorldComponentsEnum     : seq[string]
  WorldTotalComponents    : int
  EventEmitter = initEventEmitter()

proc newEntityArgs*(entity : Entity, index : int, component : IComponent): EntityArgs =
  result.entity = entity
  result.index = index
  result.component = component

#include ecs/Entity
##
## Entity - method forward declarations
##
proc newEntity*(totalComponents : int = 32): Entity
proc addComponent*(this: Entity, index : int, component : IComponent) : Entity
proc addRef(this: Entity) : void
proc destroy*(this: Entity) : void
proc getComponent*(this: Entity, index : int) : IComponent
proc getComponentIndices*(this: Entity) : seq[int]
proc getComponents*(this: Entity) : seq[IComponent]
proc hasComponent*(this: Entity, index : int) : bool
proc hasComponents*(this: Entity, indices : seq[int]) : bool
proc hasAnyComponent*(this: Entity, indices : seq[int]) : bool
proc initialize*(this: Entity, owner : World, name : string, uuid : string, creationIndex : int): void
proc release(this: Entity) : void
proc removeAllComponents*(this: Entity) : void
proc removeComponent*(this: Entity, index : int) : Entity
proc replaceComponent*(this: Entity, index : int, component : IComponent) : Entity
proc `$`*(this: Entity) : string
proc onEntityChanged*(this: World, entity : Entity, index : int, component : IComponent) : void
proc onEntityReleased*(this: World, entity : Entity) : void
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
## World - method forward declarations
##
proc newWorld*(componentsEnum : seq[string], startCreationIndex : int = 0): World
proc add*(this: World, system : System) : void
proc count*(this : World) : int
proc createEntity*(this: World, name : string): Entity
proc destroyAllEntities*(this: World): void
proc destroyEntity*(this: World, entity : Entity): void
proc execute*(this: World) : void
proc getGroup*(this: World, matcher : Matcher) : Group
proc getEntities*(this: World, matcher : Matcher) : seq[Entity]
proc hasEntity*(this: World, entity : Entity): bool
proc initialize*(this: World) : void
proc reusableEntitiesCount*(this : World) : int
proc retainedEntitiesCount*(this : World) : int


##
##  constructor
##
proc newEntity*(totalComponents : int = 32): Entity =
  new(result)
  EntityInstanceIndex += 1
  result.id = EntityInstanceIndex
  result.totalComponents = totalComponents
##
##  initialize an entity after creation
##
proc initialize*(this: Entity, owner : World, name : string, uuid : string, creationIndex : int): void =
  this.owner = owner
  this.name = name
  this.uuid = uuid
  this.creationIndex = creationIndex
  this.isEnabled = true
  this.addRef()

proc hasComponent*(this: Entity, index : int) : bool =
  return this.components[index] != nil

proc addComponent*(this: Entity, index : int, component : IComponent) : Entity =
  if not this.isEnabled:
    raise newException(OSError, "EntityIsNotEnabledException - Cannot add component!")
  if this.hasComponent(index):
    raise newException(OSError, interp"EntityAlreadyHasComponentException - Cannot add ${WorldComponentsEnum[index]} at index ${index}")
    
  this.components[index] = component
  this.componentsCache = nil
  this.componentIndicesCache = nil
  this.toStringCache = ""
  this.owner.onEntityChanged(this, index, component)
  return this

proc ReplaceComponent(this: Entity, index : int, replacement : IComponent) : void =
  let previousComponent = this.components[index]
  if previousComponent != replacement:
    this.components[index] = replacement
    this.componentsCache = nil
    if replacement == nil:
        this.components[index] = nil
        this.componentIndicesCache = nil
        this.toStringCache = ""
        this.owner.onEntityChanged(this, index, previousComponent)

  return

proc removeComponent*(this: Entity, index : int) : Entity =
  if not this.isEnabled:
    raise newException(OSError, "EntityIsNotEnabledException - Cannot remove component!")
  if not this.hasComponent(index):
    raise newException(OSError, interp"EntityDoesNotHaveComponentException - Cannot remove ${WorldComponentsEnum[index]} at index ${index}")

  this.ReplaceComponent(index, nil)
  return this

proc replaceComponent*(this: Entity, index : int, component : IComponent) : Entity =
  if not this.isEnabled:
    raise newException(OSError, "Exception.EntityIsNotEnabledException -Cannot replace component!")

  if this.hasComponent(index):
    discard this.replaceComponent(index, component)
  elif component != nil:
    discard this.addComponent(index, component)

  return this

proc getComponent*(this: Entity, index : int) : IComponent =
  if not this.hasComponent(index):
      raise newException(OSError, interp"EntityDoesNotHaveComponentException - Cannot get ${WorldComponentsEnum[index]} at index ${index}")

  return this.components[index]

proc getComponents*(this: Entity) : seq[IComponent] =
  if this.componentsCache == nil:
    this.componentsCache = @[]
    for i in 0..this.totalComponents-1:
      if this.components[i] != nil:
        this.componentsCache.add(this.components[i])
  return this.componentsCache

proc getComponentIndices*(this: Entity) : seq[int] =
  if this.componentIndicesCache == nil:
    this.componentIndicesCache = @[]
    var index = 0
    for i in 0..this.totalComponents-1:
      if this.components[i] != nil:
        this.componentIndicesCache.add(index)
      index+= 1
  return this.componentIndicesCache

proc hasComponents*(this: Entity, indices : seq[int]) : bool =
  for i in 0..indices.len-1:
    if this.components[indices[i]] == nil:
      return false
  return true

proc hasAnyComponent*(this: Entity, indices : seq[int]) : bool =
  for i in 0..indices.len-1:
    if this.components[indices[i]] != nil:
      return true
  return false

proc removeAllComponents*(this: Entity) : void =
  this.toStringCache = ""
  var index = 0
  for i in 0..this.totalComponents-1:
    if this.components[i] != nil:
      this.ReplaceComponent(index, nil)
    index+=1
  return

proc destroy*(this: Entity) : void =
  this.removeAllComponents()
  this.componentIndicesCache = @[]
  this.componentsCache = @[]
  this.name = ""
  this.isEnabled = false

proc `$`*(this: Entity) : string =
  if this.toStringCache == "":
    var sb : seq[string] = @[]
    for index in this.getComponentIndices():
      sb.add $WorldComponentsEnum[index]
    this.toStringCache = this.name & "(" & sb.join(",") & ")"
  return this.toStringCache

proc addRef(this: Entity) : void =
  this.refCount += 1

proc release(this: Entity) : void =
  this.refCount -= 1
  if this.refCount == 0:
    this.owner.onEntityReleased(this)
  elif this.refCount < 0:
    raise newException(OSError, "EntityIsAlreadyReleasedException")
  return

#include ecs/Matcher
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
    sb.add $WorldComponentsEnum[index]
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
  let matchesAllOf = if this.allOfIndices.len == 0 : true else : entity.hasComponents(this.allOfIndices)
  let matchesAnyOf = if this.anyOfIndices.len == 0 : true else : entity.hasAnyComponent(this.anyOfIndices)
  let matchesNoneOf = if this.noneOfIndices.len == 0 : true else : not entity.hasAnyComponent(this.noneOfIndices)
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

#include ecs/Group
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
    let c = this.entities.len
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
      sb.add WorldComponentsEnum[index] #.replace("Component", "")
    this.toStringCache =  "Group(" & sb.join(",") & ")"
  return this.toStringCache

#include ecs/System
##
## System - methods
##
method setWorld*(this : System, world : World) : void {.base.} =
  this.world = world
  return
method initialize*(this : System) : void {.base.} =
  return
method execute*(this : System) : void {.base.} =
  return

#include ecs/World
##
##  constructor
##
proc newWorld*(componentsEnum : seq[string], startCreationIndex : int = 0): World =
  new(result)
  result.componentsEnum = componentsEnum
  result.totalComponents = componentsEnum.len
  result.creationIndex = startCreationIndex
  result.groupsForIndex = initTable[int, seq[Group]]()
  result.reusableEntities = initQueue[Entity]()
  result.retainedEntities = initTable[int, Entity]()
  result.entitiesCache = @[]
  result.entities = initTable[int, Entity]()
  result.groups = initTable[int, Group]()
  result.initializeSystems = @[]
  result.executeSystems = @[]
  WorldComponentsEnum = componentsEnum
  WorldTotalComponents = componentsEnum.len
  WorldInstance = result

## Getters
proc count*(this : World) : int = this.entities.len
proc reusableEntitiesCount*(this : World) : int = this.reusableEntities.len
proc retainedEntitiesCount*(this : World) : int = this.retainedEntities.len

proc onEntityReleased*(this: World, entity : Entity) : void  =
  if entity.isEnabled:
    raise newException(OSError, "EntityIsNotDestroyedException -Cannot release entity.")

  this.retainedEntities.del(entity.id)
  ## TODO fix this - adding bogus entities
  #this.reusableEntities.enqueue(entity)

proc onEntityChanged*(this: World, entity : Entity, index : int, component : IComponent) : void =
  if this.groupsForIndex.hasKey(index):
    let groups = this.groupsForIndex[index]
    if groups != nil:
      for group in groups:
        group.handleEntity(entity, index, component)

proc destroyEntity*(this: World, entity : Entity): void =
  if not this.entities.hasKey(entity.id):
    raise newException(OSError, "WorldDoesNotContainEntityException - Could not destroy entity!")

  this.entities.del(entity.id)
  this.entitiesCache = nil
  entity.destroy()
  if entity.refCount == 1:
    this.reusableEntities.enqueue(entity)
  else:
    this.retainedEntities[entity.id] = entity
  entity.release()

proc createEntity*(this: World, name : string): Entity =
  #var entity = if this.reusableEntities.len > 0 : this.reusableEntities.dequeue() else : newEntity(this.totalComponents)
  # var entity : Entity
  # if this.reusableEntities.len > 0 :
  #   entity = this.reusableEntities.dequeue()
  #   #entity = newEntity(this.totalComponents)
  # else :
  #   entity = newEntity(this.totalComponents)

  let entity =
    if this.reusableEntities.len > 0 :
      this.reusableEntities.dequeue()
      #entity = newEntity(this.totalComponents)
    else :
      newEntity(this.totalComponents)

  this.creationIndex+=1
  entity.initialize(this, name, generateUUID(), this.creationIndex)
  this.entities[entity.id] = entity
  this.entitiesCache = nil
  return entity

proc getEntities*(this: World, matcher : Matcher) : seq[Entity] =
  if matcher != nil:
    return this.getGroup(matcher).getEntities()
  else:
    if this.entitiesCache == nil:
      this.entitiesCache = @[]
      for e in this.entities.values:
        this.entitiesCache.add(e)
    return this.entitiesCache

proc getGroup*(this: World, matcher : Matcher) : Group  =
  var group:Group

  if this.groups.hasKey(matcher.id):
    group = this.groups[matcher.id]
  else:
    group = newGroup(matcher)

    var entities : seq[Entity] = @[] #this.getEntities(nil)

    for entity in this.entities.values:
      group.handleEntitySilently(entity)

    this.groups[matcher.id] = group

    for index in matcher.indices:
      if not this.groupsForIndex.hasKey(index):
        this.groupsForIndex[index] = @[]
      this.groupsForIndex[index].add(group)

  return group

proc destroyAllEntities*(this: World): void =
  let entities = this.getEntities(nil)
  for entity in entities:
    this.destroyEntity(entity)

proc hasEntity*(this: World, entity : Entity): bool =
  return this.entities.hasKey(entity.id)

proc add*(this: World, system : System) : void =
  system.setWorld(this)
  this.initializeSystems.add(system)
  this.executeSystems.add(system)

proc initialize*(this: World) : void =
  for sys in this.initializeSystems:
    sys.initialize()

proc execute*(this: World) : void =
  for sys in this.executeSystems:
    sys.execute()

