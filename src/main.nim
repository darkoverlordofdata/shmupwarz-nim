import events
import bosco/ECS          # Entity/Component/System Framework
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

proc constructor*(this : Game, name : string, width : cint, height : cint) =
  this.name = name
  this.height = height
  this.width = width
  this.running = true

method initialize*(this : Game) =
  var cp : seq[string] = @[]
  for x in Component: cp.add $x
  this.world = newWorld(cp)
  this.world.add(newViewManagerSystem(this))
  #this.world.add(newRenderPositionSystem(this))
  this.world.initialize()
  this.player = this.createPlayer()


proc newGame*(name : string, width : cint, height : cint) : Game =
  new(result)
  result.sprites = @[]
  result.constructor(name, width, height)

method update*(this : Game, delta : float64) =
  this.world.execute()

method cleanup(this : Game) =
  echo "Bye!"

newGame("My Game", 320, 480).start()
