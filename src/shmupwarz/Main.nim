
##
## new Game constructor
##
proc newGame*(name : string, width : cint, height : cint) : Game =
  new(result)
  result.name = name
  result.height = height
  result.width = width
  result.running = true
  result.sprites = @[]
##
##  Start the game
##
proc play*(this : Game) =
  this.start()
##
##  Callback to initilize the game
##
method initialize*(this : Game) =
  var cp : seq[string] = @[]
  for x in Component: cp.add $x
  this.world = newWorld(cp)

  this.world.add(newMovementSystem(this))
  this.player = newPlayerInputSystem(this)
  this.world.add(this.player)
  this.world.add(newCollisionSystem(this))
  this.world.add(newExpiringSystem(this))
  this.world.add(newEntitySpawningTimerSystem(this))
  this.world.add(newScaleAnimationSystem(this))
  this.world.add(newViewManagerSystem(this))
  this.world.add(newRenderPositionSystem(this))
  this.world.add(newHudRenderSystem(this))
  this.world.add(newRemoveOffscreenShipsSystem(this))
  this.world.add(newDestroySystem(this))

  this.world.initialize()
  discard this.createBackground()
  this.player.setPlayer this.createPlayer()


method event*(this : Game, evt : Event)  =
  ## Abstract method: receive SDL events
  if evt.kind == MouseMotion or
      evt.kind == MouseButtonDown or
      evt.kind == MouseButtonUp:
    var x:cint
    var y:cint
    getMouseState(addr(x), addr(y))
    this.player.onMouseEvent(evt.kind, x, y)
##
##  Callback to update the game
##
method update*(this : Game, delta : float64) =
  this.world.execute()
##
##  Callback to teardown the game
##
method cleanup(this : Game) =
  echo "Bye!"
