import tables
import deques
import events

const MAX_COMPONENTS* = 31
var
  EntityInstanceIndex*     : int
  MatcherUniqueId*         : int = 0
  WorldComponentsEnum*     : seq[string]
  WorldTotalComponents*    : int
  EventEmitter* = initEventEmitter()

proc raiseEntityChanged*(entity : RootRef, owner: RootRef, index : int, component : RootRef) : void 
proc raiseEntityReleased*(entity : RootRef, owner: RootRef) : void 

import entitas.entity
export entity
import entitas.matcher
export matcher
import entitas.group
export group
import entitas.world
export world

proc raiseEntityChanged*(entity : RootRef, owner: RootRef, index : int, component : RootRef) : void =
  World(owner).onEntityChanged(Entity(entity), index, IComponent(component))

proc raiseEntityReleased*(entity : RootRef, owner: RootRef) : void =
  World(owner).onEntityReleased(Entity(entity))



