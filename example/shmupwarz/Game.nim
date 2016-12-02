import events
import sdl2
import sdl2/image
import sdl2/ttf
import strfmt
import math
import random
import queues
import entitas
import Sprite
import AbstractGame
import EntitasExtensions

type
  Game* = ref object of AbstractGame
    world* : World
    input* : PlayerInputSystem
    player*: Entity

  PlayerInputSystem* = ref object of System
    game* : Game
    group* : Group
    player : Entity
    mouseDown : bool
    mouseDefined : bool
    timeToFire : float64

  MovementSystem* = ref object of System
    game* : Game
    group* : Group

  CollisionSystem* = ref object of System
    game* : Game
    bullets* : Group
    enemies*: Group

  EntitySpawningTimerSystem* = ref object of System
    game* : Game
    timer1* : float64
    timer2* : float64
    timer3* : float64

  ScaleAnimationSystem* = ref object of System
    game* : Game
    group* : Group

  ExpiringSystem* = ref object of System
    game* : Game
    group* : Group

  ViewManagerSystem* = ref object of System
    game* : Game
    group* : Group

  RenderPositionSystem* = ref object of System
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

include systems/EntityFactory
include systems/MovementSystem
include systems/CollisionSystem
include systems/EntitySpawningTimerSystem
include systems/ScaleAnimationSystem
include systems/ExpiringSystem
include systems/ViewManagerSystem
include systems/RenderPositionSystem
include systems/HudRenderSystem
include systems/DestroySystem
include systems/RemoveOffscreenShipsSystem
include systems/PlayerInputSystem
include systems/GameMethods
