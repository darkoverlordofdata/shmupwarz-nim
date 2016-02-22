##
## Entitas Generated Entity Extensions for shmupwarz
##
## ** do not edit this file **
##
import queues
import bosco/ecs
import bosco/Sprite
import ComponentEx

##
## Extend Entity
##


proc clearBoundsComponent*(this : Entity) =
  Pool.boundsComponent = initQueue[BoundsComponent]()

## @type {shmupwarz.BoundsComponent} 
proc bounds*(this : Entity) : BoundsComponent =
  (BoundsComponent)this.getComponent(int(Component.Bounds))

## @type {boolean} 
proc hasBounds*(this : Entity) : bool =
  this.hasComponent(int(Component.Bounds))

##
## @param {float64} radius
## @returns {bosco.Entity}
##
proc addBounds*(this : Entity, radius:float64) : Entity =
  var component = if Pool.boundsComponent.len > 0 : Pool.boundsComponent.dequeue() else: BoundsComponent()
  component.radius = radius
  discard this.addComponent(int(Component.Bounds), component)
  return this

##
## @param {float64} radius
## @returns {bosco.Entity}
##
proc replaceBounds*(this : Entity, radius:float64) : Entity =
  var previousComponent = if this.hasBounds : this.bounds else: nil
  var component = if Pool.boundsComponent.len > 0 : Pool.boundsComponent.dequeue() else: BoundsComponent()
  component.radius = radius
  discard this.replaceComponent(int(Component.Bounds), component)
  if previousComponent != nil:
    Pool.boundsComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeBounds*(this : Entity) : Entity =
  var component = this.bounds
  discard this.removeComponent(int(Component.Bounds))
  Pool.boundsComponent.enqueue(component)
  return this

## @type {boolean} 
proc isBullet*(this : Entity) : bool =
  this.hasComponent(int(Component.Bullet))
proc `isBullet=`*(this : Entity, value : bool) =
  if value != this.isBullet:
    if value:
      discard this.addComponent(int(Component.Bullet), Pool.bulletComponent)
    else:
      discard this.removeComponent(int(Component.Bullet))

##
## @param {boolean} value
## @returns {bosco.Entity}
##
proc setBullet*(this : Entity, value : bool) : Entity =
  this.isBullet = value
  return this


proc clearColorAnimationComponent*(this : Entity) =
  Pool.colorAnimationComponent = initQueue[ColorAnimationComponent]()

## @type {shmupwarz.ColorAnimationComponent} 
proc colorAnimation*(this : Entity) : ColorAnimationComponent =
  (ColorAnimationComponent)this.getComponent(int(Component.ColorAnimation))

## @type {boolean} 
proc hasColorAnimation*(this : Entity) : bool =
  this.hasComponent(int(Component.ColorAnimation))

##
## @param {float64} redMin
## @param {float64} redMax
## @param {float64} redSpeed
## @param {float64} greenMin
## @param {float64} greenMax
## @param {float64} greenSpeed
## @param {float64} blueMin
## @param {float64} blueMax
## @param {float64} blueSpeed
## @param {float64} alphaMin
## @param {float64} alphaMax
## @param {float64} alphaSpeed
## @param {bool} redAnimate
## @param {bool} greenAnimate
## @param {bool} blueAnimate
## @param {bool} alphaAnimate
## @param {bool} repeat
## @returns {bosco.Entity}
##
proc addColorAnimation*(this : Entity, redMin:float64, redMax:float64, redSpeed:float64, greenMin:float64, greenMax:float64, greenSpeed:float64, blueMin:float64, blueMax:float64, blueSpeed:float64, alphaMin:float64, alphaMax:float64, alphaSpeed:float64, redAnimate:bool, greenAnimate:bool, blueAnimate:bool, alphaAnimate:bool, repeat:bool) : Entity =
  var component = if Pool.colorAnimationComponent.len > 0 : Pool.colorAnimationComponent.dequeue() else: ColorAnimationComponent()
  component.redMin = redMin
  component.redMax = redMax
  component.redSpeed = redSpeed
  component.greenMin = greenMin
  component.greenMax = greenMax
  component.greenSpeed = greenSpeed
  component.blueMin = blueMin
  component.blueMax = blueMax
  component.blueSpeed = blueSpeed
  component.alphaMin = alphaMin
  component.alphaMax = alphaMax
  component.alphaSpeed = alphaSpeed
  component.redAnimate = redAnimate
  component.greenAnimate = greenAnimate
  component.blueAnimate = blueAnimate
  component.alphaAnimate = alphaAnimate
  component.repeat = repeat
  discard this.addComponent(int(Component.ColorAnimation), component)
  return this

