proc newViewManagerSystem*(game : Game) : ViewManagerSystem =
  new(result)
  result.game = game

method initialize*(this : ViewManagerSystem) =
  this.world.getGroup(Match.Resource).onAddEntity
  .addHandler(proc(e : EventArgs) =
    var res = ResourceComponent(EntityArgs(e).component)
    res.sprite = SpriteFromFile(this.game.renderer, res.path)
    this.game.sprites.add(res.sprite)
  )

proc newRenderPositionSystem*(game : Game) : RenderPositionSystem =
  new(result)
  result.game = game

method initialize*(this : RenderPositionSystem) =
  this.group = this.world.getGroup(Match.Position)

method execute*(this : RenderPositionSystem) =
  for entity in this.group.getEntities():
    if entity.hasResource():
      echo $entity
