
##
##  Player Entity
##
proc createPlayer*(this : Game) : Entity =
  return this.world.createEntity("player")
  .setPlayer(true)
  .addPosition(0, 0)
  .addVelocity(0, 0)
  .addResource("res/images/fighter.png", nil)
