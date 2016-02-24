import events
import sdl2
import sdl2/image
import sdl2/ttf
import strfmt
import math

import bosco/ecs          # Entity/Component/System Framework
import bosco/Sprite       # GUI Sprite object
import bosco/AbstractGame # Base game
import gen/ComponentEx    # Generated Component Extensions
import gen/MatchEx        # Generated Match Extensions
import gen/WorldEx        # Generated World Extensions
import gen/EntityEx       # Generated Entity Extensions

const Tau : float64 = 2 * math.PI

type
  Game* = ref object of AbstractGame
    world* : World
    input* : PlayerInputSystem
    player*: Entity

  PlayerInputSystem* = ref object of System
    game* : Game
    group* : Group
    player : Entity
    mouseDown : bool
    mouseDefined : bool
    timeToFire : float64

include Entities
include systems/MovementSystem
include systems/CollisionSystem
include systems/EntitySpawningTimerSystem
include systems/ScaleAnimationSystem
include systems/ExpiringSystem
include systems/ViewManagerSystem
include systems/RenderPositionSystem
include systems/HudRenderSystem
include systems/DestroySystem
include systems/RemoveOffscreenShipsSystem
include systems/PlayerInputSystem
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
  this.input = newPlayerInputSystem(this)
  this.world.add(this.input)
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
  this.player = this.createPlayer()
  this.input.setPlayer this.player


method event*(this : Game, evt : Event)  =
  ## Abstract method: receive SDL events
  if evt.kind == MouseMotion or
      evt.kind == MouseButtonDown or
      evt.kind == MouseButtonUp:
    var x:cint
    var y:cint
    getMouseState(addr(x), addr(y))
    this.input.onMouseEvent(evt.kind, x, y)
##
##  Callback to update the game
##
method update*(this : Game, delta : float64) =
  try:
    this.world.execute()
  except:
    let e = getCurrentException()
    echo "Error!"
##
##  Callback to teardown the game
##
method cleanup(this : Game) =
  echo "Bye!"
