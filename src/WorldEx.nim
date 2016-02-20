##
## Entitas Generated World Extensions for shmupwarz
##
## do not edit this file
##
import bosco/ECS
import ComponentEx
import MatchEx
import EntityEx


## @type {entitas.Entity} 
proc scoreEntity*(this : World) : Entity =
  return this.getGroup(Match.Score).getSingleEntity()

## @type {shmupwarz.ScoreComponent} 
proc score*(this : World) : ScoreComponent =
  return this.scoreEntity.score

## @type {boolean} 
proc hasScore*(this : World) : bool =
  return this.scoreEntity != nil

##
## @param {float64} value
## @returns {entitas.Entity}
##
proc setScore*(this : World, value:float64) : Entity =
  if this.hasScore:
    raise newException(OSError, "SingleEntityException Matching Score")

  var entity = this.createEntity("Score")
  discard entity.addScore(value)
  return entity

##
## @param {float64} value
## @returns {entitas.Entity}
##
proc replaceScore*(this : World, value:float64) : Entity =
  var entity = this.scoreEntity
  if entity == nil:
    entity = this.setScore(value)
  else:
     discard entity.replaceScore(value)
  return entity

##
## @returns {entitas.Entity}
##
proc removeScore*(this : World) =
  this.destroyEntity(this.scoreEntity)

## @type {entitas.Entity} 
proc mouseEntity*(this : World) : Entity =
  return this.getGroup(Match.Mouse).getSingleEntity()

## @type {shmupwarz.MouseComponent} 
proc mouse*(this : World) : MouseComponent =
  return this.mouseEntity.mouse

## @type {boolean} 
proc hasMouse*(this : World) : bool =
  return this.mouseEntity != nil

##
## @param {float64} x
## @param {float64} y
## @returns {entitas.Entity}
##
proc setMouse*(this : World, x:float64, y:float64) : Entity =
  if this.hasMouse:
    raise newException(OSError, "SingleEntityException Matching Mouse")

  var entity = this.createEntity("Mouse")
  discard entity.addMouse(x, y)
  return entity

##
## @param {float64} x
## @param {float64} y
## @returns {entitas.Entity}
##
proc replaceMouse*(this : World, x:float64, y:float64) : Entity =
  var entity = this.mouseEntity
  if entity == nil:
    entity = this.setMouse(x, y)
  else:
     discard entity.replaceMouse(x, y)
  return entity

##
## @returns {entitas.Entity}
##
proc removeMouse*(this : World) =
  this.destroyEntity(this.mouseEntity)

## @type {entitas.Match} 
proc firingEntity*(this : World) : Entity =
  return this.getGroup(Match.Firing).getSingleEntity()

## @type {boolean} 
proc isFiring*(this : World) : bool =
  return this.firingEntity != nil
proc `isFiring=`*(this : World, value : bool) =
  var entity = this.firingEntity
  if value != (entity != nil):
    if value:
      this.createEntity("Firing").isFiring = true
    else:
      this.destroyEntity(entity)


