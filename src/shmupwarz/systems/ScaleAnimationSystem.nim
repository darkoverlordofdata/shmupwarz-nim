##
## ScaleAnimationSystem
##
type ScaleAnimationSystem* = ref object of System
  game* : Game
  group* : Group

##
## Create new ScaleAnimationSystem
##
proc newScaleAnimationSystem*(game : Game) : ScaleAnimationSystem =
  new(result)
  result.game = game
method initialize*(this : ScaleAnimationSystem) =
  return
method execute*(this : ScaleAnimationSystem) =
  return
