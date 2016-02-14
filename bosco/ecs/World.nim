proc count*(this : World) : int = this.entities.len
proc reusableEntitiesCount*(this : World) : int = this.reusableEntities.len
proc retainedEntitiesCount*(this : World) : int = this.retainedEntities.len


proc constructor*(this: World, componentsEnum : seq[string], startCreationIndex : int = 0): void =
  this.onGroupCreated = initEventHandler("GroupCreated")
  this.onEntityCreated = initEventHandler("EntityCreated")
  this.onEntityDestroyed = initEventHandler("EntityDestroyed")
  this.onEntityWillBeDestroyed = initEventHandler("EntityWillBeDestroyed")

  this.componentsEnum = componentsEnum
  this.totalComponents = componentsEnum.len
  this.creationIndex = startCreationIndex
  this.groupsForIndex = @[]

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

proc onEntityReleased*(this: World, entity : Entity) : void =
  if entity.isEnabled:
    raise newException(OSError, "EntityIsNotDestroyedException -Cannot release entity.")

  # entity.onEntityReleased.removeHandler(onEntityReleased)
  this.retainedEntities.del(entity.id)
  this.reusableEntities.enqueue(entity)

proc updateGroupsComponentAddedOrRemoved*(this: World, entity : Entity, index : int, component : IComponent) : void =
  if index+1 <= this.groupsForIndex.len:
    var groups = this.groupsForIndex[index]
    if groups != nil:
      for group in groups:
        group.handleEntity(entity, index, component)

proc updateGroupsComponentReplaced*(this: World, entity : Entity, index : int, component : IComponent, newComponent : IComponent) : void =
  if index+1 <= this.groupsForIndex.len:
    var groups = this.groupsForIndex[index]
    if groups != nil:
      for group in groups:
        group.updateEntity(entity, index, component, newComponent)

proc destroyEntity*(this: World, entity : Entity): void =
  if not this.entities.hasKey(entity.id):
    raise newException(OSError, "WorldDoesNotContainEntityException - Could not destroy entity!")

  this.entities.del(entity.id)
  this.entitiesCache = nil
  var args: EventArgs
  ecsEvents.emit(this.onEntityWillBeDestroyed, args)
  # this.onEntityWillBeDestroyed.dispatch(this, entity)
  entity.destroy()

  # var args: EventArgs
  ecsEvents.emit(this.onEntityDestroyed, args)
  # this.onEntityDestroyed.dispatch(this, entity)

  if entity.refCount == 1:
    # entity.onEntityReleased.removeHandler(this.onEntityReleased)
    this.reusableEntities.add(entity)
  else:
    this.retainedEntities[entity.id] = entity

  entity.release()

proc createEntity*(this: World, name : string): Entity =
  var entity = if this.reusableEntities.len > 0 : this.reusableEntities.dequeue() else : newEntity(this.componentsEnum, this.totalComponents)
  this.creationIndex+=1
  entity.initialize(name, generateUUID(), this.creationIndex)
  this.entities[entity.id] = entity
  this.entitiesCache = nil
  # entity.onComponentAdded.addHandler(updateGroupsComponentAddedOrRemoved)
  # entity.onComponentRemoved.addHandler(updateGroupsComponentAddedOrRemoved)
  # entity.onComponentReplaced.addHandler(this.updateGroupsComponentReplaced)
  # entity.onEntityReleased.addHandler(onEntityReleased)

  var args: EventArgs
  ecsEvents.emit(this.onEntityCreated, args)
  # onEntityCreated.dispatch((World)this, entity)
  return entity

proc getEntities*(this: World, matcher : Matcher) : seq[Entity] =
  if matcher != nil:
    ## PoolExtension::getEntities
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
    for entity in entities:
      group.handleEntitySilently(entity)

    this.groups[matcher.id] = group

    for index in matcher.indices:
      if this.groupsForIndex[index] == nil:
        this.groupsForIndex[index] = @[]
      this.groupsForIndex[index].add(group)

    var args: EventArgs
    ecsEvents.emit(this.onGroupCreated, args)
    # this.onGroupCreated.dispatch((World)this, group)
  return group

proc destroyAllEntities*(this: World): void =
  var entities = this.getEntities(nil)
  for entity in entities:
    this.destroyEntity(entity)

proc hasEntity*(this: World, entity : Entity): bool =
  return this.entities.hasKey(entity.id)

proc add*(this: World, system : System) : void =
  this.initializeSystems.add(system)
  this.executeSystems.add(system)

proc initialize*(this: World) : void =
  for sys in this.initializeSystems:
    sys.initialize(this)

proc execute*(this: World) : void =
  for sys in this.executeSystems:
    sys.execute(this)
