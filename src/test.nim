import strfmt
import unittest, macros
import sdl2
import sdl2/image
import sdl2/ttf
import bosco/ecs
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
    group* : Group

proc newTestSystem*() : TestSystem = new(result)

method initialize*(this : TestSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[int(Resource)]))
  let e1 = this.group.getSingleEntity()
  echo "Entity = ", $e1

var
  sys : TestSystem
  world : World
  player : Entity
  cp : seq[string] = @[]

for x in Components: cp.add $x
world = newWorld(cp)

suite "TestExample":

  test "Create Player":
    player = world.createEntity("player");
    check player.name == "player"

  test "Add Components":
    discard player
    .addComponent(int(Position), PositionComponent())
    .addComponent(int(Movement), MovementComponent())
    .addComponent(int(Resource), ResourceComponent())
    check $player == "player(Position,Movement,Resource)"

  test "Create System":
    sys = newTestSystem()
    world.add(sys)

  test "Initialize":
    world.initialize()

  test "Execute":
    world.execute()
