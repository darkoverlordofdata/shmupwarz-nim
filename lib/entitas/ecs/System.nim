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
