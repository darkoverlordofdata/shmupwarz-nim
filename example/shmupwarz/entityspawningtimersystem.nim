import gamestate

type
  EntitySpawningTimerSystem* = ref object of System
    ## Generate new enemies
    game* : Game
    timer1* : float64
    timer2* : float64
    timer3* : float64

##
## Create new EntitySpawningTimerSystem
##
proc newEntitySpawningTimerSystem*(game : Game) : EntitySpawningTimerSystem =
  new(result)
  result.game = game
  result.timer1 = 2.0
  result.timer2 = 6.0
  result.timer3 = 12.0

proc spawnEnemy*(this : EntitySpawningTimerSystem, t : float64, enemy : EnemyShip) : float64 =
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
    # else: result = 0
  else: result = delta

method execute*(this : EntitySpawningTimerSystem) =
  this.timer1 = this.spawnEnemy(this.timer1, EnemyShip.Enemy1)
  this.timer2 = this.spawnEnemy(this.timer2, EnemyShip.Enemy2)
  this.timer3 = this.spawnEnemy(this.timer3, EnemyShip.Enemy3)

