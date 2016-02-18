import sdl2
import sdl2/image
import sdl2/ttf
import Sprite

type
  AbstractGame* = ref object of RootObj
    name* : string
    width* : cint
    height* : cint
    running* : bool
    window* : WindowPtr
    renderer* : RendererPtr
    sprites* : seq[Sprite]
    currentKeyStates* : ptr array[0..512, uint8]
    delta* : float64
    ticks* : uint32
    lastTick : uint32

proc start*(this : AbstractGame) :  int {.discardable.}
method event*(this : AbstractGame, evt : Event) {.base.}
method update*(this : AbstractGame, delta : float64) {.base.}
proc render*(this : AbstractGame)
proc init*(this : AbstractGame) : bool
method cleanup*(this : AbstractGame) {.base.}

proc start*(this : AbstractGame) : int =

  this.running = this.init()
  if not this.running : return -1

  this.currentKeyStates = getKeyboardState(nil)
  var evt = defaultEvent
  while this.running:
    while pollEvent(evt):
      case evt.kind
        of QuitEvent:
          this.running = false
        #else: discard
        else: this.event(evt)
    if (bool)this.currentKeyStates[41] : this.running = false
    this.ticks = getTicks()
    this.delta = float64(this.ticks - this.lastTick)/1000.0
    this.lastTick = this.ticks
    this.update(this.delta)
    this.render()
    destroy this.renderer
    destroy this.window

  this.cleanup()
  return 0

method event*(this : AbstractGame, evt : Event)  =
  return

method update*(this : AbstractGame, delta : float64) =
  return

proc render*(this : AbstractGame) =

  this.renderer.setDrawColor(0, 0, 0, 255)
  this.renderer.clear()
  for sprite in this.sprites:
    sprite.render(this.renderer)
  this.renderer.present()

proc init*(this : AbstractGame) : bool =

  discard sdl2.init(INIT_EVERYTHING)
  discard image.init(IMG_INIT_PNG)

  this.window = createWindow(this.name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, this.width, this.height, SDL_WINDOW_SHOWN)
  if this.window == nil:
      echo "Error creating SDL_Window: ", getError()
      quit 1

  this.renderer = createRenderer(this.window, -1, Renderer_Accelerated or Renderer_PresentVsync)
  if this.renderer == nil:
      echo "Error creating SDL_Renderer: ", getError()
      quit 1

  return true

method cleanup*(this : AbstractGame) =
  return
