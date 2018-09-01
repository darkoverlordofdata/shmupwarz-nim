import gamestate

type
  ViewManagerSystem* = ref object of System
    ## Manage texture display
    game* : Game
    group* : Group

##
## Create new ViewManagerSystem
##
proc newViewManagerSystem*(game : Game) : ViewManagerSystem =
  new(result)
  result.game = game

##
## Trigger event when a Resource component is added to an entity
##
method initialize*(this : ViewManagerSystem) =
  this.world.getGroup(Match.Resource).onAddEntity
  .addHandler(proc(e : EventArgs) =

    ##
    ##  Load the resource, and add it to the rendering system
    ##
    var ordinal : int
    let entity = EntityArgs(e).entity
    let res = ResourceComponent(EntityArgs(e).component)
    res.sprite = SpriteFromFile(this.game.renderer, res.path)

    if entity.hasScale:
      res.sprite.scale.x = entity.scale.x
      res.sprite.scale.y = entity.scale.y

    if entity.hasLayer:
      ordinal = entity.layer.ordinal
      res.sprite.layer = ordinal

    res.sprite.centered = res.centered

    ##
    ##  Sort the sprite into the display by layer
    ##
    if this.game.eos == 0:
      this.game.sprites[0] = res.sprite
      this.game.eos = 1
    else:
      for i in 0..this.game.eos-1:
        if ordinal <= this.game.sprites[i].layer:
          this.game.sprites.insert(res.sprite, i)
          return
      this.game.sprites.add(res.sprite)

  )

