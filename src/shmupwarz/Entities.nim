import math

const Tau : float64 = 2 * math.PI

type
  Layer* {.pure.} = enum
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

  Enemy* {.pure.} = enum
    Enemy1
    Enemy2
    Enemy3



proc createBackground*(this : Game) : Entity =
  return this.world.createEntity("background")
  .addPosition(0, 0)
  .addLayer(int(Layer.BACKGROUND))
  .addScale(2, 1)
  .addResource("res/images/BackdropBlackLittleSparkBlack.png", nil, true)


##
##  Player Entity
##
proc createPlayer*(this : Game) : Entity =
  return this.world.createEntity("player")
  .setPlayer(true)
  .addBounds(43)
  .addHealth(100, 100)
  .addVelocity(0, 0)
  .addLayer(int(Layer.PLAYER))
  .addPosition(float64(this.width/2), float64(this.height-80))
  .addResource("res/images/fighter.png", nil, false)

proc createBullet(this : Game, x : float64, y : float64) : Entity =
  return this.world.createEntity("bullet")
  .setBullet(true)
  .addPosition(x, y)
  .addVelocity(0, -800)
  .addBounds(5)
  .addExpires(1)
  .addLayer(int(Layer.BULLET))
  .addResource("res/images/bullet.png", nil, false)
  .addSoundEffect(int(Effect.PEW))

proc createParticle(this : Game, x : float64, y : float64) : Entity =
  let radians = math.random(1.0) * Tau
  let magnitude = float64(math.random(200))
  let velocityX = magnitude * math.cos(radians)
  let velocityY = magnitude * math.sin(radians)
  let scale = (math.random(1.0) * 0.5) + 0.5
  return this.world.createEntity("particle")
  .addPosition(x, y)
  .addVelocity(velocityX, velocityY)
  .addExpires(1)
  .addLayer(int(Layer.PARTICLE))
  .addScale(scale, scale)
  .addResource("res/images/particle.png", nil, false)

proc createExplosion(this : Game, x : float64, y : float64, scale : float64) : Entity =
  return this.world.createEntity("explosion")
  .addPosition(x, y)
  .addExpires(0.5)
  .addLayer(int(Layer.PARTICLE))
  .addScale(scale, scale)
  .addSoundEffect(if scale < 0.5 : int(Effect.SMALLASPLODE) else : int(Effect.ASPLODE))
  .addScaleAnimation(scale / 100, scale, -3, false, true)
  .addResource("res/images/explosion.png", nil, false)

proc createEnemy1(this : Game) : Entity =
  let x = float64(math.random(this.width))
  let y = float64(this.height/2 - 200)
  return this.world.createEntity("enemy1")
  .setEnemy(true)
  .addBounds(20)
  .addHealth(10, 10)
  .addVelocity(0, 40)
  .addLayer(int(Layer.ACTORS_1))
  .addPosition(x, y)
  .addResource("res/images/enemy1.png", nil, false)

proc createEnemy2(this : Game) : Entity =
  let x = float64(math.random(this.width))
  let y = float64(this.height/2 - 100)
  return this.world.createEntity("enemy2")
  .setEnemy(true)
  .addBounds(40)
  .addHealth(20, 20)
  .addVelocity(0, 30)
  .addLayer(int(Layer.ACTORS_2))
  .addPosition(x, y)
  .addResource("res/images/enemy2.png", nil, false)

proc createEnemy3(this : Game) : Entity =
  let x = float64(math.random(this.width))
  let y = float64(this.height/2 - 50)
  return this.world.createEntity("enemy3")
  .setEnemy(true)
  .addBounds(70)
  .addHealth(60, 60)
  .addVelocity(0, 20)
  .addLayer(int(Layer.ACTORS_3))
  .addPosition(x, y)
  .addResource("res/images/enemy3.png", nil, false)
