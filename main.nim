import NimMan/Game
import bosco/ECS
import strfmt
# var game: Game
# game.Init()
# game.Run()

type
  Components* = enum
    Position
    Movement
    Resource

  PositionComponent* = ref object of IComponent
    x : float64
    y : float64

  MovementComponent* = ref object of IComponent
    x : float64
    y : float64

  ResourceComponent* = ref object of IComponent
    path : string

var cp : seq[string] = @[]
for x in Components:
    cp.add $x

let world = newWorld(cp)
assert world.totalComponents == 3

let frodo = world.createEntity("Frodo")
assert world.count == 1
assert frodo.name == "Frodo"

discard frodo
.addComponent(int(Position), PositionComponent())
.addComponent(int(Movement), MovementComponent())
.addComponent(int(Resource), ResourceComponent())

assert $frodo == "Frodo(Position, Movement, Resource)"

let m = MatchAllOf(@[1, 2, 3])
echo "Matcher ", $m
