import events
import sdl2
import sdl2/image
import sdl2/ttf
import strfmt
import math
import random
import queues
import entitas
import bosco
import EntitasExtensions
const Tau : float64 = 2 * math.PI
var empty:Sprite


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

  ZOrder* {.pure.} = enum
    DEFAULT
    BACKGROUND
    TEXT
    LIVES
    MINES
    ACTORS_1
    ACTORS_2
    ACTORS_3
    PLAYER
    BULLET
    PARTICLE
    HUD

  Effect* {.pure.} = enum
    PEW
    ASPLODE
    SMALLASPLODE

  EnemyShip* {.pure.} = enum
    Enemy1
    Enemy2
    Enemy3

{.warning[LockLevel]:off.}
#import systems/EntityFactory
proc createBackground*(this : Game) : Entity =
  return this.world.createEntity("background")
  .addPosition(0, 0)
  .addLayer(int(ZOrder.BACKGROUND))
  .addScale(2, 1)
  .addResource("res/images/BackdropBlackLittleSparkBlack.png", empty, false)


##
##  Player Entity
##
proc createPlayer*(this : Game) : Entity =
  return this.world.createEntity("player")
  .setPlayer(true)
  .addBounds(43)
  .addHealth(100, 100)
  .addVelocity(0, 0)
  .addLayer(int(ZOrder.PLAYER))
  .addPosition(float64(this.width/2), float64(this.height-80))
  .addResource("res/images/fighter.png", empty, true)

proc createBullet(this : Game, x : float64, y : float64) : Entity =
  return this.world.createEntity("bullet")
  .setBullet(true)
  .addPosition(x, y)
  .addVelocity(0, -800)
  .addBounds(5)
  .addExpires(1)
  .addLayer(int(ZOrder.BULLET))
  .addResource("res/images/bullet.png", empty, true)
  .addSoundEffect(int(Effect.PEW))

proc createParticle(this : Game, x : float64, y : float64) : Entity =
  let radians = random(1.0) * Tau
  let magnitude = float64(random(200))
  let velocityX = magnitude * math.cos(radians)
  let velocityY = magnitude * math.sin(radians)
  let scale = (random(1.0) * 0.5) + 0.5
  return this.world.createEntity("particle")
  .addPosition(x, y)
  .addVelocity(velocityX, velocityY)
  .addExpires(1)
  .addLayer(int(ZOrder.PARTICLE))
  .addScale(scale, scale)
  .addResource("res/images/particle.png", empty, true)

proc createExplosion(this : Game, x : float64, y : float64, scale : float64) : Entity =
  return this.world.createEntity("explosion")
  .addPosition(x, y)
  .addExpires(0.5)
  .addLayer(int(ZOrder.PARTICLE))
  .addScale(scale, scale)
  .addSoundEffect(if scale < 0.5 : int(Effect.SMALLASPLODE) else : int(Effect.ASPLODE))
  .addScaleAnimation(scale / 100, scale, -3, false, true)
  .addResource("res/images/explosion.png", empty, true)

proc createEnemy1(this : Game) : Entity =
  let x = float64(random(this.width))
  let y = float64(this.height/2 - 200)
  return this.world.createEntity("enemy1")
  .setEnemy(true)
  .addBounds(20)
  .addHealth(10, 10)
  .addVelocity(0, 40)
  .addLayer(int(ZOrder.ACTORS_1))
  .addPosition(x, y)
  .addResource("res/images/enemy1.png", empty, true)

proc createEnemy2(this : Game) : Entity =
  let x = float64(random(this.width))
  let y = float64(this.height/2 - 100)
  return this.world.createEntity("enemy2")
  .setEnemy(true)
  .addBounds(40)
  .addHealth(20, 20)
  .addVelocity(0, 30)
  .addLayer(int(ZOrder.ACTORS_2))
  .addPosition(x, y)
  .addResource("res/images/enemy2.png", empty, true)

proc createEnemy3(this : Game) : Entity =
  let x = float64(random(this.width))
  let y = float64(this.height/2 - 50)
  return this.world.createEntity("enemy3")
  .setEnemy(true)
  .addBounds(70)
  .addHealth(60, 60)
  .addVelocity(0, 20)
  .addLayer(int(ZOrder.ACTORS_3))
  .addPosition(x, y)
  .addResource("res/images/enemy3.png", empty, true)

#include systems/MovementSystem
##
## Create new MovementSystem
##
proc newMovementSystem*(game : Game) : MovementSystem =
  new(result)
  result.game = game