##
## @param {float64} redMin
## @param {float64} redMax
## @param {float64} redSpeed
## @param {float64} greenMin
## @param {float64} greenMax
## @param {float64} greenSpeed
## @param {float64} blueMin
## @param {float64} blueMax
## @param {float64} blueSpeed
## @param {float64} alphaMin
## @param {float64} alphaMax
## @param {float64} alphaSpeed
## @param {bool} redAnimate
## @param {bool} greenAnimate
## @param {bool} blueAnimate
## @param {bool} alphaAnimate
## @param {bool} repeat
## @returns {bosco.Entity}
##
proc replaceColorAnimation*(this : Entity, redMin:float64, redMax:float64, redSpeed:float64, greenMin:float64, greenMax:float64, greenSpeed:float64, blueMin:float64, blueMax:float64, blueSpeed:float64, alphaMin:float64, alphaMax:float64, alphaSpeed:float64, redAnimate:bool, greenAnimate:bool, blueAnimate:bool, alphaAnimate:bool, repeat:bool) : Entity =
  var previousComponent = if this.hasColorAnimation : this.colorAnimation else: nil
  var component = if Pool.colorAnimationComponent.len > 0 : Pool.colorAnimationComponent.dequeue() else: ColorAnimationComponent()
  component.redMin = redMin
  component.redMax = redMax
  component.redSpeed = redSpeed
  component.greenMin = greenMin
  component.greenMax = greenMax
  component.greenSpeed = greenSpeed
  component.blueMin = blueMin
  component.blueMax = blueMax
  component.blueSpeed = blueSpeed
  component.alphaMin = alphaMin
  component.alphaMax = alphaMax
  component.alphaSpeed = alphaSpeed
  component.redAnimate = redAnimate
  component.greenAnimate = greenAnimate
  component.blueAnimate = blueAnimate
  component.alphaAnimate = alphaAnimate
  component.repeat = repeat
  discard this.replaceComponent(int(Component.ColorAnimation), component)
  if previousComponent != nil:
    Pool.colorAnimationComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeColorAnimation*(this : Entity) : Entity =
  var component = this.colorAnimation
  discard this.removeComponent(int(Component.ColorAnimation))
  Pool.colorAnimationComponent.enqueue(component)
  return this


proc clearDestroyComponent*(this : Entity) =
  Pool.destroyComponent = initQueue[DestroyComponent]()

## @type {shmupwarz.DestroyComponent} 
proc destroy*(this : Entity) : DestroyComponent =
  (DestroyComponent)this.getComponent(int(Component.Destroy))

## @type {boolean} 
proc hasDestroy*(this : Entity) : bool =
  this.hasComponent(int(Component.Destroy))

##
## @param {bool} active
## @returns {bosco.Entity}
##
proc addDestroy*(this : Entity, active:bool) : Entity =
  var component = if Pool.destroyComponent.len > 0 : Pool.destroyComponent.dequeue() else: DestroyComponent()
  component.active = active
  discard this.addComponent(int(Component.Destroy), component)
  return this

##
## @param {bool} active
## @returns {bosco.Entity}
##
proc replaceDestroy*(this : Entity, active:bool) : Entity =
  var previousComponent = if this.hasDestroy : this.destroy else: nil
  var component = if Pool.destroyComponent.len > 0 : Pool.destroyComponent.dequeue() else: DestroyComponent()
  component.active = active
  discard this.replaceComponent(int(Component.Destroy), component)
  if previousComponent != nil:
    Pool.destroyComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeDestroy*(this : Entity) : Entity =
  var component = this.destroy
  discard this.removeComponent(int(Component.Destroy))
  Pool.destroyComponent.enqueue(component)
  return this

