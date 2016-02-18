import strfmt
import unittest, macros
import sdl2
import sdl2/image
import sdl2/ttf
import bosco/ECS
import bosco/Sprite
import bosco/AbstractGame

type
  Components* = enum
    Position
    Movement
    Resource

  PositionComponent* = ref object of IComponent
    x* : float64
    y* : float64

  MovementComponent* = ref object of IComponent
    x* : float64
    y* : float64

  ResourceComponent* = ref object of IComponent
    path* : string

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
  this.group = this.world.getGroup(MatchAllOf(@[int(Resource)]))
  let e1 = this.group.getSingleEntity()
  echo "Entity = ", $e1

proc createPlayer(this : Game) : Entity =
  let player = this.world.createEntity("player")
  return player
  .addComponent(int(Position), PositionComponent())
  .addComponent(int(Movement), MovementComponent())
  .addComponent(int(Resource), ResourceComponent())


proc constructor*(this : Game) =
  this.name = "My Game"
  this.height = 480
  this.width = 320
  if this.init():
    var cp : seq[string] = @[]
    for x in Components: cp.add $x
    this.world = newWorld(cp)
    this.player = this.createPlayer()
    this.world.add(newTestSystem(this))
    this.world.initialize()

proc newGame*() : Game =
  new(result)
  result.constructor()

method update*(this : Game, delta : float64) =
  this.world.execute()

method cleanup(this : Game) =
  echo "Bye!"
  image.quit()

newGame().start()
