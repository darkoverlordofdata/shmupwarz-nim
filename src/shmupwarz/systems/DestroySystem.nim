##
## DestroySystem
##
type DestroySystem* = ref object of System
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
    var entity = EntityArgs(e).entity
    let sprite = entity.resource.sprite
    for i in 0..this.game.sprites.len-1:
      var s = this.game.sprites[i]
      if s.id == sprite.id:
        this.game.sprites.delete(i)
        entity.resource.sprite = nil
        break
    this.world.destroyEntity(entity)

  )
