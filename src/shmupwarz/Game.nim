import events
import sdl2
import sdl2/image
import sdl2/ttf
import strfmt

import bosco/ecs          # Entity/Component/System Framework
import bosco/Sprite       # GUI Sprite object
import bosco/AbstractGame # Base game
import gen/ComponentEx    # Generated Component Extensions
import gen/MatchEx        # Generated Match Extensions
import gen/WorldEx        # Generated World Extensions
import gen/EntityEx       # Generated Entity Extensions

const FireRate = 0.1

type
  ViewManagerSystem* = ref object of System
    game* : Game
    group* : Group

  RenderPositionSystem* = ref object of System
    game* : Game
    group* : Group

  MovementSystem* = ref object of System
    game* : Game
    group* : Group

  EntitySpawningTimerSystem* = ref object of System
    game* : Game
    timer1* : float64
    timer2* : float64
    timer3* : float64

  ExpiringSystem* = ref object of System
    game* : Game
    group* : Group

  PlayerInputSystem* = ref object of System
    game* : Game
    group* : Group
    player : Entity
    mouseDown : bool
    mouseDefined : bool
    timeToFire : float64

  CollisionSystem* = ref object of System
    game* : Game
    group* : Group

  ScaleAnimationSystem* = ref object of System
    game* : Game
    group* : Group

  HudRenderSystem* = ref object of System
    game* : Game
    group* : Group
    font : FontPtr
    fg : Color
    bg : Color
    activeEntities : Sprite
    totalRetained : Sprite
    totalReusable : Sprite

  DestroySystem* = ref object of System
    game* : Game
    group* : Group

  RemoveOffscreenShipsSystem* = ref object of System
    game* : Game
    group* : Group

  Game* = ref object of AbstractGame
    world* : World
    player* : PlayerInputSystem

include "Entities"
include "systems/MovementSystem"
include "systems/PlayerInputSystem"
include "systems/CollisionSystem"
include "systems/EntitySpawningTimerSystem"
include "systems/ScaleAnimationSystem"
include "systems/ExpiringSystem"
include "systems/ViewManagerSystem"
include "systems/RenderPositionSystem"
include "systems/HudRenderSystem"
include "systems/DestroySystem"
include "systems/RemoveOffscreenShipsSystem"
include "Main.nim"
