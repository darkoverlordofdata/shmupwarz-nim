import gamestate

proc newPlayerInputSystem*(game : Game) : PlayerInputSystem =
  new(result)
  result.game = game

proc setPlayer*(this : PlayerInputSystem, player : Entity) =
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

proc moveTo*(this : PlayerInputSystem, x: int, y: int) =

  if this.player == nil: return
  if not this.player.hasPosition: return
  let pos = this.player.position
  pos.x = float64(x)
  pos.y = float64(y)

proc onMouseEvent*(this : PlayerInputSystem, e : EventType, x : int, y : int) =
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

