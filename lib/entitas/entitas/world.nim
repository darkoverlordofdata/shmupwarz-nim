import tables
import deques
import nuuid
import entitas


type
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
    reusableEntities      : Deque[Entity]
    totalComponents*      : int

  System* = ref object of RootObj
    ##
    ## System - members
    ##
    world*                 : World


var  WorldInstance*           : World
proc getGroup*(this: World, matcher : Matcher) : Group
##
## Abstract System
##
method setWorld*(this : System, world : World) : void {.base.} =
  this.world = world
  return
method initialize*(this : System) : void {.base.} =
  return
method execute*(this : System) : void {.base.} =
  return

##
##  constructor
##
proc newWorld*(componentsEnum : seq[string], startCreationIndex : int = 0): World =
  new(result)
  result.componentsEnum = componentsEnum
  result.totalComponents = componentsEnum.len
  result.creationIndex = startCreationIndex
  result.groupsForIndex = initTable[int, seq[Group]]()
  result.reusableEntities = initDeque[Entity]()
  result.retainedEntities = initTable[int, Entity]()
  result.entitiesCache = newSeqOfCap[Entity](100) #@[]
  result.entities = initTable[int, Entity]()
  result.groups = initTable[int, Group]()
  result.initializeSystems = newSeqOfCap[System](MAX_COMPONENTS) #@[]
  result.executeSystems = newSeqOfCap[System](MAX_COMPONENTS) #@[]
  WorldComponentsEnum = componentsEnum
  WorldTotalComponents = componentsEnum.len
  WorldInstance = result

## Getters
proc count*(this : World) : int = this.entities.len
proc reusableEntitiesCount*(this : World) : int = this.reusableEntities.len
proc retainedEntitiesCount*(this : World) : int = this.retainedEntities.len

proc onEntityReleased*(this: World, entity : Entity) : void  =
  ## Event: all references to the entity have been released
  if entity.isEnabled:
    raise newException(OSError, "EntityIsNotDestroyedException -Cannot release entity.")

  this.retainedEntities.del(entity.id)
  ## TODO fix this - adding bogus entities
  #this.reusableEntities.enqueue(entity)

proc onEntityChanged*(this: World, entity : Entity, index : int, component : IComponent) : void =
  ## Event: entity has been changed
  if this.groupsForIndex.hasKey(index):
    let groups = this.groupsForIndex[index]
    if groups.len() != 0:
      for group in groups:
        group.handleEntity(entity, index, component)

proc destroyEntity*(this: World, entity : Entity): void =
  if not this.entities.hasKey(entity.id):
    raise newException(OSError, "WorldDoesNotContainEntityException - Could not destroy entity!")

  this.entities.del(entity.id)
  this.entitiesCache = @[]
  entity.destroy()
  if entity.refCount == 1:
    this.reusableEntities.addFirst(entity)
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
      this.reusableEntities.popFirst()
      #entity = newEntity(this.totalComponents)
    else :
      newEntity(this.totalComponents)

  this.creationIndex+=1
  entity.initialize(this, name, generateUUID(), this.creationIndex)
  this.entities[entity.id] = entity
  this.entitiesCache = @[]
  return entity

proc getEntities*(this: World, matcher : Matcher) : seq[Entity] =
  if matcher != nil:
    return this.getGroup(matcher).getEntities()
  else:
    if this.entitiesCache.len() == 0:
      this.entitiesCache = newSeqOfCap[Entity](100) #@[]
      for e in this.entities.values:
        this.entitiesCache.add(e)
    return this.entitiesCache

proc getGroup*(this: World, matcher : Matcher) : Group  =
  var group:Group

  if this.groups.hasKey(matcher.id):
    group = this.groups[matcher.id]
  else:
    group = newGroup(matcher)

    #var entities : seq[Entity] = newSeqOfCap[Entity](100) #@[] #this.getEntities(nil)

    for entity in this.entities.values:
      group.handleEntitySilently(entity)

    this.groups[matcher.id] = group

    for index in matcher.indices:
      if not this.groupsForIndex.hasKey(index):
        this.groupsForIndex[index] = newSeqOfCap[Group](MAX_COMPONENTS) #@[]
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

