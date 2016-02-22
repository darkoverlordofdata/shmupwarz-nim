##
## MovementSystem
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
    let pos = entity.position
    let vel = entity.velocity
    pos.x += (vel.x * this.game.delta)
    pos.y += (vel.y * this.game.delta)
