import bosco/ecs
import bosco/Sprite
import bosco/AbstractGame
import strfmt
import unittest, macros
import sdl2
import sdl2/image
import sdl2/ttf

# import ../NimMan/Game
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

var
  world : World
  frodo : Entity
  matcher : Matcher
  group : Group

suite "Test Bosco":
  setup:
    var cp : seq[string] = @[]
    for x in Components:
        cp.add $x

  test "Create World":
    world = newWorld(cp)
    check world.totalComponents == 3

  test "Create Entity":
    frodo = world.createEntity("Frodo")
    check world.count == 1
    check frodo.name == "Frodo"

  test "Add Components":
    discard frodo
    .addComponent(int(Position), PositionComponent())
    .addComponent(int(Movement), MovementComponent())
    .addComponent(int(Resource), ResourceComponent())

    check $frodo == "Frodo(Position, Movement, Resource)"

  test "Create Matcher":
    matcher = MatchAllOf(@[1, 2, 3])
    check $matcher == "AllOf(Position,Movement,Resource)"

  test "Create Group":
    group = world.getGroup(matcher)
    check $group == "Group(Position,Movement,Resource)"

  test "Create Sprite":
    let window = createWindow("test", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 320, 480, SDL_WINDOW_SHOWN)
    if window == nil:
        echo "Error creating SDL_Window: ", getError()
        quit 1

    let renderer = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync)
    if renderer == nil:
        echo "Error creating SDL_Renderer: ", getError()
        quit 1

    let sprite = SpriteFromFile(renderer, "res/images/fighter.png")
    check sprite.height == 286 and sprite.width == 232
