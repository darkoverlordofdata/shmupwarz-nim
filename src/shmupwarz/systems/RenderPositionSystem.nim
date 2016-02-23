##
## RenderPositionSystem
##
type RenderPositionSystem* = ref object of System
  game* : Game
  group* : Group

##
## Create new RenderPositionSystem
##
proc newRenderPositionSystem*(game : Game) : RenderPositionSystem =
  new(result)
  result.game = game

##
##  Select all entities with Position+Resource
##
method initialize*(this : RenderPositionSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.Resource, Match.Position]))

##
##  Set the sprite position on the screen
##
method execute*(this : RenderPositionSystem) =
  for entity in this.group.getEntities():
    let res = entity.resource
    let pos = entity.position
    res.sprite.x = (int)pos.x
    res.sprite.y = (int)pos.y
