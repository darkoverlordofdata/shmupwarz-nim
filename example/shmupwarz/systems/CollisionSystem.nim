#
## CollisionSystem
##

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
        for i in countdown(5, 1):
          discard this.game.createParticle(bp.x, bp.y)
        discard bullet.setDestroy(true)
        health.health -= 1
        if health.health < 0:
          discard enemy.setDestroy(true)
          discard this.game.createExplosion(position.x, position.y, 0.5)
        break
