##
## EntitySpawningTimerSystem
##
proc newEntitySpawningTimerSystem(game : Game) : EntitySpawningTimerSystem =
  new(result)
  result.game = game
  result.timer1 = 2.0
  result.timer2 = 6.0
  result.timer3 = 12.0

proc spawnEnemy(this : EntitySpawningTimerSystem, t : float64, enemy : Enemy) : float64 =
  let delta = t - this.game.delta
  if delta < 0:
    case enemy
    of Enemy.Enemy1:
      discard this.game.createEnemy1()
      result = 2.0
    of Enemy.Enemy2:
      discard this.game.createEnemy2()
      result = 6.0
    of Enemy.Enemy3:
      discard this.game.createEnemy3()
      result = 12.0
    else: result = 0
  else: result = delta

method execute*(this : EntitySpawningTimerSystem) =
  this.timer1 = this.spawnEnemy(this.timer1, Enemy.Enemy1)
  this.timer2 = this.spawnEnemy(this.timer2, Enemy.Enemy2)
  this.timer3 = this.spawnEnemy(this.timer3, Enemy.Enemy3)
