proc constructor*(this: Entity, componentsEnum : seq[string], totalComponents : int = 32): void =
  this.totalComponents = totalComponents
  this.componentCount = componentsEnum.len
  this.componentsEnum = componentsEnum
  #this.world = World.instance
  this.onEntityReleased = initEventHandler("EntityReleased")
  this.onComponentAdded = initEventHandler("ComponentAdded")
  this.onComponentRemoved = initEventHandler("ComponentRemoved")
  this.onComponentReplaced = initEventHandler("ComponentReplaced")

proc addRef(this: Entity) : void =
  this.refCount += 1

proc release(this: Entity) : void =
  this.refCount -= 1
  if this.refCount == 0:
    var args: EventArgs
    ecsEvents.emit(this.onEntityReleased, args)
  elif this.refCount < 0:
    raise newException(OSError, "EntityIsAlreadyReleasedException")
  return

proc initialize*(this: Entity, name : string, id : string, creationIndex : int): void =
  this.name = name
  #this.id = id
  this.creationIndex = creationIndex
  this.addRef()

proc hasComponent*(this: Entity, index : int) : bool =
  return this.components[index] != nil

proc addComponent*(this: Entity, index : int, component : IComponent) : Entity =
  if not this.isEnabled:
    raise newException(OSError, "EntityIsNotEnabledException - Cannot add component!")
  if this.hasComponent(index):
    raise newException(OSError, interp"EntityAlreadyHasComponentException - Cannot add ${this.componentsEnum[index]} at index ${index}")
  this.components[index] = component
  this.componentsCache = nil
  this.componentIndicesCache = nil
  this.toStringCache = ""
  # onComponentAdded.dispatch(this, index, component)
  var args: EventArgs
  ecsEvents.emit(this.onComponentAdded, args)
  return this

proc ReplaceComponent(this: Entity, index : int, replacement : IComponent) : void =
  var previousComponent = this.components[index]
  if previousComponent == replacement:
    var args: EventArgs
    ecsEvents.emit(this.onComponentReplaced, args)
    #_onComponentReplaced.dispatch((Entity)this, index, previousComponent, replacement)
  else:
    this.components[index] = replacement
    this.componentsCache = nil
    if replacement == nil:
        this.components[index] = nil
        this.componentIndicesCache = nil
        this.toStringCache = ""
        var args: EventArgs
        ecsEvents.emit(this.onComponentRemoved, args)
        #_onComponentRemoved.dispatch((Entity)this, index, previousComponent)

    else:
      var args: EventArgs
      ecsEvents.emit(this.onComponentReplaced, args)
      # _onComponentReplaced.dispatch((Entity)this, index, previousComponent, replacement)
  return

proc removeComponent*(this: Entity, index : int) : Entity =
  if not this.isEnabled:
    raise newException(OSError, "EntityIsNotEnabledException - Cannot remove component!")

  if not this.hasComponent(index):
    raise newException(OSError, interp"EntityDoesNotHaveComponentException - Cannot remove ${this.componentsEnum[index]} at index ${index}")

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
      raise newException(OSError, interp"EntityDoesNotHaveComponentException - Cannot get ${this.componentsEnum[index]} at index ${index}")

  return this.components[index]

proc getComponents*(this: Entity) : seq[IComponent] =
  if this.componentsCache == nil:
    this.componentsCache = @[]
    for i in 0..this.componentCount-1:
      if this.components[i] != nil:
        this.componentsCache.add(this.components[i])
  return this.componentsCache

proc getComponentIndices*(this: Entity) : seq[int] =
  if this.componentIndicesCache == nil:
    this.componentIndicesCache = @[]
    var index = 0
    for i in 0..this.componentCount-1:
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
  for i in 0..this.componentCount-1:
    if this.components[i] != nil:
      this.ReplaceComponent(index, nil)
    index+=1
  return

proc destroy*(this: Entity) : void =
  this.removeAllComponents()
  this.onComponentAdded.clearHandlers()
  this.onComponentReplaced.clearHandlers()
  this.onComponentRemoved.clearHandlers()
  this.isEnabled = false

proc toString*(this: Entity) : string =
  if this.toStringCache == nil:
    var sb = ""
    var seperator = ", "

    var components = this.getComponentIndices()
    var lastSeperator = components.len - 1
    for i in 0..lastSeperator:
      sb = sb & this.componentsEnum[components[i]]
      if i < lastSeperator:
        sb = sb & seperator
    this.toStringCache = sb
  return this.toStringCache

proc newEntity*(componentsEnum : seq[string], totalComponents : int = 32): Entity =
  new(result)
  result.constructor(componentsEnum, totalComponents)
