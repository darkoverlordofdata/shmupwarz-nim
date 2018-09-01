import gamestate

type
  RemoveOffscreenShipsSystem* = ref object of System
    ## Remove enemies when they leave the screen
    game* : Game
    group* : Group

##
## Create new RemoveOffscreenShipsSystem
##
proc newRemoveOffscreenShipsSystem*(game : Game) : RemoveOffscreenShipsSystem =
  new(result)
  result.game = game

method initialize*(this : RemoveOffscreenShipsSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.Velocity, Match.Position, Match.Health, Match.Bounds]))

method execute*(this : RemoveOffscreenShipsSystem) =
  for entity in this.group.getEntities():
    if entity.position.y > float64(this.game.height) - entity.bounds.radius:
      if not entity.isPlayer:
        discard entity.setDestroy(true)

