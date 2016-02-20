import events
import bosco/ecs          # Entity/Component/System Framework
import bosco/Sprite       # GUI Sprite object
import bosco/AbstractGame # Base game
import gen/ComponentEx    # Generated Components
import gen/MatchEx        # Generated Matchers
import gen/WorldEx        # Generated World Extensions
import gen/EntityEx       # Generated Entity Extensions

type

  ViewManagerSystem* = ref object of System
    game* : Game
    group* : Group

  RenderPositionSystem* = ref object of System
    game* : Game
    group* : Group

  Game* = ref object of AbstractGame
    world* : World
    player* : Entity

include "Systems"
include "Entities"

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
  this.world.add(newViewManagerSystem(this))
  #this.world.add(newRenderPositionSystem(this))
  this.world.initialize()
  this.player = this.createPlayer()
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