## @type {boolean} 
proc isEnemy*(this : Entity) : bool =
  this.hasComponent(int(Component.Enemy))
proc `isEnemy=`*(this : Entity, value : bool) =
  if value != this.isEnemy:
    if value:
      discard this.addComponent(int(Component.Enemy), Pool.enemyComponent)
    else:
      discard this.removeComponent(int(Component.Enemy))

##
## @param {boolean} value
## @returns {bosco.Entity}
##
proc setEnemy*(this : Entity, value : bool) : Entity =
  this.isEnemy = value
  return this


proc clearExpiresComponent*(this : Entity) =
  Pool.expiresComponent = initQueue[ExpiresComponent]()

## @type {shmupwarz.ExpiresComponent} 
proc expires*(this : Entity) : ExpiresComponent =
  (ExpiresComponent)this.getComponent(int(Component.Expires))

## @type {boolean} 
proc hasExpires*(this : Entity) : bool =
  this.hasComponent(int(Component.Expires))

##
## @param {float64} delay
## @returns {bosco.Entity}
##
proc addExpires*(this : Entity, delay:float64) : Entity =
  var component = if Pool.expiresComponent.len > 0 : Pool.expiresComponent.dequeue() else: ExpiresComponent()
  component.delay = delay
  discard this.addComponent(int(Component.Expires), component)
  return this

##
## @param {float64} delay
## @returns {bosco.Entity}
##
proc replaceExpires*(this : Entity, delay:float64) : Entity =
  var previousComponent = if this.hasExpires : this.expires else: nil
  var component = if Pool.expiresComponent.len > 0 : Pool.expiresComponent.dequeue() else: ExpiresComponent()
  component.delay = delay
  discard this.replaceComponent(int(Component.Expires), component)
  if previousComponent != nil:
    Pool.expiresComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeExpires*(this : Entity) : Entity =
  var component = this.expires
  discard this.removeComponent(int(Component.Expires))
  Pool.expiresComponent.enqueue(component)
  return this

## @type {boolean} 
proc isFiring*(this : Entity) : bool =
  this.hasComponent(int(Component.Firing))
proc `isFiring=`*(this : Entity, value : bool) =
  if value != this.isFiring:
    if value:
      discard this.addComponent(int(Component.Firing), Pool.firingComponent)
    else:
      discard this.removeComponent(int(Component.Firing))

##
## @param {boolean} value
## @returns {bosco.Entity}
##
proc setFiring*(this : Entity, value : bool) : Entity =
  this.isFiring = value
  return this


proc clearHealthComponent*(this : Entity) =
  Pool.healthComponent = initQueue[HealthComponent]()

## @type {shmupwarz.HealthComponent} 
proc health*(this : Entity) : HealthComponent =
  (HealthComponent)this.getComponent(int(Component.Health))

## @type {boolean} 
proc hasHealth*(this : Entity) : bool =
  this.hasComponent(int(Component.Health))

##
## @param {float64} health
## @param {float64} maximumHealth
## @returns {bosco.Entity}
##
proc addHealth*(this : Entity, health:float64, maximumHealth:float64) : Entity =
  var component = if Pool.healthComponent.len > 0 : Pool.healthComponent.dequeue() else: HealthComponent()
  component.health = health
  component.maximumHealth = maximumHealth
  discard this.addComponent(int(Component.Health), component)
  return this

##
## @param {float64} health
## @param {float64} maximumHealth
## @returns {bosco.Entity}
##
proc replaceHealth*(this : Entity, health:float64, maximumHealth:float64) : Entity =
  var previousComponent = if this.hasHealth : this.health else: nil
  var component = if Pool.healthComponent.len > 0 : Pool.healthComponent.dequeue() else: HealthComponent()
  component.health = health
  component.maximumHealth = maximumHealth
  discard this.replaceComponent(int(Component.Health), component)
  if previousComponent != nil:
    Pool.healthComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeHealth*(this : Entity) : Entity =
  var component = this.health
  discard this.removeComponent(int(Component.Health))
  Pool.healthComponent.enqueue(component)
  return this


