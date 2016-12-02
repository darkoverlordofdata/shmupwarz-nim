import sdl2
import sdl2/image
import sdl2/ttf
import strfmt
import Sprite


type
  AbstractGame* = ref object of RootObj
    name* : string
    width* : cint
    height* : cint
    running* : bool
    window* : WindowPtr
    renderer* : RendererPtr
    font* : FontPtr
    sprites* : seq[Sprite]
    currentKeyStates* : ptr array[0..512, uint8]
    delta* : float64
    ticks* : uint32
    lastTick : uint32
    showFps : bool
    fpsTimes : array[0..14, int]
    fpsTimeLast : int
    fpsCount : int
    fpsTickLast : int
    fpsSprite : Sprite
    fpsBg : Color
    fpsFg : Color
    fpsSrcRect : Rect
    fpsDstRect : Rect
    lastCount : int

proc init_sdl(this : AbstractGame)
proc render*(this : AbstractGame)
proc get_fps(this : AbstractGame) : Sprite
method start*(this : AbstractGame) {.base.}
method event*(this : AbstractGame, evt : Event) {.base.}
method update*(this : AbstractGame, delta : float64) {.base.}
method cleanup*(this : AbstractGame) {.base.}
method initialize*(this : AbstractGame) {.base.}

const FONT_PATH = "res/fonts/skranji.regular.ttf"
const FONT_SIZE = 16

proc init_sdl(this : AbstractGame) =
  ## Initialize SDL layer
  discard sdl2.init(INIT_EVERYTHING)
  discard image.init(IMG_INIT_PNG)
  discard ttf.ttfInit()

  this.window = createWindow(this.name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, this.width, this.height, SDL_WINDOW_SHOWN)
  if this.window == nil:
      echo "Error creating SDL_Window: ", getError()
      quit 1

  this.renderer = createRenderer(this.window, -1, Renderer_Accelerated or Renderer_PresentVsync)
  if this.renderer == nil:
      echo "Error creating SDL_Renderer: ", getError()
      quit 1
  this.renderer.setDrawColor(0xff, 0xff, 0xff, 0xff)

  this.font = ttf.openFont(FONT_PATH, FONT_SIZE)
  if this.font == nil:
      echo "Error creating SDL_Font: ", getError()
      quit 1

  ## setup for FPS display
  this.showFps = true
  this.fpsTimes = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  this.fpsFg.r = 255
  this.fpsFg.g = 255
  this.fpsFg.b = 255
  this.fpsFg.a = 255
  this.fpsBg.r = 0
  this.fpsBg.g = 0
  this.fpsBg.b = 0
  this.fpsBg.a = 0
  let su = this.font.renderText("fps: 99.99", this.fpsFg, this.fpsBg)
  this.fpsSrcRect = rect(0, 0, (cint)su.w, (cint)su.h)
  this.fpsDstRect = rect(0, 0, (cint)su.w, (cint)su.h)


method start*(this : AbstractGame) =
  ## Start the game
  this.init_sdl()
  this.initialize()
  this.currentKeyStates = getKeyboardState(nil)
  var evt = defaultEvent
  while this.running:
    while pollEvent(evt):
      case evt.kind
        of QuitEvent:
          this.running = false
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

##
## Create a sprite with the current FPS value
##
proc get_fps(this : AbstractGame) : Sprite =
  let frametimesindex = this.fpsCount mod this.fpsTimes.len
  this.fpsTimes[frametimesindex] = int(this.ticks) - this.fpsTimeLast
  this.fpsTimeLast = int(this.ticks)
  this.fpsCount += 1
  var total:int = 0
  for i in 0..14:
    total += this.fpsTimes[i]
  let value:float64 = 1000.0  / (total / 15)
  let s = value.format("02.2f")
  this.fpsTickLast = int(this.ticks)
  if this.fpsCount mod this.fpsTimes.len == 0 or this.fpsSprite == nil:
    this.fpsSprite = SpriteFromText(this.renderer, s, this.font, this.fpsFg, this.fpsBg)
    this.fpsSprite.centered = false
  return this.fpsSprite

proc render*(this : AbstractGame) =
  ## Render the frame
  this.renderer.setDrawColor(0, 0, 0, 255)
  this.renderer.clear()
  for sprite in this.sprites:
    sprite.render(this.renderer)
  if this.showFps: this.get_fps().render(this.renderer)
  this.renderer.present()

method initialize*(this : AbstractGame) =
  ## Abstract method: initialize the game
  return

method event*(this : AbstractGame, evt : Event)  =
  ## Abstract method: receive SDL events
  return

method update*(this : AbstractGame, delta : float64) =
  ## Abstract update: update the game system
  return

method cleanup*(this : AbstractGame) =
  ## Abstract cleanup: teardown the game
  return
