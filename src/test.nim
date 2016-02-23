import unittest, macros
import bosco/ecs
import bosco/Sprite
import bosco/AbstractGame
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


type
  # Components* = enum
  #   Position
  #   Movement
  #   Resource
  #
  # PositionComponent* = ref object of IComponent
  #   x* : float64
  #   y* : float64
  #
  # MovementComponent* = ref object of IComponent
  #   x* : float64
  #   y* : float64
  #
  # ResourceComponent* = ref object of IComponent
  #   path* : string

  TestSystem* = ref object of System
    group* : Group

proc newTestSystem*() : TestSystem = new(result)

method initialize*(this : TestSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[int(Component.Resource)]))
  let e1 = this.group.getSingleEntity()
  echo "Entity = ", $e1

var
  sys : TestSystem
  world : World
  player : Entity
  cp : seq[string] = @[]

for x in Component: cp.add $x
world = newWorld(cp)

suite "TestExample":

  test "Create Player":
    player = world.createEntity("player");
    check player.name == "player"

  test "Add Components":
    discard player
    .addComponent(int(Component.Position), PositionComponent())
    .addComponent(int(Component.Velocity), VelocityComponent())
    .addComponent(int(Component.Resource), ResourceComponent())
    check $player == "player(Position,Resource,Velocity)"

  test "Match Components":
    # let match = Match.Enemy
    let match = MatchAllOf(@[int(Component.Enemy)])
    check $match == "AllOf(Enemy)"
    check $match == $Match.Enemy
    echo "$Match.Enemy ", $Match.Enemy


  test "Create System":
    sys = newTestSystem()
    world.add(sys)

  test "Initialize":
    world.initialize()

  test "Execute":
    world.execute()