proc clearLayerComponent*(this : Entity) =
  Pool.layerComponent = initQueue[LayerComponent]()

## @type {shmupwarz.LayerComponent} 
proc layer*(this : Entity) : LayerComponent =
  (LayerComponent)this.getComponent(int(Component.Layer))

## @type {boolean} 
proc hasLayer*(this : Entity) : bool =
  this.hasComponent(int(Component.Layer))

##
## @param {int} ordinal
## @returns {bosco.Entity}
##
proc addLayer*(this : Entity, ordinal:int) : Entity =
  var component = if Pool.layerComponent.len > 0 : Pool.layerComponent.dequeue() else: LayerComponent()
  component.ordinal = ordinal
  discard this.addComponent(int(Component.Layer), component)
  return this

##
## @param {int} ordinal
## @returns {bosco.Entity}
##
proc replaceLayer*(this : Entity, ordinal:int) : Entity =
  var previousComponent = if this.hasLayer : this.layer else: nil
  var component = if Pool.layerComponent.len > 0 : Pool.layerComponent.dequeue() else: LayerComponent()
  component.ordinal = ordinal
  discard this.replaceComponent(int(Component.Layer), component)
  if previousComponent != nil:
    Pool.layerComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeLayer*(this : Entity) : Entity =
  var component = this.layer
  discard this.removeComponent(int(Component.Layer))
  Pool.layerComponent.enqueue(component)
  return this


proc clearLifeComponent*(this : Entity) =
  Pool.lifeComponent = initQueue[LifeComponent]()

## @type {shmupwarz.LifeComponent} 
proc life*(this : Entity) : LifeComponent =
  (LifeComponent)this.getComponent(int(Component.Life))

## @type {boolean} 
proc hasLife*(this : Entity) : bool =
  this.hasComponent(int(Component.Life))

##
## @param {int} count
## @returns {bosco.Entity}
##
proc addLife*(this : Entity, count:int) : Entity =
  var component = if Pool.lifeComponent.len > 0 : Pool.lifeComponent.dequeue() else: LifeComponent()
  component.count = count
  discard this.addComponent(int(Component.Life), component)
  return this

##
## @param {int} count
## @returns {bosco.Entity}
##
proc replaceLife*(this : Entity, count:int) : Entity =
  var previousComponent = if this.hasLife : this.life else: nil
  var component = if Pool.lifeComponent.len > 0 : Pool.lifeComponent.dequeue() else: LifeComponent()
  component.count = count
  discard this.replaceComponent(int(Component.Life), component)
  if previousComponent != nil:
    Pool.lifeComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeLife*(this : Entity) : Entity =
  var component = this.life
  discard this.removeComponent(int(Component.Life))
  Pool.lifeComponent.enqueue(component)
  return this

## @type {boolean} 
proc isMine*(this : Entity) : bool =
  this.hasComponent(int(Component.Mine))
proc `isMine=`*(this : Entity, value : bool) =
  if value != this.isMine:
    if value:
      discard this.addComponent(int(Component.Mine), Pool.mineComponent)
    else:
      discard this.removeComponent(int(Component.Mine))

##
## @param {boolean} value
## @returns {bosco.Entity}
##
proc setMine*(this : Entity, value : bool) : Entity =
  this.isMine = value
  return this


proc clearMouseComponent*(this : Entity) =
  Pool.mouseComponent = initQueue[MouseComponent]()

## @type {shmupwarz.MouseComponent} 
proc mouse*(this : Entity) : MouseComponent =
  (MouseComponent)this.getComponent(int(Component.Mouse))