##
## Select all entities with Position+Velocity
##
method initialize*(this : MovementSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.Position, Match.Velocity]))

##
## Calculate new position
##
method execute*(this : MovementSystem) =
  for entity in this.group.getEntities():
    entity.position.x += (entity.velocity.x * this.game.delta)
    entity.position.y += (entity.velocity.y * this.game.delta)

#include systems/CollisionSystem
##
## Create new CollisionSystem
##
proc newCollisionSystem*(game : Game) : CollisionSystem =
  new(result)
  result.game = game

proc collisionExists(this : CollisionSystem, e1: Entity, e2: Entity): bool =
  let p1 = e1.position
  let p2 = e2.position
  let b1 = e1.bounds
  let b2 = e2.bounds
  let a = p1.x - p2.x
  let b = p1.y - p2.y
  return math.sqrt(a * a + b * b) - (b1.radius) < (b2.radius)

method initialize*(this : CollisionSystem) =
  this.bullets = this.world.getGroup(Match.Bullet)
  this.enemies = this.world.getGroup(Match.Enemy)

method execute*(this : CollisionSystem) =
  if this.bullets.count == 0: return
  if this.enemies.count == 0: return

  for bullet in this.bullets.getEntities():
    for enemy in this.enemies.getEntities():
      if this.collisionExists(bullet, enemy):
        let bp = bullet.position
        let health = enemy.health
        let position = enemy.position

        discard this.game.createExplosion(bp.x, bp.y, 0.25)
        # for i in countdown(5, 1):
        #   discard this.game.createParticle(bp.x, bp.y)
        discard bullet.setDestroy(true)
        health.health -= 1
        if health.health < 0:
          discard enemy.setDestroy(true)
          discard this.game.createExplosion(position.x, position.y, 0.5)
        break

#include systems/EntitySpawningTimerSystem
##
## Create new EntitySpawningTimerSystem
##
proc newEntitySpawningTimerSystem(game : Game) : EntitySpawningTimerSystem =
  new(result)
  result.game = game
  result.timer1 = 2.0
  result.timer2 = 6.0
  result.timer3 = 12.0

proc spawnEnemy(this : EntitySpawningTimerSystem, t : float64, enemy : EnemyShip) : float64 =
  let delta = t - this.game.delta
  if delta < 0:
    case enemy
    of EnemyShip.Enemy1:
      discard this.game.createEnemy1()
      result = 2.0
    of EnemyShip.Enemy2:
      discard this.game.createEnemy2()
      result = 6.0
    of EnemyShip.Enemy3:
      discard this.game.createEnemy3()
      result = 12.0
    else: result = 0
  else: result = delta

method execute*(this : EntitySpawningTimerSystem) =
  this.timer1 = this.spawnEnemy(this.timer1, EnemyShip.Enemy1)
  this.timer2 = this.spawnEnemy(this.timer2, EnemyShip.Enemy2)
  this.timer3 = this.spawnEnemy(this.timer3, EnemyShip.Enemy3)


#include systems/ScaleAnimationSystem
##
## Create new ScaleAnimationSystem
##
proc newScaleAnimationSystem*(game : Game) : ScaleAnimationSystem =
  new(result)
  result.game = game

method initialize*(this : ScaleAnimationSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.ScaleAnimation, Match.Resource]))

method execute*(this : ScaleAnimationSystem) =
  for entity in this.group.getEntities():
    let scaleAnimation = entity.scaleAnimation
    let res = entity.resource
    let scale = res.sprite.scale

    if scaleAnimation.active:
      res.sprite.scale.x += scaleAnimation.speed * this.game.delta
      res.sprite.scale.y += scaleAnimation.speed * this.game.delta

      if scale.x > scaleAnimation.max:
        res.sprite.scale.x = scaleAnimation.max
        res.sprite.scale.y = scaleAnimation.max
        scaleAnimation.active = false
      elif scale.x < scaleAnimation.min:
        res.sprite.scale.x = scaleAnimation.min
        res.sprite.scale.y = scaleAnimation.min
        scaleAnimation.active = false

#include systems/ExpiringSystem
##
## Create new ExpiringSystem
##
proc newExpiringSystem*(game : Game) : ExpiringSystem =
  new(result)
  result.game = game

method initialize*(this : ExpiringSystem) =
  this.group = this.world.getGroup(Match.Expires)

method execute*(this : ExpiringSystem) =
  for entity in this.group.getEntities():
    entity.expires.delay -= this.game.delta
    if entity.expires.delay <= 0:
      discard entity.setDestroy(true)


