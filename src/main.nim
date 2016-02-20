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

type

  TestSystem* = ref object of System
    game* : Game
    group* : Group

  Game* = ref object of AbstractGame
    world* : World
    player* : Entity

proc newTestSystem*(game : Game) : TestSystem =
  new(result)
  result.game = game

method initialize*(this : TestSystem) =
  this.group = this.world.getGroup(Match.Resource)
  let e1 = this.group.getSingleEntity()
  echo "Entity = ", $e1

proc createPlayer(this : Game) : Entity =
  return this.world.createEntity("player")
  .addPosition(0, 0)
  .addVelocity(0, 0)
  .addResource("res/images/fighter.png")

proc constructor*(this : Game, name : string, width : cint, height : cint) =
  this.name = name
  this.height = height
  this.width = width
  this.running = true

method initialize*(this : Game) =
  var cp : seq[string] = @[]
  for x in Component: cp.add $x
  this.world = newWorld(cp)
  this.player = this.createPlayer()
  this.world.add(newTestSystem(this))
  this.world.initialize()


proc newGame*(name : string, width : cint, height : cint) : Game =
  new(result)
  result.constructor(name, width, height)

method update*(this : Game, delta : float64) =
  this.world.execute()

method cleanup(this : Game) =
  echo "Bye!"
  image.quit()

newGame("My Game", 320, 480).start()