## @type {boolean} 
proc hasMouse*(this : Entity) : bool =
  this.hasComponent(int(Component.Mouse))

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc addMouse*(this : Entity, x:float64, y:float64) : Entity =
  var component = if Pool.mouseComponent.len > 0 : Pool.mouseComponent.dequeue() else: MouseComponent()
  component.x = x
  component.y = y
  discard this.addComponent(int(Component.Mouse), component)
  return this

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc replaceMouse*(this : Entity, x:float64, y:float64) : Entity =
  var previousComponent = if this.hasMouse : this.mouse else: nil
  var component = if Pool.mouseComponent.len > 0 : Pool.mouseComponent.dequeue() else: MouseComponent()
  component.x = x
  component.y = y
  discard this.replaceComponent(int(Component.Mouse), component)
  if previousComponent != nil:
    Pool.mouseComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeMouse*(this : Entity) : Entity =
  var component = this.mouse
  discard this.removeComponent(int(Component.Mouse))
  Pool.mouseComponent.enqueue(component)
  return this

## @type {boolean} 
proc isPlayer*(this : Entity) : bool =
  this.hasComponent(int(Component.Player))
proc `isPlayer=`*(this : Entity, value : bool) =
  if value != this.isPlayer:
    if value:
      discard this.addComponent(int(Component.Player), Pool.playerComponent)
    else:
      discard this.removeComponent(int(Component.Player))

##
## @param {boolean} value
## @returns {bosco.Entity}
##
proc setPlayer*(this : Entity, value : bool) : Entity =
  this.isPlayer = value
  return this


proc clearPositionComponent*(this : Entity) =
  Pool.positionComponent = initQueue[PositionComponent]()

## @type {shmupwarz.PositionComponent} 
proc position*(this : Entity) : PositionComponent =
  (PositionComponent)this.getComponent(int(Component.Position))

## @type {boolean} 
proc hasPosition*(this : Entity) : bool =
  this.hasComponent(int(Component.Position))

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc addPosition*(this : Entity, x:float64, y:float64) : Entity =
  var component = if Pool.positionComponent.len > 0 : Pool.positionComponent.dequeue() else: PositionComponent()
  component.x = x
  component.y = y
  discard this.addComponent(int(Component.Position), component)
  return this

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc replacePosition*(this : Entity, x:float64, y:float64) : Entity =
  var previousComponent = if this.hasPosition : this.position else: nil
  var component = if Pool.positionComponent.len > 0 : Pool.positionComponent.dequeue() else: PositionComponent()
  component.x = x
  component.y = y
  discard this.replaceComponent(int(Component.Position), component)
  if previousComponent != nil:
    Pool.positionComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removePosition*(this : Entity) : Entity =
  var component = this.position
  discard this.removeComponent(int(Component.Position))
  Pool.positionComponent.enqueue(component)
  return this


proc clearResourceComponent*(this : Entity) =
  Pool.resourceComponent = initQueue[ResourceComponent]()

## @type {shmupwarz.ResourceComponent} 
proc resource*(this : Entity) : ResourceComponent =
  (ResourceComponent)this.getComponent(int(Component.Resource))

## @type {boolean} 
proc hasResource*(this : Entity) : bool =
  this.hasComponent(int(Component.Resource))

##
## @param {string} path
## @param {Sprite} sprite
## @param {bool} bgd
## @returns {bosco.Entity}
##
proc addResource*(this : Entity, path:string, sprite:Sprite, bgd:bool) : Entity =
  var component = if Pool.resourceComponent.len > 0 : Pool.resourceComponent.dequeue() else: ResourceComponent()
  component.path = path
  component.sprite = sprite
  component.bgd = bgd
  discard this.addComponent(int(Component.Resource), component)
  return this

##
## @param {string} path
## @param {Sprite} sprite
## @param {bool} bgd
## @returns {bosco.Entity}
##
proc replaceResource*(this : Entity, path:string, sprite:Sprite, bgd:bool) : Entity =
  var previousComponent = if this.hasResource : this.resource else: nil
  var component = if Pool.resourceComponent.len > 0 : Pool.resourceComponent.dequeue() else: ResourceComponent()
  component.path = path
  component.sprite = sprite
  component.bgd = bgd
  discard this.replaceComponent(int(Component.Resource), component)
  if previousComponent != nil:
    Pool.resourceComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeResource*(this : Entity) : Entity =
  var component = this.resource
  discard this.removeComponent(int(Component.Resource))
  Pool.resourceComponent.enqueue(component)
  return this


