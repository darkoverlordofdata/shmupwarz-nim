##
## ExpiringSystem
##
# type 
#   ExpiringSystem* = ref object of System
#     game* : Game
#     group* : Group

##
## Create new ExpiringSystem
##
proc newExpiringSystem*(game : Game) : ExpiringSystem =
  new(result)
  result.game = game

method initialize*(this : ExpiringSystem) =
  this.group = this.world.getGroup(Match.Expires)

method execute*(this : ExpiringSystem) =
  for entity in this.group.getEntities():
    entity.expires.delay -= this.game.delta
    if entity.expires.delay <= 0:
      discard entity.setDestroy(true)