#include systems/ViewManagerSystem
##
## Create new ViewManagerSystem
##
proc newViewManagerSystem*(game : Game) : ViewManagerSystem =
  new(result)
  result.game = game
##
## Trigger event when a Resource component is added to an entity
##
method initialize*(this : ViewManagerSystem) =
  this.world.getGroup(Match.Resource).onAddEntity
  .addHandler(proc(e : EventArgs) =

    ##
    ##  Load the resource, and add it to the rendering system
    ##
    var ordinal : int
    let entity = EntityArgs(e).entity
    let res = ResourceComponent(EntityArgs(e).component)
    res.sprite = SpriteFromFile(this.game.renderer, res.path)

    if entity.hasScale:
      res.sprite.scale.x = entity.scale.x
      res.sprite.scale.y = entity.scale.y

    if entity.hasLayer:
      ordinal = entity.layer.ordinal
      res.sprite.layer = ordinal

    res.sprite.centered = res.centered

    ##
    ##  Sort the sprite into the display by layer
    ##
    if this.game.eos == 0:
      this.game.sprites[0] = res.sprite
      this.game.eos = 1
    else:
      for i in 0..this.game.eos-1:
        if ordinal <= this.game.sprites[i].layer:
          this.game.sprites.insert(res.sprite, i)
          return
      this.game.sprites.add(res.sprite)

  )

#include systems/RenderPositionSystem
##
## Create new RenderPositionSystem
##
proc newRenderPositionSystem*(game : Game) : RenderPositionSystem =
  new(result)
  result.game = game

##
##  Select all entities with Position+Resource
##
method initialize*(this : RenderPositionSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.Resource, Match.Position]))

##
##  Set the sprite position on the screen
##
method execute*(this : RenderPositionSystem) =
  for entity in this.group.getEntities():
    let res = entity.resource
    let pos = entity.position
    res.sprite.x = (int)pos.x
    res.sprite.y = (int)pos.y


#include systems/HudRenderSystem
##
## Create new HudRenderSystem
##
const ACTIVE_ENTITIES : string  = "Active entities:         "
const TOTAL_RETAINED : string   = "Total reusable:          "
const TOTAL_REUSABLE : string   = "Total retained:          "
const FONT_PATH = "res/fonts/skranji.regular.ttf"
const FONT_SIZE = 16

proc newHudRenderSystem*(game : Game) : HudRenderSystem =
  new(result)
  result.game = game

proc createText(this : HudRenderSystem, x : int, y : int, text : string) : Sprite =
  this.fg = color(255, 255, 255, 255)
  this.bg = color(0, 0, 0, 0)
  let sprite = SpriteFromText(this.game.renderer, text, this.font, this.fg, this.bg)
  sprite.x = x
  sprite.y = y
  sprite.layer = int(Zorder.HUD)
  sprite.centered = false
  return sprite

proc setText(this : HudRenderSystem, sprite : Sprite, text : string) =
  discard sprite.setText(this.game.renderer, text, this.font, this.fg, this.bg)

method initialize*(this : HudRenderSystem) =
  this.font = ttf.openFont(FONT_PATH, FONT_SIZE)
  this.activeEntities = this.createText(0, 40, ACTIVE_ENTITIES & this.world.count.format("d"))
  this.totalRetained = this.createText(0, 60, TOTAL_RETAINED & this.world.reusableEntitiesCount.format("d"))
  this.totalReusable = this.createText(0, 80, TOTAL_REUSABLE & this.world.retainedEntitiesCount.format("d"))

  this.game.sprites.add(this.activeEntities)
  this.game.sprites.add(this.totalRetained)
  this.game.sprites.add(this.totalReusable)

method execute*(this : HudRenderSystem) =
  this.setText(this.activeEntities, ACTIVE_ENTITIES & this.world.count.format("d"))
  this.setText(this.totalRetained, TOTAL_RETAINED & this.world.reusableEntitiesCount.format("d"))
  this.setText(this.totalReusable, TOTAL_REUSABLE & this.world.retainedEntitiesCount.format("d"))

#include systems/DestroySystem
##
## Create new DestroySystem
##
proc newDestroySystem*(game : Game) : DestroySystem =
  new(result)
  result.game = game
