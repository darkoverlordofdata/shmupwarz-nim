import strfmt
import unittest, macros
import sdl2
import sdl2/image
import sdl2/ttf
import bosco/ECS
import bosco/Sprite
import bosco/AbstractGame
import ComponentEx
import MatchEx
import WorldEx
import EntityEx
import events

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

proc createPlayer*(this : Game) : Entity =
  return this.world.createEntity("player")
  .setPlayer(true)
  .addPosition(0, 0)
  .addVelocity(0, 0)
  .addResource("res/images/fighter.png", nil)

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
  image.quit()

newGame("My Game", 320, 480).start()
