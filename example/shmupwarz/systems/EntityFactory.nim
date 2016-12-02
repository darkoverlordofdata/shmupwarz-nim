const Tau : float64 = 2 * math.PI

type
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

var empty:Sprite


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