##
## Trigger event when a Destroy component is added to an entity
##
method initialize*(this : DestroySystem) =
  this.group = this.world.getGroup(Match.Destroy)
  this.world.getGroup(Match.Destroy).onAddEntity
  .addHandler(proc(e : EventArgs) =
    let entity = EntityArgs(e).entity
    let sprite = entity.resource.sprite
    for i, s in this.game.sprites:
      if s.id == sprite.id:
        this.game.sprites.delete(i)
        entity.resource.sprite.texture.destroy()
        entity.resource.sprite = nil
        break
    this.world.destroyEntity(entity)

  )

#include systems/RemoveOffscreenShipsSystem
##
## Create new RemoveOffscreenShipsSystem
##
proc newRemoveOffscreenShipsSystem*(game : Game) : RemoveOffscreenShipsSystem =
  new(result)
  result.game = game

method initialize*(this : RemoveOffscreenShipsSystem) =
  this.group = this.world.getGroup(MatchAllOf(@[Match.Velocity, Match.Position, Match.Health, Match.Bounds]))

method execute*(this : RemoveOffscreenShipsSystem) =
  for entity in this.group.getEntities():
    if entity.position.y > float64(this.game.height) - entity.bounds.radius:
      if not entity.isPlayer:
        discard entity.setDestroy(true)


#include systems/PlayerInputSystem
proc newPlayerInputSystem*(game : Game) : PlayerInputSystem =
  new(result)
  result.game = game

proc setPlayer(this : PlayerInputSystem, player : Entity) =
  this.player = player

method execute*(this : PlayerInputSystem) =
  const FireRate = 0.1

  if this.player == nil: return
  if not this.player.hasPosition:return

  let pos = this.player.position
  if this.mouseDefined:
    if this.mouseDown or this.game.keys[(int)SDL_SCANCODE_Z] == 1:
      if this.timeToFire <= 0:
        discard this.game.createBullet(pos.x - 27, pos.y + 2)
        discard this.game.createBullet(pos.x + 27, pos.y + 2)
        this.timeToFire = FireRate

  if this.timeToFire > 0:
    this.timeToFire -= this.game.delta
    if this.timeToFire < 0:
      this.timeToFire = 0

proc moveTo(this : PlayerInputSystem, x: int, y: int) =

  if this.player == nil: return
  if not this.player.hasPosition: return
  let pos = this.player.position
  pos.x = float64(x)
  pos.y = float64(y)

proc onMouseEvent(this : PlayerInputSystem, e : EventType, x : int, y : int) =
  this.mouseDefined = true
  case e
  of MouseMotion:
    this.moveTo(x, y)
  of MouseButtonDown:
    this.moveTo(x, y)
    this.mouseDown = true
  of MouseButtonUp:
    this.mouseDown = false
  else : return #this.mouseDefined = false

#include systems/GameMethods
##
## new Game constructor
##
proc newGame*(name : string, width : cint, height : cint) : Game =
  new(result)
  result.name = name
  result.height = height
  result.width = width
  result.running = true
  result.sprites = newSeqOfCap[Sprite](1000) #@[]
##
##  Start the game
##
proc play*(this : Game) =
  this.start()
##
##  Callback to initilize the game
##
method initialize*(this : Game) =
  var cp : seq[string] = newSeqOfCap[string](100) #@[]
  for x in Component: cp.add $x
  this.world = newWorld(cp)

  this.world.add(newMovementSystem(this))
  this.input = newPlayerInputSystem(this)
  this.world.add(this.input)
  this.world.add(newCollisionSystem(this))
  this.world.add(newExpiringSystem(this))
  this.world.add(newEntitySpawningTimerSystem(this))
  this.world.add(newScaleAnimationSystem(this))
  this.world.add(newViewManagerSystem(this))
  this.world.add(newRenderPositionSystem(this))
  this.world.add(newHudRenderSystem(this))
  this.world.add(newRemoveOffscreenShipsSystem(this))
  this.world.add(newDestroySystem(this))
  this.world.initialize()
  discard this.createBackground()
  this.player = this.createPlayer()
  this.input.setPlayer this.player


method event*(this : Game, evt : Event)  =
  ## Abstract method: receive SDL events
  if evt.kind == MouseMotion or
      evt.kind == MouseButtonDown or
      evt.kind == MouseButtonUp:
    var x:cint
    var y:cint
    getMouseState(addr(x), addr(y))
    this.input.onMouseEvent(evt.kind, x, y)
##
##  Callback to update the game
##
method update*(this : Game, delta : float64) =
  this.world.execute()

##
##  Callback to teardown the game
##
method cleanup(this : Game) =
  echo "Bye!"
