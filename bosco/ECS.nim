import strfmt
import strutils
import lists
import tables
import sets
import queues
import sequtils
import nuuid

const MAX_COMPONENTS = 31

type
  ##
  ## Base Component
  ##
  IComponent* = ref object of RootObj
  ##
  ## Entity - members
  ##
  Entity* = ref object of RootObj
    owner : World
    creationIndex* : int
    name*: string
    id*: int
    uuid*: string
    isEnabled* : bool
    refCount : int
    toStringCache : string
    totalComponents : int
    componentCount : int
    componentsEnum : seq[string]
    components : array[0..MAX_COMPONENTS, IComponent]
    componentsCache : seq[IComponent]
    componentIndicesCache : seq[int]
  ##
  ## Matcher - members
  ##
  Matcher* = ref object of RootObj
    id*: int
    allOfIndices* : seq[int]
    anyOfIndices* : seq[int]
    noneOfIndices* : seq[int]
    indicesCache : seq[int]
    toStringCache : string
  ##
  ## Group - members
  ##
  Group* = ref object of RootObj
    matcher* : Matcher
    entities* : Table[int,Entity]
    entitiesCache: seq[Entity]
    singleEntityCache: Entity
    toStringCache : string
  ##
  ## World - members
  ##
  World* = ref object of RootObj
    name* : string
    totalComponents* : int
    entities : Table[int,Entity]
    groups : Table[int,Group]
    groupsForIndex : seq[seq[Group]]
    reusableEntities : Queue[Entity]
    retainedEntities : Table[int,Entity]
    componentsEnum : seq[string]
    creationIndex : int
    entitiesCache : seq[Entity]
    initializeSystems : seq[System]
    executeSystems : seq[System]
  ##
  ## System - members
  ##
  System* = ref object of RootObj
    world : World

var
  EntityInstanceIndex : int
  EntitySize : int
  MatcherUniqueId : int = 0
  WorldInstance : World
  WorldComponentsEnum : seq[string]
  WorldTotalComponents : int

##
## Entity - method forward declarations
##
proc newEntity*(componentsEnum : seq[string], totalComponents : int = 32): Entity
proc constructor*(this: Entity, componentsEnum : seq[string], totalComponents : int = 32): void
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

##
## Matcher - method forward declarations
##
proc MatchAllOf*(args : seq[int]) : Matcher
proc MatchAnyOf*(args : seq[int]) : Matcher
proc newMatcher*() : Matcher
proc constructor*(this: Matcher): void
proc anyOf*(this: Matcher, args : seq[int]) : Matcher
proc indices*(this: Matcher) : seq[int]
proc matches*(this: Matcher, entity : Entity) : bool
proc noneOf*(this: Matcher, args : seq[int]) : Matcher
proc `$`*(this : Matcher) : string

##
## Group - method forward declarations
##
proc newGroup*(matcher : Matcher): Group
proc constructor*(this : Group, matcher : Matcher): void
proc addEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc addEntitySilently(this : Group, entity : Entity): void
proc containsEntity(this : Group, entity : Entity) : bool
proc count*(this : Group) : int
proc getEntities(this : Group) : seq[Entity]
proc getSingleEntity(this : Group) : Entity
proc handleEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc handleEntitySilently(this : Group, entity : Entity): void
proc removeEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc removeEntitySilently(this : Group, entity : Entity): void
proc `$`(this : Group) : string

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
proc onEntityChanged*(this: World, entity : Entity, index : int, component : IComponent) : void
proc onEntityReleased*(this: World, entity : Entity) : void

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

include ecs/Entity
include ecs/Matcher
include ecs/Group
include ecs/World
