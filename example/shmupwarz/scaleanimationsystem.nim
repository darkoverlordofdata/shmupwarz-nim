import gamestate

type
  ScaleAnimationSystem* = ref object of System
    ## Tweening for explosions
    game* : Game
    group* : Group

##
## Create new ScaleAnimationSystem
##
proc newScaleAnimationSystem*(game : Game) : ScaleAnimationSystem =
  new(result)
  result.game = game

method initialize*(this : ScaleAnimationSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.ScaleAnimation, Match.Resource]))

method execute*(this : ScaleAnimationSystem) =
  for entity in this.group.getEntities():
    let scaleAnimation = entity.scaleAnimation
    let res = entity.resource
    let scale = res.sprite.scale

    if scaleAnimation.active:
      res.sprite.scale.x += scaleAnimation.speed * this.game.delta
      res.sprite.scale.y += scaleAnimation.speed * this.game.delta

      if scale.x > scaleAnimation.max:
        res.sprite.scale.x = scaleAnimation.max
        res.sprite.scale.y = scaleAnimation.max
        scaleAnimation.active = false
      elif scale.x < scaleAnimation.min:
        res.sprite.scale.x = scaleAnimation.min
        res.sprite.scale.y = scaleAnimation.min
        scaleAnimation.active = false

