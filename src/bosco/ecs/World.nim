##
## World - method forward declarations
##
proc newWorld*(componentsEnum : seq[string], startCreationIndex : int = 0): World
proc constructor*(this: World, componentsEnum : seq[string], startCreationIndex : int = 0): void
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

proc newWorld*(componentsEnum : seq[string], startCreationIndex : int = 0): World =
  new(result)
  result.constructor(componentsEnum, startCreationIndex)

## Getters
proc count*(this : World) : int = this.entities.len
proc reusableEntitiesCount*(this : World) : int = this.reusableEntities.len
proc retainedEntitiesCount*(this : World) : int = this.retainedEntities.len


proc constructor*(this: World, componentsEnum : seq[string], startCreationIndex : int = 0): void =

  this.componentsEnum = componentsEnum
  this.totalComponents = componentsEnum.len
  this.creationIndex = startCreationIndex
  this.groupsForIndex = initTable[int, seq[Group]]()

  this.reusableEntities = initQueue[Entity]()
  this.retainedEntities = initTable[int, Entity]()
  this.entitiesCache = @[]
  this.entities = initTable[int, Entity]()
  this.groups = initTable[int, Group]()
  this.initializeSystems = @[]
  this.executeSystems = @[]
  WorldComponentsEnum = componentsEnum
  WorldTotalComponents = componentsEnum.len
  WorldInstance = this

proc onEntityReleased*(this: World, entity : Entity) : void  =
  if entity.isEnabled:
    raise newException(OSError, "EntityIsNotDestroyedException -Cannot release entity.")

  this.retainedEntities.del(entity.id)
  this.reusableEntities.enqueue(entity)

proc onEntityChanged*(this: World, entity : Entity, index : int, component : IComponent) : void =
  if this.groupsForIndex.hasKey(index):
    var groups = this.groupsForIndex[index]
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
    this.reusableEntities.add(entity)
  else:
    this.retainedEntities[entity.id] = entity
  entity.release()

proc createEntity*(this: World, name : string): Entity =
  var entity = if this.reusableEntities.len > 0 : this.reusableEntities.dequeue() else : newEntity(this.totalComponents)
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
  var entities = this.getEntities(nil)
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
