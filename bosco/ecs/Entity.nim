##
## Entity - method forward declarations
##
proc newEntity*(totalComponents : int = 32): Entity
proc constructor*(this: Entity, totalComponents : int = 32): void
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


proc newEntity*(totalComponents : int = 32): Entity =
  new(result)
  result.constructor(totalComponents)

proc constructor*(this: Entity, totalComponents : int = 32): void =
  this.totalComponents = totalComponents

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
  var previousComponent = this.components[index]
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
  this.isEnabled = false

proc `$`*(this: Entity) : string =
  if this.toStringCache == "":
    var sb : seq[string] = @[]
    for index in this.getComponentIndices():
      sb.add $WorldComponentsEnum[index]
    this.toStringCache = this.name & "(" & sb.join(", ") & ")"
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
