import Events
import strfmt
import tables
import sets
import queues
import nuuid

var ecsEvents = initEventEmitter()

const MAX_COMPONENTS = 31

type GroupEventType = enum
    OnEntityAdded
    OnEntityRemoved
    OnEntityAddedOrRemoved

type IComponent* = ref object of RootObj
type System* = ref object of RootObj
type Entity* = ref object of RootObj
  ## Entity type
  onEntityReleased* : EventHandler
  onComponentAdded* : EventHandler
  onComponentRemoved* : EventHandler
  onComponentReplaced* : EventHandler
  creationIndex* : int
  name*: string
  id*: int
  isEnabled* : bool
  refCount : int
  toStringCache : string
  totalComponents : int
  componentCount : int
  componentsEnum : seq[string]
  components : array[0..MAX_COMPONENTS, IComponent]
  componentsCache : seq[IComponent]
  componentIndicesCache : seq[int]
proc newEntity*(componentsEnum : seq[string], totalComponents : int = 32): Entity
proc constructor*(this: Entity, componentsEnum : seq[string], totalComponents : int = 32): void
proc initialize*(this: Entity, name : string, id : string, creationIndex : int): void
proc hasComponent*(this: Entity, index : int) : bool
proc addComponent*(this: Entity, index : int, component : IComponent) : Entity
proc removeComponent*(this: Entity, index : int) : Entity
proc replaceComponent*(this: Entity, index : int, component : IComponent) : Entity
proc getComponent*(this: Entity, index : int) : IComponent
proc getComponents*(this: Entity) : seq[IComponent]
proc getComponentIndices*(this: Entity) : seq[int]
proc hasComponents*(this: Entity, indices : seq[int]) : bool
proc hasAnyComponent*(this: Entity, indices : seq[int]) : bool
proc removeAllComponents*(this: Entity) : void
proc destroy*(this: Entity) : void
proc toString*(this: Entity) : string
proc addRef(this: Entity) : void
proc release(this: Entity) : void

type Matcher* = ref object of RootObj
  ## Matcher type
  id*: int
  allOfIndices* : seq[int]
  anyOfIndices* : seq[int]
  noneOfIndices* : seq[int]
  indicesCache : seq[int]
  toStringCache : string
proc MatcherDistinctIndices(indices : seq[int]) : seq[int]
proc MatcherMerge(matchers : seq[Matcher]) : seq[int]
proc MatcherAllOf*(args : seq[int]) : Matcher
proc MatcherAnyOf*(args : seq[int]) : Matcher
proc constructor*(this: Matcher): void
proc mergeIndices*(this: Matcher) : seq[int]
proc indices*(this: Matcher) : seq[int]
proc toString*(this : Matcher) : string
proc anyOf*(this: Matcher, args : seq[int]) : Matcher
proc noneOf*(this: Matcher, args : seq[int]) : Matcher
proc matches*(this: Matcher, entity : Entity) : bool

type Group* = ref object of RootObj
  ## Group type
  onEntityAdded* : EventHandler
  onEntityRemoved* : EventHandler
  onEntityUpdated* : EventHandler
  matcher* : Matcher
  entities* : Table[int,Entity]
  entitiesCache: seq[Entity]
  singleEntityCache: Entity
  toStringCache : string
proc count*(this : Group) : int
proc newGroup*(matcher : Matcher): Group
proc constructor*(this : Group, matcher : Matcher): void
proc addEntitySilently(this : Group, entity : Entity): void
proc removeEntitySilently(this : Group, entity : Entity): void
proc addEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc removeEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc handleEntitySilently(this : Group, entity : Entity): void
proc handleEntity(this : Group, entity : Entity, index : int, component : IComponent): void
proc updateEntity(this : Group, entity : Entity, index : int, previousComponent : IComponent, newComponent : IComponent): void
proc containsEntity(this : Group, entity : Entity) : bool
proc getEntities(this : Group) : seq[Entity]
proc getSingleEntity(this : Group) : Entity
proc toString(this : Group) : string

type World* = ref object of RootObj
  ## World type
  onEntityCreated* : EventHandler
  onEntityWillBeDestroyed* : EventHandler
  onEntityDestroyed* : EventHandler
  onGroupCreated* : EventHandler
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
proc count*(this : World) : int
proc reusableEntitiesCount*(this : World) : int
proc retainedEntitiesCount*(this : World) : int
proc getGroup*(this: World, matcher : Matcher) : Group
proc constructor*(this: World, componentsEnum : seq[string], startCreationIndex : int = 0): void
proc onEntityReleased*(this: World, entity : Entity) : void
proc updateGroupsComponentAddedOrRemoved*(this: World, entity : Entity, index : int, component : IComponent) : void
proc updateGroupsComponentReplaced*(this: World, entity : Entity, index : int, component : IComponent, newComponent : IComponent) : void
proc destroyEntity*(this: World, entity : Entity): void
proc createEntity*(this: World, name : string): Entity
proc getEntities*(this: World, matcher : Matcher) : seq[Entity]
proc destroyAllEntities*(this: World): void
proc hasEntity*(this: World, entity : Entity): bool
proc add*(this: World, system : System) : void
proc initialize*(this: World) : void
proc execute*(this: World) : void


proc execute*(this : System, world : World) =
  return
proc initialize*(this : System, world : World) =
  return

var EntityInstanceIndex : int
var EntitySize : int
var MatcherUniqueId : int = 0

var WorldInstance : World
var WorldComponentsEnum : seq[string]
var WorldTotalComponents : int

include ecs/Entity
include ecs/Matcher
include ecs/Group
include ecs/World
