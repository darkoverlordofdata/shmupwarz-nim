##
## DestroySystem
##
proc newDestroySystem*(game : Game) : DestroySystem =
  new(result)
  result.game = game

method initialize*(this : DestroySystem) =
  this.group = this.world.getGroup(Match.Destroy)
  this.world.getGroup(Match.Destroy).onAddEntity
  .addHandler(proc(e : EventArgs) =
    var sprites = this.game.sprites
    var entity = EntityArgs(e).entity
    let sprite = entity.resource.sprite
    for i in 0..sprites.len-1:
      var s = sprites[i]
      if s.id == sprite.id:
        sprites.delete(i)
        break
    entity.resource.sprite = nil
    this.world.destroyEntity(entity)

  )