proc clearScaleAnimationComponent*(this : Entity) =
  Pool.scaleAnimationComponent = initQueue[ScaleAnimationComponent]()

## @type {shmupwarz.ScaleAnimationComponent} 
proc scaleAnimation*(this : Entity) : ScaleAnimationComponent =
  (ScaleAnimationComponent)this.getComponent(int(Component.ScaleAnimation))

## @type {boolean} 
proc hasScaleAnimation*(this : Entity) : bool =
  this.hasComponent(int(Component.ScaleAnimation))

##
## @param {float64} min
## @param {float64} max
## @param {float64} speed
## @param {bool} repeat
## @param {bool} active
## @returns {bosco.Entity}
##
proc addScaleAnimation*(this : Entity, min:float64, max:float64, speed:float64, repeat:bool, active:bool) : Entity =
  var component = if Pool.scaleAnimationComponent.len > 0 : Pool.scaleAnimationComponent.dequeue() else: ScaleAnimationComponent()
  component.min = min
  component.max = max
  component.speed = speed
  component.repeat = repeat
  component.active = active
  discard this.addComponent(int(Component.ScaleAnimation), component)
  return this

##
## @param {float64} min
## @param {float64} max
## @param {float64} speed
## @param {bool} repeat
## @param {bool} active
## @returns {bosco.Entity}
##
proc replaceScaleAnimation*(this : Entity, min:float64, max:float64, speed:float64, repeat:bool, active:bool) : Entity =
  var previousComponent = if this.hasScaleAnimation : this.scaleAnimation else: nil
  var component = if Pool.scaleAnimationComponent.len > 0 : Pool.scaleAnimationComponent.dequeue() else: ScaleAnimationComponent()
  component.min = min
  component.max = max
  component.speed = speed
  component.repeat = repeat
  component.active = active
  discard this.replaceComponent(int(Component.ScaleAnimation), component)
  if previousComponent != nil:
    Pool.scaleAnimationComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeScaleAnimation*(this : Entity) : Entity =
  var component = this.scaleAnimation
  discard this.removeComponent(int(Component.ScaleAnimation))
  Pool.scaleAnimationComponent.enqueue(component)
  return this


proc clearScaleComponent*(this : Entity) =
  Pool.scaleComponent = initQueue[ScaleComponent]()

## @type {shmupwarz.ScaleComponent} 
proc scale*(this : Entity) : ScaleComponent =
  (ScaleComponent)this.getComponent(int(Component.Scale))

## @type {boolean} 
proc hasScale*(this : Entity) : bool =
  this.hasComponent(int(Component.Scale))

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc addScale*(this : Entity, x:float64, y:float64) : Entity =
  var component = if Pool.scaleComponent.len > 0 : Pool.scaleComponent.dequeue() else: ScaleComponent()
  component.x = x
  component.y = y
  discard this.addComponent(int(Component.Scale), component)
  return this

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc replaceScale*(this : Entity, x:float64, y:float64) : Entity =
  var previousComponent = if this.hasScale : this.scale else: nil
  var component = if Pool.scaleComponent.len > 0 : Pool.scaleComponent.dequeue() else: ScaleComponent()
  component.x = x
  component.y = y
  discard this.replaceComponent(int(Component.Scale), component)
  if previousComponent != nil:
    Pool.scaleComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeScale*(this : Entity) : Entity =
  var component = this.scale
  discard this.removeComponent(int(Component.Scale))
  Pool.scaleComponent.enqueue(component)
  return this


proc clearScoreComponent*(this : Entity) =
  Pool.scoreComponent = initQueue[ScoreComponent]()

## @type {shmupwarz.ScoreComponent} 
proc score*(this : Entity) : ScoreComponent =
  (ScoreComponent)this.getComponent(int(Component.Score))

## @type {boolean} 
proc hasScore*(this : Entity) : bool =
  this.hasComponent(int(Component.Score))

