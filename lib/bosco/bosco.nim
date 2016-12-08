import sdl2
import sdl2/image
import sdl2/ttf
import strfmt
import os
import times
import algorithm, future

const FONT_PATH = "res/fonts/skranji.regular.ttf"
const FONT_SIZE = 16
const FPS = 1/60
var
  SpriteUniqueId : int = 0

type
  Vector2* = object of RootObj
    x* : float64
    y* : float64

  Sprite* = ref object of RootObj
    texture* : TexturePtr
    x* : int
    y* : int
    width* : int
    height* : int
    scale* : Vector2
    centered* : bool
    layer* : int
    id* : int
    path* : string

  AbstractGame* = ref object of RootObj
    name* : string
    width* : cint
    height* : cint
    running* : bool
    window* : WindowPtr
    renderer* : RendererPtr
    font* : FontPtr
    sprites* : seq[Sprite]
    eos* : int
    currentKeyStates* : ptr array[0..512, uint8]
    delta* : float64
    showFps : bool
    fpsBg : Color
    fpsFg : Color
    fpsSrcRect : Rect
    fpsDstRect : Rect
    lastCount : int


proc SpriteFromFile*(renderer : RendererPtr, path : string): Sprite
proc SpriteFromText*(renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite
proc setText*(this : Sprite, renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite

proc init_sdl(this : AbstractGame)
method start*(this : AbstractGame) {.base.}
method event*(this : AbstractGame, evt : Event) {.base.}
method update*(this : AbstractGame, delta : float64) {.base.}
method cleanup*(this : AbstractGame) {.base.}
method initialize*(this : AbstractGame) {.base.}


proc init_sdl(this : AbstractGame) =
  ## Initialize SDL layer
  discard sdl2.init(INIT_EVERYTHING)
  discard image.init(IMG_INIT_PNG)
  discard ttf.ttfInit()

  this.window = createWindow(this.name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, this.width, this.height, SDL_WINDOW_SHOWN)
  if this.window == nil:
      echo "Error creating SDL_Window: ", getError()
      quit 1

  this.renderer = createRenderer(this.window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
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
  var dst:Rect
  var w = 0.0
  var h = 0.0
  var x = 0
  var y = 0
  var i = 0
  var sprite:Sprite
  var fpsSprite:Sprite
  var fpsString = ""
  var elapsed = 0.0
  var lastTime = 0.0
  var currentTime = 0.0
  var currentFps = 0.0
  var frames = 0


  ## Start the game
  this.init_sdl()
  this.initialize()
  this.currentKeyStates = getKeyboardState(nil)
  var evt = defaultEvent
  GC_disable()
  currentTime = epochTime()
  while this.running:
    while pollEvent(evt):
      case evt.kind
        of QuitEvent:
          this.running = false
        else: this.event(evt)
    if (bool) this.currentKeyStates[41] : this.running = false


    lastTime = currentTime
    currentTime = epochTime()
    this.delta = currentTime - lastTime
    this.update(this.delta)

    this.renderer.setDrawColor(0, 0, 0, 255)
    this.renderer.clear()

    for sprite in this.sprites:
      w = float64(sprite.width) * sprite.scale.x
      h = float64(sprite.height) * sprite.scale.y
      x = if sprite.centered: sprite.x-(int(w/2)) else: sprite.x
      y = if sprite.centered: sprite.y-(int(h/2)) else: sprite.y
      dst = rect(cint(x), cint(y), cint(w), cint(h))
      this.renderer.copy sprite.texture, nil, addr(dst)

    if this.showFps: 
      frames += 1
      elapsed = elapsed + this.delta
      if elapsed > 1.0:
        currentFps = float32(frames) / elapsed
        elapsed = 0.0
        frames = 0
        fpsString = currentFps.format("02.2f")
        fpsSprite = SpriteFromText(this.renderer, fpsString, this.font, this.fpsFg, this.fpsBg)
        fpsSprite.centered = false
      elif fpsSprite == nil:
        fpsSprite = SpriteFromText(this.renderer, "60.00", this.font, this.fpsFg, this.fpsBg)
        fpsSprite.centered = false
      sprite = fpsSprite
      w = float64(sprite.width) * sprite.scale.x
      h = float64(sprite.height) * sprite.scale.y
      x = if sprite.centered: sprite.x-(int(w/2)) else: sprite.x
      y = if sprite.centered: sprite.y-(int(h/2)) else: sprite.y
      dst = rect(cint(x), cint(y), cint(w), cint(h))
      this.renderer.copy sprite.texture, nil, addr(dst)
      
    GC_step(us = 5)
    this.renderer.present

  destroy this.renderer
  destroy this.window
  this.cleanup()

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


proc SpriteFromFile*(renderer : RendererPtr, path : string) : Sprite =
  let loadedSurface = load(path)
  if loadedSurface == nil:
      echo "Unable to load image: ", path
  else:
    result.new()
    result.texture = renderer.createTextureFromSurface(loadedSurface)
    if result.texture == nil:
      echo "Error creating texture from: ", path
    else:
      result.texture.setTextureBlendMode BlendMode_Blend
      SpriteUniqueId += 1
      result.id = SpriteUniqueId
      result.path = path
      result.centered = true
      result.height = loadedSurface.h
      result.width = loadedSurface.w
      result.scale.x = 1
      result.scale.y = 1

proc SpriteFromText*(renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite =
  assert font != nil

  let textSurface = font.renderText(text, fg, bg)
  if textSurface == nil:
    echo "Unable to render text surface: ", text
  else:
    result.new()
    result.texture = renderer.createTextureFromSurface(textSurface)
    if result.texture == nil:
      echo "Unable to create texture from rendered text: ", text
    else:
      SpriteUniqueId += 1
      result.id = SpriteUniqueId
      result.width = textSurface.w
      result.height = textSurface.h
      result.scale.x = 1
      result.scale.y = 1

proc setText*(this : Sprite, renderer : RendererPtr, text : string, font : FontPtr, fg : Color, bg : Color) : Sprite =
  let textSurface = font.renderText(text, fg, bg)
  if textSurface == nil:
    echo "Unable to render text surface: ", text
  else:
    this.texture = renderer.createTextureFromSurface(textSurface)
    if this.texture == nil:
      echo "Unable to create texture from rendered text: ", text
    else:
      this.width = textSurface.w
      this.height = textSurface.h

