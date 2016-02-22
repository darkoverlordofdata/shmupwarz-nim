##
## CollisionSystem
##
proc newCollisionSystem*(game : Game) : CollisionSystem =
  new(result)
  result.game = game
method initialize*(this : CollisionSystem) =
  return
method execute*(this : CollisionSystem) =
  return