##
## @param {float64} value
## @returns {bosco.Entity}
##
proc addScore*(this : Entity, value:float64) : Entity =
  var component = if Pool.scoreComponent.len > 0 : Pool.scoreComponent.dequeue() else: ScoreComponent()
  component.value = value
  discard this.addComponent(int(Component.Score), component)
  return this

##
## @param {float64} value
## @returns {bosco.Entity}
##
proc replaceScore*(this : Entity, value:float64) : Entity =
  var previousComponent = if this.hasScore : this.score else: nil
  var component = if Pool.scoreComponent.len > 0 : Pool.scoreComponent.dequeue() else: ScoreComponent()
  component.value = value
  discard this.replaceComponent(int(Component.Score), component)
  if previousComponent != nil:
    Pool.scoreComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeScore*(this : Entity) : Entity =
  var component = this.score
  discard this.removeComponent(int(Component.Score))
  Pool.scoreComponent.enqueue(component)
  return this


proc clearSoundEffectComponent*(this : Entity) =
  Pool.soundEffectComponent = initQueue[SoundEffectComponent]()

## @type {shmupwarz.SoundEffectComponent} 
proc soundEffect*(this : Entity) : SoundEffectComponent =
  (SoundEffectComponent)this.getComponent(int(Component.SoundEffect))

## @type {boolean} 
proc hasSoundEffect*(this : Entity) : bool =
  this.hasComponent(int(Component.SoundEffect))

##
## @param {int} effect
## @returns {bosco.Entity}
##
proc addSoundEffect*(this : Entity, effect:int) : Entity =
  var component = if Pool.soundEffectComponent.len > 0 : Pool.soundEffectComponent.dequeue() else: SoundEffectComponent()
  component.effect = effect
  discard this.addComponent(int(Component.SoundEffect), component)
  return this

##
## @param {int} effect
## @returns {bosco.Entity}
##
proc replaceSoundEffect*(this : Entity, effect:int) : Entity =
  var previousComponent = if this.hasSoundEffect : this.soundEffect else: nil
  var component = if Pool.soundEffectComponent.len > 0 : Pool.soundEffectComponent.dequeue() else: SoundEffectComponent()
  component.effect = effect
  discard this.replaceComponent(int(Component.SoundEffect), component)
  if previousComponent != nil:
    Pool.soundEffectComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeSoundEffect*(this : Entity) : Entity =
  var component = this.soundEffect
  discard this.removeComponent(int(Component.SoundEffect))
  Pool.soundEffectComponent.enqueue(component)
  return this


proc clearVelocityComponent*(this : Entity) =
  Pool.velocityComponent = initQueue[VelocityComponent]()

## @type {shmupwarz.VelocityComponent} 
proc velocity*(this : Entity) : VelocityComponent =
  (VelocityComponent)this.getComponent(int(Component.Velocity))

## @type {boolean} 
proc hasVelocity*(this : Entity) : bool =
  this.hasComponent(int(Component.Velocity))

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc addVelocity*(this : Entity, x:float64, y:float64) : Entity =
  var component = if Pool.velocityComponent.len > 0 : Pool.velocityComponent.dequeue() else: VelocityComponent()
  component.x = x
  component.y = y
  discard this.addComponent(int(Component.Velocity), component)
  return this

##
## @param {float64} x
## @param {float64} y
## @returns {bosco.Entity}
##
proc replaceVelocity*(this : Entity, x:float64, y:float64) : Entity =
  var previousComponent = if this.hasVelocity : this.velocity else: nil
  var component = if Pool.velocityComponent.len > 0 : Pool.velocityComponent.dequeue() else: VelocityComponent()
  component.x = x
  component.y = y
  discard this.replaceComponent(int(Component.Velocity), component)
  if previousComponent != nil:
    Pool.velocityComponent.enqueue(previousComponent)

  return this

##
## @returns {bosco.Entity}
##
proc removeVelocity*(this : Entity) : Entity =
  var component = this.velocity
  discard this.removeComponent(int(Component.Velocity))
  Pool.velocityComponent.enqueue(component)
  return this


