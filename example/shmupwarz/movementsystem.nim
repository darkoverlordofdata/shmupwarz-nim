import gamestate

type
  MovementSystem* = ref object of System
    ## Process movement
    game* : Game
    group* : Group

##
## Create new MovementSystem
##
proc newMovementSystem*(game : Game) : MovementSystem =
  new(result)
  result.game = game

##
## Select all entities with Position+Velocity
##
method initialize*(this : MovementSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.Position, Match.Velocity]))

##
## Calculate new position
##
method execute*(this : MovementSystem) =
  for entity in this.group.getEntities():
    entity.position.x += (entity.velocity.x * this.game.delta)
    entity.position.y += (entity.velocity.y * this.game.delta)

