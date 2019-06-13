import strutils
import sequtils
import events
import entitas

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
    owner                 : RootRef
    refCount*              : int
    toStringCache         : string
    totalComponents       : int
    uuid*                 : string

  EntityArgs* = object of EventArgs
    entity*: Entity
    index* : int
    component* : IComponent

proc newEntityArgs*(entity : Entity, index : int, component : IComponent): EntityArgs =
  result.entity = entity
  result.index = index
  result.component = component

proc addRef*(this: Entity) : void

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
proc initialize*(this: Entity, owner : RootRef, name : string, uuid : string, creationIndex : int): void =
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
    raise newException(OSError, "EntityAlreadyHasComponentException - Cannot add ${WorldComponentsEnum[index]} at index ${index}")
    
  this.components[index] = component
  this.componentsCache = @[] #nil
  this.componentIndicesCache = @[] #nil
  this.toStringCache = ""
  raiseEntityChanged(this, this.owner, index, component)
  return this

proc ReplaceComponent(this: Entity, index : int, replacement : IComponent) : void =
  let previousComponent = this.components[index]
  if previousComponent != replacement:
    this.components[index] = replacement
    this.componentsCache = @[] #nil
    if replacement == nil:
        this.components[index] = nil
        this.componentIndicesCache = @[] #nil
        this.toStringCache = ""
        raiseEntityChanged(this, this.owner, index, previousComponent)

  return

proc removeComponent*(this: Entity, index : int) : Entity =
  if not this.isEnabled:
    raise newException(OSError, "EntityIsNotEnabledException - Cannot remove component!")
  if not this.hasComponent(index):
    raise newException(OSError, "EntityDoesNotHaveComponentException - Cannot remove ${WorldComponentsEnum[index]} at index ${index}")

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
      raise newException(OSError, "EntityDoesNotHaveComponentException - Cannot get ${WorldComponentsEnum[index]} at index ${index}")

  return this.components[index]

proc getComponents*(this: Entity) : seq[IComponent] =
  if this.componentsCache.len() == 0:
    this.componentsCache = newSeqOfCap[IComponent](MAX_COMPONENTS) #@[]
    for i in 0..this.totalComponents-1:
      if this.components[i] != nil:
        this.componentsCache.add(this.components[i])
  return this.componentsCache

proc getComponentIndices*(this: Entity) : seq[int] =
  if this.componentIndicesCache.len() == 0:
    this.componentIndicesCache = newSeqOfCap[int](MAX_COMPONENTS) #@[]
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
  this.componentIndicesCache = newSeqOfCap[int](MAX_COMPONENTS) #@[]
  this.componentsCache = newSeqOfCap[IComponent](MAX_COMPONENTS) #@[]
  this.name = ""
  this.isEnabled = false

proc `$`*(this: Entity) : string =
  if this.toStringCache == "":
    var sb : seq[string] = newSeqOfCap[string](MAX_COMPONENTS) #@[]
    for index in this.getComponentIndices():
      sb.add $WorldComponentsEnum[index]
    this.toStringCache = this.name & "(" & sb.join(",") & ")"
  return this.toStringCache

proc addRef(this: Entity) : void =
  this.refCount += 1

proc release*(this: Entity) : void =
  this.refCount -= 1
  if this.refCount == 0:
    raiseEntityReleased(this, this.owner)
  elif this.refCount < 0:
    raise newException(OSError, "EntityIsAlreadyReleasedException")
  return

