import gamestate

type
  DestroySystem* = ref object of System
    ## Destroy entities
    game* : Game
    group* : Group
##
## Create new DestroySystem
##
proc newDestroySystem*(game : Game) : DestroySystem =
  new(result)
  result.game = game
##
## Trigger event when a Destroy component is added to an entity
##
method initialize*(this : DestroySystem) =
  this.group = this.world.getGroup(Match.Destroy)
  this.world.getGroup(Match.Destroy).onAddEntity
  .addHandler(proc(e : EventArgs) =
    let entity = EntityArgs(e).entity
    let sprite = entity.resource.sprite
    for i, s in this.game.sprites:
      if s.id == sprite.id:
        this.game.sprites.delete(i)
        entity.resource.sprite.texture.destroy()
        entity.resource.sprite = nil
        break
    this.world.destroyEntity(entity)

  )
