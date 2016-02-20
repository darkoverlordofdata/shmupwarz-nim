import queues
import bosco/ECS
import bosco/Sprite
import ComponentEx
const POOL_SIZE : int = 128

##
## Component Pool
##
type PoolObj* = ref object of RootObj
  boundsComponent* : Queue[BoundsComponent]
  bulletComponent* : BulletComponent
  colorAnimationComponent* : Queue[ColorAnimationComponent]
  destroyComponent* : DestroyComponent
  enemyComponent* : EnemyComponent
  expiresComponent* : Queue[ExpiresComponent]
  firingComponent* : FiringComponent
  healthComponent* : Queue[HealthComponent]
  layerComponent* : Queue[LayerComponent]
  lifeComponent* : Queue[LifeComponent]
  mineComponent* : MineComponent
  mouseComponent* : Queue[MouseComponent]
  playerComponent* : PlayerComponent
  positionComponent* : Queue[PositionComponent]
  resourceComponent* : Queue[ResourceComponent]
  scaleAnimationComponent* : Queue[ScaleAnimationComponent]
  scaleComponent* : Queue[ScaleComponent]
  scoreComponent* : Queue[ScoreComponent]
  soundEffectComponent* : Queue[SoundEffectComponent]
  velocityComponent* : Queue[VelocityComponent]

##
## constructor for a new Component Pool
##
proc newPoolObj() : PoolObj =
  new(result)

  result.boundsComponent = initQueue[BoundsComponent]()
  for i in 1..POOL_SIZE:
    result.boundsComponent.add(BoundsComponent())

  result.bulletComponent = BulletComponent()

  result.colorAnimationComponent = initQueue[ColorAnimationComponent]()
  for i in 1..POOL_SIZE:
    result.colorAnimationComponent.add(ColorAnimationComponent())

  result.destroyComponent = DestroyComponent()

  result.enemyComponent = EnemyComponent()

  result.expiresComponent = initQueue[ExpiresComponent]()
  for i in 1..POOL_SIZE:
    result.expiresComponent.add(ExpiresComponent())

  result.firingComponent = FiringComponent()

  result.healthComponent = initQueue[HealthComponent]()
  for i in 1..POOL_SIZE:
    result.healthComponent.add(HealthComponent())

  result.layerComponent = initQueue[LayerComponent]()
  for i in 1..POOL_SIZE:
    result.layerComponent.add(LayerComponent())

  result.lifeComponent = initQueue[LifeComponent]()
  for i in 1..POOL_SIZE:
    result.lifeComponent.add(LifeComponent())

  result.mineComponent = MineComponent()

  result.mouseComponent = initQueue[MouseComponent]()
  for i in 1..POOL_SIZE:
    result.mouseComponent.add(MouseComponent())

  result.playerComponent = PlayerComponent()

  result.positionComponent = initQueue[PositionComponent]()
  for i in 1..POOL_SIZE:
    result.positionComponent.add(PositionComponent())

  result.resourceComponent = initQueue[ResourceComponent]()
  for i in 1..POOL_SIZE:
    result.resourceComponent.add(ResourceComponent())

  result.scaleAnimationComponent = initQueue[ScaleAnimationComponent]()
  for i in 1..POOL_SIZE:
    result.scaleAnimationComponent.add(ScaleAnimationComponent())

  result.scaleComponent = initQueue[ScaleComponent]()
  for i in 1..POOL_SIZE:
    result.scaleComponent.add(ScaleComponent())

  result.scoreComponent = initQueue[ScoreComponent]()
  for i in 1..POOL_SIZE:
    result.scoreComponent.add(ScoreComponent())

  result.soundEffectComponent = initQueue[SoundEffectComponent]()
  for i in 1..POOL_SIZE:
    result.soundEffectComponent.add(SoundEffectComponent())

  result.velocityComponent = initQueue[VelocityComponent]()
  for i in 1..POOL_SIZE:
    result.velocityComponent.add(VelocityComponent())

var Pool* = PoolObj()
