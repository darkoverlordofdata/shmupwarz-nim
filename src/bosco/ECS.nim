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

var
  EntityInstanceIndex     : int
  EntitySize              : int
  MatcherUniqueId         : int = 0
  WorldInstance           : World
  WorldComponentsEnum     : seq[string]
  WorldTotalComponents    : int

include ecs/Entity
include ecs/Matcher
include ecs/Group
include ecs/System
include ecs/World
